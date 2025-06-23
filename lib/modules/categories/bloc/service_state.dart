import '../models/service_item.dart';
import '../models/tasker_service_response.dart';

abstract class ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ServiceItem> services;

  ServiceLoaded({required this.services});
}

class ServiceError extends ServiceState {
  final String error;

  ServiceError({required this.error});
}

class TaskerServiceLoaded extends ServiceState {
  final List<TaskerServiceResponse> taskerServices;

  TaskerServiceLoaded({required this.taskerServices});
}
