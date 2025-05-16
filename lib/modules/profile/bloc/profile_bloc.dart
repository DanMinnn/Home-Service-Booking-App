import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/profile/bloc/profile_event.dart';
import 'package:home_service/modules/profile/bloc/profile_state.dart';
import 'package:home_service/modules/profile/repo/user_repo.dart';
import 'package:home_service/providers/log_provider.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepo _userRepo;
  final LogProvider logger = const LogProvider(":::PROFILE-BLOC:::");

  ProfileBloc(this._userRepo) : super(ProfileStateInitial()) {
    on<ProfileEventUpdate>(_onUpdateProfile);
    on<ProfileEventDeleteAccount>(_onDeleteAccount);
    //on<ProfileEventUploadImage>(_onUploadImage);
  }

  Future<void> _onUpdateProfile(
      ProfileEventUpdate event, Emitter<ProfileState> emit) async {
    emit(ProfileStateLoading());
    try {
      final message = await _userRepo.updateUserProfile(
          event.userId, event.updateUser,
          imageFile: event.imageFile);
      emit(ProfileStateSuccess(message));
    } catch (e) {
      emit(ProfileStateError(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
      ProfileEventDeleteAccount event, Emitter<ProfileState> emit) async {
    emit(ProfileStateLoading());
    try {
      final message = await _userRepo.deleteAccount(event.userId);
      emit(ProfileStateDeleteAccountSuccess(message));
    } catch (e) {
      emit(ProfileStateDeleteAccountError(e.toString()));
    }
  }

  /*Future<void> _onUploadImage(
      ProfileEventUploadImage event, Emitter<ProfileState> emit) async {
    emit(ProfileStateLoading());
    try {
      final imageUrl = await _userRepo.uploadImage(event.imagePath);
      logger.log("Image URL: $imageUrl");
      emit(ProfileStateUploadSuccess(imageUrl));
    } catch (e) {
      emit(ProfileStateError(e.toString()));
      logger.log("Image URL error: ${e.toString()}");
      rethrow;
    }
  }*/
}
