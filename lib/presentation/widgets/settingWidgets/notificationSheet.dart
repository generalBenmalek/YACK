import 'package:yack/presentation/widgets/settingWidgets/settingsSheet.dart';
import 'package:flutter/material.dart';
import 'package:yack/logic/services/translation_handler.dart';

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  @override
  State<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool contractUpdates = true;
  bool paymentReminders = true;

  @override
  Widget build(BuildContext context) {
    return SettingsSheet<bool>(
      title: TranslationHandler.get('notification_settings'),
      options: [
        SettingOption(
          title: TranslationHandler.get('push_notifications'),
          subtitle: TranslationHandler.get('push_notifications_desc'),
          type: SettingType.switchTile,
          value: pushNotifications,
          onChanged: (v) => setState(() => pushNotifications = v),
        ),
        SettingOption(
          title: TranslationHandler.get('email_notifications'),
          subtitle: TranslationHandler.get('email_notifications_desc'),
          type: SettingType.switchTile,
          value: emailNotifications,
          onChanged: (v) => setState(() => emailNotifications = v),
        ),
        SettingOption(
          title: TranslationHandler.get('contract_updates'),
          subtitle: TranslationHandler.get('contract_updates_desc'),
          type: SettingType.switchTile,
          value: contractUpdates,
          onChanged: (v) => setState(() => contractUpdates = v),
        ),
        SettingOption(
          title: TranslationHandler.get('payment_reminders'),
          subtitle: TranslationHandler.get('payment_reminders_desc'),
          type: SettingType.switchTile,
          value: paymentReminders,
          onChanged: (v) => setState(() => paymentReminders = v),
        ),
      ],
      onApply: () => Navigator.pop(context),
    );
  }
}
