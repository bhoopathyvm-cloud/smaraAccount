import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/ui/features/transfer/view_models/transfer_view_model.dart';
import 'package:smara_accounting/ui/features/transfer/views/transfer_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;

  const checking = Account(
    id: 'asset-1',
    name: 'Checking',
    type: AccountType.asset,
    archived: false,
  );
  const savings = Account(
    id: 'asset-2',
    name: 'Savings',
    type: AccountType.asset,
    archived: false,
  );

  setUp(() {
    repository = MockLedgerRepository();
    when(
      repository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking, savings]));
  });

  testWidgets('shows a hint and disables submit with fewer than two accounts', (
    tester,
  ) async {
    when(
      repository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking]));

    final viewModel = TransferViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: TransferView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(
      find.text('Create at least two active accounts to make a transfer.'),
      findsOneWidget,
    );
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('submitting a valid transfer calls onSaved', (tester) async {
    when(
      repository.recordTransfer(
        fromAccountId: anyNamed('fromAccountId'),
        toAccountId: anyNamed('toAccountId'),
        amountMinor: anyNamed('amountMinor'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async {});

    final viewModel = TransferViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);
    var saved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TransferView(viewModel: viewModel, onSaved: () => saved = true),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, '25.00');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Transfer'));
    await tester.pump();
    await tester.pump();

    expect(saved, isTrue);
    verify(
      repository.recordTransfer(
        fromAccountId: 'asset-1',
        toAccountId: 'asset-2',
        amountMinor: 2500,
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    ).called(1);
  });

  testWidgets('surfaces a domain exception as an error message', (
    tester,
  ) async {
    when(
      repository.recordTransfer(
        fromAccountId: anyNamed('fromAccountId'),
        toAccountId: anyNamed('toAccountId'),
        amountMinor: anyNamed('amountMinor'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    ).thenThrow(InvalidTransferException('accounts must be distinct'));

    final viewModel = TransferViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: TransferView(viewModel: viewModel)),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, '10.00');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Transfer'));
    await tester.pump();
    await tester.pump();

    expect(find.text('accounts must be distinct'), findsOneWidget);
  });
}
