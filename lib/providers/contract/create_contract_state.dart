import 'package:yack/db/models/contract.dart';

abstract class CreateContractState {}

class CreateContractInitial extends CreateContractState {}

class CreateContractLoading extends CreateContractState {}

class CreateContractSuccess extends CreateContractState {
  final Contract contract; // not saved in Isar yet, just in-memory object
  final String hash;
  final String tempId;

  CreateContractSuccess({
    required this.contract,
    required this.hash,
    required this.tempId,
  });
}

class CreateContractError extends CreateContractState {
  final String messageKey;
  CreateContractError(this.messageKey);
}
