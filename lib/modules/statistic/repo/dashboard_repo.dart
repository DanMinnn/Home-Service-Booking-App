import 'dart:convert';

import 'package:home_service_admin/modules/statistic/models/dashboard_models.dart';
import 'package:home_service_admin/providers/api_provider.dart';
import 'package:home_service_admin/providers/log_provider.dart';

class DashboardRepo {
  final LogProvider logger = LogProvider('::::DASHBOARD-REPO::::');
  final _apiProvider = ApiProvider();

  Future<DashboardResponse> fetchDashboardData() async {
    try {
      final response = await _apiProvider.get('/dashboard/summary');
      logger.log('API Response: ${jsonEncode(response.data)}');

      if (response.data['status'] == 200) {
        final responseData = response.data['data'] ?? {};
        return DashboardResponse.fromJson({
          'status': response.data['status'] ?? 0,
          'message': response.data['message'] ?? '',
          'data': responseData,
        });
      } else {
        throw Exception(
            'Failed to fetch dashboard data: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e, stackTrace) {
      logger.log('Error fetching dashboard data: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
