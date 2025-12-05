import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/cubits/auth/password_reset_cubit.dart';
import 'package:yack/logic/cubits/auth/password_reset_state.dart';
import 'package:yack/logic/utils/platform.dart';
import 'package:yack/logic/utils/validator.dart';
import 'package:yack/presentation/widgets/inputFormWidget.dart';
import 'package:yack/presentation/widgets/titleWidget.dart';
import 'package:yack/presentation/widgets/hrefTextWidget.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/presentation/widgets/primaryActionButton.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TranslationHandler.get('app_name'),
                    style: theme.textTheme.titleMedium),
                SizedBox(
                  width: PlatformInfo.isDesktop
                      ? min(400, screenWidth * 0.9)
                      : screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TitleWidget(
                          text: TranslationHandler.get('forget_password')),
                      const SizedBox(height: 8),
                      Text(
                        TranslationHandler.get('forget_password_message'),
                      ),
                      const SizedBox(height: 30),
                      CustomTextFormField(
                        controller: _emailController,
                        hintText: TranslationHandler.get('email'),
                        validator: Validator.email,
                      ),
                      const SizedBox(height: 25),
                      BlocConsumer<PasswordResetCubit,PasswordResetState>(
                        listener: (context,state) {

                          if (state is PasswordResetSuccess){
                            SnackBarHandler.showSuccess(
                                context, TranslationHandler.get('password_reset_sent'));
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                          else if (state is PasswordResetError) {
                            print (state.messageKey);
                            SnackBarHandler.showError(context, TranslationHandler.get(state.messageKey));
                          }

                        },
                        builder: (context,state) {
                          return PrimaryActionButton(
                              isLoading: state is PasswordResetLoading,
                              action: TranslationHandler.get('reset'),
                              onClick: (){
                                context.read<PasswordResetCubit>().resetPassword(
                                  context,
                                  _formKey,
                                  _emailController.text,);
                                },
                          );
                        })
                     ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(TranslationHandler.get('dont_have_account')),
                    HrefWidget(
                      text: TranslationHandler.get('sign_up'),
                      onClick: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
