import 'package:yack/logic/services/network/http_handler.dart';

class ContractVerificationService {
  ContractVerificationService({HttpHandler? httpHandler})
      : _http = httpHandler ?? HttpHandler();

  final HttpHandler _http;

  Future<bool> verifyHash({required String contractId, required String hash}) async {
    final response = await _http.get('/contracts/verify?contractId=$contractId&hash=$hash');
    if (response is Map && response.containsKey('matches')) {
      return response['matches'] == true;
    }
    return false;
  }
}

