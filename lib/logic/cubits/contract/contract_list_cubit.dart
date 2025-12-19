import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/services/contract/contract_list_service.dart';

import 'contract_list_state.dart';

class ContractListCubit extends Cubit<ContractListState> {
  ContractListCubit({ContractListService? service})
      : _service = service ?? ContractListService(),
        super(const ContractListInitial());

  final ContractListService _service;

  /// Fetch all contracts involving the caller.
  Future<void> loadContracts() async {
    emit(const ContractListLoading());
    try {
      final contracts = await _service.list();
      emit(ContractListLoaded(contracts));
    } catch (e) {
      emit(ContractListError(e.toString()));
    }
  }

  /// Refresh the contract list
  Future<void> refresh() async {
    await loadContracts();
  }
}

