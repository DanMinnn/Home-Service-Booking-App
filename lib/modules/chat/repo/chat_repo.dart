import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/api_provider.dart';
import '../../../providers/log_provider.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';

class ChatRepo {
  final LogProvider logger = LogProvider(':::::CHAT-REPO:::::');
  final ApiProvider _apiProvider = ApiProvider();

  String? _authToken;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('access_token');
      logger.log('Auth token found: ${_authToken != null}');
      if (_authToken == null) {
        throw Exception('Access token not found in SharedPreferences');
      }
    } catch (e) {
      logger.log('Error initializing ChatRepo: $e');
      throw Exception('Failed to initialize ChatRepo: $e');
    }
  }

  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      if (_authToken == null) {
        await initialize();
      }

      final response = await _apiProvider.get('/chat/user/',
          options: Options(
            headers: {
              'Authorization': 'Bearer $_authToken',
              'Content-Type': 'application/json',
            },
          ));

      logger.log('Chat rooms response status: ${response.data['status']}');
      logger.log('Response headers: ${response.headers}');

      if (response.data['status'] == 202) {
        final List<dynamic> roomsJson = response.data['data'];
        logger.log('Received ${roomsJson.length} chat rooms');
        return roomsJson.map((json) => ChatRoomModel.fromJson(json)).toList();
      } else {
        logger.log(
            'Failed to load chat rooms: ${response.data['message'] ?? "Unknown error"}');
        throw Exception(
            'Failed to load chat rooms: ${response.data['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      logger.log('Error fetching chat rooms: $e');
      rethrow;
    }
  }

  // Similar changes for getChatMessages
  Future<List<ChatMessageModel>> getChatMessages(int roomId,
      {int page = 0, int size = 50}) async {
    try {
      // Make sure we have a token before proceeding
      if (_authToken == null) {
        await initialize();
      }

      final response = await _apiProvider.get(
        '/chat/message/$roomId?page=$page&size=$size',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['status'] == 202) {
        final List<dynamic> messagesJson = response.data['data'];
        return messagesJson
            .map((json) => ChatMessageModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load chat messages');
      }
    } catch (e) {
      logger.log('Error fetch chat message: $e');
      rethrow;
    }
  }
}
