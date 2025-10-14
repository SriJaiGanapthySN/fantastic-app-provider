class CoachingDetail {
  // final String id;
  final String animationLink;
  final String audioLink;
  final String backgroundLink;
  final String category;
  final String contentUrl;
  final DateTime createdAt;
  final double dayOfWeek;
  final String iconLink;
  final bool isCompleted;
   bool isDailyRoutine;
  final String name;
  final String objectID;
  final double position;
  final String recordId;
  final String subtitle;
  final String type;
  final DateTime updatedAt;

  CoachingDetail({
    // required this.id,
    required this.animationLink,
    required this.audioLink,
    required this.backgroundLink,
    required this.category,
    required this.contentUrl,
    required this.createdAt,
    required this.dayOfWeek,
    required this.iconLink,
    required this.isCompleted,
    required this.isDailyRoutine,
    required this.name,
    required this.objectID,
    required this.position,
    required this.recordId,
    required this.subtitle,
    required this.type,
    required this.updatedAt,
  });

  // Factory constructor to create an instance from Firebase data
  factory CoachingDetail.fromMap(Map<String, dynamic> map) {
    return CoachingDetail(
      // id: map['id']?['$oid'] ?? '',
      animationLink: map['animationLink'] ?? '',
      audioLink: map['audioLink'] ?? '',
      backgroundLink: map['backgroundLink'] ?? '',
      category: map['category'] ?? '',
      contentUrl: map['contentUrl'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      dayOfWeek: map['dayOfWeek'] ?? 0,
      iconLink: map['iconLink'] ?? '',
      isCompleted: map['iscompleted'] ?? false,
      isDailyRoutine: map['isdailyroutine'] ?? false,
      name: map['name'] ?? '',
      objectID: map['objectID'] ?? '',
      position: map['position'] ?? 0,
      recordId: map['record_id'] ?? '',
      subtitle: map['subtitle'] ?? '',
      type: map['type'] ?? '',
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Method to convert instance to a map (if needed for saving back to Firebase)
  Map<String, dynamic> toMap() {
    return {
      // 'id': {'$oid': id},
      'animationLink': animationLink,
      'audioLink': audioLink,
      'backgroundLink': backgroundLink,
      'category': category,
      'contentUrl': contentUrl,
      'createdAt': createdAt.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'iconLink': iconLink,
      'iscompleted': isCompleted,
      'isdailyroutine': isDailyRoutine,
      'name': name,
      'objectID': objectID,
      'position': position,
      'record_id': recordId,
      'subtitle': subtitle,
      'type': type,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}