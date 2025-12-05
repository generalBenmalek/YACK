import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:yack/logic/services/auth/password_service.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordInitial());

  Future<void> changePassword(
      GlobalKey<FormState> formKey,
      String oldPassword,
      String newPassword,
      ) async {
    emit(ChangePasswordLoading());

    try {
      await PasswordService.changePassword(
        formKey,
        oldPassword,
        newPassword,
      );

      emit(ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordError(e.toString()));
    }
  }
}
