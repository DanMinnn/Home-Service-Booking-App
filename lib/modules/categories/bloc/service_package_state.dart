import 'package:home_service/modules/categories/models/service_package.dart';

abstract class ServicePackagesState {}

class ServicePackagesLoading extends ServicePackagesState {}

class ServicePackagesLoaded extends ServicePackagesState {
  final List<ServicePackages> servicePackages;

  ServicePackagesLoaded({required this.servicePackages});
}

class ServicePackagesError extends ServicePackagesState {
  final String error;

  ServicePackagesError({required this.error});
}
