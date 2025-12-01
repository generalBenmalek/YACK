import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/db/models/contract.dart';
import 'package:yack/models/contract/contract_preview.dart';
import 'package:yack/services/contract/contract_service.dart';

import 'join_contract_state.dart';

class JoinContractCubit extends Cubit<JoinContractState> {
  JoinContractCubit() : super(JoinContractInitial());

  Future<void> joinByQr(String code) async {
    emit(JoinContractLoading());

    try {
      // 1. Decode and validate QR via service
      final ContractPreview preview =
          await ContractService.joinContractFromQr(code);

      // 2. Create in-memory contract (not saved yet, will be saved after user accepts)
      final Contract contract = Contract()
        ..name = preview.name
        ..description = preview.description ?? ''
        ..price = preview.price
        ..userA = preview.userA
        ..userB = 'Me'
        ..status = ContractStatus.pending
        ..createdAt = DateTime.now();

      emit(JoinContractSuccess(preview: preview, contract: contract));
    } on FormatException {
      emit(JoinContractError('invalid_contract_qr'));
    } catch (_) {
      emit(JoinContractError('failed_to_decode_contract'));
    }
  }

  void reset() {
    emit(JoinContractInitial());
  }
}

