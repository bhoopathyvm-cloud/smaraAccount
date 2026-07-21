import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import 'app_colors.dart';

const _largeScreenMinWidth = 600.0;

const _destinations = [
  (icon: TablerIcons.home, label: 'Home', path: '/home'),
  (icon: TablerIcons.receipt, label: 'Register', path: '/register'),
  (icon: TablerIcons.chartBar, label: 'Summary', path: '/summary'),
  (icon: TablerIcons.wallet, label: 'Accounts', path: '/accounts'),
  (icon: TablerIcons.tag, label: 'Categories', path: '/categories'),
];

/// Bottom tab bar on narrow windows, a sidebar on wide ones (design
/// system: mobile bottom nav vs. desktop sidebar/top bar) - the choice is
/// based on available window width, not device type
/// (flutter-build-responsive-layout).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > _largeScreenMinWidth) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onSelect,
                  backgroundColor: AppColors.primary,
                  selectedIconTheme: const IconThemeData(
                    color: AppColors.cardBackground,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: AppColors.borderCard,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.cardBackground,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.borderCard,
                  ),
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onSelect,
            items: [
              for (final d in _destinations)
                BottomNavigationBarItem(icon: Icon(d.icon), label: d.label),
            ],
          ),
        );
      },
    );
  }
}
