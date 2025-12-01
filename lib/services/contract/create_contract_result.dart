import 'package:yack/db/models/contract.dart';

class CreateContractResult {
  final Contract contract;
  final String hash;
  final String tempId;

  CreateContractResult({
    required this.contract,
    required this.hash,
    required this.tempId,
  });
}
