import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/authentication/blocs/login/login_event.dart';
import 'package:home_service/modules/authentication/blocs/login/login_state.dart';
import 'package:home_service/modules/authentication/repos/login_repo.dart';
import 'package:home_service/repo/user_repository.dart';

import '../../../../common/response_data.dart';
import '../../../../providers/log_provider.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo loginRepository;
  final UserRepository userRepository = UserRepository();
  LogProvider get logger => const LogProvider('LOGIN-BLOC');

  LoginBloc(this.loginRepository) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GetUserInfo>(_onGetUserInfo);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final req = event.loginReq;

      final loginResponse = await loginRepository.loginRequest(req);
      emit(LoginSuccess(loginResponse.message.toString()));
    } catch (e) {
      emit(LoginFailure("Error: ${e.toString()}"));
      logger.log("Error: ${e.toString()}");
    }
  }

  Future<void> _onGetUserInfo(
      GetUserInfo event, Emitter<LoginState> emit) async {
    try {
      final user = await loginRepository.getUserInfo(event.email);
      userRepository.setCurrentUser(user);
      emit(UserInfoLoaded(user));
      logger.log("User info loaded: ${user.name}");
    } catch (e) {
      logger.log("Error getting user info: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> _onForgotPassword(
      ForgotPasswordEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final response = await loginRepository.resetPassword(event.email);
      emit(LoginSuccess(response.toString()));
    } catch (e) {
      emit(LoginFailure("Error: ${e.toString()}"));
      logger.log("Error: ${e.toString()}");
    }
  }

  Future<void> _onChangePassword(
      ChangePasswordEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      ResponseData response;
      response = await loginRepository.changePassword(event.changePasswordReq);
      if (response.status == 200) {
        emit(LoginSuccess(response.message.toString()));
      } else if (response.status == 401) {
        emit(LoginFailure(response.message.toString()));
      } else {
        emit(LoginFailure(response.message.toString()));
      }
      //emit(AuthSuccess(response.toString()));
    } catch (e) {
      emit(LoginFailure(e.toString()));
      logger.log("Error: ${e.toString()}");
    }
  }
}
