import 'package:flutter/material.dart';


class HrefWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClick;

  const HrefWidget({
    super.key,
    required this.text,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      child: GestureDetector(
          onTap: onClick,
          child: Text(text,style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold
          ),
          )
      ),
    );
  }
}
