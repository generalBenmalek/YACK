import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yack/data/repositories/isar_adapter.dart';
import 'package:yack/data/db/models/notification.dart';
import 'package:yack/logic/services/notification/contract_notification_handler.dart';

/// Service for handling push notifications from Firebase Cloud Messaging.
/// Parses notification data and saves to local Isar database.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Contract notification handler for real-time contract events
  final ContractNotificationHandler contractHandler = ContractNotificationHandler();

  /// Initialize FCM and set up handlers
  Future<void> initialize() async {
    // Request notification permissions
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize contract notification handler
    contractHandler.initialize();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Handle foreground messages - save to Isar and optionally show local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _saveNotificationToIsar(message);
    // TODO: Show local notification if needed
  }

  /// Handle when user taps on a notification
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    await _saveNotificationToIsar(message);
    // TODO: Navigate to relevant screen based on notification type
    _handleNotificationNavigation(message.data);
  }

  /// Parse and save notification to Isar database
  Future<AppNotification> _saveNotificationToIsar(RemoteMessage message) async {
    final notification = AppNotification.fromFcmData(
      message.data,
      title: message.notification?.title,
      body: message.notification?.body,
    );
    return await saveNotificationToIsar(notification);
  }

  /// Handle navigation based on notification type
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    final contractId = data['contractId']?.toString();
    final tempId = data['tempId']?.toString();

    switch (type) {
      case 'contractJoin':
        // Navigate to temp contract / sign screen
        if (tempId != null) {
          // TODO: NavigationService.navigateToTempContract(tempId);
        }
        break;
      case 'contractSign':
        // Navigate to contract signing screen
        if (tempId != null) {
          // TODO: NavigationService.navigateToSignContract(tempId);
        }
        break;
      case 'contractAccept':
      case 'contractDispute':
        // Navigate to contract details
        if (contractId != null) {
          // TODO: NavigationService.navigateToContract(contractId);
        }
        break;
      case 'contractMessage':
      case 'contractMedia':
        // Navigate to contract chat/media screen
        if (contractId != null) {
          // TODO: NavigationService.navigateToContractChat(contractId);
        }
        break;
    }
  }

  /// Get FCM token for registration with backend
  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Save notification to Isar when app is in background
  final notification = AppNotification.fromFcmData(
    message.data,
    title: message.notification?.title,
    body: message.notification?.body,
  );
  await saveNotificationToIsar(notification);
}

