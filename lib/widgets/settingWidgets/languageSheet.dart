import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:yack/utils/translation_handler.dart';

import '../../utils/snackBarHandler.dart';
import 'settingsSheet.dart';

class LanguageSettingsSheet extends StatefulWidget {
  const LanguageSettingsSheet({super.key});

  @override
  State<LanguageSettingsSheet> createState() => _LanguageSettingsSheetState();
}

class _LanguageSettingsSheetState extends State<LanguageSettingsSheet> {
  late String _selectedLanguage;

  final Map<String, String> _languageFlags = const {
    'en': '🇺🇸',
    'fr': '🇫🇷',
    'ar': '🇸🇦',
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = TranslationHandler.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSheet<String>(
      title: TranslationHandler.get('language_settings'),
      options: [
        for (final languageCode in _languageFlags.keys)
          SettingOption<String>(
            title:
                '${_languageFlags[languageCode]} ${TranslationHandler.get(_languageNameKey(languageCode))}',
            type: SettingType.radioTile,
            value: languageCode,
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() => _selectedLanguage = value);
            },
          ),
      ],
      applyLabel: TranslationHandler.get('apply'),
      onApply: () async {
        final box = Hive.box('user');
        await TranslationHandler.changeLanguage(_selectedLanguage);
        await box.put('language', _selectedLanguage);
        if (mounted) {
          SnackBarHandler.showSuccess(
            context,
            TranslationHandler.get('language_updated'),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  String _languageNameKey(String code) {
    switch (code) {
      case 'fr':
        return 'french';
      case 'ar':
        return 'arabic';
      case 'en':
      default:
        return 'english';
    }
  }
}
