import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_chenab_times/main.dart';
import 'package:the_chenab_times/screens/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool onboardingComplete =
          prefs.getBool('onboarding_complete') ?? false;

      if (!mounted) return;

      if (onboardingComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LanguageSelectionScreen(isInitialSetup: true),
          ),
        );
      }
    } catch (e) {
      debugPrint('Splash Error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LanguageSelectionScreen(isInitialSetup: true),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12100E),
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 700),
        opacity: _visible ? 1 : 0,
        child: Center(
          child: Container(
            width: 132,
            height: 132,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF3D5), Color(0xFFE7B24A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9B1C20).withValues(alpha: 0.28),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset('lib/images/appIco.png', fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
