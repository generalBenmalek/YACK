import 'package:yack/logic/services/translation_handler.dart';

class Validator {
  /// Checks if a field is empty
  static String? required(String? value, {String? fieldKey}) {
    if (value == null || value.trim().isEmpty) {
      if (fieldKey == null) {
        return TranslationHandler.get('field_required_generic');
      }
      return TranslationHandler.resolve('field_required',
          params: {'field': TranslationHandler.get(fieldKey)});
    }
    return null;
  }

  /// Validates an email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationHandler.get('email_required');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return TranslationHandler.get('invalid_email');
    }
    return null;
  }

  /// Validates a strong password (min 8 chars, 1 uppercase, 1 lowercase, 1 number)
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return TranslationHandler.get('password_required');
    }
    if (value.length < minLength) {
      return TranslationHandler.resolve('password_min_length',
          params: {'count': '$minLength'});
    }
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'\d'));
    if (!hasUpper || !hasLower || !hasNumber) {
      return TranslationHandler.get('password_requirements');
    }
    return null;
  }

  /// Confirm password check
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return TranslationHandler.get('confirm_password_required');
    }
    if (value != original) {
      return TranslationHandler.get('passwords_do_not_match');
    }
    return null;
  }

  /// Validates minimum and maximum length
  static String? length(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return TranslationHandler.get('field_required_generic');
    }
    if (min != null && value.length < min) {
      return TranslationHandler.resolve('length_min', params: {'count': '$min'});
    }
    if (max != null && value.length > max) {
      return TranslationHandler.resolve('length_max', params: {'count': '$max'});
    }
    return null;
  }

  /// Validates a name (letters and spaces only)
  static String? name(String? value, {String fieldName = 'name'}) {
    if (value == null || value.trim().isEmpty) {
      return TranslationHandler.resolve('field_required',
          params: {'field': TranslationHandler.get(fieldName)});
    }
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ'’ -]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return TranslationHandler.resolve('invalid_name',
          params: {'field': TranslationHandler.get(fieldName)});
    }
    return null;
  }

  /// Validates phone numbers (basic international support)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationHandler.get('phone_required');
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return TranslationHandler.get('invalid_phone');
    }
    return null;
  }

  /// Checks if input is numeric
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return TranslationHandler.get('field_required_generic');
    }
    if (double.tryParse(value) == null) {
      return TranslationHandler.get('invalid_number');
    }
    return null;
  }
}
