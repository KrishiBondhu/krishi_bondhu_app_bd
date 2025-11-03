/// Chat message model for AI conversations
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
    );
  }
}
