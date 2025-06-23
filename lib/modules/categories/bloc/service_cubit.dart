import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/categories/bloc/service_state.dart';

import '../models/service_item.dart';
import '../repo/services_repo.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServicesRepo _serviceRepository;
  ServiceCubit(this._serviceRepository) : super(ServiceLoading());

  Future<void> fetchServices() async {
    try {
      emit(ServiceLoading());
      final serviceCategories = await _serviceRepository.getServices();

      List<ServiceItem> services = [];

      for (var category in serviceCategories) {
        if (category.serviceItems != null) {
          services.addAll(category.serviceItems!);
        }
      }
      emit(ServiceLoaded(services: services));
    } catch (e) {
      emit(ServiceError(error: e.toString()));
    }
  }

  Future<void> fetchTaskerServices(int taskerId) async {
    try {
      emit(ServiceLoading());
      final taskerServices =
          await _serviceRepository.getTaskerServices(taskerId);
      emit(TaskerServiceLoaded(taskerServices: taskerServices));
    } catch (e) {
      emit(ServiceError(error: e.toString()));
    }
  }
}
