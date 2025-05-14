import 'package:home_service/providers/api_provider.dart';
import 'package:home_service/providers/log_provider.dart';

import '../models/post.dart';

class PostsRepo {
  LogProvider get logger => const LogProvider('::::POSTS-REPO::::');
  final _apiProvider = ApiProvider();

  Future<List<Post>> getPosts(int userId, {String? status}) async {
    try {
      String endpoint = '/booking/$userId/booking-detail/';

      if (status != null) {
        endpoint += '?status=$status';
      }

      final response = await _apiProvider.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data['data']['items'] as List;
        final posts =
            data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();

        logger.log('POST REPO: ${posts.length}');
        return posts;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log('Error fetching posts: ${e.toString()}');
      rethrow;
    }
  }
}
