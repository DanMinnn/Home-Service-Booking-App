import 'package:dio/dio.dart';
import 'package:home_service/modules/authentication/models/signup_req.dart';
import 'package:home_service/providers/api_provider.dart';
import 'package:home_service/providers/log_provider.dart';

class SignupRepo {
  final apiProvider = ApiProvider();

  LogProvider get logger => const LogProvider('Signup Repo');
  final dio = Dio();
  Future<String> signupRequest(SignupReq signupReq) async {
    try {
      logger.log(
          "Sending POST request to /register/user/ with data: ${signupReq.toJson()}");
      final response = await apiProvider.post(
        '/register/user/',
        data: signupReq.toJson(),
        options: Options(
          method: 'POST',
          contentType: 'application/json',
        ),
      );
      logger.log("Response status: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['message'] ?? 'Signup successful';
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
