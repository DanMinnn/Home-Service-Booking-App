import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/user/bloc/user_event.dart';
import 'package:home_service_admin/modules/user/bloc/user_state.dart';
import 'package:home_service_admin/modules/user/repo/user_repo.dart';

import '../../../models/paging_data.dart';
import '../models/user_response.dart';

enum UserType { customer, tasker }

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepo userRepo;
  UserType _currentUserType = UserType.customer;

  UserType get currentUserType => _currentUserType;

  UserBloc({required this.userRepo}) : super(UserInitial()) {
    on<CustomerFetchEvent>(_onCustomerFetch);
    on<TaskerFetchEvent>(_onTaskerFetchEvent);
    on<ChangePage>(_onChangePage);
    on<ChangeItemsPerPage>(_onChangeItemsPerPage);
    on<SetUserType>(_onSetUserType);
  }

  Future<void> _onCustomerFetch(
      CustomerFetchEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      _currentUserType = UserType.customer;
      final result = await userRepo.getAllCustomers(
          pageNo: event.pageNo, pageSize: event.pageSize);

      final users = result['users'] as List<UserResponse>;
      final metadata = result['metadata'] as PaginationMetadata;

      emit(UserLoaded(users, metadata: metadata));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  void _onTaskerFetchEvent(
      TaskerFetchEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      _currentUserType = UserType.tasker;
      final result = await userRepo.getAllTaskers(
          pageNo: event.pageNo, pageSize: event.pageSize);

      final users = result['users'] as List<UserResponse>;
      final metadata = result['metadata'] as PaginationMetadata;

      emit(UserLoaded(users, metadata: metadata));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  void _onSetUserType(SetUserType event, Emitter<UserState> emit) {
    _currentUserType = event.userType;
  }

  void _onChangePage(ChangePage event, Emitter<UserState> emit) {
    final currentState = state;
    int? pageSize = 10;

    if (currentState is UserLoaded) {
      pageSize = currentState.metadata?.pageSize;
    }

    if (_currentUserType == UserType.tasker) {
      add(TaskerFetchEvent(
        pageNo: event.page,
        pageSize: pageSize,
      ));
    } else {
      add(CustomerFetchEvent(
        pageNo: event.page,
        pageSize: pageSize,
      ));
    }
  }

  void _onChangeItemsPerPage(
      ChangeItemsPerPage event, Emitter<UserState> emit) {
    if (_currentUserType == UserType.tasker) {
      add(TaskerFetchEvent(
        pageNo: 0,
        pageSize: event.limit,
      ));
    } else {
      add(CustomerFetchEvent(
        pageNo: 0,
        pageSize: event.limit,
      ));
    }
  }
}
