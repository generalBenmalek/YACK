// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:yack/screens/auth/forgetPassword.dart';
import 'package:yack/screens/auth/login.dart';
import 'package:yack/screens/auth/signup.dart';
import "../theme/theme.dart";
import 'screens/settings.dart'; 
import 'screens/sign_contract.dart';
import 'screens/create_contract.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
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
      routes: {
        // '/': (context) => Home,
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/reset_password': (context) => const ForgetPassword(),
        '/contract/create': (context) => const CreateContractScreen()
        // TODO: add routes for your page after finishing
      },
      initialRoute: '/signup' // will be changed later,
    );
  }
}