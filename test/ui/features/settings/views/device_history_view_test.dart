import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/integrity_event.dart';
import 'package:smara_accounting/ui/features/settings/view_models/device_history_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/device_history_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  testWidgets(
    'shows continued-from-copy wording with both dates',
    (tester) async {
      final ledger = MockLedgerRepository();
      when(ledger.watchIntegrityEvents()).thenAnswer(
        (_) => Stream.value([
          IntegrityEvent(
            eventId: 'e1',
            eventType: IntegrityEventType.identityContinued,
            occurredAt: DateTime.utc(2026, 10, 3),
            relatedEntryId: null,
            relatedIdentityId: 'new',
            detail:
                '{"newId":"n","previousId":"p","copySavedAt":"2026-10-01T00:00:00.000Z"}',
          ),
        ]),
      );
      final viewModel = DeviceHistoryViewModel(ledgerRepository: ledger);
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: DeviceHistoryView(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('continued on this phone on'),
        findsOneWidget,
      );
      expect(find.textContaining('from a copy saved on'), findsOneWidget);
    },
  );
}
