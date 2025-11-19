import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/utils/translation_handler.dart';
import 'package:yack/utils/validator.dart';
import 'package:yack/widgets/inputFormWidget.dart';
import 'package:yack/widgets/primaryActionButtonAutoLoading.dart';

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
                      PrimaryActionButtonAutoReload(
                        action: TranslationHandler.get('save'),
                        onClick: () async {
                          if (formKey.currentState!.validate()) {
                            // Simulate backend password update delay
                            await Future.delayed(const Duration(seconds: 2));

                            Navigator.pop(context);

                            SnackBarHandler.showSuccess(
                              context,
                              TranslationHandler.get('password_updated_successfully'),
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
      );
    },
  );
}
