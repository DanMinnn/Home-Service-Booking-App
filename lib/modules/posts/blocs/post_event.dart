abstract class PostEvent {}

class PostFetchEvent extends PostEvent {
  final int userId;
  final String? status;
  final int pageNo;
  final int pageSize;

  PostFetchEvent(
      {required this.userId, this.status, this.pageNo = 0, this.pageSize = 10});
}
