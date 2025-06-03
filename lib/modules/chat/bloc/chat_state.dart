import 'package:home_service_tasker/modules/chat/model/chat_message_model.dart';
import 'package:home_service_tasker/modules/chat/model/chat_room_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConnecting extends ChatState {}

class ChatConnected extends ChatState {
  final bool isConnected;

  ChatConnected(this.isConnected);
}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoomModel> rooms;

  ChatRoomsLoaded(this.rooms);
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

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
