import 'package:flutter/material.dart';

class AppTheme {
  // YACK Brand Colors
  static const Color yackGreen = Color(0xFF00D563);
  static const Color yackGreenLight = Color(0xFFE8F5E9);
  static const Color yackBackground = Color(0xFFF5F5F5);
  static const Color yackWhite = Color(0xFFFFFFFF);
  static const Color yackBlack = Color(0xFF000000);
  static const Color yackGray = Color(0xFF757575);
  static const Color yackGrayLight = Color(0xFFEEEEEE);
  static const Color yackDivider = Color(0xFFE0E0E0);
  
  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFE0E0E0);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: yackGreen,
      secondary: yackGreen,
      surface: yackWhite,
      onPrimary: yackWhite,
      onSecondary: yackWhite,
      onSurface: yackBlack,
      surfaceContainerHighest: yackGrayLight,
      outline: yackDivider,
    ),
    scaffoldBackgroundColor: yackBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: yackWhite,
      foregroundColor: yackBlack,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: yackBlack,
      ),
      iconTheme: IconThemeData(color: yackBlack),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: yackBlack),
      bodyMedium: TextStyle(fontSize: 14, color: yackGray),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: yackBlack,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: yackBlack,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: yackWhite,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: yackDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: yackDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: yackGreen, width: 2),
      ),
      filled: true,
      fillColor: yackWhite,
      hintStyle: TextStyle(color: yackGray),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: yackGreen,
        foregroundColor: yackWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: yackGreen,
        side: const BorderSide(color: yackGreen, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: yackWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: yackDivider,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: yackBlack,
      size: 24,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: yackWhite,
      selectedItemColor: yackGreen,
      unselectedItemColor: yackGray,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: yackGreen,
      secondary: yackGreen,
      surface: darkSurface,
      onPrimary: yackBlack,
      onSecondary: yackBlack,
      onSurface: darkText,
      surfaceContainerHighest: const Color(0xFF2C2C2C),
      outline: const Color(0xFF424242),
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      iconTheme: IconThemeData(color: darkText),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: darkText),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0B0B0)),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: darkText,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: yackBlack,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: yackGreen, width: 2),
      ),
      filled: true,
      fillColor: darkSurface,
      hintStyle: const TextStyle(color: Color(0xFF757575)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: yackGreen,
        foregroundColor: yackBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: yackGreen,
        side: const BorderSide(color: yackGreen, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF424242),
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: darkText,
      size: 24,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: yackGreen,
      unselectedItemColor: Color(0xFF757575),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}