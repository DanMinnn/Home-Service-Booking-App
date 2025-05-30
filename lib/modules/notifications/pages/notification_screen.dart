import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await _notificationService.fetchNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications: $e')),
      );
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      await _notificationService.markAsRead(notification.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(isRead: true);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark notification as read: $e')),
      );
    }
  }

  Future<void> _clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      setState(() {
        _notifications = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear notifications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearConfirmationDialog(),
              tooltip: 'Clear all notifications',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Dismissible(
      key: Key('notification_${notification.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Remove notification from list
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
        // TODO: Implement API call to delete notification
      },
      child: Card(
        elevation: notification.isRead ? 0 : 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead ? null : Colors.blue.shade50,
        child: ListTile(
          leading: _getNotificationIcon(notification.type),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(notification.createdAt),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification);
            }

            // Navigate based on notification type
            if (notification.type == 'new_job') {
              // Navigate to job details
            } else if (notification.type == 'job_accepted') {
              // Navigate to accepted job details
            }
            // Add more navigation logic as needed
          },
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'new_job':
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.work, color: Colors.white),
        );
      case 'job_accepted':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check_circle, color: Colors.white),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.notifications, color: Colors.white),
        );
    }
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content:
            const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              _clearAllNotifications();
              Navigator.of(context).pop();
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}
