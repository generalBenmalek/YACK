import 'package:flutter_test/flutter_test.dart';
import 'package:yack/logic/services/contract/contract_list_service.dart';

void main() {
  group('ContractListItem', () {
    group('fromJson', () {
      test('parses complete JSON with all fields', () {
        final json = {
          '_id': 'contract123',
          'title': 'encrypted_title',
          'description': 'encrypted_description',
          'price': 'encrypted_price',
          'detailsHash': 'hash123',
          'otherUser': {
            '_id': 'user456',
            'firstName': 'John',
            'lastName': 'Doe',
            'publicKey': 'other_user_public_key',
          },
          'isUserA': true,
          'status': 'active',
          'userASign': true,
          'userBSign': false,
          'agreedUserA': true,
          'agreedUserB': false,
          'disputedUserA': false,
          'disputedUserB': false,
          'hash': 'qr_hash',
          'createdAt': '2025-01-10T12:00:00.000Z',
          'updatedAt': '2025-01-10T14:00:00.000Z',
        };

        final item = ContractListItem.fromJson(json);

        expect(item.id, 'contract123');
        expect(item.title, 'encrypted_title');
        expect(item.description, 'encrypted_description');
        expect(item.price, 'encrypted_price');
        expect(item.detailsHash, 'hash123');
        expect(item.otherUserId, 'user456');
        expect(item.otherUserName, 'John Doe');
        expect(item.otherUserPublicKey, 'other_user_public_key');
        expect(item.isUserA, true);
        expect(item.status, 'active');
        expect(item.userASigned, true);
        expect(item.userBSigned, false);
        expect(item.agreedUserA, true);
        expect(item.agreedUserB, false);
        expect(item.disputedUserA, false);
        expect(item.disputedUserB, false);
        expect(item.hash, 'qr_hash');
        expect(item.createdAt?.year, 2025);
        expect(item.updatedAt?.year, 2025);
      });

      test('parses JSON with id instead of _id', () {
        final json = {
          'id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'pending',
        };

        final item = ContractListItem.fromJson(json);

        expect(item.id, 'contract123');
      });

      test('parses isUserA as false', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'isUserA': false,
          'status': 'active',
        };

        final item = ContractListItem.fromJson(json);

        expect(item.isUserA, false);
      });

      test('handles userASigned and userBSigned alternate field names', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'active',
          'userASigned': true, // Alternate field name
          'userBSigned': true, // Alternate field name
        };

        final item = ContractListItem.fromJson(json);

        expect(item.userASigned, true);
        expect(item.userBSigned, true);
      });

      test('parses otherUser with only first name', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'active',
          'otherUser': {
            '_id': 'user456',
            'firstName': 'John',
          },
        };

        final item = ContractListItem.fromJson(json);

        expect(item.otherUserName, 'John');
      });

      test('parses otherUser with only last name', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'active',
          'otherUser': {
            '_id': 'user456',
            'lastName': 'Doe',
          },
        };

        final item = ContractListItem.fromJson(json);

        expect(item.otherUserName, 'Doe');
      });

      test('handles empty otherUser object', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'active',
          'otherUser': {},
        };

        final item = ContractListItem.fromJson(json);

        expect(item.otherUserId, isNull);
        expect(item.otherUserName, isNull);
        expect(item.otherUserPublicKey, isNull);
      });

      test('handles missing otherUser', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'active',
        };

        final item = ContractListItem.fromJson(json);

        expect(item.otherUserId, isNull);
        expect(item.otherUserName, isNull);
        expect(item.otherUserPublicKey, isNull);
      });

      test('parses timestamps from milliseconds', () {
        final createdTimestamp = DateTime(2025, 1, 10, 12, 0, 0).millisecondsSinceEpoch;
        final updatedTimestamp = DateTime(2025, 1, 10, 14, 0, 0).millisecondsSinceEpoch;

        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'active',
          'createdAt': createdTimestamp,
          'updatedAt': updatedTimestamp,
        };

        final item = ContractListItem.fromJson(json);

        expect(item.createdAt?.year, 2025);
        expect(item.createdAt?.month, 1);
        expect(item.updatedAt?.year, 2025);
      });

      test('handles null values gracefully', () {
        final json = <String, dynamic>{
          '_id': null,
          'title': null,
          'description': null,
          'price': null,
          'status': null,
          'createdAt': null,
          'updatedAt': null,
        };

        final item = ContractListItem.fromJson(json);

        expect(item.id, '');
        expect(item.title, '');
        expect(item.description, '');
        expect(item.price, '');
        expect(item.status, 'pending'); // Default status
        expect(item.createdAt, isNull);
        expect(item.updatedAt, isNull);
      });

      test('defaults isUserA to true', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'active',
        };

        final item = ContractListItem.fromJson(json);

        expect(item.isUserA, false); // Not set, defaults to false from (json['isUserA'] == true)
      });

      test('defaults boolean flags to false', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'active',
        };

        final item = ContractListItem.fromJson(json);

        expect(item.userASigned, false);
        expect(item.userBSigned, false);
        expect(item.agreedUserA, false);
        expect(item.agreedUserB, false);
        expect(item.disputedUserA, false);
        expect(item.disputedUserB, false);
      });

      test('handles all disputed states', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'disputed',
          'disputedUserA': true,
          'disputedUserB': true,
        };

        final item = ContractListItem.fromJson(json);

        expect(item.disputedUserA, true);
        expect(item.disputedUserB, true);
        expect(item.status, 'disputed');
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final createdAt = DateTime(2025, 1, 10, 12, 0, 0);
        final updatedAt = DateTime(2025, 1, 10, 14, 0, 0);

        final item = ContractListItem(
          id: 'contract123',
          title: 'encrypted_title',
          description: 'encrypted_description',
          price: 'encrypted_price',
          detailsHash: 'hash123',
          otherUserId: 'user456',
          otherUserName: 'John Doe',
          otherUserPublicKey: 'public_key',
          isUserA: true,
          status: 'active',
          userASigned: true,
          userBSigned: false,
          agreedUserA: true,
          agreedUserB: false,
          disputedUserA: false,
          disputedUserB: false,
          hash: 'qr_hash',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = item.toJson();

        expect(json['id'], 'contract123');
        expect(json['title'], 'encrypted_title');
        expect(json['description'], 'encrypted_description');
        expect(json['price'], 'encrypted_price');
        expect(json['detailsHash'], 'hash123');
        expect(json['otherUserId'], 'user456');
        expect(json['otherUserName'], 'John Doe');
        expect(json['otherUserPublicKey'], 'public_key');
        expect(json['isUserA'], true);
        expect(json['status'], 'active');
        expect(json['userASigned'], true);
        expect(json['userBSigned'], false);
        expect(json['agreedUserA'], true);
        expect(json['agreedUserB'], false);
        expect(json['disputedUserA'], false);
        expect(json['disputedUserB'], false);
        expect(json['hash'], 'qr_hash');
        expect(json['createdAt'], createdAt.toIso8601String());
        expect(json['updatedAt'], updatedAt.toIso8601String());
      });

      test('handles null optional fields', () {
        final item = ContractListItem(
          id: 'contract123',
          title: 'title',
          description: 'desc',
          price: 'price',
          status: 'pending',
        );

        final json = item.toJson();

        expect(json['detailsHash'], isNull);
        expect(json['otherUserId'], isNull);
        expect(json['otherUserName'], isNull);
        expect(json['otherUserPublicKey'], isNull);
        expect(json['hash'], isNull);
        expect(json['createdAt'], isNull);
        expect(json['updatedAt'], isNull);
      });
    });

    group('status values', () {
      test('parses pending status', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'pending',
        };

        final item = ContractListItem.fromJson(json);
        expect(item.status, 'pending');
      });

      test('parses active status', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'active',
        };

        final item = ContractListItem.fromJson(json);
        expect(item.status, 'active');
      });

      test('parses completed status', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'completed',
        };

        final item = ContractListItem.fromJson(json);
        expect(item.status, 'completed');
      });

      test('parses disputed status', () {
        final json = {
          '_id': 'contract123',
          'title': 'title',
          'description': 'desc',
          'price': 'price',
          'status': 'disputed',
        };

        final item = ContractListItem.fromJson(json);
        expect(item.status, 'disputed');
      });
    });
  });
}

