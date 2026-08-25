import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/core/show_managed_dialog.dart';

void main() {
  testWidgets(
    'closing a managed dialog never disposes its controller mid-animation',
    (tester) async {
      late TextEditingController captured;
      late Future<Object?> dialogFuture;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  dialogFuture = showManagedDialog<void>(
                    context: context,
                    controllerCount: 1,
                    initialTexts: const ['hello'],
                    builder: (dialogContext, controllers) {
                      captured = controllers.single;
                      return AlertDialog(
                        content: TextField(controller: controllers.single),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(captured.text, 'hello');

      await tester.tap(find.text('Close'));
      // Start the exit transition without settling — the route is still
      // mounted and rebuilding its TextField for a few frames.
      await tester.pump();
      expect(
        () => captured.text,
        returnsNormally,
        reason: 'controller must still be alive during exit animation',
      );

      await tester.pumpAndSettle();
      await dialogFuture;
      // TextEditingController.text is readable after dispose; a second
      // dispose is what asserts the managed helper already disposed it.
      expect(
        () => captured.dispose(),
        throwsFlutterError,
        reason: 'controller is disposed only after the route completes',
      );
    },
  );
}
