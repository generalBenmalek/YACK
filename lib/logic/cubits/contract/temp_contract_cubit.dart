import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/data/models/contract/temp_contract.dart';
import 'package:yack/logic/services/contract/temp_contract_service.dart';

import 'temp_contract_state.dart';

class TempContractCubit extends Cubit<TempContractState> {
  TempContractCubit({TempContractService? service})
      : _service = service ?? TempContractService(),
        super(const TempContractInitial());

  final TempContractService _service;

  Future<void> create({String? hash}) async {
    await _guard(() => _service.create(hash: hash));
  }

  Future<void> join({required String tempId, String? hash}) async {
    await _guard(() => _service.join(tempId: tempId, hash: hash));
  }

  Future<void> sign(String tempId) async {
    await _guard(() => _service.sign(tempId));
  }

  Future<void> _guard(Future<TempContract> Function() action) async {
    emit(const TempContractLoading());
    try {
      final contract = await action();
      emit(TempContractSuccess(contract));
    } catch (e) {
      emit(TempContractError(e.toString()));
    }
  }
}

