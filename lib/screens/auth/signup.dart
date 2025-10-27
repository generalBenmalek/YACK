import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/widgets/inputFormWidget.dart';
import 'package:yack/widgets/primaryActionButton.dart';
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

  bool isLoading = false;

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Step 1: Create user in Firebase Auth
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userBox = await Hive.openBox('user');
      userBox.put('firstName', firstNameController.text.trim());
      userBox.put('lastName', lastNameController.text.trim());
      userBox.close();

      await userCred.user?.sendEmailVerification();

      Navigator.pushNamed(context, '/confirm');

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error creating account")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
                      children: [
                        TitleWidget(text: 'Welcome'),
                        const SizedBox(height: 30),

                        // Email
                        CustomTextFormField(
                          hintText: 'Email',
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        // First & Last Name
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextFormField(
                                hintText: 'First Name',
                                controller: firstNameController,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'First name required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextFormField(
                                hintText: 'Last Name',
                                controller: lastNameController,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Last name required'
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Password
                        CustomTextFormField(
                          hintText: 'Password',
                          isPassword: true,
                          controller: passwordController,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        PrimaryActionButton(
                          action: isLoading ? 'Creating...' : 'Sign up',
                          onClick: isLoading ? (){} : signUp,
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
                        onClick: () =>
                            Navigator.pushNamed(context, '/login'),
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
