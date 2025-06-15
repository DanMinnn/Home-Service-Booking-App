import 'package:home_service_admin/models/response_data.dart';
import 'package:home_service_admin/modules/services/models/req/category_req.dart';
import 'package:home_service_admin/modules/services/models/req/package_req.dart';
import 'package:home_service_admin/modules/services/models/req/service_req.dart';
import 'package:home_service_admin/modules/services/models/req/variant_req.dart';

import '../../../providers/api_provider.dart';
import '../../../providers/log_provider.dart';
import '../models/services.dart';

class ServicesRepo {
  final LogProvider logger = LogProvider('::::SERVICES-REPO::::');
  final _apiProvider = ApiProvider();

  Future<ServiceCategoryResponse> fetchServiceCategories({
    required int pageNo,
    required int pageSize,
  }) async {
    try {
      final response = await _apiProvider.get(
        '/service/list-service',
        queryParameters: {
          'pageNo': pageNo,
          'pageSize': pageSize,
        },
      );

      logger.log('Service categories fetched successfully');
      return ServiceCategoryResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      logger.log('Error fetching service categories: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<ServiceDetailResponse> fetchServiceDetail(int serviceId) async {
    try {
      final response = await _apiProvider.get(
        '/service/list-service-package/$serviceId',
      );

      logger.log('Service detail fetched successfully for ID: $serviceId');
      return ServiceDetailResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      logger.log('Error fetching service detail: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  //=========== CATEGORY ===========//
  Future<ResponseData> addCategory(CategoryReq category) async {
    try {
      ResponseData responseData = ResponseData(
        status: 200,
        message: 'Category added successfully',
      );
      final response = await _apiProvider.post(
        '/service/category',
        data: category.toJson(),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 200) {
          responseData.status = response.data['status'] ?? 200;
          responseData.message =
              response.data['message'] ?? 'Category added successfully';
        } else {
          responseData.status = response.data['status'] ?? 400;
          responseData.message =
              response.data['message'] ?? 'Failed to add category';
        }
      } else {
        responseData.status = response.statusCode ?? 500;
        responseData.message = 'Failed to add category';
      }
      return responseData;
    } catch (e, stackTrace) {
      logger.log('Error adding service category: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateCategory(int categoryId, CategoryReq category) async {
    try {
      await _apiProvider.put(
        '/service/update/$categoryId',
        data: category.toJson(),
      );
    } catch (e, stackTrace) {
      logger.log('Error updating service category: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await _apiProvider.delete(
        '/service/delete/$categoryId',
      );
    } catch (e, stackTrace) {
      logger.log('Error deleting service category: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  //=========== SERVICE ===========//
  Future<ResponseData> addService(int categoryId, ServiceReq service) async {
    try {
      ResponseData responseData = ResponseData(
        status: 200,
        message: 'Service added successfully',
      );
      final response = await _apiProvider.post(
        '/service/add-service/$categoryId',
        data: service.toJson(),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 200) {
          responseData.status = response.data['status'] ?? 200;
          responseData.message =
              response.data['message'] ?? 'Service added successfully';
        } else {
          responseData.status = response.data['status'] ?? 400;
          responseData.message =
              response.data['message'] ?? 'Failed to add service';
        }
      } else {
        responseData.status = response.statusCode ?? 500;
        responseData.message = 'Failed to add service';
      }
      return responseData;
    } catch (e, stackTrace) {
      logger.log('Error adding service: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateService(int serviceId, ServiceReq service) async {
    try {
      await _apiProvider.put(
        '/service/update-service/$serviceId',
        data: service.toJson(),
      );
    } catch (e, stackTrace) {
      logger.log('Error updating service: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteService(int serviceId) async {
    try {
      await _apiProvider.delete(
        '/service/delete-service/$serviceId',
      );
    } catch (e, stackTrace) {
      logger.log('Error deleting service: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  //=========== PACKAGE ===========//
  Future<ResponseData> addPackage(int serviceId, PackageReq package) async {
    try {
      ResponseData responseData = ResponseData(
        status: 200,
        message: 'Package added successfully',
      );
      final response = await _apiProvider.post(
        '/service/add-package/$serviceId',
        data: package.toJson(),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 200) {
          responseData.status = response.data['status'] ?? 200;
          responseData.message =
              response.data['message'] ?? 'Package added successfully';
        } else {
          responseData.status = response.data['status'] ?? 400;
          responseData.message =
              response.data['message'] ?? 'Failed to add package';
        }
      } else {
        responseData.status = response.statusCode ?? 500;
        responseData.message = 'Failed to add package';
      }
      return responseData;
    } catch (e, stackTrace) {
      logger.log('Error adding package: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updatePackage(int packageId, PackageReq package) async {
    try {
      await _apiProvider.put(
        '/service/update-package/$packageId',
        data: package.toJson(),
      );
    } catch (e, stackTrace) {
      logger.log('Error updating package: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deletePackage(int packageId) async {
    try {
      await _apiProvider.delete(
        '/service/delete-package/$packageId',
      );
    } catch (e, stackTrace) {
      logger.log('Error deleting package: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  //=========== VARIANT ===========//
  Future<ResponseData> addVariant(int packageId, Variant variant) async {
    try {
      ResponseData responseData = ResponseData(
        status: 200,
        message: 'Variant added successfully',
      );
      final response = await _apiProvider.post(
        '/service/add-variant/$packageId',
        data: variant.toJson(),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 200) {
          responseData.status = response.data['status'] ?? 200;
          responseData.message =
              response.data['message'] ?? 'Variant added successfully';
        } else {
          responseData.status = response.data['status'] ?? 400;
          responseData.message =
              response.data['message'] ?? 'Failed to add variant';
        }
      } else {
        responseData.status = response.statusCode ?? 500;
        responseData.message = 'Failed to add variant';
      }
      return responseData;
    } catch (e, stackTrace) {
      logger.log('Error adding variant: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateVariant(int variantId, Variant variant) async {
    try {
      await _apiProvider.put(
        '/service/update-variant/$variantId',
        data: variant.toJson(),
      );
    } catch (e, stackTrace) {
      logger.log('Error updating variant: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteVariant(int variantId) async {
    try {
      await _apiProvider.delete(
        '/service/delete-variant/$variantId',
      );
    } catch (e, stackTrace) {
      logger.log('Error deleting variant: $e');
      logger.log('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
