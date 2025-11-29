import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/services/auth/auth_service.dart';

import 'confirm_state.dart';

class ConfirmCubit extends Cubit<ConfirmState> {
  ConfirmCubit() : super(ConfirmInitial());

  Future<void> confirm() async {

    emit(ConfirmLoading());

    try {
      final didConfirm = await AuthService.confirmAccount();
      if (didConfirm) {
        emit(ConfirmSuccess());
        return;
      }
      emit(ConfirmUnverified());
    }
    catch (e){
      emit(ConfirmError(e.toString()));
    }
  }

  Future<bool> sendConfirmationEmail() async {
    try {
      await AuthService.sendEmailVerification();
      return true;
    } catch (e) {
      return false;
    }
  }
}
