import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:isar/isar.dart';
import 'package:yack/db/online.dart';
import 'package:yack/screens/auth/confirm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yack/screens/contract_agr/contract_agreement.dart';
import 'package:yack/screens/contract_agr/nomore_contracts.dart';
import 'package:yack/screens/subscription.dart';
import 'package:yack/screens/root.dart';
import 'firebase_options.dart';
import 'package:yack/screens/auth/forgetPassword.dart';
import 'package:yack/screens/auth/login.dart';
import 'package:yack/screens/auth/signup.dart';
import 'package:yack/screens/welcome.dart';
import '../theme/theme.dart';
import 'screens/sign_contract.dart';
import 'screens/settings.dart';
import 'screens/create_contract.dart';
import 'screens/scan_contract.dart';
import 'utils/translation_handler.dart';
import 'package:yack/db/models/contract.dart';
import 'package:yack/db/models/mediaFile.dart';
import 'package:yack/db/models/message.dart';
import 'package:yack/db/models/notification.dart';
import 'package:path_provider/path_provider.dart';

late Isar isar;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  isar = await Isar.open([
    ContractSchema,
    MessageSchema,
    MediaFileSchema,
    AppNotificationSchema,
  ], directory: dir.path);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();
  final userBox = await Hive.openBox('user');
  await Hive.openBox('contracts');
  await TranslationHandler.initialize(userBox);

  // Sync offline data and check completed contracts status (Chadli)
  syncOfflineData();
  syncCompletedContractsStatus();

  late final String initialRoute;

  // BYPASS AUTH FOR TESTING - Remove this line when auth is ready
  const bypassAuth = true;

  final user = FirebaseAuth.instance.currentUser;

  if (bypassAuth) {
    // TESTING MODE: Skip authentication
    initialRoute = '/home';
  } else if (userBox.get('didFirstTime') == null ||
      userBox.get('didFirstTime') == false) {
    initialRoute = '/welcome';
    await userBox.put('didFirstTime', true);
  } else if (user != null) {
    initialRoute = '/home';
  } else if (userBox.get('didFirstLogin') == true) {
    initialRoute = '/login';
  } else {
    initialRoute = '/signup';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Box userBox;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box('user');
  }

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

  Widget themedRoute(
    BuildContext context,
    Widget child, {
    bool transparent = false,
  }) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode =
        _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && brightness == Brightness.dark);

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: !transparent
          ? Theme.of(context).colorScheme.surface
          : Colors.transparent,
      systemNavigationBarDividerColor: !transparent
          ? Theme.of(context).colorScheme.surface
          : Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: isDarkMode
          ? Brightness.light
          : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: userBox.listenable(keys: ['theme', 'language']),
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
            '/welcome': (context) => themedRoute(
              context,
              const OnboardingScreen(),
              transparent: true,
            ),

            '/signup': (context) =>
                themedRoute(context, const SignUpScreen(), transparent: true),
            '/login': (context) =>
                themedRoute(context, const LoginScreen(), transparent: true),
            '/confirm': (context) =>
                themedRoute(context, const ConfirmAccount(), transparent: true),
            '/forgot-password': (context) =>
                themedRoute(context, const ForgetPassword(), transparent: true),

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
            '/upgrade': (context) => themedRoute(
              context,
              const NoMoreContractsAvailable(),
              transparent: true,
            ),
            '/subscription': (context) =>
                themedRoute(context, const SubscriptionScreen()),
            '/home': (context) => themedRoute(context, const BottomNavBar()),
          },
          initialRoute: widget.initialRoute,
        );
      },
    );
  }
}
