import 'dart:convert';
import 'package:yack/logic/services/auth/cryptoService.dart';

void main() async {
  print('================ CRYPTO TEST START ================\n');

  const password = 'StrongPassword123!';
  const testMessage = '2500 DZD';

  // --------------------------------------------------
  // 1️⃣ Generate RSA keypair + encrypt private key
  // --------------------------------------------------
  print('1️⃣ Generating RSA keypair and encrypting private key...\n');

  final generated = await CryptoService.generateAndEncryptKeys(password);

  final publicKeyBase64 = generated['publicKey']!;
  final encryptedPrivateKey = generated['encryptedPrivateKey']!;
  final salt = generated['salt']!;
  final iv = generated['iv']!;

  print('Public Key (base64):');
  print(publicKeyBase64);
  print('\nEncrypted Private Key (base64):');
  print(encryptedPrivateKey);
  print('\nSalt (base64): $salt');
  print('IV (base64): $iv\n');

  // --------------------------------------------------
  // 2️⃣ Decrypt private key
  // --------------------------------------------------
  print('2️⃣ Decrypting private key using password...\n');

  final decryptedPrivateKeyBytes = CryptoService.decryptPrivateKey(
    ciphertextBase64: encryptedPrivateKey,
    password: password,
    saltBase64: salt,
    ivBase64: iv,
  );

  print('Decrypted Private Key Bytes (utf8 JSON):');
  print(utf8.decode(decryptedPrivateKeyBytes));
  print('');

  // --------------------------------------------------
  // 3️⃣ Encrypt message with PUBLIC key
  // --------------------------------------------------
  print('3️⃣ Encrypting message with PUBLIC key...\n');
  print('Plaintext: "$testMessage"\n');

  final encryptedMessage = CryptoService.encryptWithPublicKey(
    plaintext: testMessage,
    publicKeyBase64: publicKeyBase64,
  );

  print('Encrypted Message (base64):');
  print(encryptedMessage);
  print('');

  // --------------------------------------------------
  // 4️⃣ Decrypt message with PRIVATE key
  // --------------------------------------------------
  print('4️⃣ Decrypting message with PRIVATE key...\n');

  final decryptedMessage = CryptoService.decryptWithPrivateKey(
    ciphertextBase64: encryptedMessage,
    privateKeyBytes: decryptedPrivateKeyBytes,
  );

  print('Decrypted Message:');
  print(decryptedMessage);
  print('');

  // --------------------------------------------------
  // 5️⃣ Final verification
  // --------------------------------------------------
  print('5️⃣ FINAL CHECK\n');

  if (decryptedMessage == testMessage) {
    print('✅ SUCCESS: Encryption and decryption WORK correctly');
  } else {
    print('❌ FAILURE: Decrypted text does NOT match original');
  }

  print('\n================ CRYPTO TEST END ================');
}
