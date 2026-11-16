import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Official Blue Hour Creative Studios Logo Emblem Widget
/// Uses the bundled `assets/images/blue_hour_symbol.png` ribbon monogram.
/// Official Blue Hour Creative Studios Logo Emblem Widget
/// Automatically adapts between Dark Theme (`blue_hour_symbol_dark.png` luminous sapphire)
/// and Light/White Theme (`blue_hour_symbol.png` deep royal navy) at 1024x1024 HD resolution.
class BhBrandLogo extends StatelessWidget {
  final double size;
  final double? borderRadius;
  final bool showGlow;
  final bool useFullCardLogo;
  final bool useLightTile;

  const BhBrandLogo({
    super.key,
    this.size = 42,
    this.borderRadius,
    this.showGlow = true,
    this.useFullCardLogo = false,
    this.useLightTile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? (size * 0.32);

    // If explicitly requesting the full card lockup or a light porcelain tile
    if (useFullCardLogo || useLightTile) {
      return Container(
        width: useFullCardLogo ? null : size,
        height: size,
        padding: EdgeInsets.symmetric(
          horizontal: useFullCardLogo ? 12 : size * 0.13,
          vertical: useFullCardLogo ? 6 : size * 0.13,
        ),
        decoration: BoxDecoration(
          color: isDark && !useLightTile
              ? const Color(0xFF131D35)
              : const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isDark && !useLightTile
                ? AppColors.electricBlue.withValues(alpha: 0.42)
                : const Color(0xFF0F172A).withValues(alpha: 0.10),
            width: 1.2,
          ),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: isDark
                        ? AppColors.electricBlue.withValues(alpha: 0.28)
                        : const Color(0xFF1E3A8A).withValues(alpha: 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Image.asset(
          (isDark && !useLightTile)
              ? 'assets/images/blue_hour_symbol_dark.png'
              : 'assets/images/blue_hour_symbol.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        ),
      );
    }

    // Theme-adaptive emblem tile (Dark Theme vs Light/White Theme)
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF162447),
                  Color(0xFF0C1428),
                ]
              : const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF1F5F9),
                ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? AppColors.electricBlue.withValues(alpha: 0.48)
              : const Color(0xFF1E3A8A).withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: isDark
                      ? AppColors.electricBlue.withValues(alpha: 0.32)
                      : const Color(0xFF1E3A8A).withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Image.asset(
        isDark
            ? 'assets/images/blue_hour_symbol_dark.png'
            : 'assets/images/blue_hour_symbol.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      ),
    );
  }
}

/// Editorial Wordmark matching `theblue-hour-studios.vercel.app`:
/// `BLUE HOUR.` + `CREATIVE STUDIOS` kicker.
class BhWordmark extends StatelessWidget {
  final double fontSize;
  final double? subSize;
  final String? subtitle;
  final bool center;

