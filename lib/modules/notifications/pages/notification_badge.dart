import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/notification_service.dart';
import '../../../themes/app_assets.dart';

class NotificationBadge extends StatefulWidget {
  const NotificationBadge({
    super.key,
  });

  @override
  NotificationBadgeState createState() => NotificationBadgeState();
}

class NotificationBadgeState extends State<NotificationBadge> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  int _userId = 0;

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
    final id = prefs.getInt('userId');

    if (id != null) {
      setState(() {
        _userId = id;
      });
    }
  }

  Future<void> _updateUnreadCount() async {
    final count = await _notificationService.getUnreadNotifications(_userId);
    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(child: Image.asset(AppAssetIcons.notification)),
        if (_unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
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
