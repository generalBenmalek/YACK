import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:yack/screens/auth/confirm.dart';
import 'package:yack/screens/auth/forgetPassword.dart';
import 'package:yack/screens/auth/login.dart';
import 'package:yack/screens/auth/signup.dart';
import 'package:yack/screens/welcome.dart';
import '../theme/theme.dart';
import 'screens/settings.dart';
import 'screens/create_contract.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final brightness = WidgetsBinding.instance.window.platformBrightness;
  final isDarkMode = brightness == Brightness.dark;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness:
    isDarkMode ? Brightness.light : Brightness.dark,
  ));


  // Initialize Hive first
  await Hive.initFlutter();

  // Open user box
  final userBox = await Hive.openBox('user');

  late final String initialRoute;

  // Determine first-time or returning user
  if (userBox.get('didFirstTime') == null || userBox.get('didFirstTime') == false) {
    initialRoute = '/welcome'; // later replaced with welcome screen
    await userBox.put('didFirstTime', true);
  } else if (userBox.get('didFirstLogin') == true) {
    initialRoute = '/login';
  } else {
    initialRoute = '/signup';
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/welcome': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/confirm': (context) => const ConfirmAccount(),
        '/settings': (context) => const SettingsScreen(),
        '/forgot-password': (context) => const ForgetPassword(),
        '/contract/create': (context) => const CreateContractScreen(),

      },
      initialRoute: initialRoute, // dynamic\
    );
  }
}
