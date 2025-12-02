import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:yack/services/network/http_handler.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  // ---------------------------------------------------
  // INITIALIZE ALL LISTENERS
  // ---------------------------------------------------
  Future<void> initialize() async {
    // Request permissions (Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Init Android notification channel
    await _initNotificationChannel();

    // Listen: Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen: App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedFromNotification);

    // Handle app open from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onOpenedFromNotification(initialMessage);
    }

    // Handle FCM token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  // ---------------------------------------------------
  // NOTIFICATION CHANNEL SETUP
  // ---------------------------------------------------
  Future<void> _initNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "high_importance_channel",
      "High Importance Notifications",
      description: "YACK Notifications",
      importance: Importance.max,
      playSound: true,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap in foreground
      },
    );
  }

  // ---------------------------------------------------
  // FOREGROUND NOTIFICATION HANDLER
  // ---------------------------------------------------
  void _onForegroundMessage(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;

    _localNotif.show(
      notif.hashCode,
      notif.title,
      notif.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "high_importance_channel",
          "High Importance",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // NOTIFICATION OPEN HANDLER
  // ---------------------------------------------------
  void _onOpenedFromNotification(RemoteMessage message) {
    debugPrint("App opened from a notification: ${message.data}");

    // Example: if notification has contractId
    final contractId = message.data["contractId"];

    if (contractId != null) {
      // You can navigate to contract detail page
      // NavigationService.navigateTo("/contract/$contractId");
    }
  }

  // ---------------------------------------------------
  // TOKEN REFRESH HANDLER
  // ---------------------------------------------------
  Future<void> _onTokenRefresh(String newToken) async {
    debugPrint("FCM Token refreshed: $newToken");

    // Your HttpHandler automatically adds fcmToken when sending requests,
    // but we send one update to backend after refresh:
    await HttpHandler().post("/users/updateToken", body: {
      "fcmToken": newToken,
    });
  }

  // ---------------------------------------------------
  // PUBLIC: Get Token
  // ---------------------------------------------------
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
