import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'package:yack/services/contract/contract_service.dart';
import 'package:yack/db/models/contract.dart';

import 'create_contract_state.dart';

class CreateContractCubit extends Cubit<CreateContractState> {
  CreateContractCubit() : super(CreateContractInitial());

  Future<void> createContract(
      GlobalKey<FormState> formKey,
      String name,
      String description,
      double price,
      String hash,
      ) async {
    emit(CreateContractLoading());

    try {
      /// Expectation:
      /// ContractService.createContract(...) returns an object like:
      ///   {
      ///     contract: Contract,
      ///     hash: String,
      ///     tempId: String,
      ///   }
      final result = await ContractService.createContract(
        formKey,
        name,
        description,
        price,
        hash,
      );

      emit(
        CreateContractSuccess(
          contract: result.contract,
          hash: result.hash,
          tempId: result.tempId,
        ),
      );
    } catch (e) {
      emit(CreateContractError(e.toString()));
    }
  }
}
