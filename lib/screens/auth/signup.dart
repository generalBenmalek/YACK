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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
      await userBox.close();

      // Step 3: Send verification email
      await userCred.user?.sendEmailVerification();

      // Step 4: Go to confirmation screen
      if (mounted) Navigator.pushNamed(context, '/confirm');
    } on FirebaseAuthException catch (e) {
      SnackBarHandler.showError(context, "Error creating account");
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Yack', style: theme.textTheme.titleMedium),
              const SizedBox(height: 30),
              SizedBox(
                width: PlatformInfo.isDesktop
                    ? min(400, screenWidth * 0.9)
                    : screenWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 10,
                    children: [
                      const TitleWidget(text: 'Welcome'),
                      const SizedBox(height: 30),

                      // Email
                      CustomTextFormField(
                        hintText: 'Email',
                        controller: emailController,
                        validator: Validator.email,
                      ),

                      // First & Last Name
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              hintText: 'First Name',
                              controller: firstNameController,
                              validator: (v) => Validator.name(v, fieldName: 'First name'),
                            ),
                          ),
                          Expanded(
                            child: CustomTextFormField(
                              hintText: 'Last Name',
                              controller: lastNameController,
                              validator: (v) => Validator.name(v, fieldName: 'Last name'),
                            ),
                          ),
                        ],
                      ),

                      // Password
                      CustomTextFormField(
                        hintText: 'Password',
                        isPassword: true,
                        controller: passwordController,
                        validator: (v) => Validator.password(v, minLength: 8),
                      ),

                      // Password Confirm
                      CustomTextFormField(
                        hintText: 'Confirm password',
                        isPassword: true,
                        validator: (v) => Validator.confirmPassword(v, passwordController.value.text),
                      ),


                      // Signup button with auto-loading
                      PrimaryActionButtonAutoReload(
                        action: 'Sign Up',
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
                  const Text("Already have an account?"),
                  const SizedBox(width: 5),
                  HrefWidget(
                    text: 'Login',
                    onClick: () => Navigator.pushNamed(context, '/login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
