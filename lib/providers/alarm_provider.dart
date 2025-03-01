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
          isAlarmSet: true,
          alarmTime:
              TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().hour),
          duration: Duration(minutes: 11),
        )) {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    await _requestPermissions();

    if (state.isAlarmSet) {
      _scheduleAlarm();
    }
  }

  Future<void> _requestPermissions() async {
    var notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }

    await notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    try {
      var alarmStatus = await Permission.scheduleExactAlarm.status;
      if (!alarmStatus.isGranted) {
        final result = await Permission.scheduleExactAlarm.request();

        if (!result.isGranted) {
          log('Exact alarm permission denied');
        }
      }
    } catch (e) {
      log('scheduleExactAlarm permission not available: $e');
    }
  }

  Future<void> _scheduleAlarm() async {
    await notifications.cancelAll();

    if (!state.isAlarmSet) return;

    if (!(await Permission.notification.isGranted)) {
      log('Notification permission not granted');
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
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'alarm_sound.mp3',
      presentSound: true,
    );

    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    bool canUseExactAlarms = false;
    try {
      var permissionStatus = await Permission.scheduleExactAlarm.status;
      canUseExactAlarms = permissionStatus.isGranted;
    } catch (e) {
      log('scheduleExactAlarm permission not available: $e');

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
        log('Exact alarm scheduled for $tzScheduledDate');
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
    state = state.copyWith(isAlarmSet: !state.isAlarmSet);
    if (state.isAlarmSet) {
      _scheduleAlarm();
    } else {
      notifications.cancelAll();
    }
  }

  void setAlarmTime(TimeOfDay time) {
    state = state.copyWith(
      alarmTime: time,
      isAlarmSet: true,
    );
    _scheduleAlarm();
  }

  void setDuration(Duration duration) {
    state = state.copyWith(duration: duration);
    if (state.isAlarmSet) {
      _scheduleAlarm();
    }
  }
}

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmState>((ref) {
  return AlarmNotifier(FlutterLocalNotificationsPlugin());
});
