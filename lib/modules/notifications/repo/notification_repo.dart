import '../../../providers/api_provider.dart';
import '../../../providers/log_provider.dart';
import '../model/fcm_token_req.dart';

class NotificationsRepo {
  final LogProvider logProvider = LogProvider('::::NOTIFICATIONS-REPO::::');
  final _apiProvider = ApiProvider();

  Future<String> registerFCMToken(FCMTokenReq fcmTokenReq) async {
    try {
      final response = await _apiProvider.post(
        '/notifications/fcm/register',
        data: fcmTokenReq.toJson(),
      );
      if (response.data['status'] == 200) {
        return response.data['message'] ?? 'FCM token registered successfully';
      } else {
        logProvider
            .log('Failed to register FCM token: ${response.data['message']}');
        return 'Failed to register FCM token: ${response.data['message']}';
      }
    } catch (e) {
      logProvider.log('Error registering FCM token: $e');
      return 'Error registering FCM token: $e';
    }
  }
}
