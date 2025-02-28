import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmState {
  final bool isAlarmSet;
  final String alarmTime;

  AlarmState({
    required this.isAlarmSet,
    required this.alarmTime,
  });

  AlarmState copyWith({
    bool? isAlarmSet,
    String? alarmTime,
  }) {
    return AlarmState(
      isAlarmSet: isAlarmSet ?? this.isAlarmSet,
      alarmTime: alarmTime ?? this.alarmTime,
    );
  }
}

class AlarmNotifier extends StateNotifier<AlarmState> {
  AlarmNotifier() : super(AlarmState(isAlarmSet: true, alarmTime: '9:00 AM'));

  void toggleAlarm() {
    state = state.copyWith(isAlarmSet: !state.isAlarmSet);
  }

  void setAlarmTime(String time) {
    state = state.copyWith(alarmTime: time);
  }
}
