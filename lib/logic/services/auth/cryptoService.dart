import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class CryptoService {
  CryptoService._(); // no instances

  // -----------------------------
  // CONFIG
  // -----------------------------
  static const int _argonIterations = 3;
  // We'll use memoryPowerOf2 = 16 -> 2^16 KB = 65536 KB = 64 MB
  static const int _argonMemoryPowerOf2 = 16; // use memoryPowerOf2, not raw KB
  static const int _argonParallelism = 1;
  static const int _keyLength = 32; // 256-bit AES key

  // -----------------------------
  // RANDOM HELPERS
  // -----------------------------
  static Uint8List _randomBytes(int length) {
    final rand = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => rand.nextInt(256)),
    );
  }

  // -----------------------------
  // ARGON2id KEY DERIVATION
  // -----------------------------
  static Uint8List _deriveKey({
    required String password,
    required Uint8List salt,
  }) {
    final argon2 = Argon2BytesGenerator()
      ..init(
        // Use memoryPowerOf2 for 64MB (2^16 KB)
        Argon2Parameters(
          Argon2Parameters.ARGON2_id,
          salt,
          iterations: _argonIterations,
          memoryPowerOf2: _argonMemoryPowerOf2,
          lanes: _argonParallelism,
          version: Argon2Parameters.ARGON2_VERSION_13,
          desiredKeyLength: _keyLength,
        ),
      );

    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    final key = Uint8List(_keyLength);

    // Correct method for this API
    argon2.deriveKey(passwordBytes, 0, key, 0);

    return key;
  }

  // -----------------------------
  // ENCRYPT PRIVATE KEY (AES-GCM)
  // -----------------------------
  static Map<String, String> encryptPrivateKey({
    required Uint8List privateKeyBytes,
    required String password,
  }) {
    final salt = _randomBytes(16);
    final iv = _randomBytes(12);

    final key = _deriveKey(
      password: password,
      salt: salt,
    );

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(key),
          128,
          iv,
          Uint8List(0),
        ),
      );

    final ciphertext = cipher.process(privateKeyBytes);

    return {
      'ciphertext': base64Encode(ciphertext),
      'salt': base64Encode(salt),
      'iv': base64Encode(iv),
    };
  }

  // -----------------------------
  // DECRYPT PRIVATE KEY
  // -----------------------------
  static Uint8List decryptPrivateKey({
    required String ciphertextBase64,
    required String password,
    required String saltBase64,
    required String ivBase64,
  }) {
    final ciphertext = base64Decode(ciphertextBase64);
    final salt = base64Decode(saltBase64);
    final iv = base64Decode(ivBase64);

    final key = _deriveKey(
      password: password,
      salt: salt,
    );

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(key),
          128,
          iv,
          Uint8List(0),
        ),
      );

    return cipher.process(ciphertext);
  }

  static Future<Map<String, String>> generateAndEncryptKeys(String password) async {
    final keyPair = generateRSAKeyPair();
    final encrypted = encryptPrivateKey(
      privateKeyBytes: _encodeRSAPrivateKey(keyPair.privateKey as RSAPrivateKey),
      password: password,
    );
    return {
      'publicKey': _encodeRSAPublicKey(keyPair.publicKey as RSAPublicKey),
      'privateKey': base64Encode(_encodeRSAPrivateKey(keyPair.privateKey as RSAPrivateKey)),
      'encryptedPrivateKey': encrypted['ciphertext']!,
      'salt': encrypted['salt']!,
      'iv': encrypted['iv']!,
    };
  }

  // -----------------------------
  // RSA KEY PAIR GENERATION
  // -----------------------------
  static AsymmetricKeyPair<PublicKey, PrivateKey> generateRSAKeyPair() {
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        _secureRandom(),
      ));
    return keyGen.generateKeyPair();
  }

  static SecureRandom _secureRandom() {
    final secureRandom = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(256));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  // -----------------------------
  // RSA KEY ENCODING/DECODING
  // -----------------------------
  static String _encodeRSAPublicKey(RSAPublicKey key) {
    final map = {
      'n': key.modulus.toString(),
      'e': key.exponent.toString(),
    };
    return base64Encode(utf8.encode(json.encode(map)));
  }

  static RSAPublicKey _decodeRSAPublicKey(String base64Key) {
    final jsonStr = utf8.decode(base64Decode(base64Key));
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return RSAPublicKey(
      BigInt.parse(map['n'] as String),
      BigInt.parse(map['e'] as String),
    );
  }

  static Uint8List _encodeRSAPrivateKey(RSAPrivateKey key) {
    final map = {
      'n': key.modulus.toString(),
      'd': key.privateExponent.toString(),
      'p': key.p.toString(),
      'q': key.q.toString(),
    };
    return Uint8List.fromList(utf8.encode(json.encode(map)));
  }

  static RSAPrivateKey _decodeRSAPrivateKey(Uint8List bytes) {
    final jsonStr = utf8.decode(bytes);
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return RSAPrivateKey(
      BigInt.parse(map['n'] as String),
      BigInt.parse(map['d'] as String),
      BigInt.parse(map['p'] as String),
      BigInt.parse(map['q'] as String),
    );
  }

  // -----------------------------
  // ENCRYPT STRING WITH PUBLIC KEY (from base64)
  // -----------------------------
  static String encryptWithPublicKey({
    required String plaintext,
    required String publicKeyBase64,
  }) {
    final publicKey = _decodeRSAPublicKey(publicKeyBase64);
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(
        true,
        PublicKeyParameter<RSAPublicKey>(publicKey),
      );

    final encrypted = encryptor.process(
      Uint8List.fromList(utf8.encode(plaintext)),
    );

    return base64Encode(encrypted);
  }

  // -----------------------------
  // DECRYPT STRING WITH PRIVATE KEY (from Uint8List bytes)
  // -----------------------------
  static String decryptWithPrivateKey({
    required String ciphertextBase64,
    required Uint8List privateKeyBytes,
  }) {
    final privateKey = _decodeRSAPrivateKey(privateKeyBytes);
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(
        false,
        PrivateKeyParameter<RSAPrivateKey>(privateKey),
      );

    final decrypted = decryptor.process(
      base64Decode(ciphertextBase64),
    );

    return utf8.decode(decrypted);
  }
}
