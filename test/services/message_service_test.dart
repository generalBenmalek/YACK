import 'package:flutter_test/flutter_test.dart';
import 'package:yack/logic/services/message/message_service.dart';

void main() {
  group('ContractMessage', () {
    group('fromJson', () {
      test('parses complete JSON with who object', () {
        final json = {
          '_id': 'msg123',
          'who': {
            '_id': 'user456',
            'firstName': 'John',
            'lastName': 'Doe',
          },
          'content': 'encrypted_message_content',
          'contentHash': 'sha256hash123',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final message = ContractMessage.fromJson(json);

        expect(message.id, 'msg123');
        expect(message.senderId, 'user456');
        expect(message.senderFirstName, 'John');
        expect(message.senderLastName, 'Doe');
        expect(message.senderName, 'John Doe');
        expect(message.content, 'encrypted_message_content');
        expect(message.contentHash, 'sha256hash123');
        expect(message.createdAt.year, 2025);
        expect(message.createdAt.month, 1);
        expect(message.createdAt.day, 10);
      });

      test('parses JSON with only first name', () {
        final json = {
          '_id': 'msg123',
          'who': {
            '_id': 'user456',
            'firstName': 'John',
          },
          'content': 'encrypted_content',
          'contentHash': 'hash123',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final message = ContractMessage.fromJson(json);

        expect(message.senderFirstName, 'John');
        expect(message.senderLastName, isNull);
        expect(message.senderName, 'John');
      });

      test('parses JSON with only last name', () {
        final json = {
          '_id': 'msg123',
          'who': {
            '_id': 'user456',
            'lastName': 'Doe',
          },
          'content': 'encrypted_content',
          'contentHash': 'hash123',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final message = ContractMessage.fromJson(json);

        expect(message.senderFirstName, isNull);
        expect(message.senderLastName, 'Doe');
        expect(message.senderName, 'Doe');
      });

      test('parses JSON with who as string ID', () {
        final json = {
          '_id': 'msg123',
          'who': 'user456',
          'content': 'encrypted_content',
          'contentHash': 'hash123',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final message = ContractMessage.fromJson(json);

        expect(message.senderId, 'user456');
        expect(message.senderFirstName, isNull);
        expect(message.senderLastName, isNull);
        expect(message.senderName, 'Unknown');
      });

      test('uses fallback senderId field', () {
        final json = {
          'id': 'msg123',
          'senderId': 'user456',
          'content': 'encrypted_content',
          'contentHash': 'hash123',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final message = ContractMessage.fromJson(json);

        expect(message.id, 'msg123');
        expect(message.senderId, 'user456');
      });

      test('parses createdAt from milliseconds timestamp', () {
        final timestamp = DateTime(2025, 1, 10, 12, 0, 0).millisecondsSinceEpoch;
        final json = {
          '_id': 'msg123',
          'who': 'user456',
          'content': 'encrypted_content',
          'contentHash': 'hash123',
          'createdAt': timestamp,
        };

        final message = ContractMessage.fromJson(json);

        expect(message.createdAt.year, 2025);
        expect(message.createdAt.month, 1);
        expect(message.createdAt.day, 10);
      });

      test('handles empty who object', () {
        final json = {
          '_id': 'msg123',
          'who': {},
          'content': 'encrypted_content',
          'contentHash': 'hash123',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final message = ContractMessage.fromJson(json);

        expect(message.senderId, '');
        expect(message.senderFirstName, isNull);
        expect(message.senderLastName, isNull);
        expect(message.senderName, 'Unknown');
      });

      test('handles null values gracefully', () {
        final json = <String, dynamic>{
          '_id': null,
          'who': null,
          'content': null,
          'contentHash': null,
          'createdAt': null,
        };

        final message = ContractMessage.fromJson(json);

        expect(message.id, '');
        expect(message.senderId, '');
        expect(message.content, '');
        expect(message.contentHash, '');
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{
          '_id': 'msg123',
        };

        final message = ContractMessage.fromJson(json);

        expect(message.id, 'msg123');
        expect(message.senderId, '');
        expect(message.content, '');
        expect(message.contentHash, '');
      });
    });

    group('senderName getter', () {
      test('combines first and last name', () {
        final message = ContractMessage(
          id: 'msg123',
          senderId: 'user456',
          senderFirstName: 'John',
          senderLastName: 'Doe',
          content: 'content',
          contentHash: 'hash',
          createdAt: DateTime.now(),
        );

        expect(message.senderName, 'John Doe');
      });

      test('returns only first name when last is null', () {
        final message = ContractMessage(
          id: 'msg123',
          senderId: 'user456',
          senderFirstName: 'John',
          senderLastName: null,
          content: 'content',
          contentHash: 'hash',
          createdAt: DateTime.now(),
        );

        expect(message.senderName, 'John');
      });

      test('returns only last name when first is null', () {
        final message = ContractMessage(
          id: 'msg123',
          senderId: 'user456',
          senderFirstName: null,
          senderLastName: 'Doe',
          content: 'content',
          contentHash: 'hash',
          createdAt: DateTime.now(),
        );

        expect(message.senderName, 'Doe');
      });

      test('returns Unknown when both names are null', () {
        final message = ContractMessage(
          id: 'msg123',
          senderId: 'user456',
          senderFirstName: null,
          senderLastName: null,
          content: 'content',
          contentHash: 'hash',
          createdAt: DateTime.now(),
        );

        expect(message.senderName, 'Unknown');
      });

      test('returns Unknown when both names are empty', () {
        final message = ContractMessage(
          id: 'msg123',
          senderId: 'user456',
          senderFirstName: '',
          senderLastName: '',
          content: 'content',
          contentHash: 'hash',
          createdAt: DateTime.now(),
        );

        expect(message.senderName, 'Unknown');
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final createdAt = DateTime(2025, 1, 10, 12, 0, 0);
        final message = ContractMessage(
          id: 'msg123',
          senderId: 'user456',
          senderFirstName: 'John',
          senderLastName: 'Doe',
          content: 'encrypted_content',
          contentHash: 'hash123',
          createdAt: createdAt,
        );

        final json = message.toJson();

        expect(json['id'], 'msg123');
        expect(json['senderId'], 'user456');
        expect(json['senderFirstName'], 'John');
        expect(json['senderLastName'], 'Doe');
        expect(json['content'], 'encrypted_content');
        expect(json['contentHash'], 'hash123');
        expect(json['createdAt'], createdAt.toIso8601String());
      });

      test('serializes null values correctly', () {
        final message = ContractMessage(
          id: 'msg123',
          senderId: 'user456',
          senderFirstName: null,
          senderLastName: null,
          content: 'content',
          contentHash: 'hash',
          createdAt: DateTime.now(),
        );

        final json = message.toJson();

        expect(json['senderFirstName'], isNull);
        expect(json['senderLastName'], isNull);
      });
    });
  });
}

