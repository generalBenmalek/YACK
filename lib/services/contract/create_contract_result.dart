import 'package:yack/db/models/contract.dart';

class CreateContractResult {
  final Contract contract;
  final String hash;

  CreateContractResult({
    required this.contract,
    required this.hash,
  });
}
