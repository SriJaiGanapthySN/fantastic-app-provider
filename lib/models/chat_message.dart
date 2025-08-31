class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime createdAt;
  final String messageType;
  final bool saved;
  final List<dynamic> resources;
  final List<dynamic> buttons;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.createdAt,
    required this.messageType,
    this.saved = false,
    this.resources = const [],
    this.buttons = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      isUser: json['is_user'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      messageType: json['message_type'] ?? 'text',
      saved: json['saved'] ?? false,
      resources: json['resources'] ?? [],
      buttons: json['buttons'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'is_user': isUser,
      'created_at': createdAt.toIso8601String(),
      'message_type': messageType,
      'saved': saved,
      'resources': resources,
      'buttons': buttons,
    };
  }
}