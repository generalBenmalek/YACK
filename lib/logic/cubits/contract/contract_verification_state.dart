import 'package:equatable/equatable.dart';

abstract class ContractVerificationState extends Equatable {
  const ContractVerificationState();

  @override
  List<Object?> get props => [];
}

class ContractVerificationInitial extends ContractVerificationState {
  const ContractVerificationInitial();
}

class ContractVerificationLoading extends ContractVerificationState {
  const ContractVerificationLoading();
}

class ContractVerificationResult extends ContractVerificationState {
  const ContractVerificationResult(this.matches);
  final bool matches;

  @override
  List<Object?> get props => [matches];
}

class ContractVerificationError extends ContractVerificationState {
  const ContractVerificationError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

