abstract class ProfileState {
  const ProfileState();
}

class ProfileStateInitial extends ProfileState {
  const ProfileStateInitial();
}

class ProfileStateLoading extends ProfileState {
  const ProfileStateLoading();
}

class ProfileStateSuccess extends ProfileState {
  final String message;

  const ProfileStateSuccess(this.message);
}

class ProfileStateError extends ProfileState {
  final String error;

  const ProfileStateError(this.error);
}
