import 'package:flutter/material.dart';


class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final Color? fillColor;
  final IconData? icon;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.fillColor,
    this.icon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller ?? TextEditingController(),
        obscureText: isPassword,
        textAlign: TextAlign.left,
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 14,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          // disabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(20.0),
          //
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(20.0),
          //
          // ),
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(20.0),
          //
          // ),
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
    );
  }
}
