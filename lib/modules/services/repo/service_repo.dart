import 'package:home_service_tasker/modules/services/model/tasker_service_req.dart';
import 'package:home_service_tasker/providers/log_provider.dart';

import '../../../providers/api_provider.dart';
import '../model/service_category.dart';

class ServiceRepo {
  final LogProvider logger = const LogProvider('SERVICE-REPO:::');
  final _apiProvider = ApiProvider();

  Future<List<ServiceCategory>> getServices() async {
    try {
      final response = await _apiProvider.get(
        '/service/list-service',
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['items'] as List;
        final serviceCategory = data
            .map((item) =>
                ServiceCategory.fromJson(item as Map<String, dynamic>))
            .toList();

        logger.log("Service Categories: $serviceCategory");
        return serviceCategory;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == 500) {
        throw Exception('Internal Server Error');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log("Error in services_repo: $e");
      rethrow;
    }
  }

  Future<void> addTaskerService(TaskerServiceReq req) async {
    try {
      final response = await _apiProvider.post(
        '/tasker/add-tasker-service/',
        data: req.toJson(),
      );

      if (response.data['status'] == 200) {
        logger.log("Service added successfully");
      } else {
        throw Exception('Failed to add service');
      }
    } catch (e) {
      logger.log("Error in adding service: $e");
      rethrow;
    }
  }
}
