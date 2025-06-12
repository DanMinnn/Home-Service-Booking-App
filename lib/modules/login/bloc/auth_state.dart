import 'package:home_service_admin/modules/user/models/user_response.dart';

abstract class AuthState {}

class LoginInitial extends AuthState {}

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final String message;

  LoginSuccess(this.message);
}

class LoginError extends AuthState {
  final String error;

  LoginError(this.error);
}

class AdminInfoLoaded extends AuthState {
  final UserResponse admin;

  AdminInfoLoaded(this.admin);
}
