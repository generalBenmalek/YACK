import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yack/screens/contract_agr/nomore_contracts.dart';
import 'package:yack/utils/passwordPopUp.dart';
import 'package:yack/widgets/secondaryActionButtonAutoLoading.dart';
import '../widgets/settingWidgets/appearanceSheet.dart';
import '../widgets/settingWidgets/notificationSheet.dart';
import '../widgets/settingWidgets/privacySheet.dart';
import '../widgets/settingWidgets/sectionHeader.dart';
import '../widgets/settingWidgets/settingsCard.dart';
import '../widgets/settingWidgets/settingsItem.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const NotificationSettingsSheet(),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const PrivacySettingsSheet(),
    );
  }

  void _showAppearanceSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AppearanceSettingsSheet(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About YACK'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YACK - Contract Management App'),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('© 2025 YACK. All rights reserved.'),
            SizedBox(height: 16),
            Text(
              'YACK helps you manage contracts efficiently with features like QR code scanning, digital signatures, and secure storage.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Settings', style: theme.textTheme.titleMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'ACCOUNT', color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              SettingsCard(
                children: [
                  SettingsItem(
                    icon: CircleAvatar(
                      radius: 30,
                      backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: 'Profile',
                    subtitle: 'Manage your profile information',
                    onTap: null,
                  ),
                  Divider(height: 1, color: theme.dividerTheme.color),
                  SettingsItem(
                    icon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.key_outlined,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: 'Password',
                    subtitle: 'Change your password',
                    onTap: () {
                      showChangePasswordDialog(context);
                    },
                  ),
                  Divider(height: 1, color: theme.dividerTheme.color),
                  SettingsItem(
                    icon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.rocket_launch,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: 'Upgrade',
                    subtitle: 'get premium features',
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pushNamed('/upgrade');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'PREFERENCES',
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              SettingsCard(
                children: [
                  SettingsItem(
                    icon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: 'Notifications',
                    subtitle: 'Customize notification settings',
                    onTap: () => _showNotificationSettings(context),
                  ),
                  Divider(height: 1, color: theme.dividerTheme.color),
                  SettingsItem(
                    icon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: 'Privacy',
                    subtitle: 'Adjust privacy settings',
                    onTap: () => _showPrivacySettings(context),
                  ),
                  Divider(height: 1, color: theme.dividerTheme.color),
                  SettingsItem(
                    icon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.brightness_5_outlined,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: 'Appearance',
                    subtitle: 'Manage app appearance',
                    onTap: () => _showAppearanceSettings(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'SUPPORT', color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              SettingsCard(
                children: [
                  SettingsItem(
                    icon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: 'Help & Support',
                    subtitle: 'Get help and support',
                    onTap: null,
                  ),
                  Divider(height: 1, color: theme.dividerTheme.color),
                  SettingsItem(
                    icon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: 'About YACK',
                    subtitle: 'Learn more about YACK',
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SecondaryActionButtonAutoReload(
                action: 'Logout',
                onClick: () async {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context, rootNavigator: true)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



