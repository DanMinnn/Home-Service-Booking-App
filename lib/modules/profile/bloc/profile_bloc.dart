import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/profile/bloc/profile_event.dart';
import 'package:home_service_tasker/modules/profile/bloc/profile_state.dart';
import 'package:home_service_tasker/modules/profile/repo/tasker_repo.dart';

import '../../../providers/log_provider.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final TaskerRepo _taskerRepo;
  final LogProvider logger = const LogProvider(":::PROFILE-BLOC:::");

  ProfileBloc(this._taskerRepo) : super(ProfileStateInitial()) {
    on<ProfileEventUpdate>(_onUpdateProfile);
  }

  Future<void> _onUpdateProfile(
      ProfileEventUpdate event, Emitter<ProfileState> emit) async {
    emit(ProfileStateLoading());
    try {
      final message = await _taskerRepo.updateUserProfile(
          event.taskerId, event.updateTasker,
          imageFile: event.imageFile);
      emit(ProfileStateSuccess(message));
    } catch (e) {
      emit(ProfileStateError(e.toString()));
    }
  }
}
