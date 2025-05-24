import 'package:home_service_tasker/modules/services/model/tasker_service_req.dart';

abstract class ServiceEvent {}

class GetAllServiceEvent extends ServiceEvent {}

class AddTaskerServiceEvent extends ServiceEvent {
  final TaskerServiceReq req;

  AddTaskerServiceEvent({required this.req});
}
