import 'package:home_service_tasker/modules/auth/model/login_req.dart';
import 'package:home_service_tasker/modules/auth/model/register_req.dart';

abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final LoginReq loginReq;

  LoginSubmitted(this.loginReq);
}

class RegisterSubmitted extends LoginEvent {
  final RegisterReq registerReq;

  RegisterSubmitted(this.registerReq);
}

class GetTaskerInfo extends LoginEvent {
  final String email;

  GetTaskerInfo(this.email);
}
