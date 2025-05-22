import 'dart:async';

import 'package:dio/dio.dart';
import 'package:home_service_tasker/models/response_data.dart';
import 'package:home_service_tasker/models/tasker.dart';
import 'package:home_service_tasker/modules/auth/model/login_res.dart';
import 'package:home_service_tasker/modules/auth/model/register_req.dart';
import 'package:home_service_tasker/providers/log_provider.dart';

import '../../../providers/api_provider.dart';
import '../../../utils/token_manager.dart';
import '../model/change_password_req.dart';
import '../model/login_req.dart';

class AuthRepo {
  final LogProvider logger = const LogProvider('LOGIN_REPO:::');
  final apiProvider = ApiProvider();

  Future<void> saveTokens(LoginResponse loginResponse) async {
    final tokenManager = TokenManager();
    tokenManager.accessToken = loginResponse.data?.accessToken;
    tokenManager.refreshToken = loginResponse.data?.refreshToken;
    await tokenManager.save();
  }

  // Login
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

  // Get Tasker Info
  Future<Tasker> getTaskerInfo(String email) async {
    try {
      final response = await apiProvider.get(
        '/tasker/profile/$email',
        options: Options(
          method: 'GET',
          contentType: 'application/json',
        ),
      );
      if (response.statusCode == 200) {
        logger.log("Response status: ${response.statusCode}");
        final data = response.data['data'];
        final tasker = Tasker.fromJson(data);
        logger.log("User info: ${tasker.name}");
        return tasker;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log("Error: ${e.toString()}");
      rethrow;
    }
  }

  // Register
  Future<String> register(RegisterReq req) async {
    try {
      final response = await apiProvider.post(
        '/register/tasker/',
        data: req.toJson(),
        options: Options(
          method: 'POST',
          contentType: 'application/json',
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['message'] ?? 'Signup successful';
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log("Error: ${e.toString()}");
      rethrow;
    }
  }

  // Reset Password
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

  //Change password
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
        }
        return responseData = ResponseData(
          status: response.data['status'],
          message: message,
        );
      }
    } catch (e) {
      logger.log("Error: ${e.toString()}");
      rethrow;
      /*on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return message = 'Token expired. Please enter your email again';
      } else if (e.response?.statusCode == 409) {
        return message = 'Invalid data';
      } else {
        logger.log("Error: ${e.toString()}");
        rethrow;
      }
    }*/
    }
  }
}
