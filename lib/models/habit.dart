class Habit {
  final String id;
  final String title;

  final String icon;
  bool isCompleted;

  Habit({
    required this.id,
    required this.title,
    required this.icon,
    this.isCompleted = false,
  });
}
