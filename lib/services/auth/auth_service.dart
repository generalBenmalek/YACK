import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/utils/translation_handler.dart';

class AuthService {

  /// Login Function
  /// Called FROM Cubit (LoginCubit), NOT from UI directly.
  static Future<void> login(
      BuildContext context,
      GlobalKey<FormState> formKey,
      String email,
      String password,
      ) async {

    // Throw message for invalid input
    if (!formKey.currentState!.validate()) {
      throw "Invalid Input";
    }

    final auth = FirebaseAuth.instance;

    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final box = await Hive.openBox('user');
      box.put("didFirstLogin", true);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw "Incorrect password.";
      } else if (e.code == 'user-not-found') {
        throw "No user found with this email.";
      } else if (e.code == 'invalid-email') {
        throw "Email format is invalid.";
      } else if (e.code == 'too-many-requests') {
        throw "Too many attempts. Please try later.";
      } else {
        throw e.message ?? "Login failed.";
      }
    }
  }

  // SIGN UP
  static Future<void> signup(
      BuildContext context,
      GlobalKey<FormState> formKey,
      String email,
      String password,
      String firstName,
      String lastName
      ) async {

    if (!formKey.currentState!.validate()) throw 'Invalid Input';

    final auth = FirebaseAuth.instance;

    try {
      // Step 1: Create user in Firebase Auth
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Save minimal info locally with Hive
      final userBox = await Hive.openBox('user');
      await userBox.putAll({
        'firstName': firstName,
        'lastName': lastName,
      });

      // Step 3: Send verification email
      // await userCred.user?.sendEmailVerification();
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
