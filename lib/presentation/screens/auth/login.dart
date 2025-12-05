import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/logic/cubits/auth/login_cubit.dart';
import 'package:yack/logic/cubits/auth/login_state.dart';
import 'package:yack/logic/utils/platform.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/presentation/widgets/primaryActionButton.dart';
import 'package:yack/presentation/widgets/titleWidget.dart';
import 'package:yack/presentation/widgets/hrefTextWidget.dart';
import 'package:yack/logic/utils/validator.dart';
import 'package:yack/logic/cubits/auth/auth_cubit.dart';
import 'package:yack/presentation/widgets/inputFormWidget.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TranslationHandler.get('app_name'),
                  style: theme.textTheme.titleMedium),
              SizedBox(
                width: PlatformInfo.isDesktop
                    ? min(400, screenWidth * 0.9)
                    : screenWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 10,
                    children: [
                      TitleWidget(
                          text: TranslationHandler.get('welcome_back')),
                      const SizedBox(height: 30),
                      CustomTextFormField(
                        hintText: TranslationHandler.get('email'),
                        controller: emailController,
                        validator: Validator.email,
                      ),
                      CustomTextFormField(
                        hintText: TranslationHandler.get('password'),
                        isPassword: true,
                        controller: passwordController,
                        validator: (v) => Validator.length(v,min: 8),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          HrefWidget(
                            text: TranslationHandler.get('forget_password'),
                            onClick: () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                          ),
                        ],
                      ),
                      BlocConsumer<LoginCubit,LoginState>(
                        listener: (context, state) {
                          if (state is LoginSuccess) {
                            context.read<AuthCubit>().markAuthenticated();
                            Navigator.pushReplacementNamed(context, "/home");
                          } else if (state is LoginError) {
                            SnackBarHandler.showError(context,TranslationHandler.get(state.message!));
                          }
                        },
                        builder: (context, state) {
                          return PrimaryActionButton(
                            isLoading: state is LoginLoading,
                            onClick: (){
                              context.read<LoginCubit>().login(
                                  context,
                                  _formKey,
                                  emailController.value.text.trim(),
                                  passwordController.value.text.trim());
                            },
                            action: TranslationHandler.get('login'),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
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
