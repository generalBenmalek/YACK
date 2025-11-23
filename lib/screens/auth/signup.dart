import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/providers/auth/signup_cubit.dart';
import 'package:yack/providers/auth/signup_state.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/utils/validator.dart';
import 'package:yack/widgets/inputFormWidget.dart';
import 'package:yack/widgets/primaryActionButton.dart';
import 'package:yack/widgets/titleWidget.dart';
import 'package:yack/widgets/hrefTextWidget.dart';
import 'package:yack/utils/translation_handler.dart';

class SignUpScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();


  SignUpScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TranslationHandler.get('app_name'),
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 30),
              SizedBox(
                width: PlatformInfo.isDesktop
                    ? min(400, screenWidth * 0.9)
                    : screenWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 10,
                    children: [
                      TitleWidget(text: TranslationHandler.get('welcome')),
                      const SizedBox(height: 30),

                      // Email
                      CustomTextFormField(
                        hintText: TranslationHandler.get('email'),
                        controller: emailController,
                        validator: Validator.email,
                      ),

                      // First & Last Name
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              hintText: TranslationHandler.get('first_name'),
                              controller: firstNameController,
                              validator: (v) =>
                                  Validator.name(v, fieldName: 'first_name'),
                            ),
                          ),
                          Expanded(
                            child: CustomTextFormField(
                              hintText: TranslationHandler.get('last_name'),
                              controller: lastNameController,
                              validator: (v) =>
                                  Validator.name(v, fieldName: 'last_name'),
                            ),
                          ),
                        ],
                      ),

                      // Password
                      CustomTextFormField(
                        hintText: TranslationHandler.get('password'),
                        isPassword: true,
                        controller: passwordController,
                        validator: (v) => Validator.password(v, minLength: 8),
                      ),

                      // Password Confirm
                      CustomTextFormField(
                        hintText: TranslationHandler.get('confirm_password'),
                        isPassword: true,
                        controller: confirmPasswordController,
                        validator: (v) => Validator.confirmPassword(v, passwordController.value.text),
                      ),


                      BlocConsumer<SignupCubit,SignupState>(

                          builder: (context,state) {
                            return PrimaryActionButton(
                              isLoading: state is SignupLoading,
                              action: TranslationHandler.get('sign_up'),
                              onClick: (){
                                // call context
                                context.read<SignupCubit>().signup(context,
                                    _formKey,
                                    emailController.value.text.trim(),
                                    passwordController.value.text.trim(),
                                    firstNameController.value.text.trim(),
                                    lastNameController.value.text.trim()
                                );
                              },
                            );
                          },
                          listener: (context , state) {
                            if (state is SignupSuccess) {
                              Navigator.pushReplacementNamed(context, "/confirm");
                            } else if (state is SignupError) { SnackBarHandler.showError(
                                context, TranslationHandler.get('signup_failed')
                            );
                            }
                          }
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(TranslationHandler.get('already_have_account')),
                  const SizedBox(width: 5),
                  HrefWidget(
                    text: TranslationHandler.get('login'),
                    onClick: () => Navigator.pushNamed(context, '/login'),
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
