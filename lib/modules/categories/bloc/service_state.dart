import '../models/service_item.dart';

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
