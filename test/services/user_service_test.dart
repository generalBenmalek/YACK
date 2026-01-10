import 'package:flutter_test/flutter_test.dart';
import 'package:yack/logic/services/user/user_service.dart';

void main() {
  group('UserProfile', () {
    group('fromJson', () {
      test('parses complete JSON with all fields', () {
        final json = {
          '_id': 'user123',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'publicKey': 'public_key_data',
          'encryptedPrivateKey': 'encrypted_private_key_data',
          'isComplete': true,
          'salt': 'salt_value',
          'iv': 'iv_value',
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.userId, 'user123');
        expect(profile.firstName, 'John');
        expect(profile.lastName, 'Doe');
        expect(profile.email, 'john@example.com');
        expect(profile.publicKey, 'public_key_data');
        expect(profile.encryptedPrivateKey, 'encrypted_private_key_data');
        expect(profile.isComplete, true);
        expect(profile.salt, 'salt_value');
        expect(profile.iv, 'iv_value');
      });

      test('parses JSON with id instead of _id', () {
        final json = {
          'id': 'user123',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'isComplete': true,
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.userId, 'user123');
      });

      test('handles isComplete as false', () {
        final json = {
          '_id': 'user123',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'isComplete': false,
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.isComplete, false);
      });

      test('handles missing optional fields', () {
        final json = {
          '_id': 'user123',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'isComplete': true,
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.publicKey, isNull);
        expect(profile.encryptedPrivateKey, isNull);
        expect(profile.salt, isNull);
        expect(profile.iv, isNull);
      });

      test('handles null values gracefully', () {
        final json = <String, dynamic>{
          '_id': null,
          'firstName': null,
          'lastName': null,
          'email': null,
          'publicKey': null,
          'encryptedPrivateKey': null,
          'isComplete': null,
          'salt': null,
          'iv': null,
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.userId, isNull);
        expect(profile.firstName, '');
        expect(profile.lastName, '');
        expect(profile.email, '');
        expect(profile.publicKey, isNull);
        expect(profile.encryptedPrivateKey, isNull);
        expect(profile.isComplete, false);
        expect(profile.salt, isNull);
        expect(profile.iv, isNull);
      });

      test('handles empty JSON', () {
        final json = <String, dynamic>{};

        final profile = UserProfile.fromJson(json);

        expect(profile.userId, isNull);
        expect(profile.firstName, '');
        expect(profile.lastName, '');
        expect(profile.email, '');
        expect(profile.isComplete, false);
      });

      test('converts non-string values to strings', () {
        final json = {
          '_id': 12345,
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'isComplete': true,
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.userId, '12345');
      });

      test('isComplete defaults to false for invalid values', () {
        final json = {
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'isComplete': 'yes', // Invalid value, not a boolean
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.isComplete, false);
      });

      test('isComplete handles truthy string value', () {
        final json = {
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'isComplete': 1, // Truthy but not boolean true
        };

        final profile = UserProfile.fromJson(json);

        // Only accepts boolean true
        expect(profile.isComplete, false);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final profile = UserProfile(
          userId: 'user123',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          publicKey: 'public_key_data',
          encryptedPrivateKey: 'encrypted_private_key_data',
          isComplete: true,
          salt: 'salt_value',
          iv: 'iv_value',
        );

        final json = profile.toJson();

        expect(json['userId'], 'user123');
        expect(json['firstName'], 'John');
        expect(json['lastName'], 'Doe');
        expect(json['email'], 'john@example.com');
        expect(json['publicKey'], 'public_key_data');
        expect(json['encryptedPrivateKey'], 'encrypted_private_key_data');
        expect(json['isComplete'], true);
        expect(json['salt'], 'salt_value');
        expect(json['iv'], 'iv_value');
      });

      test('serializes null values correctly', () {
        final profile = UserProfile(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          isComplete: false,
        );

        final json = profile.toJson();

        expect(json['userId'], isNull);
        expect(json['publicKey'], isNull);
        expect(json['encryptedPrivateKey'], isNull);
        expect(json['salt'], isNull);
        expect(json['iv'], isNull);
      });

      test('isComplete is serialized as boolean', () {
        final completeProfile = UserProfile(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          isComplete: true,
        );

        final incompleteProfile = UserProfile(
          firstName: 'Jane',
          lastName: 'Doe',
          email: 'jane@example.com',
          isComplete: false,
        );

        expect(completeProfile.toJson()['isComplete'], true);
        expect(incompleteProfile.toJson()['isComplete'], false);
      });
    });

    group('round-trip serialization', () {
      test('toJson then fromJson preserves all data', () {
        final original = UserProfile(
          userId: 'user123',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          publicKey: 'public_key_data',
          encryptedPrivateKey: 'encrypted_private_key_data',
          isComplete: true,
          salt: 'salt_value',
          iv: 'iv_value',
        );

        final json = original.toJson();
        // Convert userId back to _id for fromJson
        json['_id'] = json['userId'];
        final restored = UserProfile.fromJson(json);

        expect(restored.userId, original.userId);
        expect(restored.firstName, original.firstName);
        expect(restored.lastName, original.lastName);
        expect(restored.email, original.email);
        expect(restored.publicKey, original.publicKey);
        expect(restored.encryptedPrivateKey, original.encryptedPrivateKey);
        expect(restored.isComplete, original.isComplete);
        expect(restored.salt, original.salt);
        expect(restored.iv, original.iv);
      });
    });
  });
}

