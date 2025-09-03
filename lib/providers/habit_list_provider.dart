import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/task_services.dart';

final habitListProvider =
    StateNotifierProvider<HabitListNotifier, List<Map<String, dynamic>>>((ref) {
  return HabitListNotifier();
});

class HabitListNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  HabitListNotifier() : super([]);

  final TaskServices _taskServices = TaskServices();

  Future<void> fetchHabits(String email) async {
    if (email.isEmpty) {
      state = [];
      return;
    }
    final habits = await _taskServices.getUserHabits(email);
    state = habits;
  }

  void setHabits(List<Map<String, dynamic>> habits) {
    state = habits;
  }
}
