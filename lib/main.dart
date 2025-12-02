import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:isar/isar.dart';
import 'package:yack/db/online.dart';
import 'package:yack/screens/auth/confirm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yack/screens/contract_agr/contract_agreement.dart';
import 'package:yack/screens/contract_agr/nomore_contracts.dart';
import 'package:yack/screens/subscription.dart';
import 'package:yack/screens/root.dart';
import 'package:yack/providers/auth/auth_cubit.dart';
import 'package:yack/providers/auth/change_password_cubit.dart';
import 'package:yack/providers/auth/confirm_cubit.dart';
import 'package:yack/providers/auth/login_cubit.dart';
import 'package:yack/providers/auth/password_reset_cubit.dart';
import 'package:yack/providers/auth/signup_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
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
  
  await Hive.openBox('contracts');
  await TranslationHandler.initialize(userBox);

  // Sync offline data and check completed contracts status (Chadli)
  syncOfflineData();
  syncCompletedContractsStatus();
  final userBox = await Hive.openBox('user');


  // Initialize Translation Handler
  await TranslationHandler.initialize(userBox);


  runApp(
      MultiBlocProvider(
          providers: [
              BlocProvider<AuthCubit>(create: (_) => AuthCubit()..checkAuth()),
              BlocProvider<LoginCubit>(create: (_) => LoginCubit()),
              BlocProvider<SignupCubit>(create: (_) => SignupCubit()),
              BlocProvider<ConfirmCubit>(create: (_) => ConfirmCubit(),),
              BlocProvider<PasswordResetCubit>(create: (_) => PasswordResetCubit(),),
              BlocProvider<ChangePasswordCubit>(create: (_) => ChangePasswordCubit(),),

            // BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
              // BlocProvider<ContractCubit>(create: (_) => ContractCubit()),
          // add others here...,
          ],
          child: MyApp(userBox: userBox,)
      )
  );
}
