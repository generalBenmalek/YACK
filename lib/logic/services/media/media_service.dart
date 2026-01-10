import 'dart:convert';
import 'dart:io';
import 'package:yack/logic/services/network/http_handler.dart';

/// Represents a media entry from the API
/// Maps to backend response structure:
/// {
///   "_id": "...",
///   "who": { "_id": "...", "firstName": "...", "lastName": "..." },
///   "content": "cloudinary/path",
///   "url": "https://cloudinary.com/...",
///   "originalFilename": "proof.png",
///   "mimeType": "image/png",
///   "createdAt": "..."
/// }
class ContractMedia {
  final String id;
  final String senderId;
  final String? senderName;
  final String originalFilename;
  final String content; // Cloudinary path
  final String url; // Full URL for display
  final String? mimeType;
  final DateTime createdAt;

  const ContractMedia({
    required this.id,
    required this.senderId,
    this.senderName,
    required this.originalFilename,
    required this.content,
    required this.url,
    this.mimeType,
    required this.createdAt,
  });

  factory ContractMedia.fromJson(Map<String, dynamic> json) {
    final who = json['who'] ?? json['sender'];
    String senderId;
    String? senderName;

    if (who is Map) {
      senderId = who['_id']?.toString() ?? who['id']?.toString() ?? '';
      final firstName = who['firstName']?.toString() ?? '';
      final lastName = who['lastName']?.toString() ?? '';
      senderName = '$firstName $lastName'.trim();
      if (senderName.isEmpty) senderName = null;
    } else {
      senderId = who?.toString() ?? json['senderId']?.toString() ?? '';
    }

    // Map backend fields: originalFilename, content, url
    final originalFilename = json['originalFilename']?.toString() ??
        json['filename']?.toString() ??
        json['name']?.toString() ??
        '';

    final content = json['content']?.toString() ??
        json['path']?.toString() ??
        '';

    final url = json['url']?.toString() ?? content;

    return ContractMedia(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      senderId: senderId,
      senderName: senderName,
      originalFilename: originalFilename,
      content: content,
      url: url,
      mimeType: json['mimeType']?.toString() ?? json['type']?.toString(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'originalFilename': originalFilename,
      'content': content,
      'url': url,
      'mimeType': mimeType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Helper to get display filename
  String get displayFilename => originalFilename.isNotEmpty
      ? originalFilename
      : content.split('/').last;
}

class MediaService {
  MediaService({HttpHandler? httpHandler})
      : _http = httpHandler ?? HttpHandler();

  final HttpHandler _http;

  /// Store an uploaded media payload and attach metadata to the contract.
  /// POST /media/send
  /// Body: { "contractId": "...", "file": { "filename": "...", "buffer": "<base64>" } }
  /// Returns: The stored media record
  Future<ContractMedia> send({
    required String contractId,
    required File file,
    String? filename,
  }) async {
    // Read file and convert to base64
    final bytes = await file.readAsBytes();
    final base64Buffer = base64Encode(bytes);

    final actualFilename = filename ?? file.path.split(Platform.pathSeparator).last;

    final response = await _http.post('/media/send', body: {
      'contractId': contractId,
      'file': {
        'filename': actualFilename,
        'buffer': base64Buffer,
      },
    });

    return _parseMediaResponse(response);
  }

  /// Return all media entries for a contract.
  /// GET /media/all?contractId=...
  Future<List<ContractMedia>> getAll({required String contractId}) async {
    final response = await _http.get('/media/all?contractId=$contractId');
    return _parseMediaList(response);
  }

  /// Get a specific media by ID.
  /// GET /media/get?contractId=...&mediaId=...
  /// Returns media details with fresh URL from Cloudinary
  Future<ContractMedia> get({
    required String contractId,
    required String mediaId,
  }) async {
    final response = await _http.get('/media/get?contractId=$contractId&mediaId=$mediaId');
    return _parseMediaResponse(response);
  }

  ContractMedia _parseMediaResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final media = response['media'] ?? response['data'] ?? response;
      if (media is Map<String, dynamic>) {
        return ContractMedia.fromJson(media);
      }
    }
    throw Exception('Invalid media response');
  }

  List<ContractMedia> _parseMediaList(dynamic response) {
    final List<dynamic> mediaList;

    if (response is Map) {
      mediaList = response['media'] ?? response['data'] ?? [];
    } else if (response is List) {
      mediaList = response;
    } else {
      mediaList = [];
    }

    return mediaList
        .whereType<Map<String, dynamic>>()
        .map((json) => ContractMedia.fromJson(json))
        .toList();
  }
}
