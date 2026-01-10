import 'package:flutter_test/flutter_test.dart';
import 'package:yack/logic/services/media/media_service.dart';

void main() {
  group('ContractMedia', () {
    group('fromJson', () {
      test('parses complete JSON with who object', () {
        final json = {
          '_id': 'media123',
          'who': {
            '_id': 'user456',
            'firstName': 'John',
            'lastName': 'Doe',
          },
          'content': 'cloudinary/path/to/file',
          'url': 'https://cloudinary.com/image.png',
          'originalFilename': 'proof.png',
          'mimeType': 'image/png',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final media = ContractMedia.fromJson(json);

        expect(media.id, 'media123');
        expect(media.senderId, 'user456');
        expect(media.senderName, 'John Doe');
        expect(media.content, 'cloudinary/path/to/file');
        expect(media.url, 'https://cloudinary.com/image.png');
        expect(media.originalFilename, 'proof.png');
        expect(media.mimeType, 'image/png');
        expect(media.createdAt.year, 2025);
        expect(media.createdAt.month, 1);
        expect(media.createdAt.day, 10);
      });

      test('parses JSON with only first name in who object', () {
        final json = {
          '_id': 'media123',
          'who': {
            '_id': 'user456',
            'firstName': 'John',
          },
          'content': 'path/to/file',
          'url': 'https://example.com/file',
          'originalFilename': 'doc.pdf',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final media = ContractMedia.fromJson(json);

        expect(media.senderName, 'John');
      });

      test('parses JSON with who as string ID', () {
        final json = {
          '_id': 'media123',
          'who': 'user456',
          'content': 'path/to/file',
          'url': 'https://example.com/file',
          'originalFilename': 'doc.pdf',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final media = ContractMedia.fromJson(json);

        expect(media.senderId, 'user456');
        expect(media.senderName, isNull);
      });

      test('uses fallback fields when primary fields are missing', () {
        final json = {
          'id': 'media123',
          'senderId': 'user456',
          'path': 'path/to/file',
          'filename': 'doc.pdf',
          'type': 'application/pdf',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final media = ContractMedia.fromJson(json);

        expect(media.id, 'media123');
        expect(media.senderId, 'user456');
        expect(media.content, 'path/to/file');
        expect(media.originalFilename, 'doc.pdf');
        expect(media.mimeType, 'application/pdf');
      });

      test('uses content as url when url is missing', () {
        final json = {
          '_id': 'media123',
          'who': 'user456',
          'content': 'https://fallback.com/file',
          'originalFilename': 'doc.pdf',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final media = ContractMedia.fromJson(json);

        expect(media.url, 'https://fallback.com/file');
      });

      test('parses createdAt from milliseconds', () {
        final timestamp = DateTime(2025, 1, 10, 12, 0, 0).millisecondsSinceEpoch;
        final json = {
          '_id': 'media123',
          'who': 'user456',
          'content': 'path',
          'url': 'url',
          'originalFilename': 'file.txt',
          'createdAt': timestamp,
        };

        final media = ContractMedia.fromJson(json);

        expect(media.createdAt.year, 2025);
        expect(media.createdAt.month, 1);
        expect(media.createdAt.day, 10);
      });

      test('handles empty who object', () {
        final json = {
          '_id': 'media123',
          'who': {},
          'content': 'path',
          'url': 'url',
          'originalFilename': 'file.txt',
          'createdAt': '2025-01-10T12:00:00.000Z',
        };

        final media = ContractMedia.fromJson(json);

        expect(media.senderId, '');
        expect(media.senderName, isNull);
      });

      test('handles null values gracefully', () {
        final json = <String, dynamic>{
          '_id': null,
          'who': null,
          'content': null,
          'url': null,
          'originalFilename': null,
          'mimeType': null,
          'createdAt': null,
        };

        final media = ContractMedia.fromJson(json);

        expect(media.id, '');
        expect(media.senderId, '');
        expect(media.content, '');
        expect(media.url, '');
        expect(media.originalFilename, '');
        expect(media.mimeType, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final createdAt = DateTime(2025, 1, 10, 12, 0, 0);
        final media = ContractMedia(
          id: 'media123',
          senderId: 'user456',
          senderName: 'John Doe',
          originalFilename: 'proof.png',
          content: 'cloudinary/path',
          url: 'https://cloudinary.com/image.png',
          mimeType: 'image/png',
          createdAt: createdAt,
        );

        final json = media.toJson();

        expect(json['id'], 'media123');
        expect(json['senderId'], 'user456');
        expect(json['senderName'], 'John Doe');
        expect(json['originalFilename'], 'proof.png');
        expect(json['content'], 'cloudinary/path');
        expect(json['url'], 'https://cloudinary.com/image.png');
        expect(json['mimeType'], 'image/png');
        expect(json['createdAt'], createdAt.toIso8601String());
      });
    });

    group('displayFilename', () {
      test('returns originalFilename when not empty', () {
        final media = ContractMedia(
          id: 'media123',
          senderId: 'user456',
          originalFilename: 'proof.png',
          content: 'cloudinary/path/to/image.jpg',
          url: 'https://cloudinary.com/image.jpg',
          createdAt: DateTime.now(),
        );

        expect(media.displayFilename, 'proof.png');
      });

      test('extracts filename from content path when originalFilename is empty', () {
        final media = ContractMedia(
          id: 'media123',
          senderId: 'user456',
          originalFilename: '',
          content: 'cloudinary/path/to/image.jpg',
          url: 'https://cloudinary.com/image.jpg',
          createdAt: DateTime.now(),
        );

        expect(media.displayFilename, 'image.jpg');
      });
    });
  });
}

