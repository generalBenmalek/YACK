import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/widgets/inputFormWidget.dart';
import 'package:yack/widgets/inputWidget.dart';
import 'package:yack/widgets/primaryActionButtonAutoLoading.dart';
import 'package:yack/widgets/titleWidget.dart';
import 'package:yack/widgets/hrefTextWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/snackBarHandler.dart'; // only if you use Firebase

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<StatefulWidget> createState() => ForgetPasswordState();
}

class ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;


    try {
      // Firebase password reset
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      if (mounted) {
        SnackBarHandler.showSuccess(context,'Password reset email sent! Check your inbox.');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No account found with that email.';
      }

      SnackBarHandler.showError(context, message);

    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Yack', style: theme.textTheme.titleMedium),
                SizedBox(
                  width: PlatformInfo.isDesktop
                      ? min(400, screenWidth * 0.9)
                      : screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const TitleWidget(text: 'Forget Password'),
                      const SizedBox(height: 8),
                      const Text(
                        "Send a request to reset your account password.",
                      ),
                      const SizedBox(height: 30),
                      CustomTextFormField(
                        controller: _emailController,
                        hintText: 'Email',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: min(screenHeight * 0.08, 55),
                        child: PrimaryActionButtonAutoReload(action: 'Reset', onClick: _resetPassword)
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    HrefWidget(
                      text: 'Sign Up',
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
      ),
    );
  }
}
