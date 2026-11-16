import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/repositories/agency_store.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const _slides = [
    _OnboardingSlideData(
      badge: '01 // EXECUTIVE ARCHITECTURE',
      title: 'Direct Founder Command. Zero Bureaucracy.',
      description:
          'Built exclusively for Himon Bhuyan (Founder & Super Admin), Darshana Das (Partner), and Drishant Das (Co-Founder) to orchestrate Software & AI, Client Growth, and Hardware & IoT.',
      accent: AppColors.electricBlue,
      pillars: [
        ('Himon Bhuyan', 'Super Admin', 'Software & AI'),
        ('Darshana Das', 'Partner', 'Growth & Social'),
        ('Drishant Das', 'Co-Founder', 'Hardware & IoT'),
      ],
    ),
    _OnboardingSlideData(
      badge: '02 // PIPELINE & CLIENT OPS',
      title: 'Full-Lifecycle CRM, Proposals & GST Ledger',
      description:
          'Manage real inbound leads across an 8-stage Kanban pipeline, schedule multi-interval follow-up reminders, generate 18% GST proposals, and convert leads into clients.',
      accent: AppColors.indigo,
      pillars: [
        ('Kanban CRM', '8 Stages', 'Pipeline Control'),
        ('Auto Reminders', '1d • 1h • 15m', 'FCM + APNs'),
        ('INR Billing', 'GST Ready', 'Proposals & Invoices'),
      ],
    ),
    _OnboardingSlideData(
      badge: '03 // REAL-TIME WORKSPACE',
      title: 'Founders Board Chat, Sprints & Live SQL Sync',
      description:
          'Collaborate in the Founders Board, track milestone progress, schedule Google Meet client demos, and sync live with SQL & Firebase.',
      accent: AppColors.cyanAccent,
      pillars: [
        ('Founders Chat', 'Live Board', 'Voice & Docs'),
        ('Sprint Delivery', 'Milestones', 'Task Tracking'),
        ('SQL + Firebase', 'Hybrid Sync', 'Always Synced'),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    ref.read(agencyStoreProvider.notifier).completeOnboarding();
    context.go('/login');
  }

  void _nextOrFinish() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutQuart,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: BhAmbientCanvas(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with Official Blue Hour Logo
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        BhBrandLogo(size: 38),
                        SizedBox(width: 12),
                        BhWordmark(fontSize: 17),
                      ],
                    ),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Sign In →',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: BhFadeSlideIn(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Artistic Hero Showcase Card with Official Logo
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          slide.accent.withValues(alpha: 0.20),
                                          const Color(0xFF131C33),
                                          const Color(0xFF0D1426),
                                        ]
                                      : [
                                          slide.accent.withValues(alpha: 0.12),
                                          const Color(0xFFFFFFFF),
                                          const Color(0xFFF1F5F9),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: slide.accent.withValues(alpha: 0.38),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        slide.accent.withValues(alpha: 0.14),
                                    blurRadius: 34,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const BhBrandLogo(
                                        size: 54,
                                        useFullCardLogo: true,
                                      ),
                                      BhStatusPill(
                                        label: 'STUDIO OS',
                                        color: slide.accent,
                                        icon: Icons.auto_awesome_rounded,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: slide.pillars
                                        .map(
                                          (m) => Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? AppColors.darkBackground
                                                        .withValues(alpha: 0.65)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: isDark
                                                      ? AppColors.darkBorder
                                                      : AppColors.lightBorder,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    m.$2,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryTextColor,
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    m.$1,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: secondaryTextColor,
                                                      fontSize: 10.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    m.$3,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: slide.accent,
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: slide.accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                slide.badge,
                                style: TextStyle(
                                  color: slide.accent,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              slide.title,
                              style: textTheme.displayMedium?.copyWith(
                                color: primaryTextColor,
                                height: 1.18,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              slide.description,
                              style: textTheme.bodyLarge?.copyWith(
                                color: secondaryTextColor,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        _slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutQuart,
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          width: _currentIndex == index ? 28 : 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? AppColors.electricBlue
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _nextOrFinish,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentIndex == _slides.length - 1
                                ? 'Enter Founders HQ'
                                : 'Continue',
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
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

class _OnboardingSlideData {
  final String badge;
  final String title;
  final String description;
  final Color accent;
  final List<(String, String, String)> pillars;

  const _OnboardingSlideData({
    required this.badge,
    required this.title,
    required this.description,
    required this.accent,
    required this.pillars,
  });
}
