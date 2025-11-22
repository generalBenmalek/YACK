import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/services/auth/auth_service.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(
      BuildContext context,
      GlobalKey<FormState> formKey,
      String email,
      String password) async {

    emit(LoginLoading());

    final success = await AuthService.login(context, formKey, email, password);

    if (success) {
      emit(LoginSuccess());
    } else {
      emit(LoginError());
    }
  }
}
