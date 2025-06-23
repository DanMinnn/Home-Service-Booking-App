class ChatRoomReq {
  final int userId;
  final int taskerId;

  ChatRoomReq({
    required this.userId,
    required this.taskerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'taskerId': taskerId,
    };
  }
}
