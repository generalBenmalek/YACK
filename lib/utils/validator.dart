class Validator {
  /// Checks if a field is empty
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates an email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates a strong password (min 8 chars, 1 uppercase, 1 lowercase, 1 number)
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'\d'));
    if (!hasUpper || !hasLower || !hasNumber) {
      return 'Password must include upper, lower case letters and a number';
    }
    return null;
  }

  /// Confirm password check
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates minimum and maximum length
  static String? length(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (min != null && value.length < min) {
      return 'Must be at least $min characters';
    }
    if (max != null && value.length > max) {
      return 'Must be less than $max characters';
    }
    return null;
  }

  /// Validates a name (letters and spaces only)
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ'’ -]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Enter a valid $fieldName';
    }
    return null;
  }

  /// Validates phone numbers (basic international support)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Checks if input is numeric
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    return null;
  }
}
