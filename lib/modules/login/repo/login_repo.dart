import 'package:dio/dio.dart';
import 'package:home_service_admin/modules/user/models/user_response.dart';

import '../../../providers/api_provider.dart';
import '../../../providers/log_provider.dart';
import '../../../utils/token_manager.dart';
import '../models/login_req.dart';
import '../models/login_res.dart';

class LoginRepo {
  final LogProvider logger = LogProvider("::::LOGIN-REPO::::");
  final _apiProvider = ApiProvider();

  Future<void> saveTokens(LoginResponse loginResponse) async {
    final tokenManager = TokenManager();
    tokenManager.accessToken = loginResponse.data?.accessToken;
    tokenManager.refreshToken = loginResponse.data?.refreshToken;
    await tokenManager.save();
  }

  // Login
  Future<LoginResponse> loginRequest(LoginReq loginReq) async {
    try {
      final response = await _apiProvider.post(
        '/auth/access-token',
        data: loginReq.toJson(),
        options: Options(
          method: 'POST',
          contentType: 'application/json',
        ),
      );
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await saveTokens(loginResponse);
        return loginResponse;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log("Error: ${e.toString()}");
      rethrow;
    }
  }

  Future<UserResponse> getAdminInfo(String email) async {
    try {
      final response = await _apiProvider.get(
        '/user/profile/$email',
        options: Options(
          method: 'GET',
          contentType: 'application/json',
        ),
      );
      if (response.statusCode == 200) {
        logger.log("Response status: ${response.statusCode}");
        final data = response.data['data'];
        final admin = UserResponse.fromJson(data);
        return admin;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log("Error: ${e.toString()}");
      rethrow;
    }
  }
}
