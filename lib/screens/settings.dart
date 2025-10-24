import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'ACCOUNT',
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              SettingsCard(
                children: [
                  SettingsItem(
                    icon: CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                      // backgroundImage: AssetImage('images/profile.jpg'),
                    ),
                    title: 'Profile',
                    subtitle: 'Manage your profile information',
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerTheme.color,
                  ),
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
                    onTap: () {},
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
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerTheme.color,
                  ),
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
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerTheme.color,
                  ),
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
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'SUPPORT',
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
                        Icons.help_outline,
                        size: 28,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    title: 'Help & Support',
                    subtitle: 'Get help and support',
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerTheme.color,
                  ),
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
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const SectionHeader({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }
}