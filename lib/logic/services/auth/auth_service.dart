import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  // Keys for persisting auth status in Hive
  // Values: 'authenticated', 'unverified', 'unauthenticated'
  static const String _authStatusKey = 'authStatus';

  /// Helper to persist the last known auth status.
  static Future<void> _saveAuthStatus(String status) async {
    final box = await Hive.openBox('user');
    await box.put(_authStatusKey, status);
  }

  /// Public helper to read the last known auth status from Hive.
  /// Returns:
  /// - true  -> authenticated & verified
  /// - false -> unauthenticated
  /// - null  -> authenticated but email NOT verified
  static Future<bool?> readLastAuthStatus() async {
    final box = await Hive.openBox('user');
    final status = box.get(_authStatusKey);
    if (status == 'authenticated') return true;
    if (status == 'unverified') return null;
    if (status == 'unauthenticated') return false;
    return false; // default
  }

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

      final user = auth.currentUser;
      final box = await Hive.openBox('user');
      box.put("didFirstLogin", true);
      await _saveAuthStatus('authenticated');

      // // Fetch and cache first/last name on login
      // if (user != null) {
      //   String? firstName = box.get('firstName');
      //   String? lastName = box.get('lastName');
      //
      //   // If local names are missing, try to derive from displayName
      //   if ((firstName == null || firstName.isEmpty) &&
      //       (lastName == null || lastName.isEmpty)) {
      //     final displayName = user.displayName ?? '';
      //     if (displayName.isNotEmpty) {
      //       final parts = displayName.split(' ');
      //       if (parts.isNotEmpty) {
      //         firstName = parts.first;
      //         if (parts.length > 1) {
      //           lastName = parts.sublist(1).join(' ');
      //         }
      //       }
      //     }
      //
      //     if (firstName != null && firstName.isNotEmpty) {
      //       await box.put('firstName', firstName);
      //     }
      //     if (lastName != null && lastName.isNotEmpty) {
      //       await box.put('lastName', lastName);
      //     }
      //   }
      //
      //   // Optionally also try to read from Realtime Database profile node
      //   try {
      //     final profileRef = FirebaseDatabase.instance.ref(
      //       'userProfiles/${user.uid}',
      //     );
      //     final snapshot = await profileRef.get();
      //     final data = snapshot.value;
      //     if (data is Map) {
      //       final dbFirst = data['firstName']?.toString() ?? '';
      //       final dbLast = data['lastName']?.toString() ?? '';
      //       if (dbFirst.isNotEmpty) await box.put('firstName', dbFirst);
      //       if (dbLast.isNotEmpty) await box.put('lastName', dbLast);
      //     }
      //   } catch (_) {}

      // }
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseLoginError(e);
    } catch (_) {
      throw "auth_unexpected_error";
    }
  }

  static String _mapFirebaseLoginError(FirebaseAuthException e) {
    if (e.code == "wrong-password") {
      return "auth_wrong_password";
    } else if (e.code == "user-not-found") {
      return "auth_user_not_found";
    } else if (e.code == "invalid-email") {
      return "auth_invalid_email";
    } else if (e.code == "too-many-requests") {
      return "auth_too_many_requests";
    } else {
      return "auth_unknown_error";
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

      // final user = cred.user;

      // // Update FirebaseAuth profile displayName
      // final fullName = [firstName, lastName]
      //     .where((s) => s.trim().isNotEmpty)
      //     .join(' ')
      //     .trim();
      // if (user != null && fullName.isNotEmpty) {
      //   await user.updateDisplayName(fullName);
      // }

      // // Optionally store names in Realtime Database profile node
      // if (user != null) {
      //   try {
      //     final profileRef = FirebaseDatabase.instance.ref(
      //       'userProfiles/${user.uid}',
      //     );
      //     await profileRef.set({
      //       'firstName': firstName,
      //       'lastName': lastName,
      //       'email': email,
      //       'createdAt': ServerValue.timestamp,
      //     });
      //   } catch (_) {}
      // }

      // Save local user information
      final userBox = await Hive.openBox('user');
      await userBox.putAll({
        'firstName': firstName,
        'lastName': lastName,
        'didFirstLogin': true,
      });

      // New accounts are typically unverified until email is confirmed
      await _saveAuthStatus('unverified');
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

      final verified = refreshedUser.emailVerified;
      // Persist latest status
      await _saveAuthStatus(verified ? 'authenticated' : 'unverified');
      return verified;
    } on FirebaseAuthException {
      throw "auth_unknown_error";
    } catch (_) {
      throw "auth_unexpected_error";
    }
  }

  /// Returns:
  /// - true  -> authenticated & verified
  /// - false -> unauthenticated
  /// - null  -> authenticated but email NOT verified
  ///
  /// Online check only:
  /// - If Firebase throws an error (e.g. no internet), this method will
  ///   throw instead of falling back to cached state. Caller is responsible
  ///   for handling retries and/or using [readLastAuthStatus] first for
  ///   a fast offline startup.
  static Future<bool?> isAuthenticated() async {
    final auth = FirebaseAuth.instance;

    try {
      final user = auth.currentUser;

      // Not logged into Firebase
      if (user == null) {
        await _saveAuthStatus('unauthenticated');
        return false;
      }

      // check Hive box
      final box = await Hive.openBox('user');

      // If user box missing required info → treat as not logged in
      if (!box.containsKey('didFirstLogin')) {
        await _saveAuthStatus('unauthenticated');
        return false;
      }

      // email not verified -> unverified user
      if (!(user.emailVerified)) {
        await _saveAuthStatus('unverified');
        return null;
      }

      // logged in + verified - sync contracts from Firebase (Chadli)
      // This ensures contracts are synced when app restarts with existing session
      try {

      } catch (_) {
        // Sync errors shouldn't block authentication
      }

      await _saveAuthStatus('authenticated');
      return true;
    } on FirebaseAuthException catch (e) {
      // Let caller know there was an auth-related / network problem.
      throw _mapFirebaseLoginError(e);
    } catch (_) {
      // Bubble unexpected errors to caller.
      throw "auth_unexpected_error";
    }
  }
}
