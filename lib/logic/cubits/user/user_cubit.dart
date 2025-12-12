import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/services/user/user_service.dart';

import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit({UserService? service})
      : _service = service ?? UserService(),
        super(const UserInitial());

  final UserService _service;

  /// Complete account setup with verified email, name, and encryption keys.
  Future<void> finalize({
    required String firstName,
    required String lastName,
    required String publicKey,
    required String encryptedPrivateKey,
  }) async {
    emit(const UserLoading());
    try {
      await _service.finalize(
        firstName: firstName,
        lastName: lastName,
        publicKey: publicKey,
        encryptedPrivateKey: encryptedPrivateKey,
      );
      emit(const UserFinalizeSuccess());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Get user profile with keys.
  Future<void> getProfile() async {
    emit(const UserLoading());
    try {
      final profile = await _service.getProfile();
      emit(UserProfileLoaded(profile));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Update encrypted private key.
  Future<void> updatePrivateKey(String encryptedPrivateKey) async {
    emit(const UserLoading());
    try {
      await _service.updatePrivateKey(encryptedPrivateKey);
      emit(const UserUpdateSuccess());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Update profile info (firstName, lastName).
  Future<void> updateProfile({String? firstName, String? lastName}) async {
    emit(const UserLoading());
    try {
      await _service.updateProfile(firstName: firstName, lastName: lastName);
      emit(const UserUpdateSuccess());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

