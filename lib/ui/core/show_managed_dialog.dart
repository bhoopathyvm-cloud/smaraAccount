import 'package:flutter/material.dart';

/// Shows a dialog whose [TextEditingController]s outlive the route's exit
/// animation (architecture-deepening design.md D5).
///
/// [showDialog]'s Future resolves as soon as [Navigator.pop] is called,
/// while the dialog route is still animating out and rebuilding its
/// [TextField]s. Disposing controllers at that moment races the animation
/// and can throw. This helper creates [controllerCount] controllers
/// (optionally pre-filled via [initialTexts]), hands them to [builder],
/// awaits the route's [DialogRoute.completed] future, and only then
/// disposes them.
Future<T?> showManagedDialog<T>({
  required BuildContext context,
  required int controllerCount,
  List<String?>? initialTexts,
  bool barrierDismissible = true,
  required Widget Function(
    BuildContext dialogContext,
    List<TextEditingController> controllers,
  )
  builder,
}) async {
  assert(
    initialTexts == null || initialTexts.length <= controllerCount,
    'initialTexts length must not exceed controllerCount',
  );
  final controllers = List<TextEditingController>.generate(controllerCount, (
    i,
  ) {
    final initial = (initialTexts != null && i < initialTexts.length)
        ? (initialTexts[i] ?? '')
        : '';
    return TextEditingController(text: initial);
  });

  final navigator = Navigator.of(context, rootNavigator: true);
  final route = DialogRoute<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => builder(dialogContext, controllers),
  );
  // ignore: unawaited_futures — completed is awaited below
  navigator.push(route);
  try {
    return await route.completed;
  } finally {
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}
