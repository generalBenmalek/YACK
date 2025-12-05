import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:yack/core/utils/translation_handler.dart';
import 'package:yack/shared/widgets/settings/settings_sheet.dart';

import 'package:yack/core/utils/snack_bar_handler.dart';

class AppearanceSettingsSheet extends StatefulWidget {
  const AppearanceSettingsSheet({super.key});

  @override
  State<AppearanceSettingsSheet> createState() =>
      _AppearanceSettingsSheetState();
}

class _AppearanceSettingsSheetState extends State<AppearanceSettingsSheet> {
  String selectedTheme = 'System';

  @override
  void initState() {
    super.initState();

    // Load initial theme from Hive
    final box = Hive.box('user');
    final themeValue = box.get('theme'); // 1=Light, 2=Dark, 3 or null=System

    setState(() {
      if (themeValue == 1) {
        selectedTheme = 'Light';
      } else if (themeValue == 2) {
        selectedTheme = 'Dark';
      } else {
        selectedTheme = 'System';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSheet<String>(
      title: TranslationHandler.get('appearance_settings'),
      options: [
        SettingOption(
          title: TranslationHandler.get('light'),
          type: SettingType.radioTile,
          value: 'Light',
          groupValue: selectedTheme,
          onChanged: (v) => setState(() => selectedTheme = v),
        ),
        SettingOption(
          title: TranslationHandler.get('dark'),
          type: SettingType.radioTile,
          value: 'Dark',
          groupValue: selectedTheme,
          onChanged: (v) => setState(() => selectedTheme = v),
        ),
        SettingOption(
          title: TranslationHandler.get('system_default'),
          subtitle: TranslationHandler.get('system_default_description'),
          type: SettingType.radioTile,
          value: 'System',
          groupValue: selectedTheme,
          onChanged: (v) => setState(() => selectedTheme = v),
        ),
      ],
      applyLabel: TranslationHandler.get('apply'),
      onApply: () {
        final box = Hive.box('user');
        final value = selectedTheme == 'Light'
            ? 1
            : selectedTheme == 'Dark'
            ? 2
            : 3;
        box.put('theme', value);

        SnackBarHandler.showSuccess(
          context,
          TranslationHandler.get('theme_updated'),
        );
        Navigator.pop(context);
      },
    );
  }
}
