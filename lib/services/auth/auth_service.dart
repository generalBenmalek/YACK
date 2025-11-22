import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/utils/translation_handler.dart';

class AuthService {

  /// Login Function
  /// Called FROM Cubit (LoginCubit), NOT from UI directly.
  static Future<bool> login(
      BuildContext context,
      GlobalKey<FormState> formKey,
      String email,
      String password) async {

    // Validate form fields before sending request
    if (!formKey.currentState!.validate()) return false;

    final auth = FirebaseAuth.instance;

    try {
      // Try signing in user
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Open Hive user box (local data)
      final userBox = await Hive.openBox('user');
      userBox.put('didFirstLogin', true);

      return true; // Login success

    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        // Handle Firebase Errors
        SnackBarHandler.showError(
          context,
          TranslationHandler.get('login_failed'),
        );
      }
    }

    return false; // Login failed
  }
}
