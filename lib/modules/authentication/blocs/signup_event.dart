import '../models/signup_req.dart';

abstract class SignupEvent {}

class SignupSubmitted extends SignupEvent {
  final SignupReq req;

  SignupSubmitted(this.req);
}
