import 'dart:developer';

import 'package:fantastic_app_riverpod/core/log/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_options.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_page.dart';
import 'features/auth/presentation/screens/profile_completion_screen.dart';
import 'features/onboarding/presentation/Screens/onBoard1.dart';
import 'main_screen.dart';
import 'features/chat/data/services/token/token_service.dart';
import 'core/services/onboarding_service.dart';

final notificationPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize Firebase first
  await _initializeFirebase();

  // Initialize Firebase Auth monitoring in TokenService
  AppLogger.i('Initializing Firebase Auth monitoring...');
  TokenService.initializeFirebaseAuthListener();

  try {
    String timezoneName = (await FlutterTimezone.getLocalTimezone()) as String;

    if (timezoneName == "Asia/Calcutta") {
      timezoneName = "Asia/Kolkata";
    }

    tz.setLocalLocation(tz.getLocation(timezoneName));
    log('Timezone set to: $timezoneName');
  } catch (e) {
    log('Error setting timezone: $e');

    try {
      final String deviceTimeZone = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(deviceTimeZone));
      log('Fallback timezone set to device timezone: $deviceTimeZone');
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      log('Fallback to UTC timezone');
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'alarm_channel',
    'Alarm Notifications',
    description: 'Channel for alarm notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('alarm_sound'),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  AppLogger.i('App initialization complete - Firebase Auth monitoring active');

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Fantastic App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'SF Pro Display',
      ),
      home: Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authProvider);

          if (authState.isLoading) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      color: Colors.white,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              ),
            );
          }

          final isAuthenticated = authState.user != null;
          AppLogger.i(
              'Authentication state: ${isAuthenticated ? 'Authenticated' : 'Not authenticated'}');

          // If not authenticated, show auth page
          if (!isAuthenticated) {
            return const AuthPage();
          }

          // Check if profile is complete
          final user = authState.user!;
          if (!user.profileComplete) {
            AppLogger.i(
                '⚠️ User profile incomplete - showing profile completion screen');
            return ProfileCompletionScreen(user: user);
          }

          // If authenticated with complete profile, check onboarding status
          return FutureBuilder<bool>(
            future: OnboardingService.hasCompletedOnboarding(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      color: Colors.white,
                      strokeWidth: 5,
                    ),
                  ),
                );
              }

              final hasCompletedOnboarding = snapshot.data ?? false;
              AppLogger.i(
                  'Onboarding status: ${hasCompletedOnboarding ? 'Completed' : 'Not completed'}');

              // Show onboarding if not completed, otherwise show main screen
              return hasCompletedOnboarding
                  ? const MainScreen()
                  : const Onboard1();
            },
          );
        },
      ),
    );
  }
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    AppLogger.i('Firebase initialized successfully');
  } catch (e) {
    if (kDebugMode) {
      AppLogger.e("Firebase initialization error: $e");
    }
  }
}
