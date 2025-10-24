// lib/main.dart
import 'package:flutter/material.dart';
import "../theme/theme.dart";
import 'screens/settings.dart'; // Add this import
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SettingsScreen(), // Just to see the Settings Screen
    );
  }
}