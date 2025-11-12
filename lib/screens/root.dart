import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:yack/screens/home.dart';
import 'package:yack/screens/notifications.dart';
import 'package:yack/screens/scan_contract.dart';
import 'package:yack/screens/settings.dart';
import 'package:yack/utils/translation_handler.dart';

import '../models/notification.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late PersistentTabController _controller;
  static const double iconSize = 23.0;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: widget.initialIndex);
  }

  List<Widget> _buildScreens() {
    final screens = [
      const ContractsScreen(),
      const ScanContractScreen(),
      NotificationsPage(notifications: [
        NotificationModel(
          title: TranslationHandler.get('contract_approved_notification'),
          body: TranslationHandler.get('contract_approved_message'),
          date: DateTime.now().subtract(const Duration(hours: 3)),
          icon: Icons.check_circle_outline,
        ),
        NotificationModel(
          title: TranslationHandler.get('new_message_notification'),
          body: TranslationHandler.get('new_message_body'),
          date: DateTime.now().subtract(const Duration(days: 1)),
          icon: Icons.chat_bubble_outline,
        ),
      ]),
      const SettingsScreen(),
    ];

    return TranslationHandler.isRTL ? screens.reversed.toList() : screens;
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home, size: iconSize),
        title: TranslationHandler.get('contracts'),
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: colorScheme.onSurfaceVariant,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.qr_code_scanner, size: iconSize),
        title: TranslationHandler.get('scan_contract_qr'),
        activeColorPrimary: Colors.tealAccent,
        inactiveColorPrimary: colorScheme.onSurfaceVariant,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.notifications, size: iconSize + 2),
        title: TranslationHandler.get('notifications_title'),
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: colorScheme.onSurfaceVariant,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings, size: iconSize),
        title: TranslationHandler.get('settings_label'),
        activeColorPrimary: Colors.indigoAccent,
        inactiveColorPrimary: colorScheme.onSurfaceVariant,
      ),
    ];

    return TranslationHandler.isRTL ? items.reversed.toList() : items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: PersistentTabView(
        context,
        neumorphicProperties: NeumorphicProperties(showSubtitleText: false),
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(context),
        navBarStyle: NavBarStyle.style3, // change style here
        backgroundColor: Theme.of(context).colorScheme.surface,
        // decoration: const NavBarDecoration(
        //   borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        // ),
        resizeToAvoidBottomInset: true,
        hideNavigationBarWhenKeyboardAppears: true,
        popBehaviorOnSelectedNavBarItemPress: PopBehavior.once,
      ),
    );
  }
}
