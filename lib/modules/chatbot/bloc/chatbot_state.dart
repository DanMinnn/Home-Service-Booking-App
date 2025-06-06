import 'package:home_service/modules/chatbot/model/chat_message.dart';

abstract class ChatbotState {}

class ChatbotInitial extends ChatbotState {}

class ChatbotLoading extends ChatbotState {}

class ChatbotMessagesLoaded extends ChatbotState {
  final int userId;
  final List<ChatMessage> messages;

  ChatbotMessagesLoaded({required this.userId, required this.messages});
}

class ChatBotMessageSentState extends ChatbotState {
  final int userId;
  final String message;
  ChatBotMessageSentState({
    required this.userId,
    required this.message,
  });
}

class ChatbotError extends ChatbotState {
  final String message;

  ChatbotError(this.message);
}
