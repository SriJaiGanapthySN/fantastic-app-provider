import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';

class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier()
      : super([
          Habit(
            id: '1',
            title: 'Drink Water',
            icon: 'assets/icons/water.svg',
          ),
          Habit(
            id: '2',
            title: 'Listen to Daily Coaching Message',
            icon: 'assets/icons/ear.svg',
          ),
          Habit(
            id: '3',
            title: 'I Feel Great Today!',
            icon: 'assets/icons/smily.svg',
          ),
          Habit(
            id: '4',
            title: 'Celebrate!',
            icon: 'assets/icons/party.svg',
          ),
          Habit(
            id: '5',
            title: 'Take Vitamins',
            icon: 'assets/icons/fruit.svg',
          ),
          Habit(
            id: '6',
            title: 'Take Your Medicine',
            icon: 'assets/icons/pill.svg',
          ),
          Habit(
            id: '7',
            title: 'Think About Your Purpose',
            icon: 'assets/icons/bulb.svg',
          ),
          Habit(
            id: '8',
            title: 'Eat More Fruits and Vegetables',
            icon: 'assets/icons/leaf.svg',
          ),
        ]);

  void toggleHabit(String id) {
    state = state.map((habit) {
      if (habit.id == id) {
        return Habit(
          id: habit.id,
          title: habit.title,
          icon: habit.icon,
          isCompleted: !habit.isCompleted,
        );
      }
      return habit;
    }).toList();
  }
}
