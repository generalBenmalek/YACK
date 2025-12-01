import 'package:flutter_bloc/flutter_bloc.dart';
import 'accept_contract_state.dart';
import 'package:yack/services/contract/contract_service.dart';

class AcceptContractCubit extends Cubit<AcceptContractState> {
  AcceptContractCubit() : super(AcceptContractInitial());

  Future<void> acceptContract(String tempId) async {
    emit(AcceptContractLoading());

    try {
      final result = await ContractService.acceptContract(tempId);

      if (result.completed) {
        emit(AcceptContractCompleted(
          finalContractId: result.finalContractId!,
        ));
      } else {
        emit(AcceptContractSigned(
          messageKey: 'contract_waiting_other_user',
        ));
      }
    } catch (_) {
      emit(AcceptContractError('accept_contract_failed'));
    }
  }
}
