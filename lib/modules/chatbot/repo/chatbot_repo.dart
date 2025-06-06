import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_service/modules/chatbot/model/chatbot_dto.dart';
import 'package:home_service/providers/api_provider.dart';

import '../../../providers/log_provider.dart';

class ChatbotRepo {
  final LogProvider logger = LogProvider(':::::CHATBOT-REPO:::::');
  final _dio = Dio();
  final _apiProvider = ApiProvider();

  ChatbotRepo() {
    _dio.options.baseUrl = dotenv.env['CHATBOT_API_URL']!;
    _dio.options.connectTimeout = const Duration(seconds: 50); // 5 seconds
    _dio.options.receiveTimeout = const Duration(seconds: 30); // 3 seconds
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _dio.post(
        '/chat',
        data: {'query': message},
      );
      logger.log('Message sent successfully: $message');
      if (response.statusCode != 200) {
        return Future.error(
          'Failed to send message: ${response.statusMessage}',
        );
      }
      return response.data['response'];
    } catch (e) {
      logger.log('Error sending message: $e');
      rethrow; // Propagate the error
    }
  }

  Future<bool> saveConversation(ChatbotDTO chatbotReq) async {
    try {
      final response = await _apiProvider.post(
        '/chatbot/save',
        data: chatbotReq.toJson(),
      );
      logger.log('Conversation saved successfully');
      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      logger.log('Error saving conversation: $e');
      return false;
    }
  }

  Future<List<ChatbotDTO>> getConversations(int userId) async {
    try {
      final response =
          await _apiProvider.get('/chatbot/$userId/chatbot-conversation');
      if (response.data['status'] == 202) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => ChatbotDTO.fromJson(e)).toList();
      } else {
        logger.log('Failed to fetch conversations: ${response.statusMessage}');
        return [];
      }
    } catch (e) {
      logger.log('Error fetching conversations: $e');
      return [];
    }
  }
}
