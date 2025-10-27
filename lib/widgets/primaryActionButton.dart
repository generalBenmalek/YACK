import 'dart:math';

import 'package:flutter/material.dart';

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({super.key, required this.action, required this.onClick});

  final String action;
  final VoidCallback onClick;



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return  MaterialButton(
      onPressed: onClick,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsetsGeometry.all(20),
      minWidth: double.infinity,
      height: min(screenHeight * 0.08, 60),
      color: theme.colorScheme.primary,
      child: Text(
        action,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}