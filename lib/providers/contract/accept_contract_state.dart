abstract class AcceptContractState {}

class AcceptContractInitial extends AcceptContractState {}

class AcceptContractLoading extends AcceptContractState {}

/// Only this user signed (waiting for the other)
class AcceptContractSigned extends AcceptContractState {
  final String messageKey;
  AcceptContractSigned({this.messageKey = 'contract_waiting_other_user'});
}

/// Both users signed => final contract created
class AcceptContractCompleted extends AcceptContractState {
  final String finalContractId;
  AcceptContractCompleted({required this.finalContractId});
}

class AcceptContractError extends AcceptContractState {
  final String messageKey;
  AcceptContractError(this.messageKey);
}
