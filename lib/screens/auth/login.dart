import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/utils/translation_handler.dart';
import 'package:yack/widgets/titleWidget.dart';
import 'package:yack/widgets/hrefTextWidget.dart';
import 'package:yack/utils/validator.dart';
import '../../widgets/inputFormWidget.dart';
import '../../widgets/primaryActionButtonAutoLoading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        final userBox = await Hive.openBox('user');
        userBox.put('didFirstLogin', true);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      SnackBarHandler.showError(
          context, TranslationHandler.get('login_failed'));

    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Removed unused screenWidth; using LayoutBuilder constraints for width

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = PlatformInfo.isDesktop
                ? min(400.0, constraints.maxWidth * 0.9)
                : constraints.maxWidth;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(TranslationHandler.get('app_name'),
                          style: theme.textTheme.titleMedium),
                      SizedBox(
                        width: maxWidth,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            spacing: 10,
                            children: [
                              TitleWidget(
                                  text: TranslationHandler.get('welcome_back')),
                              const SizedBox(height: 30),
                              CustomTextFormField(
                                hintText: TranslationHandler.get('email'),
                                controller: emailController,
                                validator: Validator.email,
                              ),
                              CustomTextFormField(
                                hintText: TranslationHandler.get('password'),
                                isPassword: true,
                                controller: passwordController,
                                validator: (v) => Validator.length(v, min: 8),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  HrefWidget(
                                    text: TranslationHandler.get('forget_password'),
                                    onClick: () {
                                      Navigator.pushNamed(context, '/forgot-password');
                                    },
                                  ),
                                ],
                              ),
                              PrimaryActionButtonAutoReload(
                                onClick: login,
                                action: TranslationHandler.get('login'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Text(TranslationHandler.get('dont_have_account')),
                          HrefWidget(
                            text: TranslationHandler.get('sign_up'),
                            onClick: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
