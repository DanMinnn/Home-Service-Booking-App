import 'package:home_service_tasker/modules/auth/model/register_req.dart';

abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final RegisterReq req;

  RegisterSubmitted(this.req);
}
