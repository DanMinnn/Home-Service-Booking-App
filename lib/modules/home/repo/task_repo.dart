import 'package:home_service_tasker/models/response_data.dart';
import 'package:home_service_tasker/modules/home/models/task.dart';
import 'package:home_service_tasker/providers/log_provider.dart';

import '../../../providers/api_provider.dart';
import '../../chat/model/chat_room_req.dart';

class TaskRepo {
  final LogProvider logger = const LogProvider(':::TASK-REPO:::');
  final _apiProvider = ApiProvider();

  //get new tasks
  Future<List<Task>> getAllTasksPending(List<int> serviceIds) async {
    try {
      final response = await _apiProvider.get(
        '/booking/all-task-for-tasker',
        queryParameters: {
          'serviceIds': serviceIds.join(','),
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data']['items'] as List;
        final tasks =
            data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();

        logger.log('TASK REPO: ${tasks.length}');
        return tasks;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log('Error fetching tasks: $e');
      rethrow;
    }
  }

  //Assign tasker to a task
  Future<ResponseData> taskerGetTask(int bookingId, int taskerId) async {
    try {
      ResponseData responseData = ResponseData(status: 0, message: '');
      final response = await _apiProvider
          .post('/booking/$bookingId/assign-tasker', queryParameters: {
        'taskerId': taskerId,
      });

      if (response.statusCode == 200) {
        if (response.data['status'] == 400) {
          return responseData = ResponseData(
            status: response.data['status'],
            message: 'The tasker needs at least 2 hours between jobs.',
          );
        }
        return responseData = ResponseData(
          status: response.data['status'],
          message: response.data['message'] ?? 'Task assigned successfully',
        );
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log('Error assign tasker: $e');
      rethrow;
    }
  }

  //Get task of a tasker
  Future<List<Task>> getTaskAssigned(int taskerId, String selectedDate) async {
    try {
      final response = await _apiProvider.get(
          '/booking/$taskerId/get-task-assigned-by-date',
          queryParameters: {
            'selectedDate': selectedDate,
          });
      if (response.statusCode == 200) {
        final data = response.data['data']['items'] as List;
        final tasks =
            data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();

        logger.log('TASK REPO: ${tasks.length}');
        return tasks;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log('Error fetching tasker tasks: $e');
      rethrow;
    }
  }

  //tasker cancel task
  Future<ResponseData> taskerCancelTask(int bookingId, String reason) async {
    try {
      ResponseData responseData = ResponseData(status: 0, message: '');
      final response = await _apiProvider.post(
          '/booking/$bookingId/cancel-booking-by-tasker',
          queryParameters: {
            'cancelReason': reason,
          });

      if (response.statusCode == 200) {
        if (response.data['status'] == 400) {
          return responseData = ResponseData(
            status: response.data['status'],
            message: 'Limit of 2 cancellations in 7 days.',
          );
        }
        return responseData = ResponseData(
          status: response.data['status'],
          message: response.data['message'] ?? 'Cancel task successfully',
        );
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log('Error assign tasker: $e');
      rethrow;
    }
  }

  //complete task
  Future<String> taskerCompleteTask(int bookingId) async {
    try {
      final response = await _apiProvider.put(
        '/booking/$bookingId/completed-booking',
      );
      if (response.data['status'] == 200) {
        return response.data['message'] ?? 'Task completed successfully';
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log('Error completing task: $e');
      rethrow;
    }
  }

  //create chat room to communicate with customer
  Future<ResponseData> createChatRoom(ChatRoomReq req) async {
    try {
      ResponseData responseData = ResponseData(status: 0, message: '');
      final response = await _apiProvider.post(
        '/chat/rooms/create',
        data: req.toJson(),
      );

      if (response.data['status'] == 201) {
        return responseData = ResponseData(
          status: response.data['status'],
          message: response.data['message'] ?? 'Chat room created successfully',
        );
      } else {
        return responseData = ResponseData(
          status: response.data['status'],
          message: response.data['message'] ?? 'Failed to create chat room',
        );
      }
    } catch (e) {
      logger.log('Error creating chat room: $e');
      rethrow;
    }
  }
}
