import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/cubits/user/user_cubit.dart';
import 'package:yack/logic/cubits/user/user_state.dart';
import 'package:yack/logic/cubits/auth/auth_cubit.dart';
import 'package:yack/logic/utils/platform.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/presentation/widgets/primaryActionButton.dart';
import 'package:yack/presentation/widgets/titleWidget.dart';
import 'package:yack/presentation/widgets/inputFormWidget.dart';
import 'package:yack/presentation/widgets/hrefTextWidget.dart';

/// Screen shown after email verification to set up encryption password
/// The user must create a password to encrypt their private key
class InitAccountScreen extends StatefulWidget {
  const InitAccountScreen({super.key});

  @override
  State<InitAccountScreen> createState() => _InitAccountScreenState();
}

class _InitAccountScreenState extends State<InitAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return TranslationHandler.get('init_account_password_required');
    }
    if (text.length < 12) {
      return TranslationHandler.get('init_account_password_min_length');
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.trim() != _passwordController.text.trim()) {
      return TranslationHandler.get('passwords_do_not_match');
    }
    return null;
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final password = _passwordController.text.trim();

    context.read<UserCubit>().finalize(
      password: password,
    );
  }

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
              Text(
                TranslationHandler.get('app_name'),
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(
                width: PlatformInfo.isDesktop
                    ? min(400, screenWidth * 0.9)
                    : screenWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TitleWidget(
                        text: TranslationHandler.get('init_account_title'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        TranslationHandler.get('init_account_subtitle'),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Warning container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: theme.colorScheme.error,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                TranslationHandler.get('init_account_warning'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextFormField(
                        hintText: TranslationHandler.get('init_account_password_label'),
                        isPassword: true,
                        controller: _passwordController,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        TranslationHandler.get('init_account_password_helper'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        hintText: TranslationHandler.get('init_account_confirm_password_label'),
                        isPassword: true,
                        controller: _confirmPasswordController,
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 32),
                      BlocConsumer<UserCubit, UserState>(
                        listener: (context, state) {
                          if (state is UserFinalizeSuccess) {
                            context.read<AuthCubit>().markAuthenticated();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          } else if (state is UserError) {
                            SnackBarHandler.showError(context, state.message);
                          }
                        },
                        builder: (context, state) {
                          return PrimaryActionButton(
                            isLoading: state is UserLoading,
                            action: TranslationHandler.get('init_account_submit'),
                            onClick: _onSubmit,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // NEW: go back to Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  Text(TranslationHandler.get('already_have_account')),
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
