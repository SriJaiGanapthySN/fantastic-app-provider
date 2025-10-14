class Skill {
  final String color;
  final int createdAt;
  final String goalId;
  final String iconUrl;
  final String iosIconUrl;
  final String objectId;
  final int position;
  final String skillTrackId;
  final String title;
  final int updatedAt;
  final int skillLevelCompleted; // Optional field
  final int totalLevels; // Optional field
  final bool isCompleted; // Optional field

  // Constructor
  Skill({
    required this.color,
    required this.createdAt,
    required this.goalId,
    required this.iconUrl,
    required this.iosIconUrl,
    required this.objectId,
    required this.position,
    required this.skillTrackId,
    required this.title,
    required this.updatedAt,
    this.skillLevelCompleted = 0, // Default value
    this.totalLevels = 0, // Default value
    this.isCompleted = false, // Default value
  });

  // Factory method to create Skill object from map
  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      color: map['color'] as String,
      createdAt: map['createdAt'] as int,
      goalId: map['goalId'] as String,
      iconUrl: map['iconUrl'] as String,
      iosIconUrl: map['iosIconUrl'] as String,
      objectId: map['objectId'] as String,
      position: map['position'] as int,
      skillTrackId: map['skillTrackId'] as String,
      title: map['title'] as String,
      updatedAt: map['updatedAt'] as int,
      skillLevelCompleted: map['skillLevelCompleted'] ?? 0, // Handles absence
      totalLevels: map['totalLevels'] ?? 0, // Handles absence
      isCompleted: map['isCompleted'] ?? false, // Handles absence
    );
  }

  // Convert Skill object to map
  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'createdAt': createdAt,
      'goalId': goalId,
      'iconUrl': iconUrl,
      'iosIconUrl': iosIconUrl,
      'objectId': objectId,
      'position': position,
      'skillTrackId': skillTrackId,
      'title': title,
      'updatedAt': updatedAt,
      'skillLevelCompleted': skillLevelCompleted, // Include new field
      'totalLevels': totalLevels, // Include new field
      'isCompleted': isCompleted, // Include new field
    };
  }
}