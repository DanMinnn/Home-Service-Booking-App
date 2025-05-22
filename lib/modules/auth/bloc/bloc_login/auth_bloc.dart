import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/models/response_data.dart';
import 'package:home_service_tasker/modules/auth/bloc/bloc_login/auth_event.dart';
import 'package:home_service_tasker/modules/auth/repo/auth_repo.dart';
import 'package:home_service_tasker/repo/tasker_repository.dart';

import '../../../../providers/log_provider.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo authRepo;
  final TaskerRepository taskerRepository = TaskerRepository();
  LogProvider get logger => const LogProvider('LOGIN-BLOC');
  AuthBloc(this.authRepo) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GetTaskerInfo>(_onGetTaskerInfo);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<ResetPasswordSubmitted>(_onResetPassword);
    on<ChangePasswordSubmitted>(_onChangePassword);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      final response = await authRepo.loginRequest(event.loginReq);
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
      final response = await authRepo.register(event.registerReq);
      emit(AuthSuccess(response.toString()));
    } catch (e) {
      emit(AuthFailure(e.toString()));
      logger.log("Error: ${e.toString()}");
    }
  }

  Future<void> _onGetTaskerInfo(
      GetTaskerInfo event, Emitter<AuthState> emit) async {
    try {
      final tasker = await authRepo.getTaskerInfo(event.email);
      taskerRepository.setCurrentTasker(tasker);
      emit(TaskerInfoLoaded(tasker));
      logger.log("Tasker info loaded: ${tasker.name}");
    } catch (e) {
      emit(AuthFailure(e.toString()));
      logger.log("Error getting tasker info: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> _onResetPassword(
      ResetPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      final response = await authRepo.resetPassword(event.email);
      emit(AuthSuccess(response.toString()));
    } catch (e) {
      emit(AuthFailure(e.toString()));
      logger.log("Error: ${e.toString()}");
    }
  }

  Future<void> _onChangePassword(
      ChangePasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      ResponseData response;
      response = await authRepo.changePassword(event.changePasswordReq);
      if (response.status == 200) {
        emit(AuthSuccess(response.message.toString()));
      } else if (response.status == 401) {
        emit(AuthFailure(response.message.toString()));
      } else {
        emit(AuthFailure(response.message.toString()));
      }
      //emit(AuthSuccess(response.toString()));
    } catch (e) {
      emit(AuthFailure(e.toString()));
      logger.log("Error: ${e.toString()}");
    }
  }
}
