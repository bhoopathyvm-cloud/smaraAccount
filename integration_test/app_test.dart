import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/ui/app_router.dart';
import 'package:smara_accounting/ui/core/app_theme.dart';
import 'package:smara_accounting/ui/features/category_management/view_models/category_management_view_model.dart';
import 'package:smara_accounting/ui/features/register/view_models/register_view_model.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/summary/view_models/summary_view_model.dart';

// Full user journeys against the real widget tree (Repository,
// ViewModels, Views, go_router - everything main.dart wires up), with an
// in-memory Drift database standing in for the on-device file so the
// suite doesn't touch real storage.
//
// Uses only bounded tester.pump() calls, never pumpAndSettle(): the
// ViewModels subscribe to live, long-running Drift watch() streams, which
// keep the frame scheduler "active" indefinitely from pumpAndSettle's
// point of view (see the widget test suite's file comments for how this
// was diagnosed).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LedgerRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LedgerRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp() {
    return MultiProvider(
      providers: [
        Provider<LedgerRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(ledgerRepository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => SummaryViewModel(ledgerRepository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CategoryManagementViewModel(ledgerRepository: repository),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: buildAppRouter(repository),
          );
        },
      ),
    );
  }

  testWidgets('record money in updates the register and running balance', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(TablerIcons.plus));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField).first, '25');
    await tester.pump();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Salary').last);
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('+25.00'), findsOneWidget);
  });

  testWidgets(
    'reversing a posted entry keeps the original and adds a new entry',
    (tester) async {
      final categories = await repository.watchCategories().first;
      final incomeId = categories
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime.now(),
      );

      final registerViewModel = RegisterViewModel(ledgerRepository: repository);
      addTearDown(registerViewModel.dispose);
      await Future<void>.delayed(Duration.zero);
      final entryId = registerViewModel.rows.single.entryId;

      await registerViewModel.reverseEntry(entryId);
      await Future<void>.delayed(Duration.zero);

      expect(registerViewModel.rows, hasLength(2));
      expect(
        registerViewModel.rows.where((r) => r.entryId == entryId),
        hasLength(1),
      );
      expect(registerViewModel.rows.any((r) => r.isReversal), isTrue);
    },
  );

  testWidgets(
    'archiving a category hides it from the picker but keeps history visible',
    (tester) async {
      final categories = await repository.watchCategories().first;
      final salary = categories.firstWhere((a) => a.name == 'Salary');
      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: salary.id,
        transactionDate: DateTime.now(),
      );
      await repository.archiveCategory(salary.id);

      final pickerCategories = await repository.watchCategories().first;
      expect(pickerCategories.any((a) => a.id == salary.id), isFalse);

      final registerViewModel = RegisterViewModel(ledgerRepository: repository);
      addTearDown(registerViewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(registerViewModel.rows.single.categoryName, equals('Salary'));
    },
  );
}
