import 'package:yack/logic/services/network/http_handler.dart';

/// Represents a contract from the list endpoint with caller's encrypted fields
class ContractListItem {
  final String id;
  final String title;        // Encrypted for caller (decrypted locally)
  final String description;  // Encrypted for caller (decrypted locally)
  final String price;        // Encrypted for caller (decrypted locally)
  final String? detailsHash;
  final String userAId;
  final String? userAName;
  final String? userBId;
  final String? userBName;
  final String status;
  final bool userAAccepted;
  final bool userBAccepted;
  final String? disputeReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ContractListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.detailsHash,
    required this.userAId,
    this.userAName,
    this.userBId,
    this.userBName,
    required this.status,
    this.userAAccepted = false,
    this.userBAccepted = false,
    this.disputeReason,
    this.createdAt,
    this.updatedAt,
  });

  factory ContractListItem.fromJson(Map<String, dynamic> json) {
    return ContractListItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      detailsHash: json['detailsHash']?.toString(),
      userAId: json['userA']?['_id']?.toString() ??
               json['userA']?.toString() ??
               json['userAId']?.toString() ?? '',
      userAName: _extractUserName(json['userA']),
      userBId: json['userB']?['_id']?.toString() ??
               json['userB']?.toString() ??
               json['userBId']?.toString(),
      userBName: _extractUserName(json['userB']),
      status: json['status']?.toString() ?? 'pending',
      userAAccepted: json['userAAccepted'] == true,
      userBAccepted: json['userBAccepted'] == true,
      disputeReason: json['disputeReason']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static String? _extractUserName(dynamic user) {
    if (user is Map) {
      final firstName = user['firstName']?.toString() ?? '';
      final lastName = user['lastName']?.toString() ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }
    return null;
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
      'title': title,
      'description': description,
      'price': price,
      'detailsHash': detailsHash,
      'userAId': userAId,
      'userAName': userAName,
      'userBId': userBId,
      'userBName': userBName,
      'status': status,
      'userAAccepted': userAAccepted,
      'userBAccepted': userBAccepted,
      'disputeReason': disputeReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ContractListService {
  ContractListService({HttpHandler? httpHandler})
      : _http = httpHandler ?? HttpHandler();

  final HttpHandler _http;

  /// Fetch all contracts involving the caller.
  /// Returns only caller's encrypted fields (title, description, price).
  Future<List<ContractListItem>> list() async {
    final response = await _http.get('/contracts/list');
    return _parseContractList(response);
  }

  List<ContractListItem> _parseContractList(dynamic response) {
    final List<dynamic> contracts;

    if (response is List) {
      contracts = response;
    } else if (response is Map) {
      contracts = response['contracts'] ?? response['data'] ?? [];
    } else {
      contracts = [];
    }

    return contracts
        .whereType<Map<String, dynamic>>()
        .map((json) => ContractListItem.fromJson(json))
        .toList();
  }
}

