import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:yack/providers/auth/auth_cubit.dart';
import 'package:yack/providers/auth/auth_state.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'utils/translation_handler.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {

        if (state is AuthError) {
          SnackBarHandler.showError(
            context,
            TranslationHandler.get(state.messageKey),
          );
        }

        final userBox = Hive.box('user');

        if (state is Unauthenticated) {
          // FIRST TIME → welcome
          if (userBox.get('didFirstTime') != true) {
            userBox.put('didFirstTime', true);
            WidgetsBinding.instance.addPostFrameCallback(
                  (_) => Navigator.pushReplacementNamed(context, '/welcome'),
            );
          }

          // Seen login before → login
          if (userBox.get('didFirstLogin') == true) {
            WidgetsBinding.instance.addPostFrameCallback(
                  (_) => Navigator.pushReplacementNamed(context, '/login'),
            );
          }

          // Default → signup
          WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.pushReplacementNamed(context, '/signup'),
          );
        }

        if (state is Authenticated) {
          WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.pushReplacementNamed(context, '/home'),
          );
        }

      },
      builder: (context, state) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
