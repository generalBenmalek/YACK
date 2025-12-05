import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Utility class for checking the current platform.
class PlatformInfo {
  // Prevent instantiation
  PlatformInfo._();

  /// Returns true if the app is running on Web
  static bool get isWeb => kIsWeb;

  /// Returns true if the app is running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Returns true if the app is running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Returns true if the app is running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Returns true if the app is running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Returns true if the app is running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Returns true if the app is running on any desktop OS (Windows, macOS, Linux)
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// Returns true if the app is running on a PC (desktop OS)
  static bool get isPc => isDesktop;

  /// Returns a readable platform name
  static String get name {
    if (isWeb) return "Web";
    if (isAndroid) return "Android";
    if (isIOS) return "iOS";
    if (isWindows) return "Windows";
    if (isMacOS) return "macOS";
    if (isLinux) return "Linux";
    return "Unknown";
  }
}
