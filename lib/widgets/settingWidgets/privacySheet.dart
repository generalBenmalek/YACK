import 'package:yack/widgets/settingWidgets/settingsSheet.dart';
import 'package:flutter/material.dart';

class PrivacySettingsSheet extends StatefulWidget {
  const PrivacySettingsSheet({super.key});

  @override
  State<PrivacySettingsSheet> createState() => _PrivacySettingsSheetState();
}

class _PrivacySettingsSheetState extends State<PrivacySettingsSheet> {
  bool shareData = false;
  bool biometricAuth = true;
  bool showProfilePublicly = false;

  @override
  Widget build(BuildContext context) {
    return SettingsSheet<bool>(
      title: 'Privacy Settings',
      options: [
        SettingOption(
          title: 'Share Analytics Data',
          subtitle: 'Help improve the app',
          type: SettingType.switchTile,
          value: shareData,
          onChanged: (v) => setState(() => shareData = v),
        ),
      ],
      onApply: () => Navigator.pop(context),
    );
  }
}
