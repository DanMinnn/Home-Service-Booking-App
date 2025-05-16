import 'dart:io';

import '../models/update_user.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileEventUpdate extends ProfileEvent {
  final int userId;
  final UpdateUser updateUser;
  final File imageFile;

  const ProfileEventUpdate(this.userId, this.updateUser, this.imageFile);
}

/*class ProfileEventUploadImage extends ProfileEvent {
  final File imagePath;

  const ProfileEventUploadImage(this.imagePath);
}*/
