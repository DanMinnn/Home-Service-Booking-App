import '../../../models/notification.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String error;

  NotificationError(this.error);
}
