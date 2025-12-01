import 'package:equatable/equatable.dart';
import 'package:yack/db/models/contract.dart';
import 'package:yack/models/contract/contract_preview.dart';

abstract class JoinContractState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JoinContractInitial extends JoinContractState {}

class JoinContractLoading extends JoinContractState {}

class JoinContractSuccess extends JoinContractState {
  final ContractPreview preview;
  final Contract contract;

  JoinContractSuccess({
    required this.preview,
    required this.contract,
  });

  @override
  List<Object?> get props => [preview, contract];
}

class JoinContractError extends JoinContractState {
  final String messageKey;

  JoinContractError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

