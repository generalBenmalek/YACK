import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/utils/validator.dart';
import 'package:yack/widgets/inputFormWidget.dart';
import 'package:yack/widgets/primaryActionButtonAutoLoading.dart';
import 'package:yack/widgets/titleWidget.dart';
import 'package:yack/widgets/hrefTextWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/snackBarHandler.dart'; // only if you use Firebase
import 'package:yack/utils/translation_handler.dart';

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
        SnackBarHandler.showSuccess(
            context, TranslationHandler.get('password_reset_sent'));
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      String message = TranslationHandler.get('generic_error');
      if (e.code == 'user-not-found') {
        message = TranslationHandler.get('no_account_found');
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
                Text(TranslationHandler.get('app_name'),
                    style: theme.textTheme.titleMedium),
                SizedBox(
                  width: PlatformInfo.isDesktop
                      ? min(400, screenWidth * 0.9)
                      : screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TitleWidget(
                          text: TranslationHandler.get('forget_password')),
                      const SizedBox(height: 8),
                      Text(
                        TranslationHandler.get('forget_password_message'),
                      ),
                      const SizedBox(height: 30),
                      CustomTextFormField(
                        controller: _emailController,
                        hintText: TranslationHandler.get('email'),
                        validator: Validator.email,
                      ),
                      const SizedBox(height: 25),
                      PrimaryActionButtonAutoReload(
                          action: TranslationHandler.get('reset'),
                          onClick: _resetPassword)

                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}
