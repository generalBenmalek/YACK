import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/services/contract/contract_verification_service.dart';

import 'contract_verification_state.dart';

class ContractVerificationCubit extends Cubit<ContractVerificationState> {
  ContractVerificationCubit({ContractVerificationService? service})
      : _service = service ?? ContractVerificationService(),
        super(const ContractVerificationInitial());

  final ContractVerificationService _service;

  Future<void> verify(String contractId, String hash) async {
    emit(const ContractVerificationLoading());
    try {
      final matches = await _service.verifyHash(contractId: contractId, hash: hash);
      emit(ContractVerificationResult(matches));
    } catch (e) {
      emit(ContractVerificationError(e.toString()));
    }
  }
}

