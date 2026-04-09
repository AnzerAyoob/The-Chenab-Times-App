import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chenab_times/l10n/app_localizations.dart';
import 'package:the_chenab_times/screens/notification_screen.dart';
import 'package:the_chenab_times/screens/search_screen.dart';
import 'package:the_chenab_times/services/location_service.dart';
import 'package:the_chenab_times/widgets/category_news_tab.dart';
import 'package:the_chenab_times/widgets/for_you_tab.dart';

/// The home screen of the app, which displays a tab bar with different news
/// categories.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: 'For You'),
    Tab(text: 'Jammu & Kashmir'),
    Tab(text: 'Chenab Valley'),
    Tab(text: 'Politics'),
    Tab(text: 'Government'),
    Tab(text: 'Education'),
    Tab(text: 'India'),
    Tab(text: 'Artificial Intelligence'),
    Tab(text: 'Religion'),
    Tab(text: 'Business'),
    Tab(text: 'World'),
    Tab(text: 'Crime'),
    Tab(text: 'Technology'),
    Tab(text: 'Agriculture'),
    Tab(text: 'Culture'),
    Tab(text: 'Inspirational Stories'),
    Tab(text: 'Op-ed'),
  ];

  final List<Widget> _tabViews = const [
    ForYouTab(),
    CategoryNewsTab(categoryId: 3),
    CategoryNewsTab(categoryId: 463),
    CategoryNewsTab(categoryId: 497),
    CategoryNewsTab(categoryId: 38866),
    CategoryNewsTab(categoryId: 10),
    CategoryNewsTab(categoryId: 317),
    CategoryNewsTab(categoryId: 40329),
    CategoryNewsTab(categoryId: 37686),
    CategoryNewsTab(categoryId: 548),
    CategoryNewsTab(categoryId: 409),
    CategoryNewsTab(categoryId: 552),
    CategoryNewsTab(categoryId: 40392),
    CategoryNewsTab(categoryId: 37617),
    CategoryNewsTab(categoryId: 38568),
    CategoryNewsTab(categoryId: 37289),
    CategoryNewsTab(categoryId: 398),
  ];

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      setState(() {});
    });
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final locationService = context.watch<LocationService>();
    final weatherTitle =
        locationService.city ??
        locationService.state ??
        locationService.country ??
        'Use location';
    final weatherValue = locationService.temperature != null
        ? '${locationService.temperature!.round()}\u00B0C'
        : (locationService.loading
              ? 'Locating...'
              : (locationService.weatherLabel ?? 'Tap to set'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F3EA),
                border: Border(bottom: BorderSide(color: Color(0xFFE1D6C5))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE1D6C5)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: locationService.refreshLocation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weatherTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7D6A52),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                weatherValue,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF1F3B2E),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            locationService.loading
                                ? Icons.sync
                                : Icons.my_location_rounded,
                            size: 18,
                            color: const Color(0xFF7D6A52),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Image.asset(
                      'lib/images/appheading.png',
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF9B7B4B)),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF9B7B4B),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFF8F3EA),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: const Color(0xFF2F6C52),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 6),
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF3E352A),
                labelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                splashBorderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                tabs: _tabs
                    .map(
                      (tab) => Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Text(
                            tab.text ??
                                localizations?.translate('home') ??
                                'Home',
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabViews,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
