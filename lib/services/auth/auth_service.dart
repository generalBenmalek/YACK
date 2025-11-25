import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AuthService {

  /// Login Function
  /// Called FROM Cubit (LoginCubit), NOT from UI directly.
  static Future<void> login(
      BuildContext context,
      GlobalKey<FormState> formKey,
      String email,
      String password,
      ) async
  {

    if (!formKey.currentState!.validate()) {
      throw "auth_invalid_input"; // translation key
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
      if (e.code == "wrong-password") {
        throw "auth_wrong_password";
      } else if (e.code == "user-not-found") {
        throw "auth_user_not_found";
      } else if (e.code == "invalid-email") {
        throw "auth_invalid_email";
      } else if (e.code == "too-many-requests") {
        throw "auth_too_many_requests";
      } else {
        throw "auth_unknown_error";
      }
    } catch (_) {
      throw "auth_unexpected_error";
    }
  }

  // SIGN UP
  static Future<void> signup(
      BuildContext context,
      GlobalKey<FormState> formKey,
      String email,
      String password,
      String firstName,
      String lastName,
      ) async
  {

    // Validate input fields
    if (!formKey.currentState!.validate()) {
      throw "auth_invalid_input";
    }

    final auth = FirebaseAuth.instance;

    try {
      // Create user in Firebase Auth
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save local user information
      final userBox = await Hive.openBox('user');
      await userBox.putAll({
        'firstName': firstName,
        'lastName': lastName,
        'didFirstLogin': true,
      });

    } on FirebaseAuthException catch (e) {

      // Firebase error codes mapped to translation keys
      if (e.code == "email-already-in-use") {
        throw "auth_email_in_use";
      } else if (e.code == "invalid-email") {
        throw "auth_invalid_email";
      } else if (e.code == "weak-password") {
        throw "auth_weak_password";
      } else {
        throw "auth_unknown_error";
      }
    } catch (_) {
      throw "auth_unexpected_error";
    }
  }


  static Future<void> sendEmailVerification() async {
    final auth = FirebaseAuth.instance;

    // If no user is logged in
    if (auth.currentUser == null) {
      throw "auth_user_not_found";
    }

    try {
      await auth.currentUser!.sendEmailVerification();

    } on FirebaseAuthException catch (e) {
      if (e.code == "too-many-requests") {
        throw "auth_too_many_requests";
      } else {
        throw "auth_unknown_error";
      }

    } catch (_) {
      throw "auth_unexpected_error";
    }
  }

  static Future<bool> confirmAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    // No logged-in user → real error
    if (user == null) {
      throw "auth_user_not_found";
    }

    try {
      // Reload fresh info from Firebase
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser!;

      // If verified → return true
      // Not verified → return false
      return refreshedUser.emailVerified;

    } on FirebaseAuthException {
      throw "auth_unknown_error";
    } catch (_) {
      throw "auth_unexpected_error";
    }
  }

  static Future<bool> isAuthenticated() async {
    final auth = FirebaseAuth.instance;

    try {
      final user = auth.currentUser;

      // Not logged into Firebase
      if (user == null) return false;

      // check Hive box
      final box = await Hive.openBox('user');

      // If user box missing required info → treat as not logged in
      if (!box.containsKey('didFirstLogin')) {
        return false;
      }

      return true;

    } on FirebaseAuthException {
      throw "auth_unknown_error";
    } catch (_) {
      throw "auth_unexpected_error";
    }
  }
}
