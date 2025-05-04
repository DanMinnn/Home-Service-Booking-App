import 'package:home_service/modules/authentication/models/login_req.dart';

abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final LoginReq loginReq;

  LoginSubmitted(this.loginReq);
}
