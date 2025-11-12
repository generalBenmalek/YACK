import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/widgets/titleWidget.dart';
import 'package:yack/widgets/hrefTextWidget.dart';
import '../../utils/snackBarHandler.dart';
import '../../widgets/primaryActionButton.dart';
import 'package:yack/utils/translation_handler.dart';

class ConfirmAccount extends StatefulWidget {
  const ConfirmAccount({super.key});

  @override
  State<StatefulWidget> createState() => ConfirmAccountState();
}

class ConfirmAccountState extends State<ConfirmAccount> {
  bool isLoading = false;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> verify() async {
    setState(() => isLoading = true);
    try {
      await user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        if (mounted) {
          SnackBarHandler.showSuccess(
              context, TranslationHandler.get('account_confirmed'));


          // // Step 2: Save additional info in Firestore
          // await _firestore.collection('users').doc(userCred.user!.uid).set({
          //   'firstName': firstNameController.text.trim(),
          //   'lastName': lastNameController.text.trim(),
          //   'email': emailController.text.trim(),
          //   'createdAt': FieldValue.serverTimestamp(),
          // });
          final userBox = await Hive.openBox('user');
          userBox.put('didFirstLogin', true);
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        SnackBarHandler.showWarning(
            context, TranslationHandler.get('email_not_verified'));
      }
    } catch (e) {
      SnackBarHandler.showError(
          context, TranslationHandler.get('verification_error'));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> resend() async {
    try {
      await user?.sendEmailVerification();
      SnackBarHandler.showMessage(
          context, TranslationHandler.get('verification_email_sent'));
    } catch (e) {
      SnackBarHandler.showError(
          context, TranslationHandler.get('resend_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TitleWidget(text: TranslationHandler.get('confirm_account')),
                    Text(
                      TranslationHandler.get('confirm_account_message'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(TranslationHandler.get('did_not_receive_email')),
                        HrefWidget(
                          text: TranslationHandler.get('resend'),
                          onClick: resend,
                        ),
                      ],
                    ),
                    PrimaryActionButton(
                      action: isLoading
                          ? TranslationHandler.get('checking')
                          : TranslationHandler.get('check'),
                      onClick: isLoading ? () {} : verify,
                    ),
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
    );
  }
}
