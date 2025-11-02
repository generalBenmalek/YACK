import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:yack/screens/create_contract.dart';
import 'package:yack/screens/home.dart';
import 'package:yack/screens/scan_contract.dart';
import 'package:yack/screens/settings.dart';

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

  List<Widget> _buildScreens() => const [
    ContractsScreen(),
    ScanContractScreen(),
    CreateContractScreen(),
    SettingsScreen(),
  ];

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home, size: iconSize),
        // title: "Home",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: colorScheme.onSurfaceVariant,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.qr_code_scanner, size: iconSize),
        // title: "Scan",
        activeColorPrimary: Colors.tealAccent,
        inactiveColorPrimary: colorScheme.onSurfaceVariant,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.notifications, size: iconSize + 2),
        // title: "Add",
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: colorScheme.onSurfaceVariant,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings, size: iconSize),
        // title: "Settings",
        activeColorPrimary: Colors.indigoAccent,
        inactiveColorPrimary: colorScheme.onSurfaceVariant,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.red,
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
