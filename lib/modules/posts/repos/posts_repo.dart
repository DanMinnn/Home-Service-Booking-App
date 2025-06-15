import 'package:home_service/providers/api_provider.dart';
import 'package:home_service/providers/log_provider.dart';

import '../models/post.dart';

class PostsRepo {
  LogProvider get logger => const LogProvider('::::POSTS-REPO::::');
  final _apiProvider = ApiProvider();

  Future<Map<String, dynamic>> getPosts(int userId,
      {String? status, int pageNo = 0, int pageSize = 10}) async {
    try {
      String endpoint = '/booking/$userId/booking-detail';

      // Build query parameters
      List<String> queryParams = [];
      if (status != null) {
        queryParams.add('status=$status');
      }
      queryParams.add('pageNo=$pageNo');
      queryParams.add('pageSize=$pageSize');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiProvider.get(endpoint);

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final data = responseData['items'] as List;
        final posts =
            data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();

        logger.log('POST REPO: ${posts.length}, Page: $pageNo/$pageSize');

        return {
          'posts': posts,
          'pageNo': responseData['pageNo'] ?? 0,
          'pageSize': responseData['pageSize'] ?? 10,
          'totalPage': responseData['totalPage'] ?? 1,
        };
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.log('Error fetching posts: ${e.toString()}');
      rethrow;
    }
  }
}
