import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
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
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final TextEditingController _internalController;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;

    // Use external controller if available, otherwise create once
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    // Only dispose if WE created the controller
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        textDirection: TextDirection.ltr,
        controller: _internalController,
        obscureText: widget.isPassword ? _obscureText : false,
        textAlign: TextAlign.left,
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            color: Colors.grey,
          ),
          filled: true,
          fillColor: widget.fillColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () => setState(() {
              _obscureText = !_obscureText;
            }),
          )
              : (widget.icon != null
              ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Icon(widget.icon, size: 24),
          )
              : null),
        ),
        validator: widget.validator,
      ),
    );
  }
}
