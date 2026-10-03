import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/l10n/generated/app_localizations.dart';
import 'package:smara_accounting/ui/features/onboarding/views/currency_selection_view.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/first_identity_setup_view_model.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/domain/time/iso_date.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/books_copy_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/investment_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_verifier.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/payee_repository.dart';
import 'package:smara_accounting/data/repositories/recurring_template_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/data/repositories/statement_import_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/integrity_event.dart';
import 'package:smara_accounting/ui/app_router.dart';
import 'package:smara_accounting/ui/core/app_lock_controller.dart';
import 'package:smara_accounting/ui/core/app_theme.dart';
import 'package:smara_accounting/ui/features/account_management/view_models/account_management_view_model.dart';
import 'package:smara_accounting/ui/features/category_management/view_models/category_management_view_model.dart';
import 'package:smara_accounting/ui/features/home/view_models/home_view_model.dart';
import 'package:smara_accounting/ui/features/continuation/view_models/continuation_view_model.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';
import 'package:smara_accounting/ui/features/register/view_models/register_view_model.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/setup_choice/view_models/bundle_import_view_model.dart';
import 'package:smara_accounting/ui/features/summary/view_models/summary_view_model.dart';

import '../test/domain/crypto/in_memory_secure_key_storage.dart';

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
//
// app_router.dart's redirect chains several awaited Repository calls
// (currentIdentity/hasMatchingStoredKey/verifyChain) - pumpUntilFound
// polls with bounded pumps instead of guessing a fixed duration, which
// held for the simpler pre-existing navigations in this file but proved
// too fragile once a redirect needed multiple resolved Futures in a row.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxTries = 40,
}) async {
  for (var i = 0; i < maxTries; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 50));
  }
  // Final attempt so the caller's own expect() produces a clear failure
  // message rather than this helper silently giving up.
  await tester.pump(const Duration(milliseconds: 50));
}

