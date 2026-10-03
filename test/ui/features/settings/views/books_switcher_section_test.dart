import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/books_set/active_books_session.dart';
import 'package:smara_accounting/data/books_set/books_set_paths.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/books_set_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/investment_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/recurring_template_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/home/view_models/home_view_model.dart';
import 'package:smara_accounting/ui/features/settings/view_models/books_switcher_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/books_switcher_section.dart';

import '../../../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late Directory tempDir;
  late BooksSetStore store;
  late InMemorySecureKeyStorage secureStorage;
  late ActiveBooksSession session;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('smara-books-switcher-');
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    store = BooksSetStore();
    secureStorage = InMemorySecureKeyStorage();
    final booksSets = BooksSetRepository(
      supportDirectory: tempDir,
      store: store,
      secureStorage: secureStorage,
    );
    session = ActiveBooksSession(
      booksSets: booksSets,
      store: store,
      signingKeyService: SigningKeyService(
        secureStorage: secureStorage,
        resolveBooksSetId: store.activeBooksSetId,
      ),
    );
  });

  tearDown(() async {
    session.dispose();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<void> seedSet({
    required AppDatabase db,
    required SigningKeyService keys,
    required String description,
  }) async {
    final ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    final categories = CategoryRepository(database: db);
    final identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
    final financial = (await accounts.watchFinancialAccounts().first).first;
    final expense = (await categories.watchCategories().first).firstWhere(
      (a) => a.type == AccountType.expense,
    );
    await ledger.recordTransaction(
      transactionDate: DateTime.utc(2026, 1, 1),
      amountMinor: 500,
      direction: TransactionDirection.moneyOut,
      financialAccountId: financial.id,
      categoryId: expense.id,
      description: description,
    );
  }

  test(
    'BooksSwitcherViewModel lists sets by name and switches active set',
    () async {
      await session.createSet(displayName: 'My household');
      await session.createSet(displayName: 'Travel');

      final switcher = BooksSwitcherViewModel(session: session);
      addTearDown(switcher.dispose);
      await switcher.refresh();

      expect(
        switcher.sets.map((s) => s.displayName),
        containsAll(['My household', 'Travel']),
      );
      expect(
        switcher.sets.where((s) => s.isActive).single.displayName,
        'Travel',
      );

      final household = switcher.sets.firstWhere(
        (s) => s.displayName == 'My household',
      );
      final ok = await switcher.switchTo(household.id);
      expect(ok, isTrue);
      expect(
        switcher.sets.where((s) => s.isActive).single.displayName,
        'My household',
      );
    },
  );

  test(
    'switching books bumps generation and HomeViewModel reads the new set',
    () async {
      final a = await session.createSet(displayName: 'Set A', id: 'set-a');
      await seedSet(
        db: session.database,
        keys: session.booksSets.signingKeyServiceFor(a.id),
        description: 'only-in-a',
      );

      final b = await session.createSet(displayName: 'Set B', id: 'set-b');
      await seedSet(
        db: session.database,
        keys: session.booksSets.signingKeyServiceFor(b.id),
        description: 'only-in-b',
      );

      await session.switchTo('set-a');
      final generationA = session.generation;

      HomeViewModel buildHome() {
        final db = session.database;
        final ledger = LedgerRepository(
          database: db,
          signingKeyService: session.signingKeyService,
        );
        return HomeViewModel(
          ledgerRepository: ledger,
          categoryRepository: CategoryRepository(database: db),
          recurringTemplateRepository: RecurringTemplateRepository(
            database: db,
            ledgerRepository: ledger,
          ),
          investmentRepository: InvestmentRepository(
            database: db,
            ledgerRepository: ledger,
          ),
          refreshInstrumentQuotes: false,
          booksGeneration: session.generation,
        );
      }

      final homeA = buildHome();
      expect(homeA.booksGeneration, generationA);

      await session.switchTo('set-b');
      final homeB = buildHome();
      addTearDown(homeB.dispose);

      final entries = await session.database
          .select(session.database.journalEntries)
          .get();
      expect(entries, hasLength(1));
      expect(entries.single.description, 'only-in-b');
      expect(homeB.booksGeneration, session.generation);
      expect(homeB.booksGeneration, isNot(generationA));
      homeA.dispose();
    },
  );

  testWidgets('BooksSwitcherSection renders set names from the view model', (
    tester,
  ) async {
    // Prepare data + load the VM in real async (setUp already opened session).
    late BooksSwitcherViewModel switcher;
    await tester.runAsync(() async {
      await session.createSet(displayName: 'My household');
      await session.createSet(displayName: 'Travel');
      switcher = BooksSwitcherViewModel(session: session);
      await switcher.refresh();
    });
    addTearDown(switcher.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
        supportedLocales: supportedAppLocales,
        home: Scaffold(body: BooksSwitcherSection(viewModel: switcher)),
      ),
    );
    await tester.pump();

    expect(find.text('My household'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Books on this device'), findsOneWidget);
  });

  testWidgets('unnamed books set shows localized fallback, never the raw id', (
    tester,
  ) async {
    late BooksSwitcherViewModel switcher;
    late String unnamedId;
    late String namedId;
    await tester.runAsync(() async {
      // First-open path seeds metadata with no user name (was UUID before).
      await session.ensureOpen();
      unnamedId = (await session.activeBooksSetId())!;
      final named = await session.createSet(displayName: 'Travel');
      namedId = named.id;
      // Switch back so both appear; leave the first unnamed.
      await session.switchTo(unnamedId);
      switcher = BooksSwitcherViewModel(session: session);
      await switcher.refresh();
    });
    addTearDown(switcher.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
        supportedLocales: supportedAppLocales,
        home: Scaffold(body: BooksSwitcherSection(viewModel: switcher)),
      ),
    );
    await tester.pump();

    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Books 1'), findsOneWidget);
    expect(find.text(unnamedId), findsNothing);
    expect(find.text(namedId), findsNothing);
    // UUID-shaped strings must not appear as titles.
    expect(switcher.sets.any((s) => s.displayName == s.id), isFalse);
  });

  testWidgets('company books rename shows company name, not Books N', (
    tester,
  ) async {
    late BooksSwitcherViewModel switcher;
    await tester.runAsync(() async {
      await session.ensureOpen();
      final id = (await session.activeBooksSetId())!;
      await session.renameSet(id, 'Acme Travel Co');
      switcher = BooksSwitcherViewModel(session: session);
      await switcher.refresh();
    });
    addTearDown(switcher.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
        supportedLocales: supportedAppLocales,
        home: Scaffold(body: BooksSwitcherSection(viewModel: switcher)),
      ),
    );
    await tester.pump();

    expect(find.text('Acme Travel Co'), findsOneWidget);
    expect(find.text('Books 1'), findsNothing);
  });
}
