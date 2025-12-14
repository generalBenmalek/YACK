import 'package:hive/hive.dart';
import 'package:yack/logic/services/network/http_handler.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String? publicKey;
  final String? encryptedPrivateKey;
  final bool isComplete;
  final String? salt;
  final String? iv;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.publicKey,
    this.encryptedPrivateKey,
    required this.isComplete,
    this.salt,
    this.iv,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      publicKey: json['publicKey']?.toString(),
      encryptedPrivateKey: json['encryptedPrivateKey']?.toString(),
      isComplete: json['isComplete'] == true,
      salt: json['salt']?.toString(),
      iv: json['iv']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'publicKey': publicKey,
      'encryptedPrivateKey': encryptedPrivateKey,
      'isComplete': isComplete,
      'salt': salt,
      'iv': iv,
    };
  }
}

class UserService {
  UserService({HttpHandler? httpHandler})
      : _http = httpHandler ?? HttpHandler();

  final HttpHandler _http;

  /// Complete account setup with verified email, name, and encryption keys.
  /// Required fields: firstName, lastName, publicKey, encryptedPrivateKey
  Future<void> finalize({
    required String publicKey,
    required String encryptedPrivateKey,
    required String salt,
    required String iv,
  }) async {
    final box = await Hive.openBox('user');
    final firstName = box.get('firstName')?.toString();
    final lastName = box.get('lastName')?.toString();
    if (firstName == null || firstName.isEmpty || lastName == null || lastName.isEmpty) {
      throw StateError('Missing cached profile name.');
    }
    await _http.post('/user/finalize', body: {
      'firstName': firstName,
      'lastName': lastName,
      'publicKey': publicKey,
      'encryptedPrivateKey': encryptedPrivateKey,
      'salt': salt,
      'iv': iv,
    });
  }

  /// Get user profile with keys.
  /// Returns: firstName, lastName, email, publicKey, encryptedPrivateKey, isComplete
  Future<UserProfile> getProfile() async {
    final response = await _http.get('/user/profile');
    return UserProfile.fromJson(_extractData(response));
  }

  /// Update encrypted private key.
  /// Used for re-encrypting the same private key with a new password.
  Future<void> updatePrivateKey(String encryptedPrivateKey) async {
    await _http.put('/user/private-key', body: {
      'encryptedPrivateKey': encryptedPrivateKey,
    });
  }

  /// Update profile info (firstName, lastName).
  /// At least one field required.
  Future<void> updateProfile({String? firstName, String? lastName}) async {
    final body = <String, dynamic>{};
    if (firstName != null && firstName.isNotEmpty) {
      body['firstName'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      body['lastName'] = lastName;
    }
    if (body.isEmpty) {
      throw ArgumentError('At least one field (firstName or lastName) is required');
    }
    await _http.put('/user/profile', body: body);
  }

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      // Check for nested data structures
      final data = response['data'] ?? response['user'] ?? response;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return Map<String, dynamic>.from(response);
    }
    if (response is Map) {
      return response.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }
}
