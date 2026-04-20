import 'dart:async';

import 'package:flutter/material.dart';
import 'package:the_chenab_times/screens/terms_and_conditions_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroController;
  late final AnimationController _buttonController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutBack),
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _buttonAnimation =
        Tween<Offset>(begin: const Offset(0, 0.7), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: Curves.easeOutCubic,
          ),
        );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    await _heroController.forward();
    if (!mounted) return;
    _buttonController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _continueToTerms() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7E8), Color(0xFFF7E2B6), Color(0xFFEBCB86)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -80,
                child: _GlowOrb(
                  size: size.width * 0.62,
                  color: const Color(0xFFFFD56F),
                ),
              ),
              Positioned(
                bottom: 90,
                left: -90,
                child: _GlowOrb(
                  size: size.width * 0.58,
                  color: const Color(0xFF9B1C20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  children: [
                    const Spacer(),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: const _WelcomeCard(),
                      ),
                    ),
                    const Spacer(),
                    SlideTransition(
                      position: _buttonAnimation,
                      child: FadeTransition(
                        opacity: _buttonController,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9B1C20),
                              foregroundColor: Colors.white,
                              elevation: 12,
                              shadowColor: const Color(
                                0xFF9B1C20,
                              ).withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _continueToTerms,
                            child: const Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B2A12).withValues(alpha: 0.16),
            blurRadius: 40,
            offset: const Offset(0, 26),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.75),
            blurRadius: 10,
            offset: const Offset(-6, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LogoMedallion(),
          const SizedBox(height: 28),
          const _ThreeDWelcomeText(),
          const SizedBox(height: 18),
          Text(
            'Trusted local, regional and global news from The Chenab Times.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF3B2A21).withValues(alpha: 0.82),
              fontSize: 17,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF12100E),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF12100E).withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Text(
              'Read smart. Stay informed.',
              style: TextStyle(
                color: Color(0xFFFFE7B0),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMedallion extends StatelessWidget {
  const _LogoMedallion();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFAEF), Color(0xFFD99B2F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B1C20).withValues(alpha: 0.24),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset('lib/images/appIco.png', fit: BoxFit.cover),
      ),
    );
  }
}

class _ThreeDWelcomeText extends StatelessWidget {
  const _ThreeDWelcomeText();

  @override
  Widget build(BuildContext context) {
    const text = 'Welcome';
    const style = TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.4,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 7),
          child: Text(text, style: style.copyWith(color: Color(0xFF7C1418))),
        ),
        Transform.translate(
          offset: const Offset(0, 4),
          child: Text(text, style: style.copyWith(color: Color(0xFFC48625))),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0B8), Color(0xFFD28B20), Color(0xFF9B1C20)],
          ).createShader(bounds),
          child: Text(
            text,
            style: style.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 8,
                  offset: Offset(-2, -2),
                ),
                Shadow(
                  color: Color(0xFF5A1516),
                  blurRadius: 14,
                  offset: Offset(0, 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
    );
  }
}
