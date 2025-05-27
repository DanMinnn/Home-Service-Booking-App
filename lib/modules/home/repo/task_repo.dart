import 'package:home_service_tasker/models/response_data.dart';
import 'package:home_service_tasker/modules/home/models/task.dart';
import 'package:home_service_tasker/providers/log_provider.dart';

import '../../../providers/api_provider.dart';

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
}
