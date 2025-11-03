import 'package:yack/widgets/settingWidgets/settingsSheet.dart';
import 'package:flutter/material.dart';

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
      title: 'Notification Settings',
      options: [
        SettingOption(
          title: 'Push Notifications',
          subtitle: 'Receive notifications on your device',
          type: SettingType.switchTile,
          value: pushNotifications,
          onChanged: (v) => setState(() => pushNotifications = v),
        ),
        SettingOption(
          title: 'Email Notifications',
          subtitle: 'Receive notifications via email',
          type: SettingType.switchTile,
          value: emailNotifications,
          onChanged: (v) => setState(() => emailNotifications = v),
        ),
        SettingOption(
          title: 'Contract Updates',
          subtitle: 'Notify when contracts are updated',
          type: SettingType.switchTile,
          value: contractUpdates,
          onChanged: (v) => setState(() => contractUpdates = v),
        ),
        SettingOption(
          title: 'Payment Reminders',
          subtitle: 'Remind about upcoming payments',
          type: SettingType.switchTile,
          value: paymentReminders,
          onChanged: (v) => setState(() => paymentReminders = v),
        ),
      ],
      onApply: () => Navigator.pop(context),
    );
  }
}
