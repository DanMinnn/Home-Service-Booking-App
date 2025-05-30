import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/notifications/bloc/notification_event.dart';
import 'package:home_service_tasker/modules/notifications/bloc/notification_state.dart';
import 'package:home_service_tasker/modules/notifications/repo/notifications_repo.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationsRepo _notificationsRepo;

  NotificationBloc(this._notificationsRepo) : super(NotificationInitial()) {
    on<NotificationFetch>(_fetchNotifications);
    on<NotificationMarkAsRead>(_onMarkAsRead);
  }

  Future<void> _fetchNotifications(
      NotificationFetch event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications =
          await _notificationsRepo.getNotifications(event.taskerId);
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
      NotificationMarkAsRead event, Emitter<NotificationState> emit) async {
    try {
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications =
            currentState.notifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        // Emit updated list immediately for UI refresh
        emit(NotificationLoaded(updatedNotifications));

        await _notificationsRepo.markAsReadNotification(event.notificationId);
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
