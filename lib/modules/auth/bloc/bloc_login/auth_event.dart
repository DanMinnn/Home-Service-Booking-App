import 'package:home_service_tasker/modules/auth/model/login_req.dart';
import 'package:home_service_tasker/modules/auth/model/register_req.dart';

abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final LoginReq loginReq;

  LoginSubmitted(this.loginReq);
}

class RegisterSubmitted extends AuthEvent {
  final RegisterReq registerReq;

  RegisterSubmitted(this.registerReq);
}

class GetTaskerInfo extends AuthEvent {
  final String email;

  GetTaskerInfo(this.email);
}