// The macOS desktop test target's default surface size is small enough
// that AppShell's bottom navigation bar renders at a screen position
// tester.tap()'s hit-testing doesn't agree with (a "derived an Offset that
// would not hit test" warning followed by the tap silently not landing) -
// this reproduces even on pre-existing, currency-unrelated tests. Forcing
// a phone-sized, 1x-density surface (matching what the app is actually
// designed and manually tested against) makes tap() coordinates agree
// with the rendered layout again.
Future<void> pumpApp(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(app);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SigningKeyService signingKeyService;
  late LedgerRepository repository;
  late AccountRepository accountRepository;
  late CategoryRepository categoryRepository;
  late IdentityRepository identityRepository;
  late String seedEntryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    signingKeyService = SigningKeyService(
      secureStorage: InMemorySecureKeyStorage(),
    );
    repository = LedgerRepository(
      database: db,
      signingKeyService: signingKeyService,
    );
    accountRepository = AccountRepository(
      database: db,
      ledgerRepository: repository,
    );
    categoryRepository = CategoryRepository(database: db);
    identityRepository = IdentityRepository(
      database: db,
      accountRepository: accountRepository,
      signingKeyService: signingKeyService,
    );
    // app_router.dart's redirect requires a confirmed signing identity
    // with at least one recorded journal entry, plus a completed
    // first-week-setup wizard, before /register (or any other main
    // route) is reachable - these tests exercise the ledger, not
    // onboarding, so start past all of it. Unlike the old mandatory
    // acknowledgment flow (removed - device-migration-bundle), there is
    // no repository-level shortcut left to skip the "has any journal
    // entry" gate other than actually posting one, so this posts a real,
    // balanced entry between two system accounts (opening-balance
    // equity and transfers-in-transit) that never appear as a financial
    // account, never touch an income/expense category, and never touch
    // the starter checking account - so it never perturbs a test's own
    // exact balance/summary/entry-count assertions. A few tests that
    // query `watchEntries()`/`watchIntegrityEvents()` globally (not
    // scoped to one account) filter this seed entry out by
    // [seedEntryId] explicitly - see their own comments.
    final generated = await identityRepository.generateFirstIdentity();
    await identityRepository.confirmFirstIdentity(generated, currency: 'USD');
    seedEntryId = await repository.appendSignedEntry(
      transactionDate: dateOnly(DateTime(2020, 1, 1)),
      description: 'app_test.dart fixture seed',
      postings: [
        (
          accountId: openingBalanceEquityAccountId,
          amountMinor: 1,
          lineNumber: 1,
        ),
        (
          accountId: transfersInTransitAccountId,
          amountMinor: -1,
          lineNumber: 2,
        ),
      ],
    );
    await SettingsRepository().setFirstWeekSetupCompleted(true);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp() => buildAppFor(repository, db, signingKeyService);

  testWidgets(
    'double-tapping Continue on the currency step seeds the starter books once',
    (tester) async {
      // Fresh books, separate from the shared fixture above: this exercises
      // the real CurrencySelectionView -> FirstIdentitySetupViewModel ->
      // IdentityRepository path on the device. Two taps with no frame in
      // between once seeded every starter category twice on a real tablet.
      final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(freshDb.close);
      final freshKeys = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final freshLedger = LedgerRepository(
        database: freshDb,
        signingKeyService: freshKeys,
      );
      final viewModel = FirstIdentitySetupViewModel(
        identityRepository: IdentityRepository(
          database: freshDb,
          accountRepository: AccountRepository(
            database: freshDb,
            ledgerRepository: freshLedger,
          ),
          signingKeyService: freshKeys,
        ),
        chainVerifier: LedgerChainVerifier(
          database: freshDb,
          signingKeyService: freshKeys,
        ),
      );
      var finished = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: CurrencySelectionView(
            viewModel: viewModel,
            onFinished: () => finished++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      await tester.tap(continueButton);
      await tester.tap(continueButton, warnIfMissed: false);
      for (var i = 0; i < 50 && finished == 0; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(finished, greaterThanOrEqualTo(1));
      expect(
        await freshDb.select(freshDb.signingIdentities).get(),
        hasLength(1),
      );
      final names = [
        for (final account in await freshDb.select(freshDb.accounts).get())
          account.name,
      ];
      expect(names.toSet().length, names.length, reason: '$names');
    },
  );

  testWidgets('record money in updates the register and running balance', (
    tester,
  ) async {
    await pumpApp(tester, buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The app now lands on Home by default; the add-transaction FAB
    // lives on the Register tab.
    await tester.tap(find.text('Register'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The FAB opens the capture sheet; pick "Received".
    await tester.tap(find.byIcon(TablerIcons.plus));
    await pumpUntilFound(tester, find.text('Received'), maxTries: 200);
    await tester.tap(find.text('Received').last);
    await pumpUntilFound(
      tester,
      find.byType(RecordTransactionView),
      maxTries: 200,
    );

    // Scoped: the Register's search field stays mounted under the route.
    await tester.enterText(
      find
          .descendant(
            of: find.byType(RecordTransactionView),
            matching: find.byType(TextField),
          )
          .first,
      '25',
    );
    await tester.pump();

    // Two dropdowns now exist (Account, then Category) - the category
    // picker is the last one.
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
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
      final categories = await categoryRepository.watchCategories().first;
      final incomeId = categories
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      final accounts = await accountRepository.watchFinancialAccounts().first;
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accounts.first.id,
        transactionDate: DateTime.now(),
      );

      final registerViewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
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
      final categories = await categoryRepository.watchCategories().first;
      final salary = categories.firstWhere((a) => a.name == 'Salary');
      final accounts = await accountRepository.watchFinancialAccounts().first;
      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: salary.id,
        financialAccountId: accounts.first.id,
        transactionDate: DateTime.now(),
      );
      await categoryRepository.archiveCategory(salary.id);

      final pickerCategories = await categoryRepository.watchCategories().first;
      expect(pickerCategories.any((a) => a.id == salary.id), isFalse);

      final registerViewModel = RegisterViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
      addTearDown(registerViewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(registerViewModel.rows.single.categoryName, equals('Salary'));
    },
  );

  testWidgets(
    'category management screen renders the archive action without a layout error',
    (tester) async {
      await pumpApp(tester, buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Categories'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Hide'), findsWidgets);

      // Both branches stay mounted under StatefulShellRoute.indexedStack,
      // so switching tabs is what previously triggered a Hero tag
      // collision between the two screens' FloatingActionButtons.
      await tester.tap(find.text('Register'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tamper detection: a mutated row is quarantined on restart and new activity re-anchors',
    (tester) async {
      final categories = await categoryRepository.watchCategories().first;
      final incomeId = categories
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      final accounts = await accountRepository.watchFinancialAccounts().first;
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accounts.first.id,
        transactionDate: DateTime(2026, 1, 15),
      );
      final tampered = (await repository.watchEntries().first).firstWhere(
        (e) => e.id != seedEntryId,
      );

      // Mutate the stored row directly - not through the Repository (which
      // has no update path) - exactly mimicking direct SQLite file access
      // outside the app.
      await (db.update(
        db.journalEntries,
      )..where((e) => e.id.equals(tampered.id))).write(
        JournalEntriesCompanion(description: Value('tampered outside the app')),
      );

      // "Restart": a fresh widget tree (fresh ViewModels, fresh
      // GoRouter/redirect closure), same underlying database - matching
      // how the real app's database file persists across restarts.
      await pumpApp(tester, buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // The app lands on Home by default; the quarantine indicator is
      // rendered on the Register tab's rows.
      await tester.tap(find.text('Register'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byIcon(TablerIcons.lock), findsOneWidget);

      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accounts.first.id,
        transactionDate: DateTime(2026, 1, 16),
      );
      final newEntry = (await repository.watchEntries().first).firstWhere(
        (e) => e.id != tampered.id,
      );
      expect(newEntry.isVerified, isTrue);

      final events = await repository.watchIntegrityEvents().first;
      expect(
        events.any((e) => e.eventType == IntegrityEventType.chainBreakDetected),
        isTrue,
      );
      expect(
        events.any((e) => e.eventType == IntegrityEventType.chainReanchored),
        isTrue,
      );

      final summary = await repository
          .watchSummary(
            start: DateTime(2020, 1, 1),
            end: DateTime(2030, 12, 31),
          )
          .first;
      // Only the post-break entry (500) counts - the quarantined 1000 does not.
      expect(summary.totalIncomeMinor, equals(500));
    },
  );

  testWidgets(
    'full cross-currency transfer lifecycle: provisional, pending on Home, then settled',
    (tester) async {
      final incomeId = (await categoryRepository.watchCategories().first)
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      final checkingId =
          (await accountRepository.watchFinancialAccounts().first).first.id;
      await repository.recordTransaction(
        amountMinor: 100000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: checkingId,
        transactionDate: DateTime(2026, 1, 15),
      );
      await accountRepository.changeAccountGroupCurrency(
        groupId: groupPensionRetirementId,
        currency: 'EUR',
      );
      await accountRepository.createFinancialAccount(
        name: 'Euro Savings',
        type: AccountType.asset,
        groupId: groupPensionRetirementId,
      );

      await pumpApp(tester, buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Accounts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byIcon(TablerIcons.arrowsExchange));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Only two accounts exist (Cash & Bank, Euro Savings), so
      // TransferViewModel's defaults already pick them as from/to - no
      // dropdown interaction needed to get a cross-currency pair.
      expect(find.text('Destination amount (optional)'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Moved money'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Back on Home (Transfer pops to its caller); the pending item shows.
      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await pumpUntilFound(tester, find.text('MONEY IN TRANSIT'));
      await pumpUntilFound(tester, find.text('MONEY IN TRANSIT'));
      expect(find.text('MONEY IN TRANSIT'), findsOneWidget);
      final pendingBefore =
          (await repository.watchPendingTransfers().first).single;
      expect(pendingBefore.currency, equals('USD'));

      await tester.ensureVisible(find.textContaining('You sent').first);
      await tester.pump();
      await tester.ensureVisible(find.textContaining('You sent').first);
      await tester.pump();
      await tester.tap(find.textContaining('You sent').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await pumpUntilFound(tester, find.text('What arrived?'));
      await pumpUntilFound(tester, find.text('What arrived?'));
      expect(find.text('What arrived?'), findsOneWidget);
      // EUR uses a decimal comma (currency_minor_units.dart), as in the
      // acceptance suite's currency_transfers group.
      await tester.enterText(find.byType(TextField).first, '92,00');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Settle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await repository.watchPendingTransfers().first, isEmpty);
      final euroAccounts = await accountRepository
          .watchFinancialAccounts()
          .first;
      final euroId = euroAccounts
          .firstWhere((a) => a.name == 'Euro Savings')
          .id;
      expect(await repository.displayBalanceMinor(euroId), equals(9200));
      // 100000 income - 10000 transferred out (debited immediately by the
      // provisional entry, well before settlement touches the destination).
      expect(await repository.displayBalanceMinor(checkingId), equals(90000));
    },
  );

  testWidgets('bounced transfer settled back to source with a retained fee', (
    tester,
  ) async {
    final incomeId = (await categoryRepository.watchCategories().first)
        .firstWhere((a) => a.type == AccountType.income)
        .id;
    final checkingId =
        (await accountRepository.watchFinancialAccounts().first).first.id;
    await repository.recordTransaction(
      amountMinor: 100000,
      direction: TransactionDirection.moneyIn,
      categoryId: incomeId,
      financialAccountId: checkingId,
      transactionDate: DateTime(2026, 1, 15),
    );
    await accountRepository.changeAccountGroupCurrency(
      groupId: groupPensionRetirementId,
      currency: 'EUR',
    );
    await accountRepository.createFinancialAccount(
      name: 'Euro Savings',
      type: AccountType.asset,
      groupId: groupPensionRetirementId,
    );
    await repository.recordTransfer(
      fromAccountId: checkingId,
      toAccountId: (await accountRepository.watchFinancialAccounts().first)
          .firstWhere((a) => a.name == 'Euro Savings')
          .id,
      amountMinor: 10000,
      transactionDate: DateTime(2026, 1, 15),
    );

    await pumpApp(tester, buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await pumpUntilFound(tester, find.text('MONEY IN TRANSIT'));
    expect(find.text('MONEY IN TRANSIT'), findsOneWidget);
    await tester.ensureVisible(find.textContaining('You sent').first);
    await tester.pump();
    await tester.tap(find.textContaining('You sent').first);
    await pumpUntilFound(tester, find.textContaining('Returned to'));

    await tester.tap(find.textContaining('Returned to'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '90.00');
    await tester.pump();

    // Returned short: the difference is booked to a fee/loss category.
    expect(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Fee / loss category',
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Fee / loss category',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Other Expense').last);
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Settle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(await repository.watchPendingTransfers().first, isEmpty);
    // 100000 income - 10000 debited by the provisional transfer + 9000
    // returned by settlement = 99000 net (the other 1000 became the fee
    // below, never returning to checking).
    expect(await repository.displayBalanceMinor(checkingId), equals(99000));
    final summary = await repository
        .watchSummary(start: DateTime(2020, 1, 1), end: DateTime(2030, 12, 31))
        .first;
    expect(summary.totalExpenseMinor, equals(1000));
  });

  testWidgets(
    'keychain loss continues books under a new this-device identity',
    (tester) async {
      final categories = await categoryRepository.watchCategories().first;
      final incomeId = categories
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      final accounts = await accountRepository.watchFinancialAccounts().first;
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accounts.first.id,
        transactionDate: DateTime(2026, 1, 15),
      );
      final oldIdentity = (await identityRepository.currentIdentity())!;

      // Simulate keychain loss: same database, empty secure storage.
      final postLossKeys = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final postLossRepository = LedgerRepository(
        database: db,
        signingKeyService: postLossKeys,
      );
      await pumpApp(tester, buildAppFor(postLossRepository, db, postLossKeys));
      await pumpUntilFound(
        tester,
        find.text('Continue my books on this phone'),
      );
      expect(find.text('Continue my books on this phone'), findsWidgets);
      expect(find.text('Restore from a copy'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Continue my books on this phone'),
      );
      await pumpUntilFound(
        tester,
        find.text('WHAT YOU HAVE MINUS WHAT YOU OWE'),
      );
      expect(find.text('WHAT YOU HAVE MINUS WHAT YOU OWE'), findsOneWidget);

      final postLossIdentity = IdentityRepository(
        database: db,
        accountRepository: AccountRepository(
          database: db,
          ledgerRepository: postLossRepository,
        ),
        signingKeyService: postLossKeys,
      );
      final newIdentity = (await postLossIdentity.currentIdentity())!;
      expect(newIdentity.identityId, isNot(equals(oldIdentity.identityId)));
      expect(newIdentity.continuesIdentityId, equals(oldIdentity.identityId));

      final entries = await postLossRepository.watchEntries().first;
      expect(entries.length, greaterThanOrEqualTo(2));
      expect(
        entries.any((e) => e.signedByIdentityId == oldIdentity.identityId),
        isTrue,
        reason: 'earlier identity entries remain and still verify',
      );

      final events = await postLossRepository.watchIntegrityEvents().first;
      expect(
        events.any((e) => e.eventType == IntegrityEventType.identityContinued),
        isTrue,
      );
    },
  );

  testWidgets('a saved copy restores on a fresh device and continues there', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('smara-app-test-');
    addTearDown(() => dir.delete(recursive: true));
    const passphrase = 'correct horse battery';

    // Old phone: file-backed books with one entry, saved as a copy.
    final oldFile = File('${dir.path}/old.sqlite');
    final oldDb = AppDatabase.openFile(oldFile);
    final oldKeys = SigningKeyService(
      secureStorage: InMemorySecureKeyStorage(),
    );
    final oldLedger = LedgerRepository(
      database: oldDb,
      signingKeyService: oldKeys,
    );
    final oldAccounts = AccountRepository(
      database: oldDb,
      ledgerRepository: oldLedger,
    );
    final oldIdentityRepository = IdentityRepository(
      database: oldDb,
      accountRepository: oldAccounts,
      signingKeyService: oldKeys,
    );
    final generated = await oldIdentityRepository.generateFirstIdentity();
    await oldIdentityRepository.confirmFirstIdentity(
      generated,
      currency: 'USD',
    );
    final income = (await CategoryRepository(
      database: oldDb,
    ).watchCategories().first).firstWhere((a) => a.type == AccountType.income);
    await oldLedger.recordTransaction(
      amountMinor: 2500,
      direction: TransactionDirection.moneyIn,
      categoryId: income.id,
      financialAccountId:
          (await oldAccounts.watchFinancialAccounts().first).first.id,
      transactionDate: DateTime(2026, 1, 15),
    );
    final oldIdentity = (await oldIdentityRepository.currentIdentity())!;
    final copy = await BooksCopyRepository(
      database: oldDb,
      identityRepository: oldIdentityRepository,
      signingKeyService: oldKeys,
      settingsRepository: SettingsRepository(),
    ).saveBooksCopy(passphrase: passphrase, databaseFile: oldFile);
    await oldDb.close();

    // New phone: empty books, empty keychain, restore the copy.
    final newFile = File('${dir.path}/new.sqlite');
    final emptyDb = AppDatabase.openFile(newFile);
    final newKeys = SigningKeyService(
      secureStorage: InMemorySecureKeyStorage(),
    );
    await BooksCopyRepository(
      database: emptyDb,
      identityRepository: IdentityRepository(
        database: emptyDb,
        accountRepository: AccountRepository(
          database: emptyDb,
          ledgerRepository: LedgerRepository(
            database: emptyDb,
            signingKeyService: newKeys,
          ),
        ),
        signingKeyService: newKeys,
      ),
      signingKeyService: newKeys,
      settingsRepository: SettingsRepository(),
    ).restoreBooksCopy(
      fileContents: copy,
      passphrase: passphrase,
      targetFile: newFile,
    );

    // Reopen: the books are there without their key, so Continuation.
    final restoredDb = AppDatabase.openFile(newFile);
    addTearDown(restoredDb.close);
    final restoredLedger = LedgerRepository(
      database: restoredDb,
      signingKeyService: newKeys,
    );
    await pumpApp(tester, buildAppFor(restoredLedger, restoredDb, newKeys));
    await pumpUntilFound(tester, find.text('Continue my books on this phone'));
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Continue my books on this phone'),
    );
    await pumpUntilFound(tester, find.text('WHAT YOU HAVE MINUS WHAT YOU OWE'));

    final newIdentity = (await IdentityRepository(
      database: restoredDb,
      accountRepository: AccountRepository(
        database: restoredDb,
        ledgerRepository: restoredLedger,
      ),
      signingKeyService: newKeys,
    ).currentIdentity())!;
    expect(newIdentity.continuesIdentityId, oldIdentity.identityId);
    final entries = await restoredLedger.watchEntries().first;
    expect(
      entries.any((e) => e.signedByIdentityId == oldIdentity.identityId),
      isTrue,
      reason: 'the copied entry is back',
    );
    final verification = await LedgerChainVerifier(
      database: restoredDb,
      signingKeyService: newKeys,
    ).verifyChain();
    expect(verification.isFullyVerified, isTrue);
  });

  testWidgets(
    'first launch offers New setup and Restore from a copy, with no phrase step',
    (tester) async {
      final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(freshDb.close);
      final freshKeys = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final freshLedger = LedgerRepository(
        database: freshDb,
        signingKeyService: freshKeys,
      );
      await SettingsRepository().setFirstWeekSetupCompleted(true);
      await pumpApp(tester, buildAppFor(freshLedger, freshDb, freshKeys));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('New setup'), findsOneWidget);
      expect(find.text('Restore from a copy'), findsOneWidget);
      expect(find.textContaining('recovery phrase'), findsNothing);
      expect(find.textContaining('keystore'), findsNothing);
    },
  );
}

Widget buildAppFor(
  LedgerRepository repository,
  AppDatabase database,
  SigningKeyService signingKeyService,
) {
  final accountRepository = AccountRepository(
    database: database,
    ledgerRepository: repository,
  );
  final categoryRepository = CategoryRepository(database: database);
  final payeeRepository = PayeeRepository(database: database);
  final identityRepository = IdentityRepository(
    database: database,
    accountRepository: accountRepository,
    signingKeyService: signingKeyService,
  );
  final chainVerifier = LedgerChainVerifier(
    database: database,
    signingKeyService: signingKeyService,
  );
  final investmentRepository = InvestmentRepository(
    database: database,
    ledgerRepository: repository,
  );
  final recurringTemplateRepository = RecurringTemplateRepository(
    database: database,
    ledgerRepository: repository,
  );
  final settingsRepository = SettingsRepository();
  final booksCopyRepository = BooksCopyRepository(
    database: database,
    identityRepository: identityRepository,
    signingKeyService: signingKeyService,
    settingsRepository: settingsRepository,
  );
  final statementImportRepository = StatementImportRepository(
    database: database,
    ledgerRepository: repository,
    accountRepository: accountRepository,
    categoryRepository: categoryRepository,
  );
  return MultiProvider(
    providers: [
      Provider<LedgerRepository>.value(value: repository),
      Provider<AccountRepository>.value(value: accountRepository),
      Provider<CategoryRepository>.value(value: categoryRepository),
      Provider<PayeeRepository>.value(value: payeeRepository),
      Provider<IdentityRepository>.value(value: identityRepository),
      Provider<LedgerChainVerifier>.value(value: chainVerifier),
      Provider<InvestmentRepository>.value(value: investmentRepository),
      Provider<RecurringTemplateRepository>.value(
        value: recurringTemplateRepository,
      ),
      Provider<BooksCopyRepository>.value(value: booksCopyRepository),
      ChangeNotifierProvider(
        create: (_) => RegisterViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => SummaryViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            CategoryManagementViewModel(categoryRepository: categoryRepository),
      ),
      ChangeNotifierProvider(
        create: (_) => ContinuationViewModel(
          identityRepository: identityRepository,
          chainVerifier: chainVerifier,
          booksCopyRepository: booksCopyRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            BundleImportViewModel(booksCopyRepository: booksCopyRepository),
      ),
      ChangeNotifierProvider(
        create: (_) => HomeViewModel(
          ledgerRepository: repository,
          categoryRepository: categoryRepository,
          recurringTemplateRepository: recurringTemplateRepository,
          investmentRepository: investmentRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            AccountManagementViewModel(accountRepository: accountRepository),
      ),
    ],
    child: Builder(
      builder: (context) {
        return MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: buildAppRouter(
            repository,
            accountRepository,
            categoryRepository,
            payeeRepository,
            identityRepository,
            chainVerifier,
            investmentRepository,
            booksCopyRepository,
            statementImportRepository,
            settingsRepository,
            AppLockController(settingsRepository: settingsRepository),
          ),
        );
      },
    ),
  );
}
