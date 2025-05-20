import 'dart:async';

import 'package:dio/dio.dart';
import 'package:home_service_tasker/models/tasker.dart';
import 'package:home_service_tasker/modules/auth/model/login_res.dart';
import 'package:home_service_tasker/modules/auth/model/register_req.dart';
import 'package:home_service_tasker/providers/log_provider.dart';

import '../../../providers/api_provider.dart';
import '../../../utils/token_manager.dart';
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
}
