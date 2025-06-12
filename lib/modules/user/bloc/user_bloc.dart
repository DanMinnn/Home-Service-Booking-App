import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/user/bloc/user_event.dart';
import 'package:home_service_admin/modules/user/bloc/user_state.dart';
import 'package:home_service_admin/modules/user/repo/user_repo.dart';

import '../../../models/paging_data.dart';
import '../models/user_response.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepo userRepo;

  UserBloc({required this.userRepo}) : super(UserInitial()) {
    on<CustomerFetchEvent>(_onCustomerFetch);
    on<TaskerFetchEvent>(_onTaskerFetchEvent);
  }

  Future<void> _onCustomerFetch(
      CustomerFetchEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final result = await userRepo.getAllTaskers(
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
      final result = await userRepo.getAllTaskers(
          pageNo: event.pageNo, pageSize: event.pageSize);

      final users = result['users'] as List<UserResponse>;
      final metadata = result['metadata'] as PaginationMetadata;

      emit(UserLoaded(users, metadata: metadata));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }
}
