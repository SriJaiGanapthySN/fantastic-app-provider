import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'habit_list_provider.dart';

final totalDurationProvider = Provider<int>((ref) {
  final habits = ref.watch(habitListProvider);
  return habits.fold<int>(
    0,
    (sum, habit) {
      final value = habit['completionTimeValue'];
      if (value is num) {
        return sum + value.toInt();
      }
      if (value is String) {
        return sum + (int.tryParse(value) ?? 0);
      }
      return sum;
    },
  );
});
