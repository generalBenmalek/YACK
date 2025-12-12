import 'package:yack/logic/services/network/http_handler.dart';

class ContractStateService {
  ContractStateService({HttpHandler? httpHandler})
      : _http = httpHandler ?? HttpHandler();

  final HttpHandler _http;

  Future<void> accept(String contractId) async {
    await _http.post('/contracts/accept', body: {'contractId': contractId});
  }

  Future<void> dispute(String contractId, {String? reason}) async {
    final body = {'contractId': contractId};
    if (reason != null && reason.isNotEmpty) {
      body['reason'] = reason;
    }
    await _http.post('/contracts/dispute', body: body);
  }
}

