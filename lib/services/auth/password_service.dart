import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordService {

  static Future<void> resetPassword(
      GlobalKey<FormState> formKey,
      String email) async {

    // Validate input fields
    if (!formKey.currentState!.validate()) {
      throw "auth_invalid_input";
    }


    try {
      // Firebase password reset
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'no_account_found';
      }
      throw 'generic_error';
    }
  }

  static Future<void> changePassword(
      GlobalKey<FormState> formKey,
      String oldPassword,
      String newPassword,
      ) async {
    if (!formKey.currentState!.validate()) {
      throw 'auth_invalid_input';
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      throw 'auth_no_user_logged_in';
    }

    try {
      // Step 1: Reauthenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Step 2: Change Password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      // Wrong old password
      if (e.code == 'wrong-password') throw 'auth_wrong_old_password';

      // Too-weak new password (firebase checks strength)
      if (e.code == 'weak-password') throw 'auth_weak_new_password';

      // Requires recent login (rare)
      if (e.code == 'requires-recent-login') {
        throw 'auth_recent_login_required';
      }

      throw 'generic_error';
    }
  }
}
