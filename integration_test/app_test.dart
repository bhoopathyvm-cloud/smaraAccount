import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/integrity_event.dart';
import 'package:smara_accounting/ui/app_router.dart';
import 'package:smara_accounting/ui/core/app_theme.dart';
import 'package:smara_accounting/ui/features/account_management/view_models/account_management_view_model.dart';
import 'package:smara_accounting/ui/features/category_management/view_models/category_management_view_model.dart';
import 'package:smara_accounting/ui/features/home/view_models/home_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/views/recovery_phrase_confirm_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/recovery_phrase_view.dart';
import 'package:smara_accounting/ui/features/register/view_models/register_view_model.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/restore/view_models/restore_identity_view_model.dart';
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
  late LedgerRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LedgerRepository(
      database: db,
      signingKeyService: SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      ),
    );
    // app_router.dart's redirect requires a confirmed signing identity
    // before /register (or any other main route) is reachable - these
    // tests exercise the ledger, not onboarding, so start past it.
    final generated = await repository.generateFirstIdentity();
    await repository.confirmFirstIdentity(generated, currency: 'USD');
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp() => buildAppFor(repository);

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

    await tester.tap(find.byIcon(TablerIcons.plus));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField).first, '25');
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
      final categories = await repository.watchCategories().first;
      final incomeId = categories
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      final accounts = await repository.watchFinancialAccounts().first;
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accounts.first.id,
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
      final accounts = await repository.watchFinancialAccounts().first;
      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: salary.id,
        financialAccountId: accounts.first.id,
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
      expect(find.text('Archive'), findsWidgets);

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
      final categories = await repository.watchCategories().first;
      final incomeId = categories
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      final accounts = await repository.watchFinancialAccounts().first;
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accounts.first.id,
        transactionDate: DateTime(2026, 1, 15),
      );
      final tampered = (await repository.watchEntries().first).single;

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
      final incomeId = (await repository.watchCategories().first)
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      final checkingId =
          (await repository.watchFinancialAccounts().first).first.id;
      await repository.recordTransaction(
        amountMinor: 100000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: checkingId,
        transactionDate: DateTime(2026, 1, 15),
      );
      await repository.changeAccountGroupCurrency(
        groupId: groupPensionRetirementId,
        currency: 'EUR',
      );
      await repository.createFinancialAccount(
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
      await tester.tap(find.widgetWithText(ElevatedButton, 'Transfer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Back on Home (Transfer pops to its caller); the pending item shows.
      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('PENDING TRANSFERS'), findsOneWidget);
      final pendingBefore =
          (await repository.watchPendingTransfers().first).single;
      expect(pendingBefore.currency, equals('USD'));

      await tester.tap(find.textContaining('→').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Settle transfer'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '92.00');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Settle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await repository.watchPendingTransfers().first, isEmpty);
      final euroAccounts = await repository.watchFinancialAccounts().first;
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
    final incomeId = (await repository.watchCategories().first)
        .firstWhere((a) => a.type == AccountType.income)
        .id;
    final checkingId =
        (await repository.watchFinancialAccounts().first).first.id;
    await repository.recordTransaction(
      amountMinor: 100000,
      direction: TransactionDirection.moneyIn,
      categoryId: incomeId,
      financialAccountId: checkingId,
      transactionDate: DateTime(2026, 1, 15),
    );
    await repository.changeAccountGroupCurrency(
      groupId: groupPensionRetirementId,
      currency: 'EUR',
    );
    await repository.createFinancialAccount(
      name: 'Euro Savings',
      type: AccountType.asset,
      groupId: groupPensionRetirementId,
    );
    await repository.recordTransfer(
      fromAccountId: checkingId,
      toAccountId: (await repository.watchFinancialAccounts().first)
          .firstWhere((a) => a.name == 'Euro Savings')
          .id,
      amountMinor: 10000,
      transactionDate: DateTime(2026, 1, 15),
    );

    await pumpApp(tester, buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PENDING TRANSFERS'), findsOneWidget);
    await tester.tap(find.textContaining('→').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.textContaining('Returned to'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '90.00');
    await tester.pump();

    expect(find.textContaining('Shortfall'), findsOneWidget);
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
    'reinstall with the recovery phrase restores the identity without re-signing',
    (tester) async {
      final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(freshDb.close);
      final firstInstallRepository = LedgerRepository(
        database: freshDb,
        signingKeyService: SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        ),
      );

      // First launch: walk the real onboarding UI. The continue button
      // only renders once the ViewModel's async key generation has
      // actually finished, unlike the bare presence of RecoveryPhraseView.
      await pumpApp(tester, buildAppFor(firstInstallRepository));
      final continueButton = find.text('I\'ve saved my recovery phrase');
      await pumpUntilFound(tester, continueButton);
      expect(continueButton, findsOneWidget);

      final phraseView = tester.widget<RecoveryPhraseView>(
        find.byType(RecoveryPhraseView),
      );
      final words = phraseView.viewModel.words;
      expect(words, hasLength(24));

      await tester.ensureVisible(continueButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(continueButton);
      await pumpUntilFound(tester, find.text('Skip'));
      expect(find.text('Skip'), findsOneWidget);

      final skipButton = find.text('Skip');
      await tester.ensureVisible(skipButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(skipButton);
      await pumpUntilFound(tester, find.text('Confirm'));
      expect(find.text('Confirm'), findsOneWidget);

      // Scoped to RecoveryPhraseConfirmView specifically, not just
      // find.byType(TextField): the previous page's fields can still be
      // present mid-transition when this is reached via pumpUntilFound's
      // early exit as soon as "Confirm" first appears.
      final wordFields = find.descendant(
        of: find.byType(RecoveryPhraseConfirmView),
        matching: find.byType(TextField),
      );
      for (
        var i = 0;
        i < RecoveryPhraseSetupViewModel.confirmationWordIndices.length;
        i++
      ) {
        await tester.enterText(
          wordFields.at(i),
          words[RecoveryPhraseSetupViewModel.confirmationWordIndices[i]],
        );
      }
      final confirmButton = find.text('Confirm');
      await tester.ensureVisible(confirmButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(confirmButton);
      // Confirming the recovery phrase only validates it now - it no
      // longer commits the identity directly. That happens one step
      // later, once a currency is chosen (multi-currency-support
      // design.md addendum), so the next screen is the currency picker.
      await pumpUntilFound(tester, find.text('Choose your currency'));
      expect(
        find.textContaining('doesn\'t match'),
        findsNothing,
        reason: 'confirmation words were rejected',
      );

      final finishSetupButton = find.text('Finish setup');
      await tester.ensureVisible(finishSetupButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(finishSetupButton);
      // Finishing triggers confirmFirstIdentity + verifyChain, then the
      // redirect's own currentIdentity/hasMatchingStoredKey/verifyChain
      // chain before /home finally builds - wait for a widget that only
      // exists there.
      await pumpUntilFound(tester, find.text('NET POSITION'));
      expect(find.text('NET POSITION'), findsOneWidget);

      final categories = await firstInstallRepository.watchCategories().first;
      final incomeId = categories
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      final accounts = await firstInstallRepository
          .watchFinancialAccounts()
          .first;
      await firstInstallRepository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accounts.first.id,
        transactionDate: DateTime(2026, 1, 15),
      );
      final originalEntry =
          (await firstInstallRepository.watchEntries().first).single;

      // Reinstall: same database file, fresh secure storage (the private
      // key is gone from this "device").
      final reinstalledRepository = LedgerRepository(
        database: freshDb,
        signingKeyService: SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        ),
      );
      await pumpApp(tester, buildAppFor(reinstalledRepository));
      await pumpUntilFound(tester, find.text('Restore signing key'));
      expect(find.text('Restore signing key'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, words.join(' '));
      await tester.tap(find.text('Restore'));
      await pumpUntilFound(tester, find.text('NET POSITION'));
      expect(find.text('NET POSITION'), findsOneWidget);

      final entries = await reinstalledRepository.watchEntries().first;
      expect(entries, hasLength(1));
      expect(entries.single.entryHash, equals(originalEntry.entryHash));
      expect(entries.single.signature, equals(originalEntry.signature));
      expect(entries.single.isVerified, isTrue);
    },
  );

  testWidgets(
    'true key loss: migrating re-signs history under a new identity end to end',
    (tester) async {
      final categories = await repository.watchCategories().first;
      final incomeId = categories
          .firstWhere((a) => a.type == AccountType.income)
          .id;
      final accounts = await repository.watchFinancialAccounts().first;
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accounts.first.id,
        transactionDate: DateTime(2026, 1, 15),
      );
      final legacy = (await repository.watchEntries().first).single;
      final oldIdentity = (await repository.currentIdentity())!;

      // Simulate true key loss: same database, brand new secure storage,
      // and no recovery phrase or keystore file to restore from.
      final postLossRepository = LedgerRepository(
        database: db,
        signingKeyService: SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        ),
      );
      await pumpApp(tester, buildAppFor(postLossRepository));
      await pumpUntilFound(tester, find.text('Restore signing key'));
      expect(find.text('Restore signing key'), findsOneWidget);

      await tester.tap(
        find.text('I don\'t have my recovery phrase or keystore file'),
      );
      await pumpUntilFound(tester, find.text('Migrate to a new key'));
      expect(find.text('Migrate to a new key'), findsWidgets);

      final checkbox = find.byType(CheckboxListTile);
      await tester.ensureVisible(checkbox);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(checkbox);
      await tester.pump();

      final migrateButton = find.widgetWithText(
        ElevatedButton,
        'Migrate to a new key',
      );
      await tester.ensureVisible(migrateButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(migrateButton);
      // Migration re-signs every entry (async crypto per entry) before the
      // redirect chain runs again for /home.
      await pumpUntilFound(tester, find.text('NET POSITION'));
      expect(find.text('NET POSITION'), findsOneWidget);

      final newIdentity = (await postLossRepository.currentIdentity())!;
      expect(newIdentity.identityId, isNot(equals(oldIdentity.identityId)));
      expect(newIdentity.supersedesIdentityId, equals(oldIdentity.identityId));

      final entries = await postLossRepository.watchEntries().first;
      expect(entries, hasLength(2));
      final migrated = entries.firstWhere(
        (e) => e.migratedFromEntryId == legacy.id,
      );
      expect(
        migrated.postings.map((p) => p.amountMinor).toSet(),
        equals(legacy.postings.map((p) => p.amountMinor).toSet()),
      );

      final summary = await postLossRepository
          .watchSummary(
            start: DateTime(2020, 1, 1),
            end: DateTime(2030, 12, 31),
          )
          .first;
      // The legacy entry is excluded from active totals - only the
      // migrated replacement counts.
      expect(summary.totalIncomeMinor, equals(1000));

      final events = await postLossRepository.watchIntegrityEvents().first;
      expect(
        events.any(
          (e) => e.eventType == IntegrityEventType.keyMigrationConfirmed,
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'navigating from Home to a different account while Register is already showing one does not throw',
    (tester) async {
      // Regression for a setState()-during-build hazard: app_router.dart's
      // Register route builder used to call RegisterViewModel.selectAccount
      // (which calls notifyListeners()) synchronously inside go_router's
      // own builder - fine on first navigation, but if Register's
      // ListenableBuilder is already mounted (as it is here, thanks to
      // StatefulShellRoute keeping every branch alive) and the user taps a
      // different account, that becomes a rebuild-during-build.
      await repository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      );

      await pumpApp(tester, buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Cash & Bank'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(
        find.widgetWithText(DropdownButtonFormField<String>, 'Cash & Bank'),
        findsOneWidget,
      );

      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Savings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(
        find.widgetWithText(DropdownButtonFormField<String>, 'Savings'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'user-created group archive lifecycle: blocked while active, allowed once empty, historical account still resolves it',
    (tester) async {
      // Setup goes through the Repository directly (not the "Create group"
      // dialog) - several other tests in this file do the same for
      // account/group setup (e.g. "Euro Savings" above); this test's focus
      // is the archive lifecycle and its effect on pickers, not the create
      // dialog itself.
      final group = await repository.createAccountGroup(
        name: 'Business',
        kind: AccountGroupKind.assetGroup,
        currency: 'USD',
      );
      await repository.createFinancialAccount(
        name: 'Business Checking',
        type: AccountType.asset,
        groupId: group.id,
      );

      await pumpApp(tester, buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Accounts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Business Checking'), findsOneWidget);

      // PopupMenuButton's default icon is platform-adaptive (more_horiz on
      // macOS, more_vert elsewhere), so byIcon is unreliable here; its
      // default tooltip ("Show menu", from MaterialLocalizations) is
      // stable across platforms. Render order at this point: [0] Cash &
      // Bank's own account popup, [1] the Business group's own popup, [2]
      // Business Checking's account popup (groups render before their
      // member accounts).
      final popups = find.byTooltip('Show menu');

      // Archiving the group while it still has an active account is
      // rejected.
      await tester.tap(popups.at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Archive'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Archive'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.text('Cannot archive a group with active financial accounts.'),
        findsOneWidget,
      );

      // Archive the account (via Repository - the account's own archive
      // flow is already covered elsewhere), then the group archives
      // successfully through the UI.
      final businessAccounts = await repository
          .watchFinancialAccounts(includeArchived: true)
          .first;
      final businessAccountId = businessAccounts
          .firstWhere((a) => a.name == 'Business Checking')
          .id;
      await repository.archiveFinancialAccount(businessAccountId);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Business Checking is now archived (no popup of its own), so only
      // two popups remain: Cash & Bank's, then the Business group's.
      await tester.tap(popups.last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Archive'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Archive'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // The group and its historical account both stay visible, labeled
      // as archived.
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Business Checking'), findsOneWidget);

      // But the archived group no longer offers itself as a reassignment
      // target: opening Cash & Bank's "Reassign group" picker (its is now
      // the only remaining popup) shows exactly one "Business" text on
      // screen (the archived group's own section header) - if it were
      // still offered, a second one would appear inside the open dropdown
      // menu.
      await tester.tap(popups.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Reassign group'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Business'), findsOneWidget);
    },
  );
}

Widget buildAppFor(LedgerRepository repository) {
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
      ChangeNotifierProvider(
        create: (_) =>
            RecoveryPhraseSetupViewModel(ledgerRepository: repository),
      ),
      ChangeNotifierProvider(
        create: (_) => RestoreIdentityViewModel(ledgerRepository: repository),
      ),
      ChangeNotifierProvider(
        create: (_) => HomeViewModel(ledgerRepository: repository),
      ),
      ChangeNotifierProvider(
        create: (_) => AccountManagementViewModel(ledgerRepository: repository),
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
