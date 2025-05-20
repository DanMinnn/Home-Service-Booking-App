import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/auth/bloc/bloc_login/auth_event.dart';
import 'package:home_service_tasker/modules/auth/repo/auth_repo.dart';
import 'package:home_service_tasker/repo/tasker_repository.dart';

import '../../../../providers/log_provider.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo loginRepo;
  final TaskerRepository taskerRepository = TaskerRepository();
  LogProvider get logger => const LogProvider('LOGIN-BLOC');
  AuthBloc(this.loginRepo) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GetTaskerInfo>(_onGetTaskerInfo);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      final response = await loginRepo.loginRequest(event.loginReq);
      emit(AuthSuccess(response.message.toString()));
    } catch (e) {
      emit(AuthFailure(e.toString()));
      logger.log("Error: ${e.toString()}");
    }
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      final response = await loginRepo.register(event.registerReq);
      emit(AuthSuccess(response.toString()));
    } catch (e) {
      emit(AuthFailure(e.toString()));
      logger.log("Error: ${e.toString()}");
    }
  }

  Future<void> _onGetTaskerInfo(
      GetTaskerInfo event, Emitter<AuthState> emit) async {
    try {
      final tasker = await loginRepo.getTaskerInfo(event.email);
      taskerRepository.setCurrentTasker(tasker);
      emit(TaskerInfoLoaded(tasker));
      logger.log("Tasker info loaded: ${tasker.name}");
    } catch (e) {
      emit(AuthFailure(e.toString()));
      logger.log("Error getting tasker info: ${e.toString()}");
      rethrow;
    }
  }
}
