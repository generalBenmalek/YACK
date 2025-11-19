import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// load only needed one
import 'languages/ar.dart' deferred as ar;
import 'languages/fr.dart' deferred as fr;
import 'languages/en.dart' deferred as en;


class TranslationHandler {

  static late Box _userBox;


  static const String defaultLanguageCode = 'en';
  static const List<String> hardCodedLanguages = ['en','ar','fr'];

  static String _currentLanguage = defaultLanguageCode;
  // static final ValueNotifier<String> _languageNotifier =
  //     ValueNotifier<String>(defaultLanguageCode);

  static Map<String, String> _currentMap = {};
  static Map<String, String> _fallBackMap = {};


  // static ValueNotifier<String> get languageNotifier => _languageNotifier;

  static Future<void> initialize(Box userBox) async {

    _userBox = userBox;
    final savedLanguage = userBox.get('language') as String?;
    final systemLanguage = PlatformDispatcher.instance.locale.languageCode;
    final fallbackLanguage =
    hardCodedLanguages.contains(systemLanguage) ? systemLanguage : defaultLanguageCode;


    _currentLanguage =
        savedLanguage != null && hardCodedLanguages.contains(savedLanguage)
            ? savedLanguage
            : fallbackLanguage;

    _currentMap = await resolveLanguage(_currentLanguage);
    _fallBackMap = _cachedEnglish ?? await resolveLanguage('en');

    await _userBox.put('language', _currentLanguage);
  }

  static Iterable<Locale> get supportedLocales =>
      hardCodedLanguages.map(Locale.new);

  static String get currentLanguage => _currentLanguage;

  static Locale get locale => Locale(_currentLanguage);

  static bool get isRTL => _currentLanguage == 'ar';

  static String get(String key) {
    final normalizedKey = key.trim().toLowerCase();

    // Use the preloaded map
    if (_currentMap.containsKey(normalizedKey)) {
      return _currentMap[normalizedKey]!;
    }

    // Fallback to English
    if (_fallBackMap.containsKey(normalizedKey)) {
      return _fallBackMap[normalizedKey]!;
    }

    return _fallBackMap['error_message'] ?? 'error';
  }

  static String resolve(String key, {Map<String, String>? params}) {
    String value = get(key);
    if (params != null) {
      params.forEach((placeholder, replacement) {
        value = value.replaceAll('{$placeholder}', replacement);
      });
    }
    return value;
  }

  static Future<void> changeLanguage(String languageCode) async {
    if (!hardCodedLanguages.contains(languageCode)) return;

    _currentLanguage = languageCode;

    _currentMap = await resolveLanguage(languageCode);

    await _userBox.put('language', languageCode);

    // Notify UI
    // _languageNotifier.value = languageCode;

  }


  static Map<String, String>? _cachedArabic;
  static Map<String, String>? _cachedFrench;
  static Map<String, String>? _cachedEnglish;


  static Future<Map<String, String>> resolveLanguage(String languageCode) async {
    switch (languageCode) {
      case 'ar':
        if (_cachedArabic != null) return _cachedArabic!;
        await ar.loadLibrary();
        _cachedArabic = ar.arabic;
        return _cachedArabic!;

      case 'fr':
        if (_cachedFrench != null) return _cachedFrench!;
        await fr.loadLibrary();
        _cachedFrench = fr.french;
        return _cachedFrench!;

      default:
        if (_cachedEnglish != null) return _cachedEnglish!;
        await en.loadLibrary();
        _cachedEnglish = en.english;
        return _cachedEnglish!;
    }
  }

}
