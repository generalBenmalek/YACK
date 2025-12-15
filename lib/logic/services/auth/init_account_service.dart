import 'package:hive/hive.dart';
import 'package:yack/logic/services/auth/cryptoService.dart';
import 'package:yack/logic/services/user/user_service.dart';

class InitAccountService {
  InitAccountService({UserService? userService})
      : _userService = userService ?? UserService();

  final UserService _userService;

  Future<void> initializeAccount(String password) async {
    final keyBundle = await CryptoService.generateAndEncryptKeys(password);
    await _userService.finalize(
      publicKey: keyBundle['publicKey']!,
      encryptedPrivateKey: keyBundle['encryptedPrivateKey']!,
      salt: keyBundle['salt']!,
      iv: keyBundle['iv']!,
    );

    // Decrypt the private key to store it for immediate use
    final decryptedPrivateKey = CryptoService.decryptPrivateKey(
      ciphertextBase64: keyBundle['encryptedPrivateKey']!,
      password: password,
      saltBase64: keyBundle['salt']!,
      ivBase64: keyBundle['iv']!,
    );

    final box = await Hive.openBox('user');
    await box.put('publicKey', keyBundle['publicKey']);
    await box.put('encryptedPrivateKey', keyBundle['encryptedPrivateKey']);
    await box.put('privateKeySalt', keyBundle['salt']);
    await box.put('privateKeyIV', keyBundle['iv']);
    await box.put('decryptedPrivateKey', decryptedPrivateKey);
    await box.put('isComplete', true);
  }
}
