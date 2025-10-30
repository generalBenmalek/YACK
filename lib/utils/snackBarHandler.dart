import 'package:flutter/material.dart';

class SnackBarHandler {
  static void showMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blueAccent);
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green);
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.redAccent);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.orangeAccent);
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;
    final animationDuration = const Duration(milliseconds: 300);
    final displayDuration = const Duration(seconds: 2);
    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: animationDuration,
    );

    final animation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned (
        top: 10,
        left: 10,
        right: 10,
        child: SafeArea(child: SlideTransition(
          position: animation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),)
    );

    overlay.insert(overlayEntry);
    controller.forward();

    Future.delayed(displayDuration, () async {
      await controller.reverse();
      overlayEntry.remove();
      controller.dispose();
    });
  }

}
