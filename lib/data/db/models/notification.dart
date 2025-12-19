import 'package:isar/isar.dart';

part 'notification.g.dart';

/// Notification types from the backend
enum NotificationType {
  contractJoin,
  contractSign,
  contractAccept,
  contractDispute,
  contractMessage,
  contractMedia,
  unknown,
}

@collection
class AppNotification {
  Id id = Isar.autoIncrement;

  late String title;
  late String body;

  /// Notification type discriminator for client routing
  @enumerated
  NotificationType type = NotificationType.unknown;

  late DateTime createdAt;

  /// Contract ID this notification refers to (if applicable)
  String? contractId;

  /// Temp contract ID for join notifications
  String? tempId;

  /// User ID who triggered the notification
  String? userId;

  /// Username (first name) of the user who triggered the notification
  String? username;

  /// Optional reason (for dispute notifications)
  String? reason;

  /// Media path (for media notifications)
  String? mediaPath;

  bool isRead = false;

  /// Default constructor required by Isar
  AppNotification();

  /// Create from FCM notification data payload
  static AppNotification fromFcmData(Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    final notification = AppNotification()
      ..title = title ?? data['title']?.toString() ?? ''
      ..body = body ?? data['body']?.toString() ?? ''
      ..createdAt = DateTime.now()
      ..contractId = data['contractId']?.toString()
      ..tempId = data['tempId']?.toString()
      ..userId = data['userId']?.toString()
      ..username = data['username']?.toString()
      ..reason = data['reason']?.toString()
      ..mediaPath = data['mediaPath']?.toString();

    // Parse notification type
    final typeStr = data['type']?.toString() ?? '';
    notification.type = _parseNotificationType(typeStr);

    return notification;
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'contractJoin':
        return NotificationType.contractJoin;
      case 'contractSign':
        return NotificationType.contractSign;
      case 'contractAccept':
        return NotificationType.contractAccept;
      case 'contractDispute':
        return NotificationType.contractDispute;
      case 'contractMessage':
        return NotificationType.contractMessage;
      case 'contractMedia':
        return NotificationType.contractMedia;
      default:
        return NotificationType.unknown;
    }
  }
}
