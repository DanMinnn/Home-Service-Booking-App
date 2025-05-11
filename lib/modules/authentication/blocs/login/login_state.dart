import '../../../../models/user.dart';

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

class UserInfoLoaded extends LoginState {
  final User user;
  UserInfoLoaded(this.user);
}
