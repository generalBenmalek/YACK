import 'package:equatable/equatable.dart';
import 'package:yack/logic/services/contract/contract_list_service.dart';

abstract class ContractListState extends Equatable {
  const ContractListState();

  @override
  List<Object?> get props => [];
}

class ContractListInitial extends ContractListState {
  const ContractListInitial();
}

class ContractListLoading extends ContractListState {
  const ContractListLoading();
}

class ContractListLoaded extends ContractListState {
  const ContractListLoaded(this.contracts);
  final List<ContractListItem> contracts;

  @override
  List<Object?> get props => [contracts];
}

class ContractListError extends ContractListState {
  const ContractListError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

