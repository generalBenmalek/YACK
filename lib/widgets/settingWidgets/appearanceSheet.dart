import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:yack/widgets/settingWidgets/settingsSheet.dart';

import '../../utils/snackBarHandler.dart';

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
      title: 'Appearance Settings',
      options: [
        SettingOption(
          title: 'Light',
          type: SettingType.radioTile,
          value: 'Light',
          groupValue: selectedTheme,
          onChanged: (v) => setState(() => selectedTheme = v),
        ),
        SettingOption(
          title: 'Dark',
          type: SettingType.radioTile,
          value: 'Dark',
          groupValue: selectedTheme,
          onChanged: (v) => setState(() => selectedTheme = v),
        ),
        SettingOption(
          title: 'System Default',
          subtitle: 'Follow system settings',
          type: SettingType.radioTile,
          value: 'System',
          groupValue: selectedTheme,
          onChanged: (v) => setState(() => selectedTheme = v),
        ),
      ],
      applyLabel: 'Apply',
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
          'Theme updated!',
        );
        Navigator.pop(context);
      },
    );
  }
}
