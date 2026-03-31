import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_chenab_times/screens/article_webview_screen.dart';
import 'package:the_chenab_times/services/notification_provider.dart';
import 'package:the_chenab_times/services/rss_service.dart';
import 'package:the_chenab_times/services/saved_articles_provider.dart';
import 'package:the_chenab_times/utils/app_status_handler.dart';
import 'l10n/app_localizations.dart';
import 'models/article_model.dart';
import 'models/notification_model.dart';
import 'screens/article_screen.dart';
import 'screens/donate_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/saved_articles_screen.dart';
import 'screens/search_screen.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';

// GLOBAL NAVIGATOR KEY
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Initializes the OneSignal SDK and sets up notification handlers.
Future<void> initOneSignal(NotificationProvider notificationProvider) async {
  final String? appId = dotenv.env['ONESIGNAL_APP_ID'];
  if (appId == null || appId.isEmpty) {
    log("OneSignal App ID is missing!");
    return;
  }

  OneSignal.initialize(appId);

  // --- HANDLER 1: Notification Clicked ---
  OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) async {
    log('NOTIFICATION CLICKED: ${event.notification.jsonRepresentation()}');

    final notification = event.notification;
    final data = notification.additionalData;

    // 1. Check for a Launch URL (highest priority)
    final String? launchUrl = notification.launchUrl;
    if (launchUrl != null && launchUrl.isNotEmpty) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => ArticleWebViewScreen(url: launchUrl)),
      );
      return; // Stop further processing
    }

    // 2. Try to find the Post ID (Standard WP Plugin sends 'post_id')
    int? postId;
    if (data != null && (data.containsKey('post_id') || data.containsKey('id'))) {
      String? idString = data['post_id']?.toString() ?? data['id']?.toString();
      postId = int.tryParse(idString ?? '');
    }

    // 3. Try to find Custom Article Data
    Article? parsedArticle;
    if (data != null && data.containsKey('article_data')) {
      try {
        parsedArticle = Article.fromJson(data['article_data']);
      } catch (e) { log("Error parsing article data: $e"); }
    }

    // 4. Save to Provider (which will save to DB)
    final notificationModel = NotificationModel(
      notificationId: notification.notificationId,
      title: notification.title ?? 'The Chenab Times',
      body: notification.body ?? 'Tap to view',
      imageUrl: notification.bigPicture,
      receivedAt: DateTime.now(),
      article: parsedArticle,
      postId: postId, // Saving the ID
    );
    await notificationProvider.addNotification(notificationModel);

    // 5. Navigation Logic

    // A. If we have the full article object already
    if (parsedArticle != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ArticleScreen(articles: [parsedArticle!], initialIndex: 0),
        ),
      );
      return;
    }

    // B. If we have a Post ID -> Fetch it -> Open it
    if (postId != null) {
      // Show loading
      if (navigatorKey.currentState?.mounted ?? false) {
        showDialog(
          context: navigatorKey.currentState!.context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()),
        );
      }

      // Fetch
      Article? fetchedArticle = await RssService().fetchArticleById(postId);

      // Close loading
      navigatorKey.currentState?.pop();

      if (fetchedArticle != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ArticleScreen(articles: [fetchedArticle], initialIndex: 0),
          ),
        );
      } else {
        AppStatusHandler.showStatusToast(message: "Could not load article", type: StatusType.error);
        // Fallback to Notification Screen
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      }
      return;
    }

    // C. Text Notification (No ID, No Data) -> Open Notification Screen as a fallback
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  });

  // --- HANDLER 2: Foreground Notification Received ---
  OneSignal.Notifications.addForegroundWillDisplayListener((OSNotificationWillDisplayEvent event) async {
    final notification = event.notification;
    final data = notification.additionalData;

    // Check for ID
    int? postId;
    if (data != null && (data.containsKey('post_id') || data.containsKey('id'))) {
      String? idString = data['post_id']?.toString() ?? data['id']?.toString();
      postId = int.tryParse(idString ?? '');
    }

    final model = NotificationModel(
      notificationId: notification.notificationId,
      title: notification.title ?? 'No Title',
      body: notification.body ?? 'No Body',
      imageUrl: notification.bigPicture,
      receivedAt: DateTime.now(),
      article: data != null && data.containsKey('article_data')
          ? Article.fromJson(data['article_data'])
          : null,
      postId: postId, // Save ID here too
    );

    await notificationProvider.addNotification(model);

    // Show the alert on top of the screen
    event.notification.display();
  });
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final notificationProvider = NotificationProvider();

    try {
      await dotenv.load(fileName: ".env");
      await Firebase.initializeApp();

      // Initialize OneSignal
      await initOneSignal(notificationProvider);

      await ThemeService.instance.loadTheme();
      await LanguageService.instance.init();
      await notificationProvider.loadNotifications(); // Load initial notifications
    } catch (e) {
      debugPrint("Initialization error: $e");
    }

    final dbService = DatabaseService();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ThemeService.instance),
          ChangeNotifierProvider.value(value: LanguageService.instance),
          ChangeNotifierProvider(create: (_) => SavedArticlesProvider(dbService)),
          ChangeNotifierProvider.value(value: notificationProvider),
          Provider.value(value: dbService),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint("Global error: $error");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeService, LanguageService>(
      builder: (context, themeService, languageService, child) {
        final buttonStyle = ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        return MaterialApp(
          title: 'The Chenab Times',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: themeService.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            elevatedButtonTheme: buttonStyle,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            elevatedButtonTheme: buttonStyle,
          ),
          locale: languageService.appLocale,
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('ur'),
          ],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DonateScreen(),
    const SavedArticlesScreen(),
    const MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/images/appheading.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined), label: localizations.translate('home')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border_outlined),
              label: localizations.translate('donate')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark_border_outlined),
              label: localizations.translate('saved')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.menu_outlined), label: localizations.translate('more')),
        ],
      ),
    );
  }
}
