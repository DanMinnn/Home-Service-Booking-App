class MessageModel {
  final String id;
  final String text;
  final String time;
  final bool isMe;
  final String chatId;
  final String senderId;

  MessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    required this.chatId,
    required this.senderId,
  });
}
