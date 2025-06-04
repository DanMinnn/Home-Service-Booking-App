class ChatRoomReq {
  final int bookingId;
  final int userId;
  final int taskerId;

  ChatRoomReq({
    required this.bookingId,
    required this.userId,
    required this.taskerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'taskerId': taskerId,
    };
  }
}
