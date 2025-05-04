import 'package:home_service/modules/authentication/models/login_data.dart';

class LoginResponse {
  final int? statusCode;
  final String? message;
  final LoginData? data;

  LoginResponse({
    this.statusCode,
    this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      statusCode: json['status'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
