import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:yack/logic/services/auth/cryptoService.dart';
import 'package:yack/logic/services/auth/init_account_service.dart';
import 'package:yack/logic/services/user/user_service.dart';

import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit({UserService? service, InitAccountService? initAccountService})
      : _service = service ?? UserService(),
        _initAccountService = initAccountService ?? InitAccountService(userService: service ?? UserService()),
        super(const UserInitial());

  final UserService _service;
  final InitAccountService _initAccountService;

  /// Complete account setup with verified email, name, and encryption keys.
  Future<void> finalize({
    required String password,
  }) async {
    emit(const UserLoading());
    try {
      await _initAccountService.initializeAccount(password);
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

      try {
        final box = await Hive.openBox('user');
        await box.put('encryptedPrivateKey', profile.encryptedPrivateKey);
        await box.put('privateKeySalt', profile.salt);
        await box.put('privateKeyIV', profile.iv);

        await box.put('firstName', profile.firstName);
        await box.put('lastName', profile.lastName);

        await box.put('email', profile.email);
        await box.put('publicKey', profile.publicKey);

      } catch (e) {
        // Ignore caching errors
      }


      emit(UserProfileLoaded(profile));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Update encrypted private key.
  Future<void> updatePrivateKey(String encryptedPrivateKey) async {
    emit(const UserLoading());
    try {
      await _service.updatePrivateKey(encryptedPrivateKey: encryptedPrivateKey, salt: '', iv: '');
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

  /// Decrypt and load private key using password.
  /// Fetches encrypted key from Hive cache and decrypts it.
  Future<void> decryptAndLoad({required String password}) async {
    emit(const UserLoading());
    try {
      final box = await Hive.openBox('user');
      final encryptedPrivateKey = box.get('encryptedPrivateKey') as String?;
      final salt = box.get('privateKeySalt') as String?;
      final iv = box.get('privateKeyIV') as String?;

      if (encryptedPrivateKey == null || salt == null || iv == null) {
        emit(const UserDecryptError('Missing encryption data. Please set up your account again.'));
        return;
      }

      // Attempt decryption - will throw if password is wrong
      final decryptedKey = CryptoService.decryptPrivateKey(
        ciphertextBase64: encryptedPrivateKey,
        password: password,
        saltBase64: salt,
        ivBase64: iv,
      );

      // Store decrypted key in memory (not persisted)
      await box.put('decryptedPrivateKey', decryptedKey);

      emit(const UserDecryptSuccess());
    } catch (e) {
      emit(UserDecryptError('Invalid password or corrupted data: ${e.toString()}'));
    }
  }
}
