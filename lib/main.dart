import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:isar/isar.dart';
import 'package:yack/data/db/online.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yack/logic/cubits/auth/auth_cubit.dart';
import 'package:yack/logic/cubits/auth/change_password_cubit.dart';
import 'package:yack/logic/cubits/auth/confirm_cubit.dart';
import 'package:yack/logic/cubits/auth/login_cubit.dart';
import 'package:yack/logic/cubits/auth/password_reset_cubit.dart';
import 'package:yack/logic/cubits/auth/signup_cubit.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/data/db/models/contract.dart';
import 'package:yack/data/db/models/mediaFile.dart';
import 'package:yack/data/db/models/message.dart';
import 'package:yack/data/db/models/notification.dart';
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

  final userBox = await Hive.openBox('user');

  await TranslationHandler.initialize(userBox);

  // Sync offline data and check completed contracts status (Chadli)
  syncOfflineData();
  syncCompletedContractsStatus();


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
