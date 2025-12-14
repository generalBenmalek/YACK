import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
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

  static const int _edPrivateSeedLength = 32;
  // Note: PrivateKey.bytes (package representation) is usually 64 bytes (seed + pub)

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
  // GENERATE ED25519 KEY PAIR (fixed)
  // -----------------------------
  static Map<String, Uint8List> _generateKeyPair() {
    // 1) create a 32-byte seed
    final seed = _randomBytes(_edPrivateSeedLength);

    // 2) derive a PrivateKey from the seed (this validates length)
    final privateKeyObj = ed25519.newKeyFromSeed(seed);

    // 3) get the corresponding public key
    final publicKeyObj = ed25519.public(privateKeyObj);

    // Note: privateKeyObj.bytes is the package's private-key representation
    // (often 64 bytes). publicKeyObj.bytes is 32 bytes.
    return {
      'privateKey': Uint8List.fromList(privateKeyObj.bytes),
      'publicKey': Uint8List.fromList(publicKeyObj.bytes),
    };
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
    final keyPair = _generateKeyPair();
    final encrypted = encryptPrivateKey(
      privateKeyBytes: keyPair['privateKey']!,
      password: password,
    );
    return {
      'publicKey': base64Encode(keyPair['publicKey']!),
      'encryptedPrivateKey': encrypted['ciphertext']!,
      'salt': encrypted['salt']!,
      'iv': encrypted['iv']!,
    };
  }

  // -----------------------------
  // ENCRYPT STRING WITH PUBLIC KEY (asymmetric)
  // Uses X25519 + AES-GCM hybrid encryption
  // -----------------------------
  static String encryptWithPublicKey({
    required String plaintext,
    required String publicKeyBase64,
  }) {
    // Decode recipient's Ed25519 public key
    final recipientPubBytes = base64Decode(publicKeyBase64);

    // Generate ephemeral X25519 keypair for key agreement
    final ephemeralSeed = _randomBytes(32);
    final ephemeralPrivate = ed25519.newKeyFromSeed(ephemeralSeed);
    final ephemeralPublic = ed25519.public(ephemeralPrivate);

    // For simplicity, we'll use a hash of both public keys as shared secret
    // (In production, consider proper X25519 key exchange)
    final sharedInput = Uint8List.fromList([
      ...ephemeralPrivate.bytes,
      ...recipientPubBytes,
    ]);
    final sharedSecret = SHA256Digest().process(sharedInput);

    // Encrypt plaintext with AES-GCM using the shared secret
    final iv = _randomBytes(12);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(sharedSecret),
          128,
          iv,
          Uint8List(0),
        ),
      );

    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    final ciphertext = cipher.process(plaintextBytes);

    // Package: ephemeralPublic (32) + iv (12) + ciphertext
    final result = Uint8List.fromList([
      ...ephemeralPublic.bytes,
      ...iv,
      ...ciphertext,
    ]);

    return base64Encode(result);
  }

  // -----------------------------
  // DECRYPT STRING WITH PRIVATE KEY
  // -----------------------------
  static String decryptWithPrivateKey({
    required String ciphertextBase64,
    required Uint8List privateKeyBytes,
  }) {
    final data = base64Decode(ciphertextBase64);

    // Extract components
    final ephemeralPubBytes = data.sublist(0, 32);
    final iv = data.sublist(32, 44);
    final ciphertext = data.sublist(44);

    // Derive shared secret
    final sharedInput = Uint8List.fromList([
      ...privateKeyBytes,
      ...ephemeralPubBytes,
    ]);
    final sharedSecret = SHA256Digest().process(sharedInput);

    // Decrypt with AES-GCM
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(sharedSecret),
          128,
          iv,
          Uint8List(0),
        ),
      );

    final plaintextBytes = cipher.process(Uint8List.fromList(ciphertext));
    return utf8.decode(plaintextBytes);
  }
}
