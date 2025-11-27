import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/utils/validator.dart';
import 'package:yack/widgets/inputFormWidget.dart';
import 'package:yack/widgets/primaryActionButtonAutoLoading.dart';
import 'package:yack/widgets/titleWidget.dart';
import 'package:yack/widgets/hrefTextWidget.dart';
import 'package:yack/utils/translation_handler.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Step 1: Create user in Firebase Auth
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Step 2: Save minimal info locally with Hive
      final userBox = await Hive.openBox('user');
      await userBox.putAll({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
      });

      // Step 3: Send verification email
      await userCred.user?.sendEmailVerification();

      // Step 4: Go to confirmation screen
      if (mounted) Navigator.pushNamed(context, '/confirm');
    } on FirebaseAuthException catch (e) {
      SnackBarHandler.showError(
          context, TranslationHandler.get('signup_failed'));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(TranslationHandler.get('app_name'),
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: maxWidth,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            spacing: 10,
                            children: [
                              TitleWidget(text: TranslationHandler.get('welcome')),
                              const SizedBox(height: 30),

                      // Email
                      CustomTextFormField(
                        hintText: TranslationHandler.get('email'),
                        controller: emailController,
                        validator: Validator.email,
                      ),

                      // First & Last Name
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              hintText: TranslationHandler.get('first_name'),
                              controller: firstNameController,
                              validator: (v) =>
                                  Validator.name(v, fieldName: 'first_name'),
                            ),
                          ),
                          Expanded(
                            child: CustomTextFormField(
                              hintText: TranslationHandler.get('last_name'),
                              controller: lastNameController,
                              validator: (v) =>
                                  Validator.name(v, fieldName: 'last_name'),
                            ),
                          ),
                        ],
                      ),

                      // Password
                      CustomTextFormField(
                        hintText: TranslationHandler.get('password'),
                        isPassword: true,
                        controller: passwordController,
                        validator: (v) => Validator.password(v, minLength: 8),
                      ),

                      // Password Confirm
                      CustomTextFormField(
                        hintText: TranslationHandler.get('confirm_password'),
                        isPassword: true,
                        controller: confirmPasswordController,
                        validator: (v) => Validator.confirmPassword(v, passwordController.value.text),
                      ),


                              // Signup button with auto-loading
                              PrimaryActionButtonAutoReload(
                                action: TranslationHandler.get('sign_up'),
                                onClick: signUp,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(TranslationHandler.get('already_have_account')),
                          const SizedBox(width: 5),
                          HrefWidget(
                            text: TranslationHandler.get('login'),
                            onClick: () => Navigator.pushNamed(context, '/login'),
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
