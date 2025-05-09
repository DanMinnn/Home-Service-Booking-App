import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/categories/bloc/service_package_state.dart';
import 'package:home_service/modules/categories/repo/services_repo.dart';

class ServicePackageCubit extends Cubit<ServicePackagesState> {
  final ServicesRepo _serviceRepository;

  ServicePackageCubit(this._serviceRepository)
      : super(ServicePackagesLoading());

  Future<void> fetchServicePackages(int serviceId) async {
    try {
      emit(ServicePackagesLoading());
      final servicePackages =
          await _serviceRepository.getServiceWithPackages(serviceId);
      emit(ServicePackagesLoaded(servicePackages: servicePackages));
    } catch (e) {
      emit(ServicePackagesError(error: e.toString()));
    }
  }
}
