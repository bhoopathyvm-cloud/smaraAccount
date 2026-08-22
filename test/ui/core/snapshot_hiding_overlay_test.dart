import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/ui/core/snapshot_hiding_overlay.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockAppLockController controller;

  setUp(() {
    controller = MockAppLockController();
  });

  // Matches lib/main.dart, which wraps MaterialApp.router *inside*
  // SnapshotHidingOverlay (so the cover is captured in the OS app-switcher
  // snapshot). That means the overlay has no ambient Directionality/MaterialApp
  // ancestor of its own - putting it the other way around here would hide
  // that requirement.
  Widget buildOverlay() {
    return SnapshotHidingOverlay(
      appLockController: controller,
      child: const MaterialApp(home: Text('Balance: 1000.00')),
    );
  }

  testWidgets('shows the child uncovered when not backgrounded', (
    tester,
  ) async {
    when(controller.isBackgrounded).thenReturn(false);
    when(controller.isSnapshotHidingEnabled).thenReturn(true);

    await tester.pumpWidget(buildOverlay());

    expect(find.text('Balance: 1000.00'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
  });

  testWidgets(
    'covers the child when backgrounded and snapshot hiding is enabled',
    (tester) async {
      when(controller.isBackgrounded).thenReturn(true);
      when(controller.isSnapshotHidingEnabled).thenReturn(true);

      await tester.pumpWidget(buildOverlay());

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    },
  );

  testWidgets(
    'does not cover the child when backgrounded but snapshot hiding is off',
    (tester) async {
      when(controller.isBackgrounded).thenReturn(true);
      when(controller.isSnapshotHidingEnabled).thenReturn(false);

      await tester.pumpWidget(buildOverlay());

      expect(find.byIcon(Icons.lock_outline), findsNothing);
    },
  );

  testWidgets(
    'does not require an ambient Directionality, since main.dart places it '
    'above MaterialApp.router with no Directionality of its own',
    (tester) async {
      when(controller.isBackgrounded).thenReturn(false);
      when(controller.isSnapshotHidingEnabled).thenReturn(false);

      await tester.pumpWidget(buildOverlay());

      expect(tester.takeException(), isNull);
    },
  );
}
