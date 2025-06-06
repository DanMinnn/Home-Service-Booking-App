class ChatMessage {
  final int? id;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}
