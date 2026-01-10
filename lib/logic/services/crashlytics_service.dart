import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  static Future<void> initialize() async {
    FlutterError.onError = _crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(exception, stack, reason: reason, fatal: fatal);
  }

  static Future<void> log(String message) => _crashlytics.log(message);
  
  static Future<void> setUserIdentifier(String id) => _crashlytics.setUserIdentifier(id);
  
  static Future<void> setCustomKey(String key, dynamic value) => _crashlytics.setCustomKey(key, value);

}