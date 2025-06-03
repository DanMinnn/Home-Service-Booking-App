import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/chat/bloc/chat_event.dart';
import 'package:home_service/modules/chat/bloc/chat_state.dart';

import '../models/chat_message_model.dart';
import '../repo/chat_repo.dart';
import '../service/chat_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();
  final ChatRepo _chatRepo = ChatRepo();
  StreamSubscription<ChatMessageModel>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  StreamSubscription<Map<String, dynamic>>? _readReceiptSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  final Map<int, List<ChatMessageModel>> _messagesCache = {};
  final Map<int, bool> _typingUsers = {};
  int? _currentRoomId;
  bool get isConnected => _chatService.isConnected;
  ChatBloc() : super(ChatInitial()) {
    on<ChatInitialized>(_onChatInitialized);
    on<ChatConnectedEvent>(_onChatConnected);
    on<ChatDisconnected>(_onChatDisconnected);
    on<ChatRoomsLoadedEvent>(_onChatRoomsLoaded);
    on<ChatRoomSelected>(_onChatRoomSelected);
    on<ChatMessagesLoadedEvent>(_onChatMessagesLoaded);
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatMessageReceived>(_onChatMessageReceived);
    on<ChatMessagesMarkedAsRead>(_onChatMessagesMarkedAsRead);
    on<ChatTypingStarted>(_onChatTypingStarted);
    on<ChatTypingStopped>(_onChatTypingStopped);
    on<ChatTypingIndicatorReceived>(_onChatTypingIndicatorReceived);
    on<ChatReadReceiptReceived>(_onChatReadReceiptReceived);
  }

  Future<void> _onChatInitialized(
    ChatInitialized event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());

      await _messageSubscription?.cancel();
      await _typingSubscription?.cancel();
      await _readReceiptSubscription?.cancel();
      await _connectionSubscription?.cancel();

      //initialize service
      _chatService.initialize(event.authToken, event.userId, event.userType);

      //listen to stream
      _messageSubscription = _chatService.messageStream.listen(
        (message) => add(ChatMessageReceived(message)),
        onError: (error) => add(ChatErrorEvent('Message stream error: $error')),
      );

      _typingSubscription = _chatService.typingStream.listen(
        (data) => add(ChatTypingIndicatorReceived(data)),
        onError: (error) => add(ChatErrorEvent('Typing stream error: $error')),
      );

      _readReceiptSubscription = _chatService.readReceiptStream.listen(
        (data) => add(ChatReadReceiptReceived(data)),
        onError: (error) =>
            add(ChatErrorEvent('Read receipt stream error: $error')),
      );

      _connectionSubscription = _chatService.connectionStatusStream.listen(
        (isConnected) =>
            add(isConnected ? ChatConnectedEvent() : ChatDisconnected()),
        onError: (error) =>
            add(ChatErrorEvent('Connection stream error: $error')),
      );

      // Connect to WebSocket
      bool connected = await _chatService.connect();
      if (connected) {
        emit(ChatConnected(true));
      } else {
        emit(ChatError('Failed to connect to chat service'));
      }
    } catch (e) {
      emit(ChatError('Failed to initialize chat: ${e.toString()}'));
    }
  }

  Future<void> _onChatConnected(
    ChatConnectedEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatConnected(true));
  }

  Future<void> _onChatDisconnected(
    ChatDisconnected event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatConnected(false));
  }

  Future<void> _onChatRoomsLoaded(
    ChatRoomsLoadedEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      final rooms = await _chatRepo.getChatRooms();
      emit(ChatRoomsLoaded(rooms));
    } catch (e) {
      emit(ChatError('Failed to load chat rooms: ${e.toString()}'));
    }
  }

  Future<void> _onChatRoomSelected(
    ChatRoomSelected event,
    Emitter<ChatState> emit,
  ) async {
    _currentRoomId = event.roomId;

    // emit cache message first
    if (_messagesCache.containsKey(event.roomId)) {
      emit(ChatMessagesLoaded(event.roomId, _messagesCache[event.roomId]!));
    }

    // Then load fresh messages
    add(ChatMessagesLoadedEvent(event.roomId));
  }

  Future<void> _onChatMessagesLoaded(
    ChatMessagesLoadedEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messages = await _chatRepo.getChatMessages(
        event.roomId,
        page: event.page,
        size: event.size,
      );

      // Cache the messages
      if (event.page == 0) {
        _messagesCache[event.roomId] = messages;
      } else {
        _messagesCache[event.roomId] = [
          ...(_messagesCache[event.roomId] ?? []),
          ...messages,
        ];
      }

      final hasReachedMax = messages.length < event.size;
      emit(ChatMessagesLoaded(
        event.roomId,
        _messagesCache[event.roomId]!,
        hasReachedMax: hasReachedMax,
      ));

      // Mark messages as read
      _chatService.markAsRead(event.roomId);
    } catch (e) {
      emit(ChatError('Failed to load messages: ${e.toString()}'));
    }
  }

  Future<void> _onChatMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatMessageSending(event.roomId, event.message));
      _chatService.sendMessage(event.roomId, event.message);

      // Create a temporary optimistic message to show immediately in UI
      final tempMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch *
            -1, // Temporary negative ID to identify it
        roomId: event.roomId,
        senderId: _chatService.userId!,
        senderType: _chatService.senderType!,
        messageText: event.message,
        sentAt: DateTime.now(),
      );

      // Add this temporary message to the cache
      if (_messagesCache.containsKey(event.roomId)) {
        _messagesCache[event.roomId]!.add(tempMessage);
      } else {
        _messagesCache[event.roomId] = [tempMessage];
      }

      // Emit updated messages with the temporary message
      emit(ChatMessagesLoaded(
        event.roomId,
        _messagesCache[event.roomId]!,
      ));
    } catch (e) {
      emit(ChatError('Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _onChatMessageReceived(
    ChatMessageReceived event,
    Emitter<ChatState> emit,
  ) async {
    final message = event.message;
    final roomId = message.roomId;

    // Check if this is a real message (from WebSocket) or local one
    bool isRealMessage = message.id == null || message.id! > 0;

    if (isRealMessage) {
      // Add to cache or replace temp message if exists
      if (_messagesCache.containsKey(roomId)) {
        // Remove any temporary message with the same text (if this is the server response)
        _messagesCache[roomId]!.removeWhere((m) =>
            m.id != null &&
            m.id! < 0 &&
            m.messageText == message.messageText &&
            m.senderId == message.senderId);

        // Check if message already exists to avoid duplicates
        final messageExists = _messagesCache[roomId]!
            .any((m) => m.id != null && m.id == message.id);

        if (!messageExists) {
          _messagesCache[roomId]!.add(message);
        }
      } else {
        _messagesCache[roomId] = [message];
      }

      // If received message is for current room, mark it as read
      if (_currentRoomId == roomId) {
        _chatService.markAsRead(roomId);

        // Emit updated messages
        emit(ChatMessagesLoaded(
          roomId,
          _messagesCache[roomId]!,
        ));
      }
    }
  }

  Future<void> _onChatMessagesMarkedAsRead(
    ChatMessagesMarkedAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      _chatService.markAsRead(event.roomId);
    } catch (e) {
      emit(ChatError('Failed to mark messages as read: ${e.toString()}'));
    }
  }

  Future<void> _onChatTypingStarted(
    ChatTypingStarted event,
    Emitter<ChatState> emit,
  ) async {
    _chatService.sendTypingIndicator(event.roomId, true);
  }

  Future<void> _onChatTypingStopped(
    ChatTypingStopped event,
    Emitter<ChatState> emit,
  ) async {
    _chatService.sendTypingIndicator(event.roomId, false);
  }

  Future<void> _onChatTypingIndicatorReceived(
    ChatTypingIndicatorReceived event,
    Emitter<ChatState> emit,
  ) async {
    final data = event.data;
    final roomId = data['roomId'] as int;
    final userId = data['userId'] as int;
    final isTyping = data['isTyping'] as bool;

    if (roomId == _currentRoomId) {
      _typingUsers[userId] = isTyping;
      if (!isTyping) {
        _typingUsers.remove(userId);
      }

      emit(ChatTypingState(roomId, Map.from(_typingUsers)));
    }
  }

  Future<void> _onChatReadReceiptReceived(
    ChatReadReceiptReceived event,
    Emitter<ChatState> emit,
  ) async {
    final data = event.data;
    final roomId = data['roomId'] as int;

    // Update message read status in cache
    if (_messagesCache.containsKey(roomId)) {
      final messages = _messagesCache[roomId]!;
      final messageIds = data['messageIds'] as List<dynamic>?;

      if (messageIds != null) {
        for (int i = 0; i < messages.length; i++) {
          if (messageIds.contains(messages[i].id)) {
            messages[i] = messages[i].copyWith(read: true);
          }
        }
      }

      // Emit updated messages if it's the current room
      if (_currentRoomId == roomId) {
        emit(ChatMessagesLoaded(roomId, messages));
      }
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    _connectionSubscription?.cancel();
    _chatService.dispose();
    return super.close();
  }
}
