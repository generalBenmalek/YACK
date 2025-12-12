import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/services/contract/temp_contract_service.dart';

import 'temp_contract_state.dart';

class TempContractCubit extends Cubit<TempContractState> {
  TempContractCubit({TempContractService? service})
      : _service = service ?? TempContractService(),
        super(const TempContractInitial());

  final TempContractService _service;

  /// Start a temporary contract with encrypted fields for user A.
  Future<void> create({
    String? hash,
    required String titleUserA,
    required String descriptionUserA,
    required String priceUserA,
    required String detailsHash,
  }) async {
    emit(const TempContractLoading());
    try {
      final contract = await _service.create(
        hash: hash,
        titleUserA: titleUserA,
        descriptionUserA: descriptionUserA,
        priceUserA: priceUserA,
        detailsHash: detailsHash,
      );
      emit(TempContractSuccess(contract));
    } catch (e) {
      emit(TempContractError(e.toString()));
    }
  }

  /// Join a temp contract as user B with encrypted fields.
  Future<void> join({
    required String tempId,
    String? hash,
    required String titleUserB,
    required String descriptionUserB,
    required String priceUserB,
  }) async {
    emit(const TempContractLoading());
    try {
      final result = await _service.join(
        tempId: tempId,
        hash: hash,
        titleUserB: titleUserB,
        descriptionUserB: descriptionUserB,
        priceUserB: priceUserB,
      );
      emit(TempContractJoinSuccess(
        contract: result.contract,
        userAPublicKey: result.userAPublicKey,
      ));
    } catch (e) {
      emit(TempContractError(e.toString()));
    }
  }

  /// Sign a temp contract.
  Future<void> sign(String tempId) async {
    emit(const TempContractLoading());
    try {
      final result = await _service.sign(tempId);
      emit(TempContractSignSuccess(
        contract: result.contract,
        contractId: result.contractId,
      ));
    } catch (e) {
      emit(TempContractError(e.toString()));
    }
  }
}

