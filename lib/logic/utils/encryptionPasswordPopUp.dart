import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/cubits/auth/change_encryption_password_cubit.dart';
import 'package:yack/logic/cubits/auth/change_encryption_password_state.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/logic/utils/validator.dart';
import 'package:yack/presentation/widgets/inputFormWidget.dart';
import 'package:yack/presentation/widgets/primaryActionButton.dart';

Future<void> showChangeEncryptionPasswordDialog(BuildContext context) async {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final theme = Theme.of(context);
  final color = theme.colorScheme;

  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return BlocProvider(
        create: (_) => ChangeEncryptionPasswordCubit(),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: color.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                TranslationHandler.get('change_encryption_password'),
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
                        // Warning
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.errorContainer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.error.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: color.error,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  TranslationHandler.get('change_encryption_password_warning'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: color.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          isPassword: true,
                          controller: oldPasswordController,
                          validator: (value) => Validator.length(value, min: 12),
                          hintText: TranslationHandler.get('old_encryption_password'),
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          isPassword: true,
                          controller: newPasswordController,
                          validator: (value) => Validator.length(value, min: 12),
                          hintText: TranslationHandler.get('new_encryption_password'),
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          isPassword: true,
                          controller: confirmPasswordController,
                          validator: (value) => Validator.confirmPassword(
                            value,
                            newPasswordController.value.text,
                          ),
                          hintText: TranslationHandler.get('confirm_encryption_password'),
                        ),
                        const SizedBox(height: 20),
                        BlocConsumer<ChangeEncryptionPasswordCubit, ChangeEncryptionPasswordState>(
                          builder: (context, state) {
                            return PrimaryActionButton(
                              isLoading: state is ChangeEncryptionPasswordLoading,
                              action: TranslationHandler.get('save'),
                              onClick: () {
                                context.read<ChangeEncryptionPasswordCubit>().changeEncryptionPassword(
                                  formKey,
                                  oldPasswordController.value.text,
                                  newPasswordController.value.text,
                                );
                              },
                            );
                          },
                          listener: (context, state) {
                            if (state is ChangeEncryptionPasswordError) {
                              SnackBarHandler.showError(
                                context,
                                TranslationHandler.get(state.messageKey),
                              );
                            } else if (state is ChangeEncryptionPasswordSuccess) {
                              Navigator.pop(context);
                              SnackBarHandler.showSuccess(
                                context,
                                TranslationHandler.get('encryption_password_updated_successfully'),
                              );
                            }
                          },
                        ),
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
        ),
      );
    },
  );
}

