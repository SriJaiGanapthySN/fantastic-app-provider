import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/main_screen.dart';

final notificationPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  try {
    String timezoneName = await FlutterTimezone.getLocalTimezone();

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

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantastic App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'SF Pro Display',
      ),
      home: const MainScreen(),
    );
  }
}
