import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../common/widgets/stateless/basic_app_bar.dart';
import '../../../models/notification_model.dart';
import '../../../providers/log_provider.dart';
import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../repo/notification_repo.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final LogProvider logger = LogProvider(':::::NOTIFICATION-SCREEN:::::');
  final navigationService = NavigationService();
  late NotificationBloc _notificationBloc;
  late AnimationController _animationController;
  int userId = 0;
  final NotificationsRepo notificationsRepo = NotificationsRepo();

  @override
  void initState() {
    super.initState();
    _notificationBloc = NotificationBloc(NotificationsRepo());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    //_fetchNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      userId = args['userId'] as int;
      if (userId != 0) {
        _notificationBloc.add(NotificationFetch(userId));
      } else {
        logger.log('User ID is not provided or is zero.');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notificationBloc.close();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    if (userId != 0) {
      _notificationBloc.add(NotificationFetch(userId));
      logger.log('Fetching notifications for user ID: $userId');
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
      body: SafeArea(
        child: BlocProvider.value(
          value: _notificationBloc,
          child: Column(
            children: [
              BasicAppBar(
                isLeading: false,
                isTrailing: false,
                leading: GestureDetector(
                  onTap: () {
                    navigationService.goBack();
                  },
                  child: Image.asset(AppAssetIcons.arrowLeft),
                ),
                title: 'Notifications',
              ),
              Expanded(
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF386DF3)),
                      );
                    } else if (state is NotificationLoaded) {
                      final notifications = state.notifications;
                      if (notifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_sharp,
                                  size: 50, color: AppColors.darkBlue20),
                              const SizedBox(height: 12),
                              Text(
                                'No Notifications!',
                                style: AppTextStyles.bodyLargeSemiBold,
                              )
                            ],
                          ),
                        );
                      } else {
                        return RefreshIndicator(
                          color: AppColors.darkBlue,
                          backgroundColor: AppColors.white,
                          onRefresh: _fetchNotifications,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return _buildNotificationItem(notification);
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Divider(
                                  height: 2,
                                  color: AppColors.darkBlue20,
                                  thickness: 1,
                                ),
                              );
                            },
                          ),
                        );
                      }
                    }
                    return Center(
                      child: Text(
                        'Something went wrong!',
                        style: AppTextStyles.bodyLargeSemiBold.copyWith(
                          color: AppColors.redMedium,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
      onDismissed: (direction) async {
        await notificationsRepo.deleteNotification(notification.id);
      },
      child: Material(
        color: AppColors.white,
        child: InkWell(
          onTap: () => _playTapAnimation(notification.id),
          splashColor: AppColors.darkBlue.withValues(alpha: 0.1),
          highlightColor: AppColors.darkBlue.withValues(alpha: 0.5),
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
                                    style: AppTextStyles.bodyLargeSemiBold
                                        .copyWith(
                                      color: AppColors.black,
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
                                      color: AppColors.darkBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification.message,
                              style: AppTextStyles.bodyLargeSemiBold.copyWith(
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
                              style: AppTextStyles.bodyMediumRegular.copyWith(
                                color: AppColors.black,
                              ),
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
      case 'JOB_ACCEPTED':
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
          child: Image.asset(AppAssetIcons.cancelIc),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.notifications, color: Colors.white),
        );
    }
  }
}
