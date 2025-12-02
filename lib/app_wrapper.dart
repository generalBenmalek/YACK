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
        final userBox = Hive.box('user');

        // ERROR → Show Snack bar only
        if (state is AuthError) {
          SnackBarHandler.showError(
            context,
            TranslationHandler.get(state.messageKey),
          );
        }

        // ==========================
        //        UNAUTHENTICATED
        // ==========================
        if (state is Unauthenticated || state is AuthError) {

          // FIRST TIME → WELCOME
          if (userBox.get('didFirstTime') != true) {
            userBox.put('didFirstTime', true);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/welcome');
            });

            return; // IMPORTANT
          }

          // Seen login screen before
          if (userBox.get('didFirstLogin') == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });

            return; // IMPORTANT
          }

          // DEFAULT → signup
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/signup');
          });

          return; // IMPORTANT
        }

        // ==========================
        //         AUTHENTICATED
        // ==========================
        if (state is Authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });

          return;
        }
      },

      builder: (context, state) {
        // Simple loading screen
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
