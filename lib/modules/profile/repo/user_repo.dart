import 'dart:io';

import 'package:dio/dio.dart';
import 'package:home_service/modules/profile/models/update_user.dart';
import 'package:home_service/providers/log_provider.dart';

import '../../../providers/api_provider.dart';

class UserRepo {
  LogProvider get logger => const LogProvider(":::USER-REPO:::");
  final _apiProvider = ApiProvider();

  Future<String> updateUserProfile(int userId, UpdateUser updateUser,
      {File? imageFile}) async {
    try {
      final formData = FormData.fromMap({
        'firstLastName': updateUser.name,
        'address': updateUser.address,
      });

      if (imageFile != null && imageFile.path.isNotEmpty) {
        formData.files.add(
          MapEntry(
              'profileImage', await MultipartFile.fromFile(imageFile.path)),
        );
      }

      final response = await _apiProvider.post(
        '/user/update-with-image/$userId',
        data: formData,
        options: Options(
          method: 'POST',
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        return response.data['message'];
      }
    } catch (e) {
      logger.log("Failed to update user profile: $e");
      rethrow;
    }
  }

  /*Future<String> uploadImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
    });

    try {
      final response = await _apiProvider.post(
        '/user/upload',
        data: formData,
        options: Options(
          method: 'POST',
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data']['url'];
      } else {
        return response.data['message'];
      }
    } catch (e) {
      logger.log("Failed to upload image: $e");
      rethrow;
    }
  }*/
}
