import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/data/repositories/isar_adapter.dart';

import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationInitial());

  /// Load all notifications from Isar
  Future<void> loadNotifications() async {
    emit(const NotificationLoading());
    try {
      final notifications = await getAllNotificationsFromIsar();
      final unreadCount = await getUnreadNotificationsCount();
      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(int id) async {
    try {
      await markNotificationAsRead(id);
      await loadNotifications(); // Refresh list
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await markAllNotificationsAsRead();
      await loadNotifications(); // Refresh list
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int id) async {
    try {
      await deleteNotificationFromIsar(id);
      await loadNotifications(); // Refresh list
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      await clearAllNotifications();
      await loadNotifications(); // Refresh list
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications();
  }
}

