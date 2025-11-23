import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/providers/auth/confirm_cubit.dart';
import 'package:yack/providers/auth/confirm_state.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/widgets/titleWidget.dart';
import 'package:yack/widgets/hrefTextWidget.dart';
import '../../utils/snackBarHandler.dart';
import '../../widgets/primaryActionButton.dart';
import 'package:yack/utils/translation_handler.dart';

class ConfirmAccount extends StatelessWidget {

  const ConfirmAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TitleWidget(text: TranslationHandler.get('confirm_account')),
                    Text(
                      TranslationHandler.get('confirm_account_message'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(TranslationHandler.get('did_not_receive_email')),
                        HrefWidget(
                          text: TranslationHandler.get('resend'),
                          onClick: () async {
                            if (await context.read<ConfirmCubit>().sendConfirmationEmail()){
                              SnackBarHandler.showMessage(context, TranslationHandler.get('verification_email_sent'));
                            }
                            else {
                              SnackBarHandler.showError(context, TranslationHandler.get('resend_failed'));
                            }
                          },
                        ),
                      ],
                    ),
                    BlocConsumer<ConfirmCubit,ConfirmState>(
                        builder: (context, state) {
                          return PrimaryActionButton(
                            isLoading: state is ConfirmLoading,
                            action: TranslationHandler.get('check'),
                            onClick: () {
                              context.read<ConfirmCubit>().confirm();
                            },
                          );
                        },
                        listener: (context,state){
                          if(state is ConfirmSuccess){
                            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          }
                          else if(state is ConfirmUnverified){
                            SnackBarHandler.showWarning(
                                context,
                                TranslationHandler.get('auth_email_not_verified')
                            );
                          }
                          else if(state is ConfirmError){
                            SnackBarHandler.showError(
                                context,
                                 TranslationHandler.get(state.message!)
                            );
                          }
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
    );
  }
}
