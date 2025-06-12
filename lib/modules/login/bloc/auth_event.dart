import '../models/login_req.dart';

abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final LoginReq loginReq;

  LoginSubmitted(this.loginReq);
}

class GetAdminInfo extends AuthEvent {
  final String email;

  GetAdminInfo(this.email);
}
