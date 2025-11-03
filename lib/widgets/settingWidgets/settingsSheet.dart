import 'package:flutter/material.dart';

enum SettingType { switchTile, radioTile }

class SettingOption<T> {
  final String title;
  final String? subtitle;
  final SettingType type;
  final T value;
  final T? groupValue; // used for radio
  final ValueChanged<T> onChanged;

  SettingOption({
    required this.title,
    this.subtitle,
    required this.type,
    required this.value,
    this.groupValue,
    required this.onChanged,
  });
}

class SettingsSheet<T> extends StatelessWidget {
  final String title;
  final List<SettingOption<T>> options;
  final VoidCallback? onApply;
  final String? applyLabel;

  const SettingsSheet({
    super.key,
    required this.title,
    required this.options,
    this.onApply,
    this.applyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...options.map((opt) {
            if (opt.type == SettingType.switchTile) {
              return SwitchListTile(
                title: Text(opt.title),
                subtitle: opt.subtitle != null ? Text(opt.subtitle!) : null,
                value: opt.value as bool,
                onChanged: (v) => opt.onChanged(v as T),
              );
            } else {
              return RadioListTile<T>(
                title: Text(opt.title),
                subtitle: opt.subtitle != null ? Text(opt.subtitle!) : null,
                value: opt.value,
                groupValue: opt.groupValue,
                onChanged: (v) {
                  if (v != null) opt.onChanged(v);
                },
              );
            }
          }),
          const SizedBox(height: 16),
          if (onApply != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApply,
                child: Text(applyLabel ?? 'Done'),
              ),
            ),
        ],
      ),
    );
  }
}
