import 'package:home_service_tasker/modules/chat/model/chat_message_model.dart';

class ChatRoomModel {
  final int id;
  final int bookingId;
  final int userId;
  final int taskerId;
  final String? userName;
  final String? taskerName;
  final String? userProfile;
  final String? taskerProfile;
  final DateTime? lastMessageAt;
  final ChatMessageModel? lastMessage;

  ChatRoomModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.taskerId,
    this.userName,
    this.taskerName,
    this.userProfile,
    this.taskerProfile,
    this.lastMessageAt,
    this.lastMessage,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'],
      bookingId: json['bookingId'],
      userId: json['userId'],
      taskerId: json['taskerId'],
      userName: json['userName'],
      taskerName: json['taskerName'],
      userProfile: json['userProfile'],
      taskerProfile: json['taskerProfile'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      lastMessage: json['lastMessage'] != null
          ? ChatMessageModel.fromJson(json['lastMessage'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'taskerId': taskerId,
      'userName': userName,
      'taskerName': taskerName,
      'userProfile': userProfile,
      'taskerProfile': taskerProfile,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessage': lastMessage?.toJson(),
    };
  }
}
