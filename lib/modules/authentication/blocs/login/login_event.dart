import 'package:home_service/modules/authentication/models/ChangePasswordReq.dart';
import 'package:home_service/modules/authentication/models/login_req.dart';

abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final LoginReq loginReq;

  LoginSubmitted(this.loginReq);
}

class ForgotPasswordEvent extends LoginEvent {
  final String email;

  ForgotPasswordEvent({required this.email});
}

class GetUserInfo extends LoginEvent {
  final String email;

  GetUserInfo(this.email);
}

class ChangePasswordEvent extends LoginEvent {
  final ChangePasswordReq changePasswordReq;

  ChangePasswordEvent({required this.changePasswordReq});
}
