import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/authentication/blocs/signup_event.dart';
import 'package:home_service/modules/authentication/blocs/signup_state.dart';
import 'package:home_service/providers/log_provider.dart';

import '../repos/signup_repo.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupRepo signupRepository;
  LogProvider get logger => const LogProvider('Signup Bloc');

  SignupBloc(this.signupRepository) : super(SignupInitial()) {
    on<SignupSubmitted>(_onSignupSubmitted);
  }

  Future<void> _onSignupSubmitted(
      SignupSubmitted event, Emitter<SignupState> emit) async {
    emit(SignupLoading());
    try {
      final req = event.req;

      final message = await signupRepository.signupRequest(req);
      emit(SignupSuccess(message));
    } catch (e) {
      emit(SignupFailure("Error: ${e.toString()}"));
      logger.log("Error: ${e.toString()}");
    }
  }
}
