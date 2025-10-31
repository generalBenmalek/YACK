import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final Color? fillColor;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.fillColor,
    this.icon,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField( // use TextFormField instead of TextField
        controller: controller ?? TextEditingController(),
        obscureText: isPassword,
        textAlign: TextAlign.left,
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            color: Colors.grey,
          ),
          filled: true,
          fillColor: fillColor,
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 20,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 10,
            ),
            child: Icon(
              icon,
              // color: primaryColor,
              size: 24,
            ),
          ),
        ),
      validator: validator,
    );
  }
}
