import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConnecting extends ChatState {}

class ChatConnected extends ChatState {
  final bool isConnected;
  final List<ChatRoomModel> rooms;
  final int roomId;
  final List<ChatMessageModel> messages;

  ChatConnected(this.isConnected,
      {this.rooms = const [], this.roomId = 0, this.messages = const []});
}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoomModel> rooms;
  final int? roomId;
  final List<ChatMessageModel> messages;
  ChatRoomsLoaded(this.rooms, {this.roomId, this.messages = const []});
}

class ChatMessagesLoaded extends ChatState {
  final int roomId;
  final List<ChatMessageModel> messages;
  final bool hasReachedMax;

  ChatMessagesLoaded(this.roomId, this.messages, {this.hasReachedMax = false});
}

class ChatMessageSending extends ChatState {
  final int roomId;
  final String message;

  ChatMessageSending(this.roomId, this.message);
}

class ChatTypingState extends ChatState {
  final int roomId;
  final Map<int, bool> typingUsers;

  ChatTypingState(this.roomId, this.typingUsers);
}

class ChatOnlineStatusState extends ChatState {
  final Map<int, bool> onlineUsers;
  final int? roomId;
  final List<ChatMessageModel> messages;
  final List<ChatRoomModel> rooms;

  ChatOnlineStatusState(
    this.onlineUsers, {
    this.roomId,
    this.messages = const [],
    this.rooms = const [],
  });
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
