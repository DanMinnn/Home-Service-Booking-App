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
