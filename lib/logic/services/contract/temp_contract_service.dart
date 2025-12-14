import 'package:yack/data/models/contract/temp_contract.dart';
import 'package:yack/logic/services/network/http_handler.dart';

class TempContractService {
  TempContractService({HttpHandler? httpHandler})
      : _http = httpHandler ?? HttpHandler();

  final HttpHandler _http;

  /// Start a temporary contract with encrypted fields for user A.
  /// Required: titleUserA, descriptionUserA, priceUserA, detailsHash
  /// Optional: hash (for QR code joining)
  Future<TempContract> create({
    String? hash,
    required String titleUserA,
    required String descriptionUserA,
    required String priceUserA,
    required String detailsHash,
  }) async {
    final body = <String, dynamic>{
      'titleUserA': titleUserA,
      'descriptionUserA': descriptionUserA,
      'priceUserA': priceUserA,
      'detailsHash': detailsHash,
    };
    if (hash != null && hash.isNotEmpty) body['hash'] = hash;

    final response = await _http.post('/contracts/create', body: body);
    return _materializeContract(response, fallbackTempId: body['tempID']?.toString());
  }

  /// Join a temp contract as user B.
  /// Required: tempId, titleUserB, descriptionUserB, priceUserB
  /// Optional: hash (if temp has hash)
  /// Returns userA info including publicKey for encryption.
  Future<TempContractJoinResult> join({
    required String tempId,
    String? hash,
    required String titleUserB,
    required String descriptionUserB,
    required String priceUserB,
  }) async {
    final body = <String, dynamic>{
      'tempID': tempId,
      'titleUserB': titleUserB,
      'descriptionUserB': descriptionUserB,
      'priceUserB': priceUserB,
    };
    if (hash != null && hash.isNotEmpty) body['hash'] = hash;

    final response = await _http.post('/contracts/join', body: body);
    final contract = _materializeContract(response, fallbackTempId: tempId);
    final userAPublicKey = _extractUserAPublicKey(response);

    return TempContractJoinResult(
      contract: contract,
      userAPublicKey: userAPublicKey,
    );
  }

  /// Sign a temp contract.
  /// When both users sign, a Contract record is created with all encrypted fields.
  Future<TempContractSignResult> sign(String tempId) async {
    final response = await _http.post('/contracts/sign', body: {
      'tempID': tempId,
    });
    final contract = _materializeContract(response, fallbackTempId: tempId);
    final contractId = _extractContractId(response);

    return TempContractSignResult(
      contract: contract,
      contractId: contractId,
    );
  }

  String? _extractUserAPublicKey(dynamic response) {
    if (response is Map) {
      return response['userAPublicKey']?.toString() ??
             response['userA']?['publicKey']?.toString();
    }
    return null;
  }

  String? _extractContractId(dynamic response) {
    if (response is Map) {
      return response['contractID']?.toString() ??
             response['contractId']?.toString();
    }
    return null;
  }

  TempContract _materializeContract(dynamic response, {String? fallbackTempId}) {
    final payload = _extractPayload(response);

    if (!payload.containsKey('tempID') && fallbackTempId != null) {
      payload['tempID'] = fallbackTempId;
    }

    if (!payload.containsKey('tempID')) {
      throw StateError('Server response missing tempID field.');
    }

    return TempContract.fromJson(payload);
  }

  Map<String, dynamic> _extractPayload(dynamic response) {
    if (response is Map<String, dynamic>) {
      final nested = response['tempContract'] ?? response['data'];
      if (nested is Map<String, dynamic>) {
        return Map<String, dynamic>.from(nested);
      }
      return Map<String, dynamic>.from(response);
    }

    if (response is Map) {
      final nested = response['tempContract'] ?? response['data'];
      if (nested is Map) {
        return nested.map((key, value) => MapEntry(key.toString(), value));
      }
      return response.map((key, value) => MapEntry(key.toString(), value));
    }

    return <String, dynamic>{};
  }
}

/// Result of joining a temp contract, includes userA's public key for encryption
class TempContractJoinResult {
  final TempContract contract;
  final String? userAPublicKey;

  const TempContractJoinResult({
    required this.contract,
    this.userAPublicKey,
  });
}

/// Result of signing a temp contract
class TempContractSignResult {
  final TempContract contract;
  final String? contractId; // Final contract ID when both users have signed

  const TempContractSignResult({
    required this.contract,
    this.contractId,
  });
}
