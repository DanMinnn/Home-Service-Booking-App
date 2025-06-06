import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/notification_model.dart';
import '../../../providers/api_provider.dart';
import '../../../providers/log_provider.dart';
import '../model/fcm_token_req.dart';

class NotificationsRepo {
  final LogProvider logger = LogProvider('::::NOTIFICATIONS-REPO::::');
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
        logger.log('Failed to register FCM token: ${response.data['message']}');
        return 'Failed to register FCM token: ${response.data['message']}';
      }
    } catch (e) {
      logger.log('Error registering FCM token: $e');
      return 'Error registering FCM token: $e';
    }
  }

  final String _notificationsKey = 'user_notifications';

  // Save notifications to local storage
  Future<void> _saveNotificationsLocally(
      List<NotificationModel> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, json.encode(notificationsJson));
    } catch (e) {
      logger.log('Error saving notifications locally: $e');
    }
  }

  // Get notifications from local storage
  Future<List<NotificationModel>> getLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString(_notificationsKey);

      if (notificationsString == null) return [];

      final List<dynamic> notificationsJson = json.decode(notificationsString);
      return notificationsJson
          .map((item) => NotificationModel.fromJson(item))
          .toList();
    } catch (e) {
      logger.log('Error retrieving local notifications: $e');
      return [];
    }
  }

  // Get notifications
  Future<List<NotificationModel>> getNotifications(int userId) async {
    try {
      final response = await _apiProvider.get(
        '/notifications/users/$userId',
      );
      if (response.data['status'] == 200) {
        final List<dynamic> data = response.data['data'];
        final notifications =
            data.map((item) => NotificationModel.fromJson(item)).toList();

        await _saveNotificationsLocally(notifications);
        return notifications;
      } else {
        logger
            .log('Failed to fetch notifications: ${response.data['message']}');
        return await getLocalNotifications();
      }
    } catch (e) {
      logger.log('Error fetching notifications: $e');
      return await getLocalNotifications();
    }
  }

  //mark as read
  Future<void> markAsReadNotification(int notificationId) async {
    try {
      await _apiProvider.put('/notifications/users/$notificationId/read');
    } catch (e) {
      logger.log('Failed to mark notification as read ${e.toString()}');
    }
  }

  //delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _apiProvider.delete('/notifications/delete/$notificationId');
    } catch (e) {
      logger.log('Failed to mark notification as read ${e.toString()}');
    }
  }
}
