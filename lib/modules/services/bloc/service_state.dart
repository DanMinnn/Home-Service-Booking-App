import '../model/service_item.dart';

abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ServiceItem> services;

  ServiceLoaded({required this.services});
}

class LoadingSuccess extends ServiceState {
  final String message;

  LoadingSuccess(this.message);
}

class ServiceError extends ServiceState {
  final String error;

  ServiceError(this.error);
}
