import '../model/chatbot_dto.dart';

abstract class ChatbotEvent {}

class ChatbotMessageSentEvent extends ChatbotEvent {
  final int userId;
  final String message;

  ChatbotMessageSentEvent(this.userId, this.message);
}

class ChatbotMessageReceivedEvent extends ChatbotEvent {
  final int userId;
  final String query;

  ChatbotMessageReceivedEvent(this.userId, this.query);
}

class ChatbotSaveConversationEvent extends ChatbotEvent {
  final ChatbotDTO chatbotReq;

  ChatbotSaveConversationEvent({required this.chatbotReq});
}

class ChatbotLoadHistoryEvent extends ChatbotEvent {
  final int userId;

  ChatbotLoadHistoryEvent(this.userId);
}
