import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/agency_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // Fall back cleanly to local cache + XAMPP SQL if Firebase init fails offline
    }
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
    );
  }
}
