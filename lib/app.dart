import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:yack/presentation/screens/auth/confirm.dart';
import 'package:yack/presentation/screens/contract_agr/contract_agreement.dart';
import 'package:yack/presentation/screens/contract_agr/nomore_contracts.dart';
import 'package:yack/presentation/screens/root.dart';
import 'package:yack/presentation/screens/subscription.dart';
import 'app_wrapper.dart';
import 'package:yack/presentation/screens/auth/forgetPassword.dart';
import 'package:yack/presentation/screens/auth/login.dart';
import 'package:yack/presentation/screens/auth/signup.dart';
import 'package:yack/presentation/screens/auth/initAccountScreen.dart';
import 'package:yack/presentation/screens/auth/decryptAccountScreen.dart';
import 'package:yack/presentation/screens/welcome.dart';
import 'package:yack/presentation/theme/theme.dart';
import 'package:yack/presentation/screens/profile.dart';
import 'package:yack/presentation/screens/sign_contract.dart';
import 'package:yack/presentation/screens/settings.dart';
import 'presentation/screens/create_contract.dart';
import 'presentation/screens/scan_contract.dart';
import 'package:yack/logic/services/translation_handler.dart';


class MyApp extends StatelessWidget {

  const MyApp({super.key, required this.userBox});
  final Box userBox;

  ThemeMode get _themeMode {
    final themeValue = userBox.get('theme');
    switch (themeValue) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 3:
      case null:
      default:
        return ThemeMode.system;
    }
  }

  /// Wraps each screen with a theme-aware system UI style
  Widget themedRoute(BuildContext context, Widget child, {
    bool transparent = false
  })
  {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && brightness == Brightness.dark);

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: !transparent? Theme.of(context).colorScheme.surface: Colors.transparent,
      systemNavigationBarDividerColor: !transparent?Theme.of(context).colorScheme.surface: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness:
      isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {

    // ValueListenableBuilder updates MaterialApp when the Hive value changes
    return ValueListenableBuilder(
      valueListenable: userBox.listenable(keys: ['theme','language']),
      builder: (context, box, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          locale: TranslationHandler.locale,
          supportedLocales: TranslationHandler.supportedLocales.toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          routes: {
            '/welcome': (context) =>
                themedRoute(context, const OnboardingScreen(),transparent: true),

            // AUTH ROUTES
            '/signup': (context) =>
                themedRoute(context,  SignUpScreen(),transparent: true),
            '/login': (context) =>
                themedRoute(context,  LoginScreen(),transparent: true),
            '/confirm': (context) =>
                themedRoute(context,  ConfirmAccount(),transparent: true),
            '/forgot-password': (context) =>
                themedRoute(context,  ForgetPassword(),transparent: true),
            '/init-account': (context) =>
                themedRoute(context, const InitAccountScreen(), transparent: true),
            '/decrypt-account': (context) =>
                themedRoute(context, const DecryptAccountScreen(), transparent: true),

            // CONTRACT ROUTES
            '/contract/scan_contract': (context) =>
                themedRoute(context, const ScanContractScreen()),
            '/contract/sign_contract': (context) =>
                themedRoute(context, const SignContractScreen()),
            '/contract/create_contract': (context) =>
                themedRoute(context, const CreateContractScreen()),
            '/contract/view': (context) {
              final contractId =
              ModalRoute.of(context)!.settings.arguments as int;
              return themedRoute(context, ContractAgreement(contractId: contractId));
            },
            '/settings': (context) =>
                themedRoute(context, const SettingsScreen()),
            '/profile': (context) =>
                themedRoute(context, const ProfileScreen(),transparent: true),
            '/upgrade': (context) =>
                themedRoute(context, const NoMoreContractsAvailable(),transparent: true),
            '/home': (context) =>
                themedRoute(context, const BottomNavBar()),
            '/subscription' : (context) =>
                themedRoute(context, const SubscriptionScreen(),transparent: true),

            '/': (context) => const AppWrapper()
          },
          initialRoute: '/',
        );
      },
    );
  }
}
