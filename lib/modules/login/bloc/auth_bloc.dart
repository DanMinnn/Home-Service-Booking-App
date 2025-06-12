import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/login/repo/admin_storage.dart';
import 'package:home_service_admin/modules/login/repo/login_repo.dart';

import '../../../../providers/log_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginRepo authRepo;
  final AdminStorage adminStorage = AdminStorage();
  LogProvider get logger => const LogProvider('LOGIN-BLOC');
  AuthBloc(this.authRepo) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GetAdminInfo>(_onAdminInfoFetch);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      final response = await authRepo.loginRequest(event.loginReq);
      emit(LoginSuccess(response.message.toString()));
    } catch (e) {
      emit(LoginError(e.toString()));
      logger.log("Error: ${e.toString()}");
    }
  }

  Future<void> _onAdminInfoFetch(
      GetAdminInfo event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      final response = await authRepo.getAdminInfo(event.email);
      adminStorage.setCurrentAdmin(response);
      emit(AdminInfoLoaded(response));
    } catch (e) {
      emit(LoginError(e.toString()));
      logger.log("Error: ${e.toString()}");
    }
  }
}
