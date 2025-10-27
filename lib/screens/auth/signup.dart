import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yack/utils/platform.dart';
import 'package:yack/widgets/inputWidget.dart';
import 'package:yack/widgets/titleWidget.dart';
import 'package:yack/widgets/hrefTextWidget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  late final int buttonWidth;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text('Yack', style: theme.textTheme.titleMedium),
            SizedBox(
              width: PlatformInfo.isDesktop
                  ? min(400, screenWidth * 0.9)
                  : screenWidth,
              child: Column(
                spacing: 10,

                children: [
                  TitleWidget(text: 'Welcome'),
                  SizedBox(height: 30),
                  CustomTextField(hintText: 'Email'),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child:CustomTextField(hintText: 'First Name'),
                      ),
                      Expanded(
                        child:CustomTextField(hintText: 'Last Name'),
                      ),
                    ],
                  ),
                  CustomTextField(hintText: 'Password',isPassword: true,),

                  MaterialButton(
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsetsGeometry.all(20),
                    minWidth: double.infinity,
                    height: min(screenHeight * 0.08, 60),
                    color: theme.colorScheme.primary,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                Text("Already have an account?"),
                HrefWidget(text: 'Login'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
