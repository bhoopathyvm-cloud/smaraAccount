import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Logical bottom system inset used to simulate an Android taskbar / nav bar.
const kBottomSystemInsetLogical = 80.0;

/// Tablet surface matching the reported Samsung SM-X230 class of device.
const kTabletLogicalSize = Size(1200, 1920);

/// Compact phone surface.
const kPhoneLogicalSize = Size(375, 667);

const kTestDevicePixelRatio = 2.0;

/// Configures the test view with a large bottom system inset and [logicalSize].
///
/// Callers should `addTearDown(tester.view.reset)` (or rely on this helper's
/// tear-down) so later tests are not polluted.
void configureBottomSystemInsetView(
  WidgetTester tester, {
  required Size logicalSize,
  double bottomInsetLogical = kBottomSystemInsetLogical,
  double devicePixelRatio = kTestDevicePixelRatio,
}) {
  tester.view.devicePixelRatio = devicePixelRatio;
  tester.view.physicalSize = Size(
    logicalSize.width * devicePixelRatio,
    logicalSize.height * devicePixelRatio,
  );
  final physicalInset = bottomInsetLogical * devicePixelRatio;
  tester.view.padding = FakeViewPadding(bottom: physicalInset);
  tester.view.viewPadding = FakeViewPadding(bottom: physicalInset);
}

/// Pumps [app] under a view with a large bottom system inset.
Future<void> pumpWithBottomSystemInset(
  WidgetTester tester, {
  required Widget app,
  required Size logicalSize,
  double bottomInsetLogical = kBottomSystemInsetLogical,
  double devicePixelRatio = kTestDevicePixelRatio,
}) async {
  configureBottomSystemInsetView(
    tester,
    logicalSize: logicalSize,
    bottomInsetLogical: bottomInsetLogical,
    devicePixelRatio: devicePixelRatio,
  );
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await tester.pump();
}

/// Asserts [actionFinder]'s bounds sit fully above the bottom system inset
/// and that its center is hit-testable.
Future<void> expectPrimaryActionClearOfBottomSystemInset(
  WidgetTester tester, {
  required Finder actionFinder,
  double bottomInsetLogical = kBottomSystemInsetLogical,
  bool scrollIntoView = false,
}) async {
  expect(actionFinder, findsOneWidget);

  if (scrollIntoView) {
    await tester.ensureVisible(actionFinder);
    await tester.pumpAndSettle();
  }

  final rect = tester.getRect(actionFinder);
  final screenHeight =
      tester.view.physicalSize.height / tester.view.devicePixelRatio;
  final maxBottom = screenHeight - bottomInsetLogical;

  expect(
    rect.bottom,
    lessThanOrEqualTo(maxBottom),
    reason:
        'Primary action bottom ${rect.bottom} must be <= $maxBottom '
        '(screen height $screenHeight − inset $bottomInsetLogical)',
  );

  final box = tester.renderObject<RenderBox>(actionFinder);
  final result = BoxHitTestResult();
  final local = box.globalToLocal(rect.center);
  expect(
    box.hitTest(result, position: local),
    isTrue,
    reason: 'Primary action center ${rect.center} must be hit-testable',
  );
}

/// Asserts a scrollable's padding bottom includes [base] + the system inset
/// (or just the inset when [base] is 0).
void expectScrollPaddingIncludesBottomInset(
  WidgetTester tester, {
  required Finder scrollableFinder,
  double bottomInsetLogical = kBottomSystemInsetLogical,
  double base = 16,
}) {
  expect(scrollableFinder, findsOneWidget);
  final widget = tester.widget(scrollableFinder);
  final EdgeInsetsGeometry? padding = switch (widget) {
    SingleChildScrollView(:final padding) => padding,
    ListView(:final padding) => padding,
    GridView(:final padding) => padding,
    CustomScrollView() => null,
    _ => null,
  };
  expect(padding, isNotNull, reason: 'Scrollable must declare padding');
  final resolved = padding!.resolve(TextDirection.ltr);
  expect(
    resolved.bottom,
    greaterThanOrEqualTo(base + bottomInsetLogical),
    reason:
        'Scroll padding bottom ${resolved.bottom} must be >= '
        '${base + bottomInsetLogical}',
  );
}
