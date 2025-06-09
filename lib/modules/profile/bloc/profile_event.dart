import 'dart:io';

import 'package:home_service_tasker/modules/profile/model/update_tasker.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileEventUpdate extends ProfileEvent {
  final int taskerId;
  final UpdateTasker updateTasker;
  final File imageFile;

  const ProfileEventUpdate(this.taskerId, this.updateTasker, this.imageFile);
}
