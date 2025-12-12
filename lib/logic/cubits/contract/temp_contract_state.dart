import 'package:equatable/equatable.dart';
import 'package:yack/data/models/contract/temp_contract.dart';

abstract class TempContractState extends Equatable {
  const TempContractState();

  @override
  List<Object?> get props => [];
}

class TempContractInitial extends TempContractState {
  const TempContractInitial();
}

class TempContractLoading extends TempContractState {
  const TempContractLoading();
}

class TempContractSuccess extends TempContractState {
  const TempContractSuccess(this.contract);
  final TempContract contract;

  @override
  List<Object?> get props => [contract];
}

/// State emitted after successfully joining a temp contract
class TempContractJoinSuccess extends TempContractState {
  const TempContractJoinSuccess({
    required this.contract,
    this.userAPublicKey,
  });
  final TempContract contract;
  final String? userAPublicKey; // For encrypting messages to user A

  @override
  List<Object?> get props => [contract, userAPublicKey];
}

/// State emitted after successfully signing a temp contract
class TempContractSignSuccess extends TempContractState {
  const TempContractSignSuccess({
    required this.contract,
    this.contractId,
  });
  final TempContract contract;
  final String? contractId; // Final contract ID when both users have signed

  @override
  List<Object?> get props => [contract, contractId];
}

class TempContractError extends TempContractState {
  const TempContractError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

