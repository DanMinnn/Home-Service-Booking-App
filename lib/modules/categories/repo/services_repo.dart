import 'package:home_service/modules/categories/models/service_package.dart';
import 'package:home_service/modules/categories/models/tasker_service_response.dart';

import '../../../providers/api_provider.dart';
import '../../../providers/log_provider.dart';
import '../models/service_category.dart';

class ServicesRepo {
  LogProvider get logger => LogProvider('SERVICE-REPO:::');
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

  Future<List<ServicePackages>> getServiceWithPackages(int serviceId) async {
    try {
      final response = await _apiProvider.get(
        '/service/list-service-package/$serviceId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['servicePackages'] as List;
        final servicePackage = data
            .map((item) =>
                ServicePackages.fromJson(item as Map<String, dynamic>))
            .toList();

        return servicePackage;
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

  Future<List<TaskerServiceResponse>> getTaskerServices(int taskerId) async {
    try {
      final response = await _apiProvider.get(
        '/tasker/get-service-tasker/$taskerId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final taskerServices = data
            .map((item) =>
                TaskerServiceResponse.fromJson(item as Map<String, dynamic>))
            .toList();

        return taskerServices;
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
}
