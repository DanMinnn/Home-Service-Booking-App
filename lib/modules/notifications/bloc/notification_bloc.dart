import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/notification_repo.dart';
import 'notification_event.dart';
import 'notification_state.dart';

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
          await _notificationsRepo.getNotifications(event.userId);
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
