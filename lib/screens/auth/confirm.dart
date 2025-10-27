import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/widgets/titleWidget.dart';
import 'package:yack/widgets/hrefTextWidget.dart';
import '../../widgets/primaryActionButton.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email verified!")),
          );

          // // Step 2: Save additional info in Firestore
          // await _firestore.collection('users').doc(userCred.user!.uid).set({
          //   'firstName': firstNameController.text.trim(),
          //   'lastName': lastNameController.text.trim(),
          //   'email': emailController.text.trim(),
          //   'createdAt': FieldValue.serverTimestamp(),
          // });

          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email not verified yet.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> resend() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent again.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend email: $e")),
      );
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
              Text('Yack', style: theme.textTheme.titleMedium),
              SizedBox(
                width: PlatformInfo.isDesktop
                    ? min(400, screenWidth * 0.9)
                    : screenWidth,
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const TitleWidget(text: 'Confirm Account'),
                    const Text(
                      "We have sent a verification email. Please check your inbox (and spam folder) before continuing.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Did not receive the email? "),
                        HrefWidget(
                          text: 'Resend',
                          onClick: resend,
                        ),
                      ],
                    ),
                    PrimaryActionButton(
                      action: isLoading ? 'Checking...' : 'Check',
                      onClick: isLoading ? () {} : verify,
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
    );
  }
}
