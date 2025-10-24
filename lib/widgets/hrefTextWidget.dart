import 'package:flutter/material.dart';


class HrefWidget extends StatelessWidget {
  final String text;


  const HrefWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      child: GestureDetector(
          onTap: (){} ,
          child: Text(text,style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold
          ),
          )
      ),
    );
  }
}
