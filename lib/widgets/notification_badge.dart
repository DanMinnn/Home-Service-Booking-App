import 'package:flutter/material.dart';
import 'package:home_service_tasker/modules/notifications/repo/notifications_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_assets.dart';

class NotificationBadge extends StatefulWidget {
  const NotificationBadge({
    super.key,
  });

  @override
  NotificationBadgeState createState() => NotificationBadgeState();
}

class NotificationBadgeState extends State<NotificationBadge> {
  final NotificationsRepo _notificationsRepo = NotificationsRepo();
  int _unreadCount = 0;
  int taskerId = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    await loadTaskerId();
    _updateUnreadCount();
  }

  Future<void> loadTaskerId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('taskerId');

    if (id != null) {
      setState(() {
        taskerId = id;
      });
    }
  }

  Future<void> _updateUnreadCount() async {
    final count = await _notificationsRepo.getUnreadNotifications(taskerId);
    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.asset(AppAssetsIcons.notificationIc),
        if (_unreadCount > 0)
          Positioned(
            right: 0,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: BoxConstraints(
                minHeight: 16,
                minWidth: 16,
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
