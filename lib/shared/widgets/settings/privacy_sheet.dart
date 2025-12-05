import 'package:yack/shared/widgets/settings/settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:yack/core/utils/translation_handler.dart';

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
      title: TranslationHandler.get('privacy_settings'),
      options: [
        SettingOption(
          title: TranslationHandler.get('share_analytics'),
          subtitle: TranslationHandler.get('share_analytics_desc'),
          type: SettingType.switchTile,
          value: shareData,
          onChanged: (v) => setState(() => shareData = v),
        ),
      ],
      onApply: () => Navigator.pop(context),
    );
  }
}
