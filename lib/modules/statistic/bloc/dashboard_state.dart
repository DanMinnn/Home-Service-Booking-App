import 'package:home_service_admin/modules/statistic/models/dashboard_models.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData dashboardData;

  DashboardLoaded(this.dashboardData);
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}
