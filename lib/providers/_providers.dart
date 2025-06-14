import 'package:fantastic_app_riverpod/main.dart';
import 'package:fantastic_app_riverpod/models/habit.dart';
import 'package:fantastic_app_riverpod/providers/date_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_provider.dart';
import 'video_provider.dart';
import 'alarm_provider.dart';

export 'habits_provider.dart';
export 'video_provider.dart';
export 'alarm_provider.dart';

final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>(
  (ref) => HabitsNotifier(),
);

final videoProvider = StateNotifierProvider<VideoNotifier, VideoState>(
  (ref) => VideoNotifier(),
);

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmState>((ref) {
  final notificationPlugin = ref.watch(notificationPluginProvider);
  return AlarmNotifier(notificationPlugin);
});

final dateProvider = StateNotifierProvider<DateState, DateTime>((ref) {
  return DateState();
});
