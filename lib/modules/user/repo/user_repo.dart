import '../../../models/paging_data.dart';
import '../../../providers/api_provider.dart';
import '../../../providers/log_provider.dart';
import '../models/user_response.dart';

class UserRepo {
  final LogProvider logger = LogProvider("::::USER-REPO::::");
  final _apiProvider = ApiProvider();

  //get all customers
  Future<Map<String, Object>> getAllCustomers(
      {int? pageNo, int? pageSize}) async {
    try {
      final response =
          await _apiProvider.get('/user/list-users', queryParameters: {
        'pageNo': pageNo ?? 0,
        'pageSize': pageSize ?? 10,
      });
      if (response.data['status'] == 200) {
        final responseData = response.data['data'];
        final PaginationMetadata metadata =
            PaginationMetadata.fromJson(responseData);
        final users = responseData['items'] as List;
        final userList =
            users.map((user) => UserResponse.fromJson(user)).toList();

        return {
          'users': userList,
          'metadata': metadata,
        };
      }
      throw Exception("Failed to fetch customers: ${response.data['message']}");
    } catch (e) {
      logger.log("Error fetching customers: $e");
      rethrow;
    }
  }

  //get all taskers
  Future<Map<String, Object>> getAllTaskers(
      {int? pageNo, int? pageSize}) async {
    try {
      final response =
          await _apiProvider.get('/user/list-taskers', queryParameters: {
        'pageNo': pageNo ?? 0,
        'pageSize': pageSize ?? 10,
      });
      if (response.data['status'] == 200) {
        final responseData = response.data['data'];
        final PaginationMetadata metadata =
            PaginationMetadata.fromJson(responseData);
        final users = responseData['items'] as List;
        final userList =
            users.map((user) => UserResponse.fromJson(user)).toList();

        return {
          'users': userList,
          'metadata': metadata,
        };
      }
      throw Exception("Failed to fetch taskers: ${response.data['message']}");
    } catch (e) {
      logger.log("Error fetching taskers: $e");
      rethrow;
    }
  }
}
