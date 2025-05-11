import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/authentication/blocs/login/login_event.dart';
import 'package:home_service/modules/authentication/blocs/login/login_state.dart';
import 'package:home_service/modules/authentication/repos/login_repo.dart';
import 'package:home_service/repo/user_repository.dart';

import '../../../../providers/log_provider.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo loginRepository;
  final UserRepository userRepository = UserRepository();
  LogProvider get logger => const LogProvider('LOGIN-BLOC');

  LoginBloc(this.loginRepository) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GetUserInfo>(_onGetUserInfo);
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
}
