import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yack/utils/translation_handler.dart';

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

}
