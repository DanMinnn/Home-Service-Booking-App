import 'package:dio/dio.dart';
import 'package:home_service/modules/authentication/models/login_req.dart';
import 'package:home_service/modules/authentication/models/login_res.dart';
import 'package:home_service/providers/api_provider.dart';

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
        logger.log("Response status: ${response.statusCode}");
        final loginResponse = LoginResponse.fromJson(response.data);
        await saveTokens(loginResponse);
        logger.log("Response data: ${response.data}");
        return loginResponse;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log("Error: ${e.toString()}");
      rethrow;
    }
  }
}
