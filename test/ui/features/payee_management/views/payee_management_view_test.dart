import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/payee.dart';
import 'package:smara_accounting/ui/features/payee_management/view_models/payee_management_view_model.dart';
import 'package:smara_accounting/ui/features/payee_management/views/payee_management_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;

  const starbucks = Payee(id: 'payee-1', name: 'Starbucks');

  setUp(() {
    repository = MockLedgerRepository();
  });

  testWidgets('lists every payee; add opens a dialog that calls through', (
    tester,
  ) async {
    when(
      repository.watchPayees(),
    ).thenAnswer((_) => Stream.value(const [starbucks]));
    when(
      repository.createPayee(name: anyNamed('name')),
    ).thenAnswer((_) async => const Payee(id: 'payee-2', name: 'Landlord'));

    final viewModel = PayeeManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: PayeeManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.text('Starbucks'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Landlord');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    verify(repository.createPayee(name: 'Landlord')).called(1);
  });

  testWidgets('renaming a payee calls through to the repository', (
    tester,
  ) async {
    when(
      repository.watchPayees(),
    ).thenAnswer((_) => Stream.value(const [starbucks]));
    when(
      repository.renamePayee(id: anyNamed('id'), newName: anyNamed('newName')),
    ).thenAnswer((_) async {});

    final viewModel = PayeeManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: PayeeManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    // Two IconButtons on the row - rename (pencil) then delete (trash).
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    expect(find.text('Rename payee'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Starbucks Coffee');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    verify(
      repository.renamePayee(id: 'payee-1', newName: 'Starbucks Coffee'),
    ).called(1);
  });

  testWidgets(
    'deleting a payee confirms first, then calls through to the repository',
    (tester) async {
      when(
        repository.watchPayees(),
      ).thenAnswer((_) => Stream.value(const [starbucks]));
      when(repository.deletePayee(any)).thenAnswer((_) async {});

      final viewModel = PayeeManagementViewModel(ledgerRepository: repository);
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: PayeeManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      // Two IconButtons on the row - rename (pencil) then delete (trash).
      await tester.tap(find.byType(IconButton).last);
      await tester.pumpAndSettle();

      expect(find.text('Delete payee?'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(repository.deletePayee('payee-1')).called(1);
    },
  );

  testWidgets('empty state when there are no payees', (tester) async {
    when(repository.watchPayees()).thenAnswer((_) => Stream.value(const []));

    final viewModel = PayeeManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: PayeeManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.text('No payees yet'), findsOneWidget);
  });
}
