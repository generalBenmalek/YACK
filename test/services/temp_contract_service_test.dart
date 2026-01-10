import 'package:flutter_test/flutter_test.dart';
import 'package:yack/data/models/contract/temp_contract.dart';

void main() {
  group('TempContract', () {
    group('fromJson', () {
      test('parses complete JSON with all fields', () {
        final json = {
          'tempID': 'temp123',
          'contractId': 'contract456',
          'hash': 'hash789',
          'userA': {
            '_id': 'userA_id',
            'firstName': 'John',
            'lastName': 'Doe',
          },
          'userB': {
            '_id': 'userB_id',
            'firstName': 'Jane',
            'lastName': 'Smith',
          },
          'userASigned': true,
          'userBSigned': false,
          'updatedAt': '2025-01-10T12:00:00.000Z',
        };

        final contract = TempContract.fromJson(json);

        expect(contract.tempId, 'temp123');
        expect(contract.contractId, 'contract456');
        expect(contract.hash, 'hash789');
        expect(contract.userAId, 'userA_id');
        expect(contract.userAName, 'John Doe');
        expect(contract.userBId, 'userB_id');
        expect(contract.userBName, 'Jane Smith');
        expect(contract.userASigned, true);
        expect(contract.userBSigned, false);
        expect(contract.updatedAt?.year, 2025);
      });

      test('parses JSON with tempId instead of tempID', () {
        final json = {
          'tempId': 'temp123',
          'userASigned': false,
          'userBSigned': false,
        };

        final contract = TempContract.fromJson(json);

        expect(contract.tempId, 'temp123');
      });

      test('parses JSON with _id instead of tempID', () {
        final json = {
          '_id': 'temp123',
          'userASigned': false,
          'userBSigned': false,
        };

        final contract = TempContract.fromJson(json);

        expect(contract.tempId, 'temp123');
      });

      test('parses JSON with id instead of tempID', () {
        final json = {
          'id': 'temp123',
          'userASigned': false,
          'userBSigned': false,
        };

        final contract = TempContract.fromJson(json);

        expect(contract.tempId, 'temp123');
      });

      test('parses userA as string ID', () {
        final json = {
          'tempID': 'temp123',
          'userA': 'userA_string_id',
          'userASigned': false,
          'userBSigned': false,
        };

        final contract = TempContract.fromJson(json);

        // When userA is a string, it's used as userAName via fallback
        expect(contract.userAName, 'userA_string_id');
      });

      test('parses userB as string ID', () {
        final json = {
          'tempID': 'temp123',
          'userB': 'userB_string_id',
          'userASigned': false,
          'userBSigned': false,
        };

        final contract = TempContract.fromJson(json);

        expect(contract.userBName, 'userB_string_id');
      });

      test('uses fallback userAId and userAName fields', () {
        final json = {
          'tempID': 'temp123',
          'userAId': 'fallback_userA_id',
          'userAName': 'Fallback UserA Name',
          'userASigned': false,
          'userBSigned': false,
        };

        final contract = TempContract.fromJson(json);

        expect(contract.userAId, 'fallback_userA_id');
        expect(contract.userAName, 'Fallback UserA Name');
      });

      test('parses userASigned and userBSigned as true', () {
        final json = {
          'tempID': 'temp123',
          'userASigned': true,
          'userBSigned': true,
        };

        final contract = TempContract.fromJson(json);

        expect(contract.userASigned, true);
        expect(contract.userBSigned, true);
      });

      test('parses alternate field names userA_signed and userB_signed', () {
        final json = {
          'tempID': 'temp123',
          'userA_signed': true,
          'userB_signed': true,
        };

        final contract = TempContract.fromJson(json);

        expect(contract.userASigned, true);
        expect(contract.userBSigned, true);
      });

      test('parses updated_at alternate field name', () {
        final json = {
          'tempID': 'temp123',
          'updated_at': '2025-01-10T12:00:00.000Z',
        };

        final contract = TempContract.fromJson(json);

        expect(contract.updatedAt?.year, 2025);
      });

      test('parses updatedAt from milliseconds timestamp', () {
        final timestamp = DateTime(2025, 1, 10, 12, 0, 0).millisecondsSinceEpoch;
        final json = {
          'tempID': 'temp123',
          'updatedAt': timestamp,
        };

        final contract = TempContract.fromJson(json);

        expect(contract.updatedAt?.year, 2025);
        expect(contract.updatedAt?.month, 1);
        expect(contract.updatedAt?.day, 10);
      });

      test('throws ArgumentError when tempId is missing', () {
        final json = <String, dynamic>{
          'contractId': 'contract456',
          'hash': 'hash789',
        };

        expect(
          () => TempContract.fromJson(json),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError when tempId is empty', () {
        final json = {
          'tempID': '',
          'contractId': 'contract456',
        };

        expect(
          () => TempContract.fromJson(json),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('handles missing optional fields', () {
        final json = {
          'tempID': 'temp123',
        };

        final contract = TempContract.fromJson(json);

        expect(contract.tempId, 'temp123');
        expect(contract.contractId, isNull);
        expect(contract.hash, isNull);
        expect(contract.userAId, isNull);
        expect(contract.userAName, isNull);
        expect(contract.userBId, isNull);
        expect(contract.userBName, isNull);
        expect(contract.userASigned, false);
        expect(contract.userBSigned, false);
        expect(contract.updatedAt, isNull);
      });

      test('parses userA object with only first name', () {
        final json = {
          'tempID': 'temp123',
          'userA': {
            '_id': 'userA_id',
            'firstName': 'John',
          },
        };

        final contract = TempContract.fromJson(json);

        expect(contract.userAName, 'John');
      });

      test('parses userA object with only last name', () {
        final json = {
          'tempID': 'temp123',
          'userA': {
            '_id': 'userA_id',
            'lastName': 'Doe',
          },
        };

        final contract = TempContract.fromJson(json);

        expect(contract.userAName, 'Doe');
      });

      test('parses userA object with name field as fallback', () {
        final json = {
          'tempID': 'temp123',
          'userA': {
            '_id': 'userA_id',
            'name': 'John Doe',
          },
        };

        final contract = TempContract.fromJson(json);

        expect(contract.userAName, 'John Doe');
      });

      test('uses id field in userA object', () {
        final json = {
          'tempID': 'temp123',
          'userA': {
            'id': 'userA_id_from_id_field',
            'firstName': 'John',
          },
        };

        final contract = TempContract.fromJson(json);

        expect(contract.userAId, 'userA_id_from_id_field');
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final updatedAt = DateTime(2025, 1, 10, 12, 0, 0);
        final contract = TempContract(
          tempId: 'temp123',
          contractId: 'contract456',
          hash: 'hash789',
          userAId: 'userA_id',
          userAName: 'John Doe',
          userBId: 'userB_id',
          userBName: 'Jane Smith',
          userASigned: true,
          userBSigned: false,
          updatedAt: updatedAt,
        );

        final json = contract.toJson();

        expect(json['tempID'], 'temp123');
        expect(json['contractId'], 'contract456');
        expect(json['hash'], 'hash789');
        expect(json['userAId'], 'userA_id');
        expect(json['userAName'], 'John Doe');
        expect(json['userBId'], 'userB_id');
        expect(json['userBName'], 'Jane Smith');
        expect(json['userASigned'], true);
        expect(json['userBSigned'], false);
        expect(json['updatedAt'], updatedAt.toIso8601String());
      });

      test('handles null optional fields', () {
        final contract = TempContract(
          tempId: 'temp123',
        );

        final json = contract.toJson();

        expect(json['tempID'], 'temp123');
        expect(json['contractId'], isNull);
        expect(json['hash'], isNull);
        expect(json['userAId'], isNull);
        expect(json['userAName'], isNull);
        expect(json['userBId'], isNull);
        expect(json['userBName'], isNull);
        expect(json['userASigned'], false);
        expect(json['userBSigned'], false);
        expect(json['updatedAt'], isNull);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final original = TempContract(
          tempId: 'temp123',
          contractId: 'contract456',
          userAId: 'userA_id',
          userAName: 'John Doe',
          userASigned: false,
          userBSigned: false,
        );

        final copy = original.copyWith(
          userASigned: true,
          userBName: 'Jane Smith',
        );

        expect(copy.tempId, 'temp123');
        expect(copy.contractId, 'contract456');
        expect(copy.userAId, 'userA_id');
        expect(copy.userAName, 'John Doe');
        expect(copy.userASigned, true); // Updated
        expect(copy.userBName, 'Jane Smith'); // Updated
        expect(copy.userBSigned, false);
      });

      test('preserves original when no updates provided', () {
        final original = TempContract(
          tempId: 'temp123',
          contractId: 'contract456',
          hash: 'hash789',
          userAId: 'userA_id',
          userAName: 'John Doe',
          userBId: 'userB_id',
          userBName: 'Jane Smith',
          userASigned: true,
          userBSigned: true,
          updatedAt: DateTime(2025, 1, 10),
        );

        final copy = original.copyWith();

        expect(copy.tempId, original.tempId);
        expect(copy.contractId, original.contractId);
        expect(copy.hash, original.hash);
        expect(copy.userAId, original.userAId);
        expect(copy.userAName, original.userAName);
        expect(copy.userBId, original.userBId);
        expect(copy.userBName, original.userBName);
        expect(copy.userASigned, original.userASigned);
        expect(copy.userBSigned, original.userBSigned);
        expect(copy.updatedAt, original.updatedAt);
      });

      test('can update tempId', () {
        final original = TempContract(tempId: 'temp123');
        final copy = original.copyWith(tempId: 'newTempId');

        expect(copy.tempId, 'newTempId');
      });
    });
  });
}

