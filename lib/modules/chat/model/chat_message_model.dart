class ChatMessageModel {
  final int? id;
  final int roomId;
  final String senderType;
  final int senderId;
  final String messageText;
  final DateTime sentAt;
  final String? senderName;
  final String? senderImage;
  final bool read;

  ChatMessageModel({
    this.id,
    required this.roomId,
    required this.senderType,
    required this.senderId,
    required this.messageText,
    required this.sentAt,
    this.senderName,
    this.senderImage,
    this.read = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      roomId: json['roomId'],
      senderType: json['senderType'],
      senderId: json['senderId'],
      messageText: json['messageText'],
      sentAt: DateTime.parse(json['sentAt']),
      senderName: json['senderName'],
      senderImage: json['senderImage'],
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderType': senderType,
      'senderId': senderId,
      'messageText': messageText,
      'sentAt': sentAt.toIso8601String(),
      'senderName': senderName,
      'senderImage': senderImage,
      'read': read,
    };
  }

  ChatMessageModel copyWith({
    int? id,
    int? roomId,
    String? senderType,
    int? senderId,
    String? messageText,
    DateTime? sentAt,
    String? senderName,
    String? senderImage,
    bool? read,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      messageText: messageText ?? this.messageText,
      sentAt: sentAt ?? this.sentAt,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      read: read ?? this.read,
    );
  }
}
