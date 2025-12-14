import 'package:hive/hive.dart';
import 'package:yack/data/repositories/isar_adapter.dart';
import 'package:yack/logic/services/network/http_handler.dart';
import 'package:yack/logic/services/user/user_service.dart';

/// Service for managing account-related operations
/// Works in conjunction with AuthService for post-authentication account setup
class AccountService {
  AccountService({HttpHandler? httpHandler, UserService? userService})
      : _userService = userService ?? UserService(httpHandler: httpHandler);

  final UserService _userService;

  /// Finalize account setup after Firebase authentication
  /// This should be called after email verification to complete the account setup
  /// with encryption keys for end-to-end encryption
  Future<void> finalizeAccount({
    required String publicKey,
    required String encryptedPrivateKey,
    required String salt,
    required String iv,
  }) async {
    await _userService.finalize(
      publicKey: publicKey,
      encryptedPrivateKey: encryptedPrivateKey,
      salt: salt,
      iv: iv,
    );

    // Cache the profile info locally
    final box = await Hive.openBox('user');
    final cachedFirstName = box.get('firstName');
    final cachedLastName = box.get('lastName');
    if (cachedFirstName != null) {
      await box.put('firstName', cachedFirstName);
    }
    if (cachedLastName != null) {
      await box.put('lastName', cachedLastName);
    }
    await box.put('publicKey', publicKey);
    await box.put('encryptedPrivateKey', encryptedPrivateKey);
    await box.put('privateKeySalt', salt);
    await box.put('privateKeyIV', iv);
    await box.put('isComplete', true);
  }

  /// Fetch and cache user profile from backend
  Future<UserProfile> fetchAndCacheProfile() async {
    final profile = await _userService.getProfile();

    // Cache the profile info locally
    final box = await Hive.openBox('user');
    await box.put('firstName', profile.firstName);
    await box.put('lastName', profile.lastName);
    await box.put('email', profile.email);
    if (profile.publicKey != null) {
      await box.put('publicKey', profile.publicKey);
    }
    if (profile.encryptedPrivateKey != null) {
      await box.put('encryptedPrivateKey', profile.encryptedPrivateKey);
    }
    if (profile.salt != null) {
      await box.put('privateKeySalt', profile.salt);
    }
    if (profile.iv != null) {
      await box.put('privateKeyIV', profile.iv);
    }
    await box.put('isComplete', profile.isComplete);

    return profile;
  }

  /// Get cached profile from local storage
  Future<Map<String, dynamic>> getCachedProfile() async {
    final box = await Hive.openBox('user');
    return {
      'firstName': box.get('firstName'),
      'lastName': box.get('lastName'),
      'email': box.get('email'),
      'publicKey': box.get('publicKey'),
      'encryptedPrivateKey': box.get('encryptedPrivateKey'),
      'salt': box.get('privateKeySalt'),
      'iv': box.get('privateKeyIV'),
      'isComplete': box.get('isComplete') ?? false,
    };
  }

  /// Check if account setup is complete
  Future<bool> isAccountComplete() async {
    final box = await Hive.openBox('user');
    return box.get('isComplete') ?? false;
  }

  /// Update profile name
  Future<void> updateProfileName({String? firstName, String? lastName}) async {
    await _userService.updateProfile(firstName: firstName, lastName: lastName);

    // Update local cache
    final box = await Hive.openBox('user');
    if (firstName != null && firstName.isNotEmpty) {
      await box.put('firstName', firstName);
    }
    if (lastName != null && lastName.isNotEmpty) {
      await box.put('lastName', lastName);
    }
  }

  /// Update encrypted private key (for password change)
  Future<void> updateEncryptedPrivateKey(String encryptedPrivateKey) async {
    await _userService.updatePrivateKey(encryptedPrivateKey);

    // Update local cache
    final box = await Hive.openBox('user');
    await box.put('encryptedPrivateKey', encryptedPrivateKey);
  }

  /// Get cached public key
  Future<String?> getCachedPublicKey() async {
    final box = await Hive.openBox('user');
    return box.get('publicKey');
  }

  /// Get cached encrypted private key
  Future<String?> getCachedEncryptedPrivateKey() async {
    final box = await Hive.openBox('user');
    return box.get('encryptedPrivateKey');
  }

  /// Clear all cached account data (for logout)
  Future<void> clearCachedData() async {
    // Clear Hive user box
    final box = await Hive.openBox('user');
    await box.delete('firstName');
    await box.delete('lastName');
    await box.delete('email');
    await box.delete('publicKey');
    await box.delete('encryptedPrivateKey');
    await box.delete('privateKeySalt');
    await box.delete('privateKeyIV');
    await box.delete('isComplete');
    await box.delete('decryptedPrivateKey');
    await box.delete('userId');

    // Clear all Isar data (contracts, messages, media, notifications)
    await clearAllIsarData();
  }
}
