import 'package:home_service/modules/home/models/service_category.dart';

import '../../../providers/api_provider.dart';
import '../../../providers/log_provider.dart';

class ServicesRepo {
  LogProvider get logger => LogProvider('CATEGORIES-REPO:::');
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

  /*
  *   "status": 200,
    "message": "Service Category",
    "data": {
        "pageNo": 1,
        "pageSize": 10,
        "totalPage": 0,
        "items": [
            {
                "id": 1,
                "name": "Repair & Maintenance",
                "services": [
                    {
                        "id": 18,
                        "createdAt": "2025-05-05T22:15:10.116661",
                        "updatedAt": "2025-05-05T22:15:10.116661",
                        "name": "Plumber",
                        "description": null,
                        "icon": "plumber_ic.png",
                        "basePrice": 0,
                        "isActive": true
                    },
                    {
                        "id": 1,
                        "createdAt": "2025-04-15T10:12:07.581",
                        "updatedAt": "2025-04-15T10:12:07.581",
                        "name": "Car Repair",
                        "description": "",
                        "icon": "car_ic.png",
                        "basePrice": 0,
                        "isActive": true
                    },
                    {
                        "id": 3,
                        "createdAt": "2025-04-15T10:13:26.405",
                        "updatedAt": "2025-04-15T10:13:26.405",
                        "name": "AC Repair",
                        "description": "Vệ sinh điều hòa",
                        "icon": "repair_ac_ic.png",
                        "basePrice": 0,
                        "isActive": true
                    },*/
}
