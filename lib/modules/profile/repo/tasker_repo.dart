import 'dart:io';

import 'package:dio/dio.dart';
import 'package:home_service_tasker/modules/profile/model/update_tasker.dart';

import '../../../providers/api_provider.dart';
import '../../../providers/log_provider.dart';

class TaskerRepo {
  LogProvider get logger => const LogProvider(":::TASKER-REPO:::");
  final _apiProvider = ApiProvider();

  Future<String> updateUserProfile(int taskerId, UpdateTasker updateTasker,
      {File? imageFile}) async {
    try {
      final formData = FormData.fromMap({
        'firstLastName': updateTasker.name,
        'address': updateTasker.address,
      });

      if (imageFile != null && imageFile.path.isNotEmpty) {
        formData.files.add(
          MapEntry(
              'profileImage', await MultipartFile.fromFile(imageFile.path)),
        );
      }

      final response = await _apiProvider.post(
        '/user/update-with-image/$taskerId',
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
}
