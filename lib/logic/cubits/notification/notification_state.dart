import 'package:equatable/equatable.dart';
import 'package:yack/data/db/models/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationsLoaded extends NotificationState {
  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });
  final List<AppNotification> notifications;
  final int unreadCount;

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

