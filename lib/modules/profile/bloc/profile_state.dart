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

/*
class ProfileStateUploadSuccess extends ProfileState {
  final String urlImage;

  const ProfileStateUploadSuccess(this.urlImage);
}
*/

class ProfileStateError extends ProfileState {
  final String error;

  const ProfileStateError(this.error);
}

class ProfileStateDeleteAccountSuccess extends ProfileState {
  final String message;
  const ProfileStateDeleteAccountSuccess(this.message);
}

class ProfileStateDeleteAccountError extends ProfileState {
  final String error;
  const ProfileStateDeleteAccountError(this.error);
}
