import 'package:yack/logic/services/network/http_handler.dart';

/// Represents a message from the API
class ContractMessage {
  final String id;
  final String senderId;
  final String? senderFirstName;
  final String? senderLastName;
  final String content;       // Encrypted content for caller
  final String contentHash;   // SHA hash of plaintext for verification
  final DateTime createdAt;

  const ContractMessage({
    required this.id,
    required this.senderId,
    this.senderFirstName,
    this.senderLastName,
    required this.content,
    required this.contentHash,
    required this.createdAt,
  });

  String get senderName {
    final first = senderFirstName ?? '';
    final last = senderLastName ?? '';
    final name = '$first $last'.trim();
    return name.isNotEmpty ? name : 'Unknown';
  }

  factory ContractMessage.fromJson(Map<String, dynamic> json) {
    final who = json['who'];
    String senderId;
    String? firstName;
    String? lastName;

    if (who is Map) {
      senderId = who['_id']?.toString() ?? who['id']?.toString() ?? '';
      firstName = who['firstName']?.toString();
      lastName = who['lastName']?.toString();
    } else {
      senderId = who?.toString() ?? json['senderId']?.toString() ?? '';
    }

    return ContractMessage(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      senderId: senderId,
      senderFirstName: firstName,
      senderLastName: lastName,
      content: json['content']?.toString() ?? '',
      contentHash: json['contentHash']?.toString() ?? '',
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
      'senderFirstName': senderFirstName,
      'senderLastName': senderLastName,
      'content': content,
      'contentHash': contentHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MessageService {
  MessageService({HttpHandler? httpHandler})
      : _http = httpHandler ?? HttpHandler();

  final HttpHandler _http;

  /// Append an encrypted message to a contract.
  /// contentForSender: Message encrypted with sender's public key
  /// contentForRecipient: Message encrypted with recipient's public key
  /// contentHash: SHA hash of plaintext message for verification
  Future<void> send({
    required String contractId,
    required String contentForSender,
    required String contentForRecipient,
    required String contentHash,
  }) async {
    await _http.post('/messages/send', body: {
      'contractId': contractId,
      'contentForSender': contentForSender,
      'contentForRecipient': contentForRecipient,
      'contentHash': contentHash,
    });
  }

  /// Retrieve contract messages (newest 50 by default).
  /// Returns only the caller's decryptable version in the content field.
  Future<List<ContractMessage>> getAll({
    required String contractId,
    int? limit,
  }) async {
    String endpoint = '/messages/all?contractId=$contractId';
    if (limit != null) {
      endpoint += '&limit=$limit';
    }

    final response = await _http.get(endpoint);
    return _parseMessages(response);
  }

  List<ContractMessage> _parseMessages(dynamic response) {
    final List<dynamic> messages;

    if (response is Map) {
      messages = response['messages'] ?? response['data'] ?? [];
    } else if (response is List) {
      messages = response;
    } else {
      messages = [];
    }

    return messages
        .whereType<Map<String, dynamic>>()
        .map((json) => ContractMessage.fromJson(json))
        .toList();
  }
}

