import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:yack/logic/cubits/auth/change_encryption_password_state.dart';
import 'package:yack/logic/services/auth/account_service.dart';
import 'package:yack/logic/services/auth/cryptoService.dart';

class ChangeEncryptionPasswordCubit extends Cubit<ChangeEncryptionPasswordState> {
  ChangeEncryptionPasswordCubit() : super(ChangeEncryptionPasswordInitial());

  Future<void> changeEncryptionPassword(
    GlobalKey<FormState> formKey,
    String oldPassword,
    String newPassword,
  ) async {
    if (!formKey.currentState!.validate()) {
      emit(ChangeEncryptionPasswordError('auth_invalid_input'));
      return;
    }

    emit(ChangeEncryptionPasswordLoading());

    try {
      final box = await Hive.openBox('user');
      final encryptedPrivateKey = box.get('encryptedPrivateKey') as String?;
      final salt = box.get('privateKeySalt') as String?;
      final iv = box.get('privateKeyIV') as String?;

      if (encryptedPrivateKey == null || salt == null || iv == null) {
        emit(ChangeEncryptionPasswordError('missing_encryption_data'));
        return;
      }

      // Decrypt with old password
      final privateKeyBytes = CryptoService.decryptPrivateKey(
        ciphertextBase64: encryptedPrivateKey,
        password: oldPassword,
        saltBase64: salt,
        ivBase64: iv,
      );

      // Re-encrypt with new password
      final newEncrypted = CryptoService.encryptPrivateKey(
        privateKeyBytes: privateKeyBytes,
        password: newPassword,
      );

      // Update on backend and locally
      final accountService = AccountService();
      await accountService.updateEncryptedPrivateKey(
        encryptedPrivateKey: newEncrypted['ciphertext']!,
        salt: newEncrypted['salt']!,
        iv: newEncrypted['iv']!,
      );

      emit(ChangeEncryptionPasswordSuccess());
    } catch (e) {
      print('[ChangeEncryptionPasswordCubit] Error: $e');
      // If decryption fails, it's likely wrong password
      if (e.toString().contains('InvalidCipherText') ||
          e.toString().contains('mac check')) {
        emit(ChangeEncryptionPasswordError('auth_wrong_old_password'));
      } else {
        emit(ChangeEncryptionPasswordError('generic_error'));
      }
    }
  }
}

