import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    super.key,
    required this.action,
    required this.onClick,
    this.isLoading = false,
  });

  final String action;
  final bool isLoading;
  final FutureOr<void> Function() onClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return MaterialButton(
      onPressed: isLoading ? () {} : onClick,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: theme.colorScheme.error, // error color border
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      minWidth: double.infinity,
      height: min(screenHeight * 0.08, 60),
      // color: Colors.transparent, // transparent background
      child: isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: theme.colorScheme.error,
          strokeWidth: 2,
        ),
      )
          : Text(
        action,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
