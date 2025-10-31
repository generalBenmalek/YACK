import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:yack/screens/auth/confirm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:yack/screens/auth/forgetPassword.dart';
import 'package:yack/screens/auth/login.dart';
import 'package:yack/screens/auth/signup.dart';
import 'package:yack/screens/welcome.dart';
import '../theme/theme.dart';
import 'screens/home.dart';
import 'screens/sign_contract.dart';
import 'screens/settings.dart';
import 'screens/create_contract.dart';
import 'screens/scan_contract.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make the UI edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initial system overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Hive
  await Hive.initFlutter();
  final userBox = await Hive.openBox('user');

  late final String initialRoute;

  if (userBox.get('didFirstTime') == null || userBox.get('didFirstTime') == false) {
    initialRoute = '/welcome';
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

  /// Wraps each screen with a theme-aware system UI style
  Widget themedRoute(BuildContext context, Widget child) {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/welcome': (context) => themedRoute(context, const OnboardingScreen()),
        '/signup': (context) => themedRoute(context, const SignUpScreen()),
        '/login': (context) => themedRoute(context, const LoginScreen()),
        '/confirm': (context) => themedRoute(context, const ConfirmAccount()),
        '/settings': (context) => themedRoute(context, const SettingsScreen()),
        '/forgot-password': (context) => themedRoute(context, const ForgetPassword()),
        '/contract/scan_contract': (context) => themedRoute(context, const ScanContractScreen()),
        '/contract/sign_contract': (context) => themedRoute(context, const SignContractScreen()),
        '/contract/create_contract': (context) => themedRoute(context, const CreateContractScreen()),
      },
      initialRoute: initialRoute,
    );
  }
}
