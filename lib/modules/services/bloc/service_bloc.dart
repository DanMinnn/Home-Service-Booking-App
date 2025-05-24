import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/services/bloc/service_event.dart';
import 'package:home_service_tasker/modules/services/bloc/service_state.dart';
import 'package:home_service_tasker/modules/services/repo/service_repo.dart';

import '../model/service_item.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepo _serviceRepo;

  ServiceBloc(this._serviceRepo) : super(ServiceInitial()) {
    on<GetAllServiceEvent>(_onGetAllService);
    on<AddTaskerServiceEvent>(_addTaskerService);
  }

  Future<void> _onGetAllService(
      GetAllServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    try {
      final serviceCategories = await _serviceRepo.getServices();

      List<ServiceItem> services = [];

      for (var category in serviceCategories) {
        if (category.serviceItems != null) {
          services.addAll(category.serviceItems!);
        }
      }
      emit(ServiceLoaded(services: services));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  Future<void> _addTaskerService(
      AddTaskerServiceEvent event, Emitter<ServiceState> emit) async {
    try {
      await _serviceRepo.addTaskerService(event.req);
      emit(LoadingSuccess("Service added successfully"));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }
}
