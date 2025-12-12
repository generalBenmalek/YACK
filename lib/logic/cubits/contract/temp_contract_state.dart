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

class TempContractError extends TempContractState {
  const TempContractError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

