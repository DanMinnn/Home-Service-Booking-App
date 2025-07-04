import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/posts/blocs/post_event.dart';
import 'package:home_service/modules/posts/blocs/post_state.dart';
import 'package:home_service/modules/posts/repos/posts_repo.dart';
import 'package:home_service/providers/log_provider.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostsRepo postsRepo;
  final LogProvider logger = const LogProvider('::::POST-BLOC::::');

  PostBloc(this.postsRepo) : super(PostInitial()) {
    on<PostFetchEvent>(_onPostFetch);
  }

  Future<void> _onPostFetch(
      PostFetchEvent event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final result = await postsRepo.getPosts(event.userId,
          status: event.status, pageNo: event.pageNo, pageSize: event.pageSize);

      emit(PostLoaded(
        posts: result['posts'],
        pageNo: result['pageNo'],
        pageSize: result['pageSize'],
        totalPage: result['totalPage'],
      ));

      logger.log(
          'Posts fetched successfully: ${result['posts'].length} posts, Page: ${result['pageNo']}/${result['totalPage']}');
    } catch (e) {
      emit(PostError(message: e.toString()));
      logger.log('Error fetching posts: ${e.toString()}');
    }
  }
}
