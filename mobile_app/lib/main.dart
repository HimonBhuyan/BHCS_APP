import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/services/biometric_auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/bh_widgets.dart';
import 'data/repositories/agency_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // Fall back cleanly to local cache + XAMPP SQL if Firebase init fails offline
    }
    await BhNotificationService.instance.initialize();
  }
  runApp(
    const ProviderScope(
      child: BlueHourHqApp(),
    ),
  );
}

class BlueHourHqApp extends ConsumerWidget {
  const BlueHourHqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      agencyStoreProvider.select((state) => state.themeMode),
    );

    return MaterialApp.router(
      title: 'Blue Hour HQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return _BiometricSecurityGate(child: child);
      },
    );
  }
}

class _BiometricSecurityGate extends ConsumerStatefulWidget {
  final Widget child;
  const _BiometricSecurityGate({required this.child});

  @override
  ConsumerState<_BiometricSecurityGate> createState() =>
      _BiometricSecurityGateState();
}

class _BiometricSecurityGateState
    extends ConsumerState<_BiometricSecurityGate> with WidgetsBindingObserver {
  bool _unlocked = true;
  bool _authInProgress = false;
  bool _wasEnabledAndLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    final store = ref.read(agencyStoreProvider);
    if (appState == AppLifecycleState.paused &&
        store.isLoggedIn &&
        store.biometricLockEnabled &&
        !_authInProgress) {
      if (mounted) setState(() => _unlocked = false);
    } else if (appState == AppLifecycleState.resumed &&
        !_unlocked &&
        store.isLoggedIn &&
        store.biometricLockEnabled) {
      _promptUnlock();
    }
  }

  Future<void> _promptUnlock() async {
    if (_authInProgress) return;
    _authInProgress = true;
    final ok = await BhBiometricAuthService.instance.authenticate(
      reason: 'Unlock Blue Hour HQ with Fingerprint or Face ID',
    );
    _authInProgress = false;
    if (ok && mounted) {
      setState(() => _unlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLockedTarget = ref.watch(
      agencyStoreProvider
          .select((s) => s.isLoggedIn && s.biometricLockEnabled),
    );

    if (isLockedTarget && !_wasEnabledAndLoggedIn) {
      _wasEnabledAndLoggedIn = true;
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        _unlocked = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => _promptUnlock());
      }
    } else if (!isLockedTarget) {
      _wasEnabledAndLoggedIn = false;
      _unlocked = true;
    }

    if (!isLockedTarget || _unlocked) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Material(
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BhBrandLogo(size: 76, borderRadius: 22),
                      const SizedBox(height: 22),
                      Text(
                        'Blue Hour HQ Locked',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Biometric verification is required to access Founder CRM, Chat & Finance.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _promptUnlock,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: const Text(
                          'Unlock with Biometrics',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
