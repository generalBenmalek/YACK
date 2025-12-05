import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yack/shared/widgets/secondary_action_button.dart';

class SecondaryActionButtonAutoReload extends StatefulWidget {
  final String action;
  final String? customLoadingText;
  /// Can be a normal or async function
  final FutureOr<void> Function() onClick;

  const SecondaryActionButtonAutoReload({
    super.key,
    required this.action,
    required this.onClick,
    this.customLoadingText,
  });

  @override
  State<SecondaryActionButtonAutoReload> createState() =>
      _SecondaryActionButtonAutoReloadState();
}

class _SecondaryActionButtonAutoReloadState
    extends State<SecondaryActionButtonAutoReload> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SecondaryActionButton(
      action: widget.customLoadingText ?? widget.action,
      isLoading: isLoading && widget.customLoadingText == null,
      onClick: () async {
        if (isLoading) return;

        setState(() => isLoading = true);

        try {
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
