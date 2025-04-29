class HabitList {
  final String imageAdd;
  final String text;

  HabitList({required this.imageAdd, required this.text});
}

List<HabitList> habitList = [
  HabitList(imageAdd: 'assets/images/login.jpg', text: "Breathe"),
  HabitList(imageAdd: 'assets/images/login.jpg', text: "Disconnect & Unplug"),
  HabitList(imageAdd: 'assets/images/login.jpg', text: "Exercise"),
  HabitList(imageAdd: 'assets/images/login.jpg', text: "Meditate"),
  HabitList(imageAdd: 'assets/images/login.jpg', text: "Practice Gratitude"),
  HabitList(imageAdd: 'assets/images/login.jpg', text: "Self-Affirmation"),
  HabitList(imageAdd: 'assets/images/login.jpg', text: "Write your Todo list"),
  HabitList(
      imageAdd: 'assets/images/login.jpg', text: "Prepare to be productive"),
];
