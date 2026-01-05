import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/cubits/user/user_cubit.dart';
import 'package:yack/logic/cubits/user/user_state.dart';
import 'package:yack/logic/cubits/auth/auth_cubit.dart';
import 'package:yack/logic/cubits/contract/contract_sync_cubit.dart';
import 'package:yack/logic/utils/platform.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/presentation/widgets/primaryActionButton.dart';
import 'package:yack/presentation/widgets/titleWidget.dart';
import 'package:yack/presentation/widgets/inputFormWidget.dart';
import 'package:yack/presentation/widgets/hrefTextWidget.dart';

/// Screen shown after login to decrypt and load user's private key
/// The user must enter their encryption password to access their account
class DecryptAccountScreen extends StatefulWidget {
  const DecryptAccountScreen({super.key});

  @override
  State<DecryptAccountScreen> createState() => _DecryptAccountScreenState();
}

class _DecryptAccountScreenState extends State<DecryptAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _profileRequested = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profileRequested) return;
    _profileRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserCubit>().getProfile();
    });
  }

  String? _validatePassword(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return TranslationHandler.get('decrypt_account_password_required');
    }
    return null;
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final password = _passwordController.text.trim();
    context.read<UserCubit>().decryptAndLoad(password: password);
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
                        text: TranslationHandler.get('decrypt_account_title'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        TranslationHandler.get('decrypt_account_subtitle'),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Info container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                TranslationHandler.get('decrypt_account_info'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextFormField(
                        hintText: TranslationHandler.get('decrypt_account_password_label'),
                        isPassword: true,
                        controller: _passwordController,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 32),
                      BlocConsumer<UserCubit, UserState>(
                        listener: (context, state) {
                          if (state is UserProfileMissingKeys) {
                            // Keys are missing, redirect to init account
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/init-account',
                              (route) => false,
                            );
                          } else if (state is UserDecryptSuccess) {
                            // Sync contracts in background (uses cached decrypted key from Hive)
                            context.read<ContractSyncCubit>().sync();

                            context.read<AuthCubit>().markAuthenticated();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          } else if (state is UserError) {
                            SnackBarHandler.showError(
                              context,
                              state.message,
                            );
                          } else if (state is UserDecryptError) {
                            SnackBarHandler.showError(
                              context,
                              TranslationHandler.get('decrypt_account_error'),
                            );
                          }
                        },
                        builder: (context, state) {
                          return PrimaryActionButton(
                            isLoading: state is UserLoading,
                            action: TranslationHandler.get('decrypt_account_submit'),
                            onClick: _onSubmit,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // NEW: go to Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
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
