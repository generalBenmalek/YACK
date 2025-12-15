import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/logic/utils/validator.dart';
import 'package:yack/presentation/widgets/inputFormWidget.dart';
import 'package:yack/presentation/widgets/primaryActionButton.dart';

import '../services/auth/account_service.dart';

Future<void> showEditNameDialog(BuildContext context) async {
  final userBox = Hive.box('user');
  final firstNameController =
      TextEditingController(text: userBox.get('firstName', defaultValue: '') ?? '');
  final lastNameController =
      TextEditingController(text: userBox.get('lastName', defaultValue: '') ?? '');

  final theme = Theme.of(context);
  final color = theme.colorScheme;

  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: color.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          TranslationHandler.get('edit_name'),
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
                    controller: firstNameController,
                    hintText: TranslationHandler.get('first_name'),
                    validator: (value) =>
                        Validator.name(value, fieldName: 'first_name'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    controller: lastNameController,
                    hintText: TranslationHandler.get('last_name'),
                    validator: (value) =>
                        Validator.name(value, fieldName: 'last_name'),
                  ),
                  const SizedBox(height: 20),
                  PrimaryActionButton(
                    action: TranslationHandler.get('save'),
                    onClick: () async {
                      FocusScope.of(context).unfocus();

                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      try {
                        await AccountService().updateProfileName(
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                        );
                      } catch (e) {
                        if (context.mounted) {
                          SnackBarHandler.showError(
                            context,
                            TranslationHandler.get('error_updating_name'),
                          );
                        }
                        return;
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        SnackBarHandler.showSuccess(
                          context,
                          TranslationHandler.get('name_updated_successfully'),
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
}
