import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/models/notification.dart';
import 'package:home_service_tasker/modules/notifications/bloc/notification_bloc.dart';
import 'package:home_service_tasker/modules/notifications/bloc/notification_event.dart';
import 'package:home_service_tasker/modules/notifications/repo/notifications_repo.dart';
import 'package:home_service_tasker/providers/log_provider.dart';
import 'package:home_service_tasker/routes/navigation_service.dart';
import 'package:home_service_tasker/theme/app_assets.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:home_service_tasker/theme/styles_text.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modules/notifications/bloc/notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final LogProvider logger = LogProvider(':::::NOTIFICATION-SCREEN:::::');
  final NavigationService _navigationService = NavigationService();
  late NotificationBloc _notificationBloc;
  late AnimationController _animationController;
  int taskerId = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationBloc = NotificationBloc(NotificationsRepo());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _initData();
  }

  Future<void> _initData() async {
    await loadTaskerId();
    if (mounted) {
      _fetchNotifications();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notificationBloc.close();
    super.dispose();
  }

  Future<void> loadTaskerId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('taskerId');

    if (id != null) {
      setState(() {
        taskerId = id;
        _isLoading = false;
      });
    }

    logger.log('TaskerId: $taskerId');
  }

  Future<void> _fetchNotifications() async {
    if (taskerId != 0) {
      _notificationBloc.add(NotificationFetch(taskerId));
    }
  }

  void _playTapAnimation(int notificationId) {
    HapticFeedback.lightImpact();
    _notificationBloc.add(NotificationMarkAsRead(notificationId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : BlocProvider.value(
              value: _notificationBloc,
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is NotificationLoaded) {
                    final notifications = state.notifications;
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_sharp,
                                size: 50, color: AppColors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'No Notifications!',
                              style: AppTextStyles.headline4,
                            )
                          ],
                        ),
                      );
                    } else {
                      return RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.white,
                        onRefresh: _fetchNotifications,
                        child: ListView.separated(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _buildNotificationItem(notification);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              height: 2,
                              color: AppColors.grey,
                              thickness: 1,
                            );
                          },
                        ),
                      );
                    }
                  }
                  return Center(
                    child: Text(
                      'Something went wrong!',
                      style: AppTextStyles.headline4.copyWith(
                        color: AppColors.alertFailed,
                      ),
                    ),
                  );
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
      onDismissed: (direction) {},
      child: Material(
        color: AppColors.white,
        child: InkWell(
          onTap: () => _playTapAnimation(notification.id),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.5),
          child: SizedBox(
            height: 140,
            child: Card(
                color: AppColors.white,
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _getNotificationIcon(notification.type),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: AppTextStyles.headline6.copyWith(
                                      color: AppColors.dark,
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification.message,
                              style: AppTextStyles.headline6.copyWith(
                                color: Color(0xFF8F92A1),
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dateFormat.format(notification.createdAt),
                              style: AppTextStyles.paragraph3,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'NEW_TASK':
        return Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Color(0xFFEEEEF7),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Image.asset(AppAssetsBackgrounds.notification),
        );
      case 'JOB_CANCELLED':
        return Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Color(0xFFF4E1E1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Image.asset(AppAssetsIcons.cancelIc),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.notifications, color: Colors.white),
        );
    }
  }
}
