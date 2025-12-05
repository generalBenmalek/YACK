import 'package:yack/core/utils/snack_bar_handler.dart';
import 'package:flutter/material.dart';
import 'package:yack/core/utils/translation_handler.dart';


class SettingsItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void futureFeature() {
      SnackBarHandler.showMessage(
          context, TranslationHandler.get('under_construction'));
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? futureFeature,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}