import 'package:flutter_bloc/flutter_bloc.dart';
import 'password_reset_state.dart';
import 'package:yack/services/auth/password_service.dart';
import 'package:flutter/material.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit() : super(PasswordResetInitial());

  Future<void> resetPassword(
      BuildContext context,
      GlobalKey<FormState> formKey,
      String email,
      ) async {
    emit(PasswordResetLoading());

    try {
      await PasswordService.resetPassword(
        formKey,
        email,
      );

      emit(PasswordResetSuccess());

    } catch (e) {
      emit(PasswordResetError(e.toString()));
    }
  }
}
