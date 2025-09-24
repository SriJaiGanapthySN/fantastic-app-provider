class ChatMessageData {
  final String id;
  final String text;
  final ChatMessageType type;
  final bool isUser;
  final bool isQuestion;
  final String? audioUrl;
  final DateTime timestamp;
  final bool hasAnimated; // Track if this message has already been animated
  final String? objectId; // For content cards
  final String? contentType; // For content cards (HABIT, JOURNEY, etc.)

  ChatMessageData({
    required this.id,
    required this.text,
    required this.type,
    required this.isUser,
    this.isQuestion = false,
    this.audioUrl,
    required this.timestamp,
    this.hasAnimated = false,
    this.objectId,
    this.contentType,
  });

  ChatMessageData copyWith({
    String? id,
    String? text,
    ChatMessageType? type,
    bool? isUser,
    bool? isQuestion,
    String? audioUrl,
    DateTime? timestamp,
    bool? hasAnimated,
    String? objectId,
    String? contentType,
  }) {
    return ChatMessageData(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      isUser: isUser ?? this.isUser,
      isQuestion: isQuestion ?? this.isQuestion,
      audioUrl: audioUrl ?? this.audioUrl,
      timestamp: timestamp ?? this.timestamp,
      hasAnimated: hasAnimated ?? this.hasAnimated,
      objectId: objectId ?? this.objectId,
      contentType: contentType ?? this.contentType,
    );
  }
}

enum ChatMessageType {
  userMessage,
  cardMessage,
  audioMessage,
  animatedObjectCard,
  contentCard,
}
