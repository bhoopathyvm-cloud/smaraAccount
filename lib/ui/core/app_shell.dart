import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/l10n.dart';
import 'app_colors.dart';

const _largeScreenMinWidth = 600.0;

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
    final l10n = l10nOf(context);
    final destinations = [
      (icon: TablerIcons.home, label: l10n.navHome, path: '/home'),
      (icon: TablerIcons.receipt, label: l10n.navRegister, path: '/register'),
      (icon: TablerIcons.chartBar, label: l10n.navSummary, path: '/summary'),
      (icon: TablerIcons.wallet, label: l10n.navAccounts, path: '/accounts'),
      (icon: TablerIcons.tag, label: l10n.navCategories, path: '/categories'),
    ];
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
                    for (final d in destinations)
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
              for (final d in destinations)
                BottomNavigationBarItem(icon: Icon(d.icon), label: d.label),
            ],
          ),
        );
      },
    );
  }
}
