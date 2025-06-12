import 'package:home_service_admin/modules/user/models/user_response.dart';

import '../../../models/paging_data.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserResponse> users;
  final PaginationMetadata? metadata;

  UserLoaded(this.users, {this.metadata});
}

class UserError extends UserState {
  final String message;

  UserError({required this.message});
}
