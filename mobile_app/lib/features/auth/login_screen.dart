import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _require2faPrompt = false;
  String _selectedFounderId = 'emp-01';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'himonbhuyan@gmail.com');
    _passwordController = TextEditingController(text: 'BlueHour#2026');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectFounder(AppUser founder) {
    setState(() {
      _selectedFounderId = founder.id;
      _emailController.text = founder.email;
    });
    ref.read(agencyStoreProvider.notifier).switchActiveFounder(founder.id);
  }

  void _handleSignIn() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(agencyStoreProvider.notifier)
        .loginAsFounder(_selectedFounderId);
    if (_require2faPrompt) {
      _showTwoFactorSheet();
    } else {
      context.go('/home');
    }
  }

  void _showTwoFactorSheet() {
    final otpController = TextEditingController(text: '482910');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: AppColors.electricBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Two-Factor Authentication',
                          style: Theme.of(ctx).textTheme.headlineSmall,
                        ),
                        Text(
                          'Enter the 6-digit Sanctum authenticator code',
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  labelText: '6-Digit Security Code',
                  counterText: '',
                  prefixIcon: Icon(Icons.key_rounded),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/home');
                  },
                  icon: const Icon(Icons.verified_user_rounded, size: 18),
                  label: const Text('Verify & Launch Workspace'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showForgotPasswordSheet() {
    final resetEmailCtrl = TextEditingController(text: _emailController.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Workspace Password',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'A signed Laravel Sanctum password reset link and OTP will be sent to your registered founder email.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Founder Email Address',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Password recovery instructions sent to ${resetEmailCtrl.text}',
                        ),
                      ),
                    );
                  },
                  child: const Text('Send Recovery Link'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final notifier = ref.read(agencyStoreProvider.notifier);
    final founders = state.employees;
    final selectedFounder = founders.firstWhere(
      (f) => f.id == _selectedFounderId,
      orElse: () => founders.first,
    );
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardItemBg =
        isDark ? AppColors.darkElevatedSurface : AppColors.lightElevatedSurface;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: BhAmbientCanvas(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: BhFadeSlideIn(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Official Brand Header + Theme Toggle
                    Row(
                      children: [
                        const BhBrandLogo(size: 50, showGlow: true),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: BhWordmark(
                            fontSize: 22,
                            subtitle: 'CREATIVE STUDIOS • FOUNDERS HQ',
                          ),
                        ),
                        IconButton(
                          tooltip: 'Toggle Light / Dark Theme',
                          onPressed: notifier.toggleThemeMode,
                          icon: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            color: AppColors.electricBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Founders Command Login',
                      style: textTheme.displayMedium?.copyWith(
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select your founder profile below or sign in directly with your Blue Hour HQ credentials.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3 Founders Selector Cards
                    BhSurfaceCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'THE 3 FOUNDERS / PARTNERS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.9,
                                  color: AppColors.electricBlue,
                                ),
                              ),
                              BhStatusPill(
                                label: 'SUPER ADMIN: HIMON',
                                color: AppColors.electricBlue,
                                icon: Icons.shield_rounded,
                                compact: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...founders.map((f) {
                            final selected = f.id == _selectedFounderId;
                            final isHimonSuperAdmin = f.isSuperAdmin;
                            final badgeColor = isHimonSuperAdmin
                                ? AppColors.electricBlue
                                : (f.id == 'emp-02'
                                    ? AppColors.indigo
                                    : AppColors.cyanAccent);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _selectFounder(f),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(11),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.electricBlue
                                            .withValues(alpha: isDark ? 0.20 : 0.10)
                                        : cardItemBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.electricBlue
                                          : cardBorder,
                                      width: selected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      BhAvatar(
                                        name: f.name,
                                        size: 40,
                                        isOnline: true,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    f.name,
                                                    style: TextStyle(
                                                      color: primaryTextColor,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                BhStatusPill(
                                                  label: f.accessBadgeLabel,
                                                  color: badgeColor,
                                                  icon: isHimonSuperAdmin
                                                      ? Icons.shield_rounded
                                                      : null,
                                                  compact: true,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              f.designation,
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (selected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.electricBlue,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Founder Email',
                        prefixIcon:
                            Icon(Icons.alternate_email_rounded, size: 20),
                      ),
                      validator: (val) => (val == null || !val.contains('@'))
                          ? 'Enter a valid studio email address'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon:
                            const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (val) => (val == null || val.length < 6)
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Switch.adaptive(
                              value: _require2faPrompt,
                              activeTrackColor: AppColors.electricBlue,
                              onChanged: (v) =>
                                  setState(() => _require2faPrompt = v),
                            ),
                            Text(
                              'Prompt 2FA OTP',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _showForgotPasswordSheet,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleSignIn,
                        icon: Icon(
                          selectedFounder.isSuperAdmin
                              ? Icons.shield_rounded
                              : Icons.login_rounded,
                          size: 19,
                        ),
                        label: Text(
                          selectedFounder.isSuperAdmin
                              ? 'Sign In as ${selectedFounder.name} (Super Admin)'
                              : 'Sign In as ${selectedFounder.name}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedFounder.isSuperAdmin
                                ? Icons.shield_rounded
                                : Icons.verified_user_outlined,
                            color: selectedFounder.isSuperAdmin
                                ? AppColors.electricBlue
                                : AppColors.successSoft,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedFounder.isSuperAdmin
                                  ? 'Super Admin Privileges Enabled (Himon Bhuyan) • Full System, RBAC & Database Governance.'
                                  : 'Co-Founder / Partner Access (${selectedFounder.name}) • Super Admin governance is reserved exclusively for Himon Bhuyan.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: secondaryTextColor,
                                height: 1.4,
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
          ),
        ),
      ),
    );
  }
}
