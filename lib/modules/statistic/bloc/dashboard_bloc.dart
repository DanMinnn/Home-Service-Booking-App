import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/statistic/bloc/dashboard_event.dart';
import 'package:home_service_admin/modules/statistic/bloc/dashboard_state.dart';
import 'package:home_service_admin/modules/statistic/repo/dashboard_repo.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepo _dashboardRepo;

  DashboardBloc(this._dashboardRepo) : super(DashboardInitial()) {
    on<DashboardLoadEvent>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
      DashboardLoadEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final response = await _dashboardRepo.fetchDashboardData();
      emit(DashboardLoaded(response.data));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
