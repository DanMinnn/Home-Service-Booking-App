abstract class PostEvent {}

class PostFetchEvent extends PostEvent {
  final int userId;
  final String? status;
  PostFetchEvent({required this.userId, this.status});
}
