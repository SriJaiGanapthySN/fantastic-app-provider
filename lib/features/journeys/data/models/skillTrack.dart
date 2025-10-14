class skillTrack {
  final String ctaColor;
  final String bigImageUrl;
  final String imageUrl;
  final bool includeInTotalProgress;
  final String type;
  final bool isReleased;
  final String color;
  final int skillLevelCount;
  final DateTime updatedAt;
  final String endTextBis;
  final String endText;
  final String topDecoImageUrl;
  final String chapterDescription;
  final String subtitle;
  final String infoText;
  final DateTime createdAt;
  final String title;
  final int skillCount;
  final String objectId;
  final int levelsCompleted; // Add the levelsCompleted field

  skillTrack({
    required this.ctaColor,
    required this.bigImageUrl,
    required this.imageUrl,
    required this.includeInTotalProgress,
    required this.type,
    required this.isReleased,
    required this.color,
    required this.skillLevelCount,
    required this.updatedAt,
    required this.endTextBis,
    required this.endText,
    required this.topDecoImageUrl,
    required this.chapterDescription,
    required this.subtitle,
    required this.infoText,
    required this.createdAt,
    required this.title,
    required this.skillCount,
    required this.objectId,
    this.levelsCompleted = 0, // Default to 0 if not provided
  });

  /// Factory constructor to create an instance from a map
  factory skillTrack.fromMap(Map<String, dynamic> map) {
    return skillTrack(
      ctaColor: map['ctaColor'] ?? '',
      bigImageUrl: map['bigImageUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      includeInTotalProgress: map['includeInTotalProgress'] ?? false,
      type: map['type'] ?? '',
      isReleased: map['isReleased'] ?? false,
      color: map['color'] ?? '',
      skillLevelCount: map['skillLevelCount'] ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      endTextBis: map['endTextBis'] ?? '',
      endText: map['endText'] ?? '',
      topDecoImageUrl: map['topDecoImageUrl'] ?? '',
      chapterDescription: map['chapterDescription'] ?? '',
      subtitle: map['subtitle'] ?? '',
      infoText: map['infoText'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      title: map['title'] ?? '',
      skillCount: map['skillCount'] ?? 0,
      objectId: map['objectId'] ?? '',
      levelsCompleted: map['levelsCompleted'] ?? 0, // Handle levelsCompleted
    );
  }

  /// Method to convert an instance to a map
  Map<String, dynamic> toMap() {
    return {
      'ctaColor': ctaColor,
      'bigImageUrl': bigImageUrl,
      'imageUrl': imageUrl,
      'includeInTotalProgress': includeInTotalProgress,
      'type': type,
      'isReleased': isReleased,
      'color': color,
      'skillLevelCount': skillLevelCount,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'endTextBis': endTextBis,
      'endText': endText,
      'topDecoImageUrl': topDecoImageUrl,
      'chapterDescription': chapterDescription,
      'subtitle': subtitle,
      'infoText': infoText,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'title': title,
      'skillCount': skillCount,
      'objectId': objectId,
      'levelsCompleted': levelsCompleted, // Add levelsCompleted
    };
  }
}