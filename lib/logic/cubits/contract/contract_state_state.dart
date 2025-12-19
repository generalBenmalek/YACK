import 'package:equatable/equatable.dart';

abstract class ContractStateState extends Equatable {
  const ContractStateState();

  @override
  List<Object?> get props => [];
}

class ContractStateInitial extends ContractStateState {
  const ContractStateInitial();
}

class ContractStateLoading extends ContractStateState {
  const ContractStateLoading();
}

class ContractStateSuccess extends ContractStateState {
  const ContractStateSuccess();
}

class ContractStateError extends ContractStateState {
  const ContractStateError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

