import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/core/app_colors.dart';
import 'package:smara_accounting/ui/core/app_shell.dart';
import 'package:smara_accounting/ui/core/app_theme.dart';
import 'package:smara_accounting/ui/core/app_typography.dart';

void main() {
  GoRouter shellRouter() => GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          for (final path in [
            '/home',
            '/register',
            '/summary',
            '/accounts',
            '/categories',
          ])
            StatefulShellBranch(
              routes: [GoRoute(path: path, builder: (_, _) => Text(path))],
            ),
        ],
      ),
    ],
  );

  testWidgets(
    'narrow window uses a fixed bottom bar so the navy theme applies',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          routerConfig: shellRouter(),
        ),
      );
      await tester.pumpAndSettle();

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.items, hasLength(5));
      // Regression: with five items and no explicit type Flutter picks
      // "shifting", which paints a white bar with an invisible selection.
      expect(bar.type, BottomNavigationBarType.fixed);
    },
  );

  test('app-bar titles are white on the navy bar', () {
    expect(AppTypography.headerTitle.color, AppColors.cardBackground);
  });
}
