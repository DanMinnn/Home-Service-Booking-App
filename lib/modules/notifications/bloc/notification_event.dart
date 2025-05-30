abstract class NotificationEvent {}

class NotificationFetch extends NotificationEvent {
  final int taskerId;

  NotificationFetch(this.taskerId);
}

class NotificationMarkAsRead extends NotificationEvent {
  final int notificationId;

  NotificationMarkAsRead(this.notificationId);
}
