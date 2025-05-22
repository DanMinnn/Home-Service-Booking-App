import 'package:dio/dio.dart';
import 'package:home_service/models/user.dart';
import 'package:home_service/modules/authentication/models/ChangePasswordReq.dart';
import 'package:home_service/modules/authentication/models/login_req.dart';
import 'package:home_service/modules/authentication/models/login_res.dart';
import 'package:home_service/providers/api_provider.dart';

import '../../../common/response_data.dart';
import '../../../providers/log_provider.dart';
import '../../../utils/token_manager.dart';

class LoginRepo {
  final apiProvider = ApiProvider();
  LogProvider get logger => const LogProvider('LOGIN-REPO');

  Future<void> saveTokens(LoginResponse loginResponse) async {
    final tokenManager = TokenManager();
    tokenManager.accessToken = loginResponse.data?.accessToken;
    tokenManager.refreshToken = loginResponse.data?.refreshToken;
    await tokenManager.save();
  }

  Future<LoginResponse> loginRequest(LoginReq loginReq) async {
    try {
      final response = await apiProvider.post(
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

  Future<User> getUserInfo(String email) async {
    try {
      final response = await apiProvider.get(
        '/user/profile/$email',
        options: Options(
          method: 'GET',
          contentType: 'application/json',
        ),
      );
      if (response.statusCode == 200) {
        logger.log("Response status: ${response.statusCode}");
        final data = response.data['data'];
        final user = User.fromJson(data);
        logger.log("User info: ${user.name}");
        return user;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log("Error: ${e.toString()}");
      rethrow;
    }
  }

  // Reset password
  Future<String> resetPassword(String email) async {
    try {
      final response = await apiProvider.post(
        '/auth/forgot-password',
        data: email,
        options: Options(
          method: 'POST',
          contentType: 'text/plain',
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['message'] ?? 'Password reset link sent';
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log("Error: ${e.toString()}");
      rethrow;
    }
  }

  // Change password
  Future<ResponseData> changePassword(ChangePasswordReq req) async {
    String message = '';
    ResponseData responseData = ResponseData(status: 0, message: '');
    try {
      final response = await apiProvider.post(
        '/auth/change-password',
        data: req.toJson(),
        options: Options(
          method: 'POST',
          contentType: 'application/json',
        ),
      );
      if (response.data['status'] == 200) {
        if (response.data['message'].toString() == 'PASSWORD_CHANGED_SUCCESS') {
          message = 'Password changed successfully';
        }
        return responseData = ResponseData(
          status: response.data['status'],
          message: message,
        );
      } else {
        if (response.data['status'] == 401) {
          if (response.data['message'] == 'TOKEN_EXPIRED') {
            message = 'Token expired. Please enter your email again';
          }
        } else if (response.data['status'] == 400) {
          if (response.data['message'] == 'USER_NOT_FOUND') {
            message = 'User not found';
          } else if (response.data['message'] == 'USER_INACTIVE') {
            message = 'User inactive';
          } else if (response.data['message'] == 'PASSWORD_MISMATCH') {
            message = 'Password mismatch';
          }
        } else {
          message = 'Server error';
        }
        return responseData = ResponseData(
          status: response.data['status'],
          message: message,
        );
      }
    } catch (e) {
      logger.log("Error: ${e.toString()}");
      rethrow;
    }
  }
}
