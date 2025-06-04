import '../models/chat_message_model.dart';

abstract class ChatEvent {}

class ChatInitialized extends ChatEvent {
  final String authToken;
  final int userId;
  final String userType;

  ChatInitialized(this.authToken, this.userId, this.userType);
}

class ChatConnectedEvent extends ChatEvent {}

class ChatDisconnected extends ChatEvent {}

class ChatRoomsLoadedEvent extends ChatEvent {
  final int taskerId;

  ChatRoomsLoadedEvent(this.taskerId);
}

class ChatRoomSelected extends ChatEvent {
  final int roomId;

  ChatRoomSelected(this.roomId);
}

class ChatMessagesLoadedEvent extends ChatEvent {
  final int roomId;
  final int page;
  final int size;

  ChatMessagesLoadedEvent(this.roomId, {this.page = 0, this.size = 50});
}

class ChatMessageSent extends ChatEvent {
  final int roomId;
  final String message;

  ChatMessageSent(this.roomId, this.message);
}

class ChatMessageReceived extends ChatEvent {
  final ChatMessageModel message;

  ChatMessageReceived(this.message);
}

class ChatMessagesMarkedAsRead extends ChatEvent {
  final int roomId;

  ChatMessagesMarkedAsRead(this.roomId);
}

class ChatTypingStarted extends ChatEvent {
  final int roomId;

  ChatTypingStarted(this.roomId);
}

class ChatTypingStopped extends ChatEvent {
  final int roomId;

  ChatTypingStopped(this.roomId);
}

class ChatTypingIndicatorReceived extends ChatEvent {
  final Map<String, dynamic> data;

  ChatTypingIndicatorReceived(this.data);
}

class ChatReadReceiptReceived extends ChatEvent {
  final Map<String, dynamic> data;

  ChatReadReceiptReceived(this.data);
}

class ChatUserOnlineStatusEvent extends ChatEvent {
  final Map<String, dynamic> data;

  ChatUserOnlineStatusEvent(this.data);
}

class ChatErrorEvent extends ChatEvent {
  final String message;

  ChatErrorEvent(this.message);
}
