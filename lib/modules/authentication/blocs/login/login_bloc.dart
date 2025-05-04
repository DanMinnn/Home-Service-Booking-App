import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/authentication/blocs/login/login_event.dart';
import 'package:home_service/modules/authentication/blocs/login/login_state.dart';
import 'package:home_service/modules/authentication/repos/login_repo.dart';

import '../../../../providers/log_provider.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo loginRepository;
  LogProvider get logger => const LogProvider('LOGIN-BLOC');

  LoginBloc(this.loginRepository) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
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
}
