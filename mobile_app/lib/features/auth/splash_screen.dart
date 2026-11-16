import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/repositories/agency_store.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _wordmarkSlideAnim;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnim = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.72, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _wordmarkSlideAnim = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.28, 0.90, curve: Curves.easeOutCubic),
    );
    _entryController.forward();

    final hydrationFuture =
        ref.read(agencyStoreProvider.notifier).hydrateFromStorage();

    _navTimer = Timer(const Duration(milliseconds: 2500), () async {
      final restored = await hydrationFuture;
      if (!mounted) return;
      if (restored.isLoggedIn) {
        context.go('/home');
      } else if (restored.hasCompletedOnboarding) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _entryController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.darkBackground : const Color(0xFFF7F8FC);
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: BhAmbientCanvas(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Orbital Constellation + Razor-Sharp 1024x1024 BH Ribbon Emblem
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _orbitController,
                          _pulseController,
                        ]),
                        builder: (context, _) {
                          final floatY =
                              math.sin(_pulseController.value * math.pi) * -5.0;
                          final glowScale =
                              1.0 + (_pulseController.value * 0.05);

                          return SizedBox(
                            width: 224,
                            height: 224,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Custom-painted orbital arcs, radar sweep & satellite nodes
                                CustomPaint(
                                  size: const Size(224, 224),
                                  painter: _SplashOrbitalPainter(
                                    orbitProgress: _orbitController.value,
                                    pulseProgress: _pulseController.value,
                                    isDark: isDark,
                                  ),
                                ),

                                // Breathing ambient aura behind the logo
                                Transform.scale(
                                  scale: glowScale,
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: isDark
                                            ? [
                                                AppColors.electricBlue
                                                    .withValues(alpha: 0.30),
                                                AppColors.indigo
                                                    .withValues(alpha: 0.08),
                                                Colors.transparent,
                                              ]
                                            : [
                                                const Color(0xFF1E3A8A)
                                                    .withValues(alpha: 0.16),
                                                AppColors.electricBlue
                                                    .withValues(alpha: 0.05),
                                                Colors.transparent,
                                              ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Floating High-Definition Theme-Adaptive Logo Medallion
                                Transform.translate(
                                  offset: Offset(0, floatY),
                                  child: Container(
                                    width: 122,
                                    height: 122,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDark
                                            ? const [
                                                Color(0xFF17254A),
                                                Color(0xFF0D152C),
                                              ]
                                            : const [
                                                Color(0xFFFFFFFF),
                                                Color(0xFFF3F6FC),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(36),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.electricBlue
                                                .withValues(alpha: 0.55)
                                            : const Color(0xFF1E3A8A)
                                                .withValues(alpha: 0.18),
                                        width: 1.6,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? AppColors.electricBlue
                                                  .withValues(alpha: 0.34)
                                              : const Color(0xFF1E3A8A)
                                                  .withValues(alpha: 0.16),
                                          blurRadius: 32,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      isDark
                                          ? 'assets/images/blue_hour_symbol_dark.png'
                                          : 'assets/images/blue_hour_symbol.png',
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      isAntiAlias: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Animated Wordmark + Studio Domain Pillars
                  AnimatedBuilder(
                    animation: _wordmarkSlideAnim,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _wordmarkSlideAnim.value,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            (1.0 - _wordmarkSlideAnim.value) * 20,
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const BhWordmark(
                          fontSize: 35,
                          subtitle: 'CREATIVE STUDIOS',
                          center: true,
                        ),
                        const SizedBox(height: 16),

                        // 3 Founder Domain Badges
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: const [
                            BhStatusPill(
                              label: 'SOFTWARE & AI',
                              color: AppColors.electricBlue,
                              compact: true,
                            ),
                            BhStatusPill(
                              label: 'GROWTH & SOCIAL',
                              color: AppColors.indigo,
                              compact: true,
                            ),
                            BhStatusPill(
                              label: 'HARDWARE & IOT',
                              color: AppColors.cyanAccent,
                              compact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),

                        // Live Progress Bar & Telemetry Counter
                        AnimatedBuilder(
                          animation: _entryController,
                          builder: (context, _) {
                            final pct = (_entryController.value * 100).round();
                            return SizedBox(
                              width: 220,
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: _entryController.value,
                                      minHeight: 3.5,
                                      backgroundColor: isDark
                                          ? AppColors.darkElevatedSurface
                                          : AppColors.lightBorder,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        AppColors.electricBlue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'FOUNDERS COMMAND OS',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.w800,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                      Text(
                                        '$pct%',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.electricBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashOrbitalPainter extends CustomPainter {
  final double orbitProgress;
  final double pulseProgress;
  final bool isDark;

  _SplashOrbitalPainter({
    required this.orbitProgress,
    required this.pulseProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.47;
    final innerRadius = size.width * 0.37;

    // 1. Expanding pulse wave ring
    final pulseRadius =
        innerRadius + (outerRadius - innerRadius) * pulseProgress;
    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppColors.electricBlue
          .withValues(alpha: (1.0 - pulseProgress) * (isDark ? 0.38 : 0.25));
    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // 2. Outer subtle track ring
    final outerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = (isDark ? AppColors.indigo : const Color(0xFF1E3A8A))
          .withValues(alpha: isDark ? 0.22 : 0.14);
    canvas.drawCircle(center, outerRadius, outerTrackPaint);

    // 3. Inner subtle track ring
    final innerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.electricBlue.withValues(alpha: isDark ? 0.30 : 0.20);
    canvas.drawCircle(center, innerRadius, innerTrackPaint);

    // 4. Sweeping luminous arcs on outer & inner rings
    final startAngle1 = orbitProgress * 2 * math.pi;
    final arcPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.electricBlue.withValues(alpha: isDark ? 0.85 : 0.70);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngle1,
      math.pi * 0.55,
      false,
      arcPaint1,
    );

    final startAngle2 = -orbitProgress * 2 * math.pi + math.pi * 0.5;
    final arcPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = (isDark ? AppColors.cyanAccent : const Color(0xFF1D4ED8))
          .withValues(alpha: isDark ? 0.75 : 0.55);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle2,
      math.pi * 0.42,
      false,
      arcPaint2,
    );

    // 5. 3 Orbiting Satellite Nodes (representing the 3 Founders)
    final nodeColors = [
      AppColors.electricBlue,
      AppColors.indigo,
      AppColors.cyanAccent,
    ];
    for (var i = 0; i < 3; i++) {
      final angle =
          (orbitProgress * 2 * math.pi) + (i * 2 * math.pi / 3.0);
      final r = i.isEven ? outerRadius : innerRadius;
      final nodeOffset = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );

      // Node glow
      final glowPaint = Paint()
        ..color = nodeColors[i].withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(nodeOffset, 6.5, glowPaint);

      // Crisp node core
      final corePaint = Paint()..color = nodeColors[i];
      canvas.drawCircle(nodeOffset, 3.6, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashOrbitalPainter oldDelegate) {
    return oldDelegate.orbitProgress != orbitProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.isDark != isDark;
  }
}
