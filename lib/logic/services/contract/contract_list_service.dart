import 'package:yack/logic/services/network/http_handler.dart';

/// Represents a contract from the list endpoint with caller's encrypted fields
class ContractListItem {
  final String id;
  final String title;        // Encrypted for caller (decrypted locally)
  final String description;  // Encrypted for caller (decrypted locally)
  final String price;        // Encrypted for caller (decrypted locally)
  final String? detailsHash;

  // Other user info (the party you're contracting with)
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserPublicKey;

  // Whether the caller is userA (creator) or userB (joiner)
  final bool isUserA;

  final String status;

  // Signature status
  final bool userASigned;
  final bool userBSigned;

  // Agreement status
  final bool agreedUserA;
  final bool agreedUserB;

  // Dispute status
  final bool disputedUserA;
  final bool disputedUserB;

  final String? hash;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ContractListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.detailsHash,
    this.otherUserId,
    this.otherUserName,
    this.otherUserPublicKey,
    this.isUserA = true,
    required this.status,
    this.userASigned = false,
    this.userBSigned = false,
    this.agreedUserA = false,
    this.agreedUserB = false,
    this.disputedUserA = false,
    this.disputedUserB = false,
    this.hash,
    this.createdAt,
    this.updatedAt,
  });

  factory ContractListItem.fromJson(Map<String, dynamic> json) {
    // Extract other user info from nested object
    final otherUser = json['otherUser'];
    String? otherUserId;
    String? otherUserName;
    String? otherUserPublicKey;

    if (otherUser is Map) {
      otherUserId = otherUser['_id']?.toString();
      final firstName = otherUser['firstName']?.toString() ?? '';
      final lastName = otherUser['lastName']?.toString() ?? '';
      otherUserName = '$firstName $lastName'.trim();
      if (otherUserName.isEmpty) otherUserName = null;
      otherUserPublicKey = otherUser['publicKey']?.toString();
    }

    return ContractListItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      detailsHash: json['detailsHash']?.toString(),
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserPublicKey: otherUserPublicKey,
      isUserA: json['isUserA'] == true,
      status: json['status']?.toString() ?? 'pending',
      userASigned: json['userASign'] == true || json['userASigned'] == true,
      userBSigned: json['userBSign'] == true || json['userBSigned'] == true,
      agreedUserA: json['agreedUserA'] == true,
      agreedUserB: json['agreedUserB'] == true,
      disputedUserA: json['disputedUserA'] == true,
      disputedUserB: json['disputedUserB'] == true,
      hash: json['hash']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
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
      'title': title,
      'description': description,
      'price': price,
      'detailsHash': detailsHash,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserPublicKey': otherUserPublicKey,
      'isUserA': isUserA,
      'status': status,
      'userASigned': userASigned,
      'userBSigned': userBSigned,
      'agreedUserA': agreedUserA,
      'agreedUserB': agreedUserB,
      'disputedUserA': disputedUserA,
      'disputedUserB': disputedUserB,
      'hash': hash,
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

