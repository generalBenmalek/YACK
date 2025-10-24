import 'package:flutter/material.dart';


class TitleWidget extends StatelessWidget {
  final String text;


  const TitleWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(text,style: TextStyle(
      fontSize: 30,
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.bold
    ),);
  }
}
