import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yack/widgets/primaryActionButton.dart';

class PrimaryActionButtonAutoReload extends StatefulWidget {
  final String action;
  final String? customLoadingText;
  /// Can be a normal or async function
  final FutureOr<void> Function() onClick;

  const PrimaryActionButtonAutoReload({
    super.key,
    required this.action,
    required this.onClick,
    this.customLoadingText,
  });

  @override
  State<PrimaryActionButtonAutoReload> createState() =>
      _PrimaryActionButtonAutoReloadState();
}

class _PrimaryActionButtonAutoReloadState
    extends State<PrimaryActionButtonAutoReload> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PrimaryActionButton(
      action: widget.customLoadingText ?? widget.action,
      isLoading: isLoading && widget.customLoadingText == null ,
      onClick: () async {
        if (isLoading) return;

        setState(() => isLoading = true);

        try {
          // Handles both sync and async automatically
          await Future.sync(widget.onClick);
        } catch (e) {
          debugPrint('Error during action: $e');
        } finally {
          if (mounted) setState(() => isLoading = false);
        }
      },
    );
  }
}
