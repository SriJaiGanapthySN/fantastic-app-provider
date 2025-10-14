import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class AlarmState {
  final bool isAlarmSet;
  final TimeOfDay alarmTime;
  final Duration duration;

  AlarmState({
    required this.isAlarmSet,
    required this.alarmTime,
    required this.duration,
  });

  String get formattedAlarmTime {
    final now = DateTime.now();
    final alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarmTime.hour,
      alarmTime.minute,
    );
    return DateFormat('h:mm a').format(alarmDateTime);
  }

  String get formattedDuration {
    return '${duration.inMinutes} Min';
  }

  AlarmState copyWith({
    bool? isAlarmSet,
    TimeOfDay? alarmTime,
    Duration? duration,
  }) {
    return AlarmState(
      isAlarmSet: isAlarmSet ?? this.isAlarmSet,
      alarmTime: alarmTime ?? this.alarmTime,
      duration: duration ?? this.duration,
    );
  }
}

class AlarmNotifier extends StateNotifier<AlarmState> {
  final FlutterLocalNotificationsPlugin notifications;

  AlarmNotifier(this.notifications)
      : super(AlarmState(
          isAlarmSet: false,
          alarmTime: TimeOfDay(
              hour: DateTime.now().hour, minute: DateTime.now().minute + 5),
          duration: const Duration(minutes: 10),
        )) {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        log('Notification response received: ${details.payload}');
      },
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      final status = await Permission.notification.request();
      log('Notification permission status: $status');
    }

    if (notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>() !=
        null) {
      await notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    try {
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      if (!alarmStatus.isGranted) {
        final result = await Permission.scheduleExactAlarm.request();
        log('Exact alarm permission status: $result');
      }
    } catch (e) {
      log('scheduleExactAlarm permission not available: $e');
    }
  }

  Future<void> _scheduleAlarm() async {
    await notifications.cancelAll();

    if (!state.isAlarmSet) {
      log('Alarm is not set, skipping scheduling');
      return;
    }

    if (!(await Permission.notification.isGranted)) {
      log('Notification permission not granted, showing dialog to request it');
      return;
    }

    final now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      state.alarmTime.hour,
      state.alarmTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      log('Alarm time is in the past, scheduling for tomorrow: $scheduledDate');
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    log('Scheduling alarm for: $tzScheduledDate');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      playSound: true,
      enableLights: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'alarm_sound.mp3',
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    bool canUseExactAlarms = false;
    try {
      final permissionStatus = await Permission.scheduleExactAlarm.status;
      canUseExactAlarms = permissionStatus.isGranted;
      log('Can use exact alarms: $canUseExactAlarms');
    } catch (e) {
      log('scheduleExactAlarm permission check failed: $e');
      canUseExactAlarms = false;
    }

    try {
      if (canUseExactAlarms) {
        await notifications.zonedSchedule(
          1,
          'Time to wake up!',
          'Your ${state.duration.inMinutes} minute morning ritual is waiting',
          tzScheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        log('Exact alarm successfully scheduled for $tzScheduledDate');
      } else {
        await notifications.zonedSchedule(
          1,
          'Time to wake up!',
          'Your ${state.duration.inMinutes} minute morning ritual is waiting',
          tzScheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        log('Inexact alarm scheduled for $tzScheduledDate');
      }
    } catch (e) {
      log('Error scheduling alarm: $e');

      try {
        await notifications.zonedSchedule(
          1,
          'Time to wake up!',
          'Your ${state.duration.inMinutes} minute morning ritual is waiting',
          tzScheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        log('Fallback inexact alarm scheduled for $tzScheduledDate');
      } catch (e2) {
        log('Could not schedule fallback inexact alarm: $e2');
      }
    }
  }

  void toggleAlarm() {
    log('Toggling alarm from ${state.isAlarmSet} to ${!state.isAlarmSet}');
    state = state.copyWith(isAlarmSet: !state.isAlarmSet);
    if (state.isAlarmSet) {
      _scheduleAlarm();
    } else {
      notifications.cancelAll();
      log('Alarm cancelled');
    }
  }

  void setAlarmTime(TimeOfDay time) {
    log('Setting alarm time to $time');
    state = state.copyWith(
      alarmTime: time,
      isAlarmSet: true,
    );
    _scheduleAlarm();
  }
}
