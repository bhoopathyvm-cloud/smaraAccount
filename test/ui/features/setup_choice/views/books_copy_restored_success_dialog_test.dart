import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/features/setup_choice/views/books_copy_restored_success_dialog.dart';

void main() {
  testWidgets(
    'restore success dialog explains the other device will not sync',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showBooksCopyRestoredSuccessDialog(context),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Books restored'), findsOneWidget);
      expect(
        find.textContaining(
          'Entries you make later on the other device will not appear here',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('save a new copy there and restore it here'),
        findsOneWidget,
      );
      expect(find.text('Close app'), findsOneWidget);
    },
  );
}
