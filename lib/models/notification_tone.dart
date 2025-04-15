class NotificationTone {
  final String id;
  final String name;
  final String category;
  final String audioPath;
  final bool isSelected;

  NotificationTone({
    required this.id,
    required this.name,
    required this.category,
    required this.audioPath,
    this.isSelected = false,
  });

  factory NotificationTone.fromJson(Map<String, dynamic> json) {
    return NotificationTone(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      audioPath: json['audioPath'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'audioPath': audioPath,
      'isSelected': isSelected,
    };
  }

  NotificationTone copyWith({
    String? id,
    String? name,
    String? category,
    String? audioPath,
    bool? isSelected,
  }) {
    return NotificationTone(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      audioPath: audioPath ?? this.audioPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }
} 