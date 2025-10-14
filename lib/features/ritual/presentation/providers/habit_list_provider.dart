import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/task_services.dart';

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

  Future<void> toggleHabitCompletion(String habitId, String email) async {
    try {
      // Find the current habit to get its completion status
      final habit =
          state.firstWhere((h) => h['objectId'] == habitId, orElse: () => {});
      if (habit.isEmpty) return;

      final currentStatus = habit['isCompleted'] ?? false;
      final newStatus = !currentStatus;

      // Update on backend
      await _taskServices.updateHabitStatus(newStatus, habitId, email);

      // Refetch habits to update state
      await fetchHabits(email);
    } catch (e) {
      print('Error toggling habit completion: $e');
    }
  }
}
