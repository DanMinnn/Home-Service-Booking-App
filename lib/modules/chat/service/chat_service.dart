import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../providers/log_provider.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final LogProvider logger = LogProvider(':::::CHAT-SERVICE:::::');
  StompClient? _stompClient;
  String? _accessToken;
  int? _userId;
  String? _senderType;
  String wsUrl = dotenv.env['WS_URL']!;

  // Stream controllers for real-time updates - late initialization for better control
  late StreamController<ChatMessageModel> _messageStreamController;
  late StreamController<Map<String, dynamic>> _typingStreamController;
  late StreamController<Map<String, dynamic>> _readReceiptStreamController;
  late StreamController<bool> _connectionStatusController;

  bool _isInitialized = false;
  bool _isDisposed = false;

  int? get userId => _userId;
  String? get senderType => _senderType;
  // Getters for streams
  Stream<ChatMessageModel> get messageStream => _messageStreamController.stream;

  Stream<Map<String, dynamic>> get typingStream =>
      _typingStreamController.stream;

  Stream<Map<String, dynamic>> get readReceiptStream =>
      _readReceiptStreamController.stream;

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  static final ChatService _instance = ChatService._internal();

  factory ChatService() => _instance;

  ChatService._internal();

  void initialize(String token, int userId, String senderType) {
    if (_isDisposed) {
      logger.log(
          'Reinitializing after disposal - creating new stream controllers');
      _resetStreamControllers();
    } else if (!_isInitialized) {
      logger.log('Initializing stream controllers for the first time');
      _resetStreamControllers();
    }

    _accessToken = token;
    _userId = userId;
    _senderType = senderType;
    _isInitialized = true;
    _isDisposed = false;

    logger.log('ChatService initialized with userId: $_userId');
  }

  void _resetStreamControllers() {
    // Create new stream controllers
    _messageStreamController = StreamController<ChatMessageModel>.broadcast();
    _typingStreamController =
        StreamController<Map<String, dynamic>>.broadcast();
    _readReceiptStreamController =
        StreamController<Map<String, dynamic>>.broadcast();
    _connectionStatusController = StreamController<bool>.broadcast();
  }

  Future<bool> connect() async {
    if (_accessToken == null || _userId == null) {
      logger.log('ChatService not initialized. Call initialize() first.');
      return false;
    }

    if (_stompClient != null && _stompClient!.connected) {
      logger.log('WebSocket already connected');
      return true;
    }

    if (_isDisposed) {
      logger.log('Cannot connect: ChatService was disposed');
      return false;
    }

    try {
      logger.log('Connecting to WebSocket with token $_accessToken');
      logger.log('WebSocket Base URL: $wsUrl');
      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          stompConnectHeaders: {
            'Authorization': 'Bearer $_accessToken',
          },
          webSocketConnectHeaders: {
            'ngrok-skip-browser-warning': 'true',
            'Authorization': 'Bearer $_accessToken',
          },
          heartbeatIncoming: const Duration(seconds: 20),
          heartbeatOutgoing: const Duration(seconds: 20),
        ),
      );
      _stompClient!.activate();
      return true;
    } catch (e) {
      logger.log('Error connecting to WebSocket: $e');
      return false;
    }
  }

  void _onConnect(StompFrame frame) {
    logger.log('Connected to WebSocket');

    // Safety check to avoid "Bad state: Cannot add new events after calling close"
    if (_isDisposed) {
      logger.log('Received connect event after disposal, ignoring');
      return;
    }

    if (_connectionStatusController.isClosed) {
      logger.log('Connection status controller is closed, cannot send event');
      return;
    }

    try {
      _connectionStatusController.add(true);

      String destination = '/queue/user.$_userId';
      logger.log('Subscribing to $destination');

      _stompClient!.subscribe(
        destination: destination,
        callback: _handleIncomingMessage,
      );

      // Subscribe to error queue
      _stompClient!.subscribe(
        destination: '/user/queue/errors',
        callback: _handleError,
      );
    } catch (e) {
      logger.log('Error in onConnect handler: $e');
    }
  }

  void _onDisconnect(StompFrame frame) {
    logger.log('Disconnected from WebSocket');

    if (_isDisposed || _connectionStatusController.isClosed) return;

    _connectionStatusController.add(false);
  }

  void _onStompError(StompFrame frame) {
    logger.log('STOMP Error: ${frame.body}');

    if (_isDisposed || _connectionStatusController.isClosed) return;

    _connectionStatusController.add(false);
  }

  void _onWebSocketError(dynamic error) {
    logger.log('WebSocket Error Details: $error');
    logger.log('Error Type: ${error.runtimeType}');

    if (error.toString().contains('401')) {
      logger.log('Authentication failed - token may be expired or invalid');
    }

    if (_isDisposed || _connectionStatusController.isClosed) return;
    _connectionStatusController.add(false);
  }

  void _handleIncomingMessage(StompFrame frame) {
    try {
      if (_isDisposed) return;

      final data = json.decode(frame.body!);

      if (data['type'] == 'typing' && !_typingStreamController.isClosed) {
        _typingStreamController.add(data);
      } else if ((data['type'] == 'messageRead' ||
              data['type'] == 'messagesRead') &&
          !_readReceiptStreamController.isClosed) {
        _readReceiptStreamController.add(data);
      } else if (!_messageStreamController.isClosed) {
        // Regular chat message
        final message = ChatMessageModel.fromJson(data);
        _messageStreamController.add(message);
      }
    } catch (e) {
      logger.log('Error parsing incoming message: $e');
    }
  }

  void _handleError(StompFrame frame) {
    try {
      final error = json.decode(frame.body!);
      logger.log('Chat Error: ${error['error']}');
    } catch (e) {
      logger.log('Error parsing error message: $e');
    }
  }

  void sendMessage(int roomId, String messageText) {
    if (_stompClient == null || !_stompClient!.connected) {
      logger.log('Not connected to WebSocket, cannot send message');
      return;
    }

    final message = {
      'roomId': roomId,
      'senderId': _userId,
      'senderType': _senderType,
      'messageText': messageText,
    };

    _stompClient!.send(
      destination: '/app/chat.sendMessage',
      body: json.encode(message),
    );
  }

  void markAsRead(int roomId) {
    if (_stompClient == null || !_stompClient!.connected) {
      logger.log('Not connected to WebSocket, cannot mark as read');
      return;
    }

    final payload = {'roomId': roomId};

    _stompClient!.send(
      destination: '/app/chat.markRead',
      body: json.encode(payload),
    );
  }

  void sendTypingIndicator(int roomId, bool isTyping) {
    if (_stompClient == null || !_stompClient!.connected) {
      return;
    }

    final payload = {
      'roomId': roomId,
      'isTyping': isTyping,
    };

    _stompClient!.send(
      destination: '/app/chat.typing',
      body: json.encode(payload),
    );
  }

  void disconnect() {
    if (_stompClient?.connected == true) {
      _stompClient?.deactivate();
    }
    _stompClient = null;

    if (_isDisposed || _connectionStatusController.isClosed) return;

    _connectionStatusController.add(false);
  }

  void dispose() {
    logger.log('Disposing ChatService');
    _isDisposed = true;
    disconnect();

    // Close all stream controllers safely
    try {
      if (!_messageStreamController.isClosed) _messageStreamController.close();
      if (!_typingStreamController.isClosed) _typingStreamController.close();
      if (!_readReceiptStreamController.isClosed)
        _readReceiptStreamController.close();
      if (!_connectionStatusController.isClosed)
        _connectionStatusController.close();
    } catch (e) {
      logger.log('Error closing stream controllers: $e');
    }
  }

  bool get isConnected => _stompClient?.connected ?? false;
}
