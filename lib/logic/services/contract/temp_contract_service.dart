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
    print('[DEBUG TempContractService] Join response: $response');

    final contract = _materializeContract(response, fallbackTempId: tempId);
    print('[DEBUG TempContractService] Materialized contract - userAName: ${contract.userAName}, userAId: ${contract.userAId}');

    final userAPublicKey = _extractUserAPublicKey(response);
    print('[DEBUG TempContractService] userAPublicKey: $userAPublicKey');

    // NEW: extract user A full name returned by backend
    final userAFullName = _extractUserAFullName(response);
    print('[DEBUG TempContractService] userAFullName: $userAFullName');

    return TempContractJoinResult(
      contract: contract,
      userAPublicKey: userAPublicKey,
      userAFullName: userAFullName,
    );
  }

  /// Sign a temp contract.
  /// When both users sign, a Contract record is created with all encrypted fields.
  Future<TempContractSignResult> sign(String tempId) async {
    final response = await _http.post('/contracts/sign', body: {
      'tempID': tempId,
    });
    print('[DEBUG TempContractService] Sign response: $response');

    final contract = _materializeContract(response, fallbackTempId: tempId);
    final contractId = _extractContractId(response);
    print('[DEBUG TempContractService] Sign result - contractId: $contractId');

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

  // NEW: helper to extract userAFullName from response
  String? _extractUserAFullName(dynamic response) {
    if (response is Map) {
      // backend returns 'userAFullName' at top-level in join response
      final direct = response['userAFullName']?.toString();
      if (direct != null && direct.isNotEmpty) return direct;

      // fallback: try userA object fields
      final userA = response['userA'];
      if (userA is Map) {
        final first = userA['firstName']?.toString() ?? '';
        final last = userA['lastName']?.toString() ?? '';
        final combined = [first, last].where((s) => s.isNotEmpty).join(' ');
        if (combined.isNotEmpty) return combined;
      }

      // fallback: try top-level firstName/lastName
      final topFirst = response['firstName']?.toString();
      final topLast = response['lastName']?.toString();
      if ((topFirst ?? '').isNotEmpty || (topLast ?? '').isNotEmpty) {
        return [topFirst, topLast].where((s) => (s ?? '').isNotEmpty).join(' ');
      }
    }
    return null;
  }

  String? _extractContractId(dynamic response) {
    if (response is Map) {
      // Try direct fields first
      var contractId = response['contractID']?.toString() ??
             response['contractId']?.toString() ??
             response['contract_id']?.toString();

      if (contractId != null && contractId.isNotEmpty) {
        return contractId;
      }

      // Try nested in 'contract' object
      final contract = response['contract'];
      if (contract is Map) {
        contractId = contract['_id']?.toString() ??
                     contract['id']?.toString() ??
                     contract['contractId']?.toString();
        if (contractId != null && contractId.isNotEmpty) {
          return contractId;
        }
      }

      // Try nested in 'data' object
      final data = response['data'];
      if (data is Map) {
        contractId = data['contractID']?.toString() ??
                     data['contractId']?.toString() ??
                     data['_id']?.toString();
        if (contractId != null && contractId.isNotEmpty) {
          return contractId;
        }
      }
    }
    return null;
  }

  TempContract _materializeContract(dynamic response, {String? fallbackTempId}) {
    final payload = _extractPayload(response);

    if (!payload.containsKey('tempID') && fallbackTempId != null) {
      payload['tempID'] = fallbackTempId;
    }

    if (!payload.containsKey('tempID')) {
      throw StateError('S mpID field.');
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
  final String? userAFullName; // NEW: user A full name returned by backend

  const TempContractJoinResult({
    required this.contract,
    this.userAPublicKey,
    this.userAFullName,
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
