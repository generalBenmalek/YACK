import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/providers/auth/signup_state.dart';
import 'package:yack/services/auth/auth_service.dart';


class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  Future<void> signup(
      BuildContext context,
      GlobalKey<FormState> formKey,
      String email,
      String password,
      String firstName,
      String lastName
      )
  async {

    emit(SignupLoading());

    try {
      await AuthService.signup(context, formKey, email, password, firstName, lastName);
      emit(SignupSuccess());
    }
    catch (e){
      emit(SignupError(e.toString()));
    }
  }
}
