class HabitList {
  final String imageAdd;
  final String text;

  HabitList({required this.imageAdd, required this.text});
}

List<HabitList> habitList = [
  HabitList(imageAdd: 'assets/images/Habit/img.png', text: "Breathe"),
  HabitList(
      imageAdd: 'assets/images/Habit/img_1.png', text: "Disconnect & Unplug"),
  HabitList(imageAdd: 'assets/images/Habit/img_2.png', text: "Exercise"),
  HabitList(imageAdd: 'assets/images/Habit/img_3.png', text: "Meditate"),
  HabitList(
      imageAdd: 'assets/images/Habit/img_4.png', text: "Practice Gratitude"),
  HabitList(
      imageAdd: 'assets/images/Habit/img_5.png', text: "Self-Affirmation"),
  HabitList(
      imageAdd: 'assets/images/Habit/img_6.png', text: "Write your Todo list"),
  HabitList(
      imageAdd: 'assets/images/Habit/img_7.png',
      text: "Prepare to be productive"),
];
