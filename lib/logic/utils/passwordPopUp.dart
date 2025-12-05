import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/cubits/auth/change_password_cubit.dart';
import 'package:yack/logic/cubits/auth/change_password_state.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/logic/utils/validator.dart';
import 'package:yack/presentation/widgets/inputFormWidget.dart';
import 'package:yack/presentation/widgets/primaryActionButton.dart';

Future<void> showChangePasswordDialog(BuildContext context) async {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final theme = Theme.of(context);
  final color = theme.colorScheme;

  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    // barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: color.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              TranslationHandler.get('change_password'),
              textAlign: TextAlign.center,
            ),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: min(480, MediaQuery.of(context).size.width * 1),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextFormField(
                        isPassword: true,
                        controller: oldPasswordController,
                        validator: (value) => Validator.length(value, min: 8),
                        hintText: TranslationHandler.get('old_password'),
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        isPassword: true,
                        controller: newPasswordController,
                        validator: (value) => Validator.password(value),
                        hintText: TranslationHandler.get('new_password'),
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        isPassword: true,
                        controller: confirmPasswordController,
                        validator: (value) => Validator.confirmPassword(
                          value,
                          newPasswordController.value.text,
                        ),
                        hintText: TranslationHandler.get('confirm_password'),
                      ),
                      const SizedBox(height: 20),
                      BlocConsumer<ChangePasswordCubit,ChangePasswordState>(
                          builder:  (context,state){
                            return PrimaryActionButton(
                              isLoading: state is ChangePasswordLoading,
                              action: TranslationHandler.get('save'),
                              onClick: ()  {
                                context.read<ChangePasswordCubit>().changePassword(
                                    formKey,
                                    oldPasswordController.value.text,
                                    newPasswordController.value.text
                                );
                              },
                            );
                          },
                          listener: (context,state){
                            if (state is ChangePasswordError){
                              SnackBarHandler.showError(context,
                                  TranslationHandler.get(state.messageKey)
                              );
                            }
                            else if (state is ChangePasswordSuccess){
                              Navigator.pop(context);
                              SnackBarHandler.showSuccess(context,
                                  TranslationHandler.get('password_updated_successfully')
                              );
                            }

                          }),

                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          TranslationHandler.get('cancel'),
                          style: TextStyle(color: color.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
