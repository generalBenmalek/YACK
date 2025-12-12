import 'package:yack/data/models/contract/temp_contract.dart';
import 'package:yack/logic/services/network/http_handler.dart';

class TempContractService {
  TempContractService({HttpHandler? httpHandler})
      : _http = httpHandler ?? HttpHandler();

  final HttpHandler _http;

  Future<TempContract> create({String? hash}) async {
    final body = <String, dynamic>{};
    if (hash != null && hash.isNotEmpty) body['hash'] = hash;

    final response = await _http.post('/contracts/create', body: body);
    return _materializeContract(response, fallbackTempId: body['tempID']);
  }

  Future<TempContract> join({required String tempId, String? hash}) async {
    final body = <String, dynamic>{'tempID': tempId};
    if (hash != null && hash.isNotEmpty) body['hash'] = hash;

    final response = await _http.post('/contracts/join', body: body);
    return _materializeContract(response, fallbackTempId: tempId);
  }

  Future<TempContract> sign(String tempId) async {
    final response = await _http.post('/contracts/sign', body: {
      'tempID': tempId,
    });
    return _materializeContract(response, fallbackTempId: tempId);
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

