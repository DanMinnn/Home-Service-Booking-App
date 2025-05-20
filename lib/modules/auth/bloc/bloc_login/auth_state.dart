import 'package:home_service_tasker/models/tasker.dart';

abstract class AuthState {}

class LoginInitial extends AuthState {}

class LoginLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;

  AuthSuccess(this.message);
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);
}

class TaskerInfoLoaded extends AuthState {
  final Tasker tasker;

  TaskerInfoLoaded(this.tasker);
}
