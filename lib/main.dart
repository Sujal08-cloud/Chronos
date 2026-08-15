import 'package:chronos/core/routing/app_router.dart';
import 'package:chronos/core/services/notification_service.dart';
import 'package:chronos/core/theme/app_theme.dart';
import 'package:chronos/firebase_options.dart';
import 'package:chronos/shared/provider/shared_prefs_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------
  // Firebase
  // --------------------------------------------------
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  // --------------------------------------------------
  // Shared Preferences
  // --------------------------------------------------
  final prefs = await SharedPreferences.getInstance();

  // --------------------------------------------------
  // Notifications
  // --------------------------------------------------
  await NotificationService().init();

  // --------------------------------------------------
  // Run App
  // --------------------------------------------------
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Router
    final router = ref.watch(appRouterProvider);

    // Current dark/light mode
    final isDarkMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Chronos',

      debugShowCheckedModeBanner: false,

      // --------------------------------------------------
      // Theme
      // --------------------------------------------------
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Dark mode switch
      themeMode: isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      // --------------------------------------------------
      // Router
      // --------------------------------------------------
      routerConfig: router,
    );
  }
}