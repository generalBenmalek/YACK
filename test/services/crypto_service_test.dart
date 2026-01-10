import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:yack/logic/services/auth/cryptoService.dart';

void main() {
  group('CryptoService', () {
    group('generateAndEncryptKeys', () {
      test('generates all required key components', () async {
        const password = 'TestPassword123!';

        final result = await CryptoService.generateAndEncryptKeys(password);

        expect(result.containsKey('publicKey'), true);
        expect(result.containsKey('encryptedPrivateKey'), true);
        expect(result.containsKey('salt'), true);
        expect(result.containsKey('iv'), true);
      });

      test('generates non-empty values for all components', () async {
        const password = 'TestPassword123!';

        final result = await CryptoService.generateAndEncryptKeys(password);

        expect(result['publicKey']!.isNotEmpty, true);
        expect(result['encryptedPrivateKey']!.isNotEmpty, true);
        expect(result['salt']!.isNotEmpty, true);
        expect(result['iv']!.isNotEmpty, true);
      });

      test('generates valid base64 encoded values', () async {
        const password = 'TestPassword123!';

        final result = await CryptoService.generateAndEncryptKeys(password);

        // These should not throw if valid base64
        expect(() => base64Decode(result['publicKey']!), returnsNormally);
        expect(() => base64Decode(result['encryptedPrivateKey']!), returnsNormally);
        expect(() => base64Decode(result['salt']!), returnsNormally);
        expect(() => base64Decode(result['iv']!), returnsNormally);
      });

      test('generates unique keys for each call', () async {
        const password = 'TestPassword123!';

        final result1 = await CryptoService.generateAndEncryptKeys(password);
        final result2 = await CryptoService.generateAndEncryptKeys(password);

        expect(result1['publicKey'], isNot(equals(result2['publicKey'])));
        expect(result1['encryptedPrivateKey'], isNot(equals(result2['encryptedPrivateKey'])));
        expect(result1['salt'], isNot(equals(result2['salt'])));
        expect(result1['iv'], isNot(equals(result2['iv'])));
      });
    });

    group('encryptPrivateKey and decryptPrivateKey', () {
      test('decrypts encrypted private key correctly', () async {
        const password = 'TestPassword123!';

        final generated = await CryptoService.generateAndEncryptKeys(password);

        final decrypted = CryptoService.decryptPrivateKey(
          ciphertextBase64: generated['encryptedPrivateKey']!,
          password: password,
          saltBase64: generated['salt']!,
          ivBase64: generated['iv']!,
        );

        // Decrypted bytes should be valid JSON containing RSA key components
        final jsonStr = utf8.decode(decrypted);
        final keyData = json.decode(jsonStr) as Map<String, dynamic>;

        expect(keyData.containsKey('n'), true);
        expect(keyData.containsKey('d'), true);
        expect(keyData.containsKey('p'), true);
        expect(keyData.containsKey('q'), true);
      });

      test('fails to decrypt with wrong password', () async {
        const password = 'CorrectPassword123!';
        const wrongPassword = 'WrongPassword456!';

        final generated = await CryptoService.generateAndEncryptKeys(password);

        expect(
          () => CryptoService.decryptPrivateKey(
            ciphertextBase64: generated['encryptedPrivateKey']!,
            password: wrongPassword,
            saltBase64: generated['salt']!,
            ivBase64: generated['iv']!,
          ),
          throwsA(anything),
        );
      });
    });

    group('encryptWithPublicKey and decryptWithPrivateKey', () {
      test('encrypts and decrypts message correctly', () async {
        const password = 'TestPassword123!';
        const testMessage = 'Hello, this is a secret message!';

        final generated = await CryptoService.generateAndEncryptKeys(password);
        final privateKeyBytes = CryptoService.decryptPrivateKey(
          ciphertextBase64: generated['encryptedPrivateKey']!,
          password: password,
          saltBase64: generated['salt']!,
          ivBase64: generated['iv']!,
        );

        final encrypted = CryptoService.encryptWithPublicKey(
          plaintext: testMessage,
          publicKeyBase64: generated['publicKey']!,
        );

        final decrypted = CryptoService.decryptWithPrivateKey(
          ciphertextBase64: encrypted,
          privateKeyBytes: privateKeyBytes,
        );

        expect(decrypted, equals(testMessage));
      });

      test('encrypts short message correctly', () async {
        const password = 'TestPassword123!';
        const testMessage = 'Hi';

        final generated = await CryptoService.generateAndEncryptKeys(password);
        final privateKeyBytes = CryptoService.decryptPrivateKey(
          ciphertextBase64: generated['encryptedPrivateKey']!,
          password: password,
          saltBase64: generated['salt']!,
          ivBase64: generated['iv']!,
        );

        final encrypted = CryptoService.encryptWithPublicKey(
          plaintext: testMessage,
          publicKeyBase64: generated['publicKey']!,
        );

        final decrypted = CryptoService.decryptWithPrivateKey(
          ciphertextBase64: encrypted,
          privateKeyBytes: privateKeyBytes,
        );

        expect(decrypted, equals(testMessage));
      });

      test('encrypts numeric message correctly', () async {
        const password = 'TestPassword123!';
        const testMessage = '2500 DZD';

        final generated = await CryptoService.generateAndEncryptKeys(password);
        final privateKeyBytes = CryptoService.decryptPrivateKey(
          ciphertextBase64: generated['encryptedPrivateKey']!,
          password: password,
          saltBase64: generated['salt']!,
          ivBase64: generated['iv']!,
        );

        final encrypted = CryptoService.encryptWithPublicKey(
          plaintext: testMessage,
          publicKeyBase64: generated['publicKey']!,
        );

        final decrypted = CryptoService.decryptWithPrivateKey(
          ciphertextBase64: encrypted,
          privateKeyBytes: privateKeyBytes,
        );

        expect(decrypted, equals(testMessage));
      });

      test('encrypts unicode message correctly', () async {
        const password = 'TestPassword123!';
        const testMessage = 'مرحبا بالعالم 👋';

        final generated = await CryptoService.generateAndEncryptKeys(password);
        final privateKeyBytes = CryptoService.decryptPrivateKey(
          ciphertextBase64: generated['encryptedPrivateKey']!,
          password: password,
          saltBase64: generated['salt']!,
          ivBase64: generated['iv']!,
        );

        final encrypted = CryptoService.encryptWithPublicKey(
          plaintext: testMessage,
          publicKeyBase64: generated['publicKey']!,
        );

        final decrypted = CryptoService.decryptWithPrivateKey(
          ciphertextBase64: encrypted,
          privateKeyBytes: privateKeyBytes,
        );

        expect(decrypted, equals(testMessage));
      });

      test('encrypted output is base64 encoded', () async {
        const password = 'TestPassword123!';
        const testMessage = 'Test message';

        final generated = await CryptoService.generateAndEncryptKeys(password);

        final encrypted = CryptoService.encryptWithPublicKey(
          plaintext: testMessage,
          publicKeyBase64: generated['publicKey']!,
        );

        // Should not throw if valid base64
        expect(() => base64Decode(encrypted), returnsNormally);
      });

      test('same message encrypted twice produces different ciphertext', () async {
        const password = 'TestPassword123!';
        const testMessage = 'Test message';

        final generated = await CryptoService.generateAndEncryptKeys(password);

        final encrypted1 = CryptoService.encryptWithPublicKey(
          plaintext: testMessage,
          publicKeyBase64: generated['publicKey']!,
        );

        final encrypted2 = CryptoService.encryptWithPublicKey(
          plaintext: testMessage,
          publicKeyBase64: generated['publicKey']!,
        );

        // OAEP padding should produce different ciphertext each time
        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('cannot decrypt with wrong private key', () async {
        const password = 'TestPassword123!';
        const testMessage = 'Test message';

        final generated1 = await CryptoService.generateAndEncryptKeys(password);
        final generated2 = await CryptoService.generateAndEncryptKeys(password);

        final privateKeyBytes2 = CryptoService.decryptPrivateKey(
          ciphertextBase64: generated2['encryptedPrivateKey']!,
          password: password,
          saltBase64: generated2['salt']!,
          ivBase64: generated2['iv']!,
        );

        final encrypted = CryptoService.encryptWithPublicKey(
          plaintext: testMessage,
          publicKeyBase64: generated1['publicKey']!, // Encrypt with key1
        );

        // Try to decrypt with key2's private key
        expect(
          () => CryptoService.decryptWithPrivateKey(
            ciphertextBase64: encrypted,
            privateKeyBytes: privateKeyBytes2,
          ),
          throwsA(anything),
        );
      });
    });

    group('generateRSAKeyPair', () {
      test('generates valid RSA key pair', () {
        final keyPair = CryptoService.generateRSAKeyPair();

        expect(keyPair.publicKey, isNotNull);
        expect(keyPair.privateKey, isNotNull);
      });
    });

    group('edge cases', () {
      test('handles empty password', () async {
        const password = '';

        final generated = await CryptoService.generateAndEncryptKeys(password);

        expect(generated['publicKey']!.isNotEmpty, true);
        expect(generated['encryptedPrivateKey']!.isNotEmpty, true);
      });

      test('handles very long password', () async {
        final password = 'A' * 1000;

        final generated = await CryptoService.generateAndEncryptKeys(password);

        expect(generated['publicKey']!.isNotEmpty, true);
        expect(generated['encryptedPrivateKey']!.isNotEmpty, true);
      });

      test('handles special characters in password', () async {
        const password = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`éèà';

        final generated = await CryptoService.generateAndEncryptKeys(password);
        final privateKeyBytes = CryptoService.decryptPrivateKey(
          ciphertextBase64: generated['encryptedPrivateKey']!,
          password: password,
          saltBase64: generated['salt']!,
          ivBase64: generated['iv']!,
        );

        expect(privateKeyBytes.isNotEmpty, true);
      });
    });
  });
}

