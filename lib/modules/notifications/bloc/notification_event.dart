abstract class NotificationEvent {}

class NotificationFetch extends NotificationEvent {
  final int userId;

  NotificationFetch(this.userId);
}

class NotificationMarkAsRead extends NotificationEvent {
  final int notificationId;

  NotificationMarkAsRead(this.notificationId);
}
