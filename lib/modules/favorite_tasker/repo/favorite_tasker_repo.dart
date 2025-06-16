import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_service/providers/log_provider.dart';

import '../../../providers/api_provider.dart';
import '../model/tasker.dart';

class FavoriteTaskerRepo {
  final LogProvider logger = LogProvider(':::::FAVORITE-TASKER-REPO:::::');
  final _apiProvider = ApiProvider();

  //Remove background
  Future<Uint8List?> removeBg(String imageUrl) async {
    final dio = Dio();
    var apiKey = dotenv.env['REMOVE_BG_API_KEY'];

    try {
      final response = await dio.post<List<int>>(
        'https://api.remove.bg/v1.0/removebg',
        options: Options(
          headers: {'X-Api-Key': apiKey},
          responseType: ResponseType.bytes,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: FormData.fromMap({
          'image_url': imageUrl,
          'size': 'auto',
        }),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data!);
      } else {
        logger
            .log('Error remove bg: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      logger.log('Exception error remove bg: $e');
      return null;
    }
  }

  // Fetch favorite taskers for a user
  Future<void> addFavoriteTasker(int bookingId) async {
    try {
      await _apiProvider.post(
        '/user/add-favorite-tasker/$bookingId',
      );
    } catch (e) {
      logger.log('Exception error fetching favorite taskers: $e');
    }
  }

  Future<bool> removeFavoriteTasker(int fTaskerId) async {
    try {
      await _apiProvider.delete(
        '/user/delete-favorite-tasker/$fTaskerId',
      );
      return true;
    } catch (e) {
      logger.log('Exception error removing favorite taskers: $e');
      return false;
    }
  }

  Future<List<Tasker>> fetchFavoriteTaskers(int userId) async {
    try {
      final response = await _apiProvider.get(
        '/user/get-favorite-tasker/$userId',
      );
      if (response.statusCode == 200) {
        final data = response.data['data']['items'] as List;
        final taskers = data
            .map((e) => Tasker.fromJson(e as Map<String, dynamic>))
            .toList();
        return taskers;
      } else {
        logger.log(
            'Error fetching favorite taskers: ${response.statusCode} - ${response.data}');
        return [];
      }
    } catch (e) {
      logger.log('Exception error fetching favorite taskers: $e');
      return [];
    }
  }

  // Check if a tasker is in favorites
  Future<bool> isTaskerInFavorites(int userId, int taskerId) async {
    try {
      final favorites = await fetchFavoriteTaskers(userId);
      return favorites.any((tasker) => tasker.id == taskerId);
    } catch (e) {
      logger.log('Exception error in alternative check: $e');
      return false;
    }
  }

  //add or remove favorite tasker
  Future<bool> toggleFavoriteTasker(
      int userId, int taskerId, int bookingId) async {
    try {
      final isInFavorites = await isTaskerInFavorites(userId, taskerId);

      if (isInFavorites) {
        await removeFavoriteTasker(taskerId);
        return false;
      } else {
        await addFavoriteTasker(bookingId);
        return true;
      }
    } catch (e) {
      logger.log('Exception error toggling favorite tasker: $e');
      return false;
    }
  }
}
