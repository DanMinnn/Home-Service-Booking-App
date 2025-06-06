import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/chatbot/bloc/chatbot_event.dart';
import 'package:home_service/modules/chatbot/bloc/chatbot_state.dart';
import 'package:home_service/modules/chatbot/repo/chatbot_repo.dart';
import 'package:home_service/providers/log_provider.dart';

import '../model/chat_message.dart';
import '../model/chatbot_dto.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final ChatbotRepo _chatbotRepo;
  final LogProvider logger = LogProvider(':::::CHATBOT-BLOC:::::');
  final Map<int, List<ChatMessage>> _messagesCache = {};
  ChatbotBloc(this._chatbotRepo) : super(ChatbotInitial()) {
    on<ChatbotMessageSentEvent>(_onMessageSent);
    on<ChatbotMessageReceivedEvent>(_onMessageReceived);
    on<ChatbotSaveConversationEvent>(_onSaveConversation);
    on<ChatbotLoadHistoryEvent>(_onLoadHistory);
  }

  Future<void> _onMessageSent(
      ChatbotMessageSentEvent event, Emitter<ChatbotState> emit) async {
    emit(ChatbotLoading());
    try {
      final tempMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch * -1,
        message: event.message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      if (_messagesCache.containsKey(event.userId)) {
        _messagesCache[event.userId]!.add(tempMessage);
      } else {
        _messagesCache[event.userId] = [tempMessage];
      }
      emit(ChatbotMessagesLoaded(
          userId: event.userId, messages: _messagesCache[event.userId]!));

      add(ChatbotMessageReceivedEvent(event.userId, event.message));
    } catch (e) {
      emit(ChatbotError("Failed to send message: $e"));
    }
  }

  Future<void> _onMessageReceived(
      ChatbotMessageReceivedEvent event, Emitter<ChatbotState> emit) async {
    try {
      final response = await _chatbotRepo.sendMessage(event.query);

      final receivedMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        message: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      if (_messagesCache.containsKey(event.userId)) {
        _messagesCache[event.userId]!.add(receivedMessage);
      } else {
        _messagesCache[event.userId] = [receivedMessage];
      }
      emit(ChatbotMessagesLoaded(
          userId: event.userId, messages: _messagesCache[event.userId]!));

      add(ChatbotSaveConversationEvent(
        chatbotReq: ChatbotDTO(
          userId: event.userId,
          question: event.query,
          response: response,
        ),
      ));
    } catch (e) {
      emit(ChatbotError("Failed to receive message: $e"));
    }
  }

  Future<void> _onSaveConversation(
      ChatbotSaveConversationEvent event, Emitter<ChatbotState> emit) async {
    try {
      await _chatbotRepo.saveConversation(event.chatbotReq);
    } catch (e) {
      logger.log('Error saving conversation: $e');
    }
  }

  Future<void> _onLoadHistory(
      ChatbotLoadHistoryEvent event, Emitter<ChatbotState> emit) async {
    emit(ChatbotLoading());
    try {
      final conversations = await _chatbotRepo.getConversations(event.userId);

      final List<ChatMessage> messages = [];

      // Sort by sentAt timestamp (oldest first)
      conversations.sort((a, b) {
        final DateTime timeA =
            DateTime.parse(a.sentAt ?? DateTime.now().toString());
        final DateTime timeB =
            DateTime.parse(b.sentAt ?? DateTime.now().toString());
        return timeA.compareTo(timeB);
      });

      for (final conversation in conversations) {
        // user message
        if (conversation.question != null) {
          final DateTime timestamp = conversation.sentAt != null
              ? DateTime.parse(conversation.sentAt!)
              : DateTime.now();

          messages.add(ChatMessage(
            id: timestamp.millisecondsSinceEpoch * 1000,
            message: conversation.question!,
            isUser: true,
            timestamp: timestamp,
          ));
        }

        // bot message
        if (conversation.response != null) {
          final DateTime timestamp = conversation.sentAt != null
              ? DateTime.parse(conversation.sentAt!)
                  .add(Duration(milliseconds: 500))
              : DateTime.now().add(Duration(milliseconds: 500));

          messages.add(ChatMessage(
            id: timestamp.millisecondsSinceEpoch * 1000 + 1,
            message: conversation.response!,
            isUser: false,
            timestamp: timestamp,
          ));
        }
      }

      _messagesCache[event.userId] = messages;
      emit(ChatbotMessagesLoaded(userId: event.userId, messages: messages));
    } catch (e) {
      emit(ChatbotError("Failed to load conversation history: $e"));
    }
  }
}
