import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import 'package:yack/services/auth/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthChecking());

    try {
      final isLoggedIn = await AuthService.isAuthenticated();

      if (isLoggedIn == true) {
        emit(Authenticated());
      } else if (isLoggedIn == null) {
        // logged in but email not verified
        emit(UnverifiedUser());
      } else {
        emit(Unauthenticated());
      }

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void markAuthenticated() {
    emit(Authenticated());
  }

  void markUnauthenticated() {
    emit(Unauthenticated());
  }
}
