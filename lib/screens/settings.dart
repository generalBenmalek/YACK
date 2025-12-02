import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yack/utils/passwordPopUp.dart';
import 'package:yack/utils/translation_handler.dart';
import 'package:yack/widgets/secondaryActionButtonAutoLoading.dart';
import '../providers/auth/auth_cubit.dart';
import '../widgets/settingWidgets/appearanceSheet.dart';
import '../widgets/settingWidgets/languageSheet.dart';
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
        title: Text(TranslationHandler.get('about_yack')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(TranslationHandler.get('about_title')),
            SizedBox(height: 16),
            Text(TranslationHandler.get('app_version')),
            SizedBox(height: 8),
            Text(TranslationHandler.get('app_copyright')),
            SizedBox(height: 16),
            Text(
              TranslationHandler.get('about_description'),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationHandler.get('close')),
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
        title: Text(TranslationHandler.get('settings'),
            style: theme.textTheme.titleMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                  title: TranslationHandler.get('account_section'),
                  color: theme.colorScheme.primary),
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
                    title: TranslationHandler.get('profile'),
                    subtitle: TranslationHandler.get('profile_subtitle'),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true)
                          .pushNamed('/profile');
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
                        Icons.key_outlined,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: TranslationHandler.get('password'),
                    subtitle: TranslationHandler.get('password_subtitle'),
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
                    title: TranslationHandler.get('upgrade'),
                    subtitle: TranslationHandler.get('upgrade_subtitle'),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pushNamed('/upgrade');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: TranslationHandler.get('preferences_section'),
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
                    title: TranslationHandler.get('notifications'),
                    subtitle: TranslationHandler.get('notifications_subtitle'),
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
                    title: TranslationHandler.get('privacy'),
                    subtitle: TranslationHandler.get('privacy_subtitle'),
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
                    title: TranslationHandler.get('appearance'),
                    subtitle: TranslationHandler.get('appearance_subtitle'),
                    onTap: () => _showAppearanceSettings(context),
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
                        Icons.language,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: TranslationHandler.get('language'),
                    subtitle: TranslationHandler.get('language_subtitle'),
                    onTap: () => _showLanguageSettings(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                  title: TranslationHandler.get('support_section'),
                  color: theme.colorScheme.primary),
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
                    title: TranslationHandler.get('help_support'),
                    subtitle: TranslationHandler.get('help_support_subtitle'),
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
                    title: TranslationHandler.get('about_yack'),
                    subtitle: TranslationHandler.get('about_subtitle'),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SecondaryActionButtonAutoReload(
                action: TranslationHandler.get('logout'),
                onClick: () async {

                  FirebaseAuth.instance.signOut();
                  context.read<AuthCubit>().markUnauthenticated();

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

  void _showLanguageSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LanguageSettingsSheet(),
    );
  }
}



