import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../providers/log_provider.dart';
import '../models/services.dart';
import '../repo/services_repo.dart';
import 'services_event.dart';
import 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final ServicesRepo servicesRepo;
  final LogProvider logger = LogProvider('::::SERVICES-BLOC::::');
  int _currentPage = 0;
  int _pageSize = 10;

  List<ServiceCategory> currentCategories = [];
  int currentPageNo = 0;
  int currentPageSize = 10;
  int currentTotalPage = 0;

  ServicesBloc({required this.servicesRepo}) : super(ServicesInitial()) {
    on<FetchServiceCategories>(_onFetchServiceCategories);
    on<FetchServiceDetail>(_onFetchServiceDetail);
    on<ChangePage>(_onChangePage);
    on<ChangeItemsPerPage>(_onChangeItemsPerPage);
  }

  Future<void> _onFetchServiceCategories(
    FetchServiceCategories event,
    Emitter<ServicesState> emit,
  ) async {
    try {
      emit(ServicesLoading());

      _currentPage = event.pageNo;
      _pageSize = event.pageSize;

      final response = await servicesRepo.fetchServiceCategories(
        pageNo: event.pageNo,
        pageSize: event.pageSize,
      );

      currentCategories = response.data.items;
      currentPageNo = response.data.pageNo;
      currentPageSize = response.data.pageSize;
      currentTotalPage = response.data.totalPage;

      emit(ServiceCategoriesLoaded(
        categories: response.data.items,
        pageNo: response.data.pageNo,
        pageSize: response.data.pageSize,
        totalPage: response.data.totalPage,
      ));
    } catch (e) {
      logger.log('Error loading service categories: $e');
      emit(ServicesLoadFailure('Failed to load service categories: $e'));
    }
  }

  Future<void> _onFetchServiceDetail(
    FetchServiceDetail event,
    Emitter<ServicesState> emit,
  ) async {
    try {
      emit(ServicesLoading());

      final response = await servicesRepo.fetchServiceDetail(event.serviceId);

      emit(ServiceDetailLoaded(
        serviceDetail: response.data,
        categories: currentCategories,
        pageNo: currentPageNo,
        pageSize: currentPageSize,
        totalPage: currentTotalPage,
      ));

      logger
          .log('Service detail loaded successfully for ID: ${event.serviceId}');
    } catch (e) {
      logger.log('Error loading service detail: $e');
      emit(ServicesLoadFailure('Failed to load service detail: $e'));
    }
  }

  Future<void> _onChangePage(
    ChangePage event,
    Emitter<ServicesState> emit,
  ) async {
    add(FetchServiceCategories(pageNo: event.pageNo, pageSize: _pageSize));
  }

  Future<void> _onChangeItemsPerPage(
    ChangeItemsPerPage event,
    Emitter<ServicesState> emit,
  ) async {
    add(FetchServiceCategories(pageNo: 0, pageSize: event.pageSize));
  }
}
