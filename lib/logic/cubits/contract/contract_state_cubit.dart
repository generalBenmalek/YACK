import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/services/contract/contract_state_service.dart';

import 'contract_state_state.dart';

class ContractStateCubit extends Cubit<ContractStateState> {
  ContractStateCubit({ContractStateService? service})
      : _service = service ?? ContractStateService(),
        super(const ContractStateInitial());

  final ContractStateService _service;

  Future<void> accept(String contractId) async {
    await _guard(() => _service.accept(contractId));
  }

  Future<void> dispute(String contractId, {String? reason}) async {
    await _guard(() => _service.dispute(contractId, reason: reason));
  }

  Future<void> _guard(Future<void> Function() action) async {
    emit(const ContractStateLoading());
    try {
      await action();
      emit(const ContractStateSuccess());
    } catch (e) {
      emit(ContractStateError(e.toString()));
    }
  }
}

