import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:the_chenab_times/screens/terms_and_conditions_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _assemblyController;
  late final AnimationController _buttonController;
  late final Animation<double> _backgroundGlow;
  late final Animation<double> _frameDrop;
  late final Animation<double> _medallionScale;
  late final Animation<double> _titleReveal;
  late final Animation<double> _subtitleReveal;
  late final Animation<double> _taglineReveal;
  late final Animation<double> _buttonReveal;
  late final Animation<double> _ringFloat;

  @override
  void initState() {
    super.initState();

    _assemblyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _backgroundGlow = CurvedAnimation(
      parent: _assemblyController,
      curve: const Interval(0.0, 0.24, curve: Curves.easeOut),
    );
    _frameDrop = CurvedAnimation(
      parent: _assemblyController,
      curve: const Interval(0.12, 0.5, curve: Curves.easeOutCubic),
    );
    _medallionScale = CurvedAnimation(
      parent: _assemblyController,
      curve: const Interval(0.34, 0.66, curve: Curves.easeOutBack),
    );
    _titleReveal = CurvedAnimation(
      parent: _assemblyController,
      curve: const Interval(0.48, 0.76, curve: Curves.easeOutCubic),
    );
    _subtitleReveal = CurvedAnimation(
      parent: _assemblyController,
      curve: const Interval(0.6, 0.86, curve: Curves.easeOutCubic),
    );
    _taglineReveal = CurvedAnimation(
      parent: _assemblyController,
      curve: const Interval(0.72, 1.0, curve: Curves.easeOutCubic),
    );
    _buttonReveal = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    );
    _ringFloat = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    await _assemblyController.forward();
    if (!mounted) return;
    await _buttonController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _assemblyController.dispose();
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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9E8BC), Color(0xFFB98D49), Color(0xFF7C5630)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _assemblyController,
              _buttonController,
            ]),
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MetalBackdropPainter(
                        glowProgress: _backgroundGlow.value,
                        ringOffset: _ringFloat.value,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    top: 24,
                    bottom: 26,
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        Transform.translate(
                          offset: Offset(0, 180 * (1 - _frameDrop.value)),
                          child: Transform.scale(
                            scale: 0.92 + (_frameDrop.value * 0.08),
                            child: Opacity(
                              opacity: _frameDrop.value.clamp(0.0, 1.0),
                              child: _WelcomePlaque(
                                medallionProgress: _medallionScale.value,
                                titleProgress: _titleReveal.value,
                                subtitleProgress: _subtitleReveal.value,
                                taglineProgress: _taglineReveal.value,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Transform.translate(
                          offset: Offset(0, 36 * (1 - _buttonReveal.value)),
                          child: Opacity(
                            opacity: _buttonReveal.value.clamp(0.0, 1.0),
                            child: SizedBox(
                              width: math.min(size.width * 0.82, 360),
                              height: 58,
                              child: ElevatedButton(
                                onPressed: _continueToTerms,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A1512),
                                  foregroundColor: const Color(0xFFFFE4AF),
                                  elevation: 16,
                                  shadowColor: const Color(
                                    0xFF26170F,
                                  ).withValues(alpha: 0.42),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                    side: const BorderSide(
                                      color: Color(0xFFC2904E),
                                      width: 1.6,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.translate(
                                      offset: Offset(8 * _ringFloat.value, 0),
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8C382),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'READ SMART. STAY INFORMED.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WelcomePlaque extends StatelessWidget {
  const _WelcomePlaque({
    required this.medallionProgress,
    required this.titleProgress,
    required this.subtitleProgress,
    required this.taglineProgress,
  });

  final double medallionProgress;
  final double titleProgress;
  final double subtitleProgress;
  final double taglineProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F0E1), Color(0xFFE8D5B4), Color(0xFFF6E8D0)],
        ),
        border: Border.all(color: const Color(0xFF6B4322), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A210F).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 18,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFF2E1A11), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C5A2A).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFCF6), Color(0xFFEDE0C8), Color(0xFFF9EEDA)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, 38 * (1 - medallionProgress)),
                child: Transform.scale(
                  scale: 0.62 + (medallionProgress * 0.38),
                  child: Opacity(
                    opacity: medallionProgress.clamp(0.0, 1.0),
                    child: const _ChenabSeal(),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _AssembleReveal(
                progress: titleProgress,
                distance: 44,
                child: const _LuxuryWelcomeText(),
              ),
              const SizedBox(height: 16),
              _AssembleReveal(
                progress: subtitleProgress,
                distance: 30,
                child: const Text(
                  'Trusted local, regional and global news\nfrom The Chenab Times.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF362415),
                    fontSize: 17,
                    height: 1.42,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _AssembleReveal(
                progress: taglineProgress,
                distance: 26,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0E0C0B), Color(0xFF32261C)],
                    ),
                    border: Border.all(
                      color: const Color(0xFFC69A5A),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2A160A).withValues(alpha: 0.26),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Read smart. Stay informed.',
                    style: TextStyle(
                      color: Color(0xFFF6CF93),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssembleReveal extends StatelessWidget {
  const _AssembleReveal({
    required this.progress,
    required this.distance,
    required this.child,
  });

  final double progress;
  final double distance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translateByDouble(0, distance * (1 - eased), 0, 1)
        ..rotateX((1 - eased) * -0.18)
        ..scaleByDouble(0.88 + (eased * 0.12), 0.88 + (eased * 0.12), 1, 1),
      child: Opacity(opacity: eased, child: child),
    );
  }
}

class _ChenabSeal extends StatelessWidget {
  const _ChenabSeal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      height: 124,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5D18C), Color(0xFF8F5B24)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A3917).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1B140F), width: 4),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A2715), Color(0xFF19120D)],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF1E6D0),
            border: Border.all(color: const Color(0xFF8A6330), width: 2),
          ),
          child: const Center(
            child: Text(
              'THE\nCHENAB\nTIMES',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF24170F),
                fontSize: 18,
                height: 1.05,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LuxuryWelcomeText extends StatelessWidget {
  const _LuxuryWelcomeText();

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontSize: 62,
      fontWeight: FontWeight.w900,
      letterSpacing: -2.2,
      height: 0.96,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 8),
          child: Text(
            'Welcome',
            style: baseStyle.copyWith(
              color: const Color(0xFF6B4C1F),
              shadows: [
                Shadow(
                  color: const Color(0xFF3A250E).withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1C1), Color(0xFFC99952), Color(0xFF7B5326)],
          ).createShader(bounds),
          child: Text(
            'Welcome',
            style: baseStyle.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.72),
                  blurRadius: 12,
                  offset: const Offset(-3, -3),
                ),
                Shadow(
                  color: const Color(0xFF5D3B18).withValues(alpha: 0.34),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetalBackdropPainter extends CustomPainter {
  _MetalBackdropPainter({required this.glowProgress, required this.ringOffset});

  final double glowProgress;
  final double ringOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF7E6BA), Color(0xFFB88945), Color(0xFF7E5831)],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, basePaint);

    final topPanel = RRect.fromRectAndRadius(
      Rect.fromLTWH(-30, -18, size.width + 60, size.height * 0.18),
      const Radius.circular(26),
    );
    final bottomPanel = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -24,
        size.height * 0.88,
        size.width + 48,
        size.height * 0.16,
      ),
      const Radius.circular(26),
    );

    final panelPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF9EEC8), Color(0xFF9A6B34)],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(topPanel, panelPaint);
    canvas.drawRRect(bottomPanel, panelPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF5C4026).withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final shadowLinePaint = Paint()
      ..color = const Color(0xFFFFF6DE).withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final circles = [
      Rect.fromCircle(
        center: Offset(
          size.width * 0.88,
          size.height * 0.14 + (ringOffset * 4),
        ),
        radius: size.width * 0.24,
      ),
      Rect.fromCircle(
        center: Offset(size.width * 0.79, size.height * 0.2 - (ringOffset * 3)),
        radius: size.width * 0.17,
      ),
      Rect.fromCircle(
        center: Offset(
          size.width * 0.23,
          size.height * 0.72 + (ringOffset * 6),
        ),
        radius: size.width * 0.24,
      ),
    ];

    for (final rect in circles) {
      canvas.drawArc(rect, -0.6, 3.5, false, linePaint);
      canvas.drawArc(rect.inflate(-8), -0.6, 3.5, false, shadowLinePaint);
    }

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFFFF7DA).withValues(alpha: 0.36 * glowProgress),
              const Color(0x00FFF7DA),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.18, size.height * 0.14),
              radius: size.width * 0.42,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.14),
      size.width * 0.42,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MetalBackdropPainter oldDelegate) {
    return oldDelegate.glowProgress != glowProgress ||
        oldDelegate.ringOffset != ringOffset;
  }
}
