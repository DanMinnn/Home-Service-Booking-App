import 'package:home_service_tasker/models/tasker.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String message;

  LoginSuccess(this.message);
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}

class TaskerInfoLoaded extends LoginState {
  final Tasker tasker;

  TaskerInfoLoaded(this.tasker);
}
