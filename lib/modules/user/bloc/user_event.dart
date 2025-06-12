import 'package:home_service_admin/modules/user/bloc/user_bloc.dart';

abstract class UserEvent {}

class CustomerFetchEvent extends UserEvent {
  final int? pageNo;
  final int? pageSize;

  CustomerFetchEvent({this.pageNo, this.pageSize});
}

class TaskerFetchEvent extends UserEvent {
  final int? pageNo;
  final int? pageSize;

  TaskerFetchEvent({this.pageNo, this.pageSize});
}

class ChangePage extends UserEvent {
  final int page;

  ChangePage(this.page);
}

class ChangeItemsPerPage extends UserEvent {
  final int limit;

  ChangeItemsPerPage(this.limit);
}

class SetUserType extends UserEvent {
  final UserType userType;

  SetUserType(this.userType);
}
