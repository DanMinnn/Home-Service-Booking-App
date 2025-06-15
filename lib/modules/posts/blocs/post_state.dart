import '../models/post.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final int pageNo;
  final int pageSize;
  final int totalPage;

  PostLoaded(
      {required this.posts,
      this.pageNo = 0,
      this.pageSize = 10,
      this.totalPage = 1});
}

class PostError extends PostState {
  final String message;

  PostError({required this.message});
}
