import 'dart:convert';

import 'package:home_service/repo/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import '../providers/api_provider.dart';
import '../providers/log_provider.dart';

class NotificationService {
  final ApiProvider _apiProvider = ApiProvider();
  final LogProvider logger = LogProvider('::::NOTIFICATION-SERVICE::::');
  final UserRepository _userRepo = UserRepository();
  final String _notificationsKey = 'user_notifications';

  // Fetch notifications from API
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final user = _userRepo.currentUser;
      if (user == null) return [];

      final endpoint = '/notifications/users/${user.id}';

      final response = await _apiProvider.get(endpoint);
      final List<dynamic> data = response.data['message'];

      final notifications =
          data.map((item) => NotificationModel.fromJson(item)).toList();

      // Also save notifications locally
      await _saveNotificationsLocally(notifications);

      return notifications;
    } catch (e) {
      logger.log('Error fetching notifications: $e');
      // If API call fails, return locally saved notifications
      return await getLocalNotifications();
    }
  }

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

  // Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiProvider.get('/notifications/users/$notificationId/read');

      // Also update local copy
      final notifications = await getLocalNotifications();
      for (var i = 0; i < notifications.length; i++) {
        if (notifications[i].id == notificationId) {
          notifications[i] = notifications[i].copyWith(isRead: true);
          break;
        }
      }
      await _saveNotificationsLocally(notifications);
    } catch (e) {
      logger.log('Error marking notification as read: $e');
    }
  }

  //Get unread count
  Future<int> getUnreadNotifications(int userId) async {
    try {
      final response =
          await _apiProvider.get('/notifications/users/$userId/unread-count');
      if (response.data['status'] == 200) {
        return response.data['data'];
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      logger.log('Failed to mark notification as read ${e.toString()}');
      rethrow;
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final user = _userRepo.currentUser;
      if (user == null) return;

      final endpoint = '/notifications/users/${user.id}';

      await _apiProvider.delete(endpoint);

      // Clear local notifications
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
    } catch (e) {
      logger.log('Error clearing notifications: $e');
    }
  }
}