  const BhWordmark({
    super.key,
    this.fontSize = 20,
    this.subSize,
    this.subtitle = 'CREATIVE STUDIOS',
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: textColor,
              height: 1.05,
            ),
            children: const [
              TextSpan(text: 'BLUE HOUR'),
              TextSpan(
                text: '.',
                style: TextStyle(color: AppColors.electricBlue),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: subSize ?? (fontSize * 0.46).clamp(8.5, 12.0),
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Smooth entrance animation wrapper (fade + subtle upward slide)
class BhFadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;

  const BhFadeSlideIn({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 18,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 480 + (delayMs.clamp(0, 600))),
      curve: Curves.easeOutQuart,
      builder: (context, value, childWidget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * offsetY),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}

/// Artistic Twilight Ambient Background Canvas with subtle aurora glows
class BhAmbientCanvas extends StatelessWidget {
  final Widget child;

  const BhAmbientCanvas({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned(
          top: -110,
          right: -70,
          child: IgnorePointer(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.electricBlue
                        .withValues(alpha: isDark ? 0.16 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          left: -90,
          child: IgnorePointer(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.indigo.withValues(alpha: isDark ? 0.14 : 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Artistic Empty State Card when there is no data yet (zero dummy data).
class BhArtisticEmptyState extends StatelessWidget {
  final String kicker;
  final String title;
  final String? description;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const BhArtisticEmptyState({
    super.key,
    this.kicker = 'CLEAN STUDIO WORKSPACE',
    required this.title,
    this.description,
    this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BhFadeSlideIn(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF162038),
                    Color(0xFF101729),
                  ],
                )
              : null,
          color: isDark ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.electricBlue.withValues(alpha: 0.28),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.electricBlue.withValues(alpha: 0.26),
                    AppColors.indigo.withValues(alpha: 0.06),
                  ],
                ),
                border: Border.all(
                  color: AppColors.electricBlue.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(icon, color: AppColors.electricBlue, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              kicker,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                color: AppColors.electricBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description ?? subtitle ?? '',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(height: 1.5),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable elevated/glassmorphic card for Blue Hour HQ.
class BhSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Gradient? gradient;
  final double borderRadius;

  const BhSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
    this.gradient,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final defaultBorder = borderColor ??
        (isDark
            ? AppColors.darkBorder.withValues(alpha: 0.85)
            : AppColors.lightBorder);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? defaultBg : null,
            gradient: gradient ??
                (isDark
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF172136),
                          Color(0xFF121A2B),
                        ],
                      )
                    : null),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: defaultBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.28)
                    : const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Semantic pill badge for status, priority, or category tags.
class BhStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool compact;

  const BhStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.compact = false,
  });

  factory BhStatusPill.fromLeadStatus(String status, {bool compact = false}) {
    switch (status) {
      case 'New Lead':
        return BhStatusPill(
          label: status,
          color: AppColors.electricBlue,
          icon: Icons.fiber_new_rounded,
          compact: compact,
        );
      case 'Contacted':
        return BhStatusPill(
          label: status,
          color: AppColors.cyanAccent,
          icon: Icons.phone_in_talk_rounded,
          compact: compact,
        );
      case 'Meeting Scheduled':
        return BhStatusPill(
          label: status,
          color: AppColors.indigo,
          icon: Icons.event_available_rounded,
          compact: compact,
        );
      case 'Requirement Gathering':
        return BhStatusPill(
          label: status,
          color: AppColors.violetAccent,
          icon: Icons.assignment_rounded,
          compact: compact,
        );
      case 'Proposal Sent':
        return BhStatusPill(
          label: status,
          color: AppColors.warning,
          icon: Icons.description_outlined,
          compact: compact,
        );
      case 'Negotiation':
        return BhStatusPill(
          label: status,
          color: const Color(0xFFF97316),
          icon: Icons.handshake_outlined,
          compact: compact,
        );
      case 'Converted':
        return BhStatusPill(
          label: status,
          color: AppColors.success,
          icon: Icons.verified_rounded,
          compact: compact,
        );
      case 'Lost':
        return BhStatusPill(
          label: status,
          color: AppColors.error,
          icon: Icons.cancel_outlined,
          compact: compact,
        );
      default:
        return BhStatusPill(
          label: status,
          color: AppColors.electricBlue,
          compact: compact,
        );
    }
  }

  factory BhStatusPill.fromPriority(String priority, {bool compact = false}) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'critical':
        return BhStatusPill(
          label: priority,
          color: AppColors.error,
          icon: Icons.local_fire_department_rounded,
          compact: compact,
        );
      case 'high':
        return BhStatusPill(
          label: priority,
          color: AppColors.warning,
          icon: Icons.keyboard_double_arrow_up_rounded,
          compact: compact,
        );
      case 'medium':
        return BhStatusPill(
          label: priority,
          color: AppColors.electricBlue,
          compact: compact,
        );
      default:
        return BhStatusPill(
          label: priority,
          color: const Color(0xFF64748B),
          compact: compact,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3.5 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 11 : 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Executive KPI metric card for Founder Dashboard & Finance views.
class BhKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String? trendText;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const BhKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.accentColor = AppColors.electricBlue,
    this.trendText,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BhSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              if (trendText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isPositiveTrend
                            ? AppColors.success
                            : AppColors.electricBlue)
                        .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    trendText!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isPositiveTrend
                          ? AppColors.successSoft
                          : AppColors.electricBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 21,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// Presence-aware avatar widget for founders, clients, and channels.
class BhAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool? isOnline;
  final Color? backgroundColor;

  const BhAvatar({
    super.key,
    required this.name,
    this.size = 42,
    this.isOnline,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'BH';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _derivedColor() {
    if (backgroundColor != null) return backgroundColor!;
    const palette = [
      AppColors.electricBlue,
      AppColors.indigo,
      AppColors.violetAccent,
      AppColors.cyanAccent,
      Color(0xFFEC4899),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
    ];
    final hash = name.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _derivedColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                baseColor.withValues(alpha: 0.72),
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.34),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.36,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (isOnline != null)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: isOnline!
                    ? AppColors.successSoft
                    : const Color(0xFF64748B),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Editorial Section Header with optional index kicker, badge count, and action button.
class BhSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? kicker;
  final int? countBadge;
  final String? actionLabel;
  final VoidCallback? onAction;

  const BhSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.kicker,
    this.countBadge,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kicker != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          kicker!,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                            color: AppColors.electricBlue,
                          ),
                        ),
                      ),
                    Text(title, style: textTheme.headlineSmall),
                    if (subtitle != null)
                      Text(subtitle!, style: textTheme.bodySmall),
                  ],
                ),
              ),
              if (countBadge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$countBadge',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.electricBlue,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.electricBlue,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_forward_ios_rounded, size: 11),
              ],
            ),
          ),
      ],
    );
  }
}

/// Always-available Back button for secondary screens (falls back to [fallbackRoute]
/// when opened directly from an OS push notification or cold deep link).
class BhSmartBackButton extends StatelessWidget {
  final String fallbackRoute;

  const BhSmartBackButton({
    super.key,
    this.fallbackRoute = '/home',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const BackButtonIcon(),
      onPressed: () {
        final router = GoRouter.maybeOf(context);
        if (router != null) {
          if (router.canPop()) {
            router.pop();
          } else {
            router.go(fallbackRoute);
          }
          return;
        }
        Navigator.maybePop(context);
      },
    );
  }
}
