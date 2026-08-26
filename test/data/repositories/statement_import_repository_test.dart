import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/database/tables/ofx_import_records_table.dart'
    show ImportSource;
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/statement_import_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/csv/csv_column_mapping.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/statement_import/parsed_statement_transaction.dart';
import 'package:smara_accounting/domain/statement_import/statement_import_batch.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository ledgerRepository;
  late AccountRepository accountRepository;
  late IdentityRepository identityRepository;
  late CategoryRepository categoryRepository;
  late StatementImportRepository importRepository;
  late String accountId;
  late String otherAccountId;
  late String journalEntryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    ledgerRepository = LedgerRepository(database: db, signingKeyService: keys);
    accountRepository = AccountRepository(
      database: db,
      ledgerRepository: ledgerRepository,
    );
    identityRepository = IdentityRepository(
      database: db,
      accountRepository: accountRepository,
      signingKeyService: keys,
    );
    categoryRepository = CategoryRepository(database: db);
    importRepository = StatementImportRepository(
      database: db,
      ledgerRepository: ledgerRepository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
    );

    final generated = await identityRepository.generateFirstIdentity();
    await identityRepository.confirmFirstIdentity(generated, currency: 'USD');
    accountId =
        (await accountRepository.watchFinancialAccounts().first).first.id;

    final assetGroup = (await accountRepository.watchAccountGroups().first)
        .firstWhere((g) => g.kind == AccountGroupKind.assetGroup);
    final otherAccount = await accountRepository.createFinancialAccount(
      name: 'Savings',
      type: AccountType.asset,
      groupId: assetGroup.id,
    );
    otherAccountId = otherAccount.id;

    final category = (await categoryRepository.watchCategories().first).first;
    await ledgerRepository.recordTransaction(
      amountMinor: 100,
      direction: TransactionDirection.moneyOut,
      categoryId: category.id,
      financialAccountId: accountId,
      transactionDate: DateTime(2026, 1, 1),
    );
    journalEntryId =
        (await ledgerRepository.watchEntriesForAccount(accountId).first)
            .first
            .id;
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> recordImport({
    required String financialAccountId,
    String? fitid,
    String? fallbackMatchKey,
  }) {
    return db
        .into(db.ofxImportRecords)
        .insert(
          OfxImportRecordsCompanion.insert(
            financialAccountId: financialAccountId,
            fitid: Value(fitid),
            fallbackMatchKey: Value(fallbackMatchKey),
            journalEntryId: journalEntryId,
            importedAt: DateTime.now(),
          ),
        );
  }

  ParsedStatementTransaction transaction({
    String? fitid,
    String description = 'Row',
  }) {
    return ParsedStatementTransaction(
      transactionDate: DateTime(2026, 1, 5),
      amountMinor: 500,
      direction: TransactionDirection.moneyOut,
      description: description,
      currency: 'USD',
      externalReferenceId: fitid,
    );
  }

  group('findDuplicateIndexes', () {
    test(
      'flags a row whose fitid was already imported for this account',
      () async {
        await recordImport(financialAccountId: accountId, fitid: 'DUP-1');

        final rows = [transaction(fitid: 'DUP-1'), transaction(fitid: 'NEW-1')];
        final duplicates = await importRepository.findDuplicateIndexes(
          financialAccountId: accountId,
          transactions: rows,
        );

        expect(duplicates, {0});
      },
    );

    test(
      'flags a row with no fitid whose fallback match key was already imported',
      () async {
        final row = transaction();
        await recordImport(
          financialAccountId: accountId,
          fallbackMatchKey: row.fallbackMatchKey,
        );

        final duplicates = await importRepository.findDuplicateIndexes(
          financialAccountId: accountId,
          transactions: [row],
        );

        expect(duplicates, {0});
      },
    );

    test('does not flag an unrelated transaction', () async {
      await recordImport(financialAccountId: accountId, fitid: 'DUP-1');

      final duplicates = await importRepository.findDuplicateIndexes(
        financialAccountId: accountId,
        transactions: [transaction(fitid: 'UNRELATED')],
      );

      expect(duplicates, isEmpty);
    });

    test(
      'a matching fitid recorded against a different account is not flagged',
      () async {
        await recordImport(financialAccountId: otherAccountId, fitid: 'DUP-1');

        final duplicates = await importRepository.findDuplicateIndexes(
          financialAccountId: accountId,
          transactions: [transaction(fitid: 'DUP-1')],
        );

        expect(duplicates, isEmpty);
      },
    );
  });

  group('parseOfxFile', () {
    test('parses a minimal OFX 2.x byte payload', () {
      const fixture = '''
<?xml version="1.0" encoding="UTF-8"?>
<OFX>
  <BANKMSGSRSV1>
    <STMTTRNRS>
      <STMTRS>
        <CURDEF>USD</CURDEF>
        <BANKTRANLIST>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260105</DTPOSTED>
            <TRNAMT>-12.34</TRNAMT>
            <FITID>ABC123</FITID>
            <NAME>Test Row</NAME>
          </STMTTRN>
        </BANKTRANLIST>
      </STMTRS>
    </STMTTRNRS>
  </BANKMSGSRSV1>
</OFX>
''';
      final result = importRepository.parseOfxFile(utf8.encode(fixture));
      expect(result.transactions, hasLength(1));
      expect(result.statementCurrency, 'USD');
    });

    test('throws OfxParseException for a non-OFX payload', () {
      expect(
        () => importRepository.parseOfxFile(utf8.encode('not an ofx file')),
        throwsA(isA<OfxParseException>()),
      );
    });
  });

  group('groupCurrencyFor', () {
    test('returns the account group currency', () async {
      final currency = await importRepository.groupCurrencyFor(accountId);
      expect(currency, 'USD');
    });
  });

  group('suggestCategoryFor', () {
    test(
      'returns the category most recently used for an exact-memo match',
      () async {
        final category =
            (await categoryRepository.watchCategories().first).first;
        await ledgerRepository.recordTransaction(
          amountMinor: 250,
          direction: TransactionDirection.moneyOut,
          categoryId: category.id,
          financialAccountId: accountId,
          transactionDate: DateTime(2026, 1, 10),
          description: 'Coffee Shop',
        );

        final suggestion = await importRepository.suggestCategoryFor(
          financialAccountId: accountId,
          description: 'Coffee Shop',
        );

        expect(suggestion, category.id);
      },
    );

    test('returns null when no prior entry matches the description', () async {
      final suggestion = await importRepository.suggestCategoryFor(
        financialAccountId: accountId,
        description: 'Never Seen Before',
      );

      expect(suggestion, isNull);
    });
  });

  group('buildPreviewRows', () {
    test(
      'returns currency, duplicate flags, and memo suggestions in one call',
      () async {
        final category =
            (await categoryRepository.watchCategories().first).first;
        await ledgerRepository.recordTransaction(
          amountMinor: 250,
          direction: TransactionDirection.moneyOut,
          categoryId: category.id,
          financialAccountId: accountId,
          transactionDate: DateTime(2026, 1, 10),
          description: 'Coffee Shop',
        );

        final coffee = ParsedStatementTransaction(
          transactionDate: DateTime(2026, 2, 2),
          amountMinor: 450,
          direction: TransactionDirection.moneyOut,
          description: 'Coffee Shop',
          currency: 'USD',
          externalReferenceId: 'FIT-NEW',
        );
        final other = ParsedStatementTransaction(
          transactionDate: DateTime(2026, 2, 3),
          amountMinor: 100,
          direction: TransactionDirection.moneyOut,
          description: 'Unknown Payee',
          currency: 'USD',
          externalReferenceId: 'FIT-OTHER',
        );

        final preview = await importRepository.buildPreviewRows(
          financialAccountId: accountId,
          transactions: [coffee, other],
          rules: const [],
        );

        expect(preview.accountCurrency, 'USD');
        expect(preview.rows, hasLength(2));
        expect(preview.rows[0].suggestedCategoryId, category.id);
        expect(preview.rows[1].suggestedCategoryId, isNull);
        expect(preview.rows.every((r) => !r.isDuplicate), isTrue);
      },
    );
  });

  group('postAcceptedRows', () {
    test(
      'posts a valid row and records it for future duplicate detection',
      () async {
        final category =
            (await categoryRepository.watchCategories().first).first;
        final row = transaction(fitid: 'POST-1', description: 'New Row');

        final result = await importRepository.postAcceptedRows(
          financialAccountId: accountId,
          rows: [
            StatementAcceptedRow(transaction: row, categoryId: category.id),
          ],
          source: ImportSource.ofx,
        );

        expect(result.postedCount, 1);
        expect(result.failedCount, 0);

        final duplicates = await importRepository.findDuplicateIndexes(
          financialAccountId: accountId,
          transactions: [row],
        );
        expect(duplicates, {0});
      },
    );

    test(
      'one row failing to post does not block the others, and the failed row is not recorded',
      () async {
        final category =
            (await categoryRepository.watchCategories().first).first;
        final badRow = ParsedStatementTransaction(
          transactionDate: DateTime(2026, 1, 6),
          amountMinor: 0,
          direction: TransactionDirection.moneyOut,
          description: 'Bad Row',
          currency: 'USD',
          externalReferenceId: 'BAD-1',
        );
        final goodRow = transaction(fitid: 'GOOD-1', description: 'Good Row');

        final result = await importRepository.postAcceptedRows(
          financialAccountId: accountId,
          rows: [
            StatementAcceptedRow(transaction: badRow, categoryId: category.id),
            StatementAcceptedRow(transaction: goodRow, categoryId: category.id),
          ],
          source: ImportSource.ofx,
        );

        expect(result.postedCount, 1);
        expect(result.failedCount, 1);
        expect(result.results.first.succeeded, isFalse);
        expect(result.results.last.succeeded, isTrue);

        final duplicates = await importRepository.findDuplicateIndexes(
          financialAccountId: accountId,
          transactions: [badRow, goodRow],
        );
        expect(duplicates, {1});
      },
    );

    test(
      'a same-currency row posts one complete entry with no pending transfer',
      () async {
        final category =
            (await categoryRepository.watchCategories().first).first;
        final row = transaction(
          fitid: 'SAME-CCY',
          description: 'Same currency row',
        );
        expect(
          row.currency,
          'USD',
        ); // matches the seeded account's group currency

        final result = await importRepository.postAcceptedRows(
          financialAccountId: accountId,
          rows: [
            StatementAcceptedRow(transaction: row, categoryId: category.id),
          ],
          source: ImportSource.ofx,
        );

        expect(result.postedCount, 1);
        expect(await ledgerRepository.watchPendingTransfers().first, isEmpty);
      },
    );

    test(
      'a foreign-currency row posts through the existing provisional-entry path',
      () async {
        final category =
            (await categoryRepository.watchCategories().first).first;
        final row = ParsedStatementTransaction(
          transactionDate: DateTime(2026, 1, 7),
          amountMinor: 4321,
          direction: TransactionDirection.moneyOut,
          description: 'Foreign currency row',
          currency: 'EUR', // seeded account's group currency is USD
          externalReferenceId: 'FX-1',
        );

        final result = await importRepository.postAcceptedRows(
          financialAccountId: accountId,
          rows: [
            StatementAcceptedRow(transaction: row, categoryId: category.id),
          ],
          source: ImportSource.ofx,
        );

        expect(result.postedCount, 1);
        final pending = await ledgerRepository.watchPendingTransfers().first;
        expect(pending, hasLength(1));
        expect(pending.single.sourceAccountId, accountId);
        expect(pending.single.currency, 'EUR');

        final duplicates = await importRepository.findDuplicateIndexes(
          financialAccountId: accountId,
          transactions: [row],
        );
        expect(duplicates, {0});
      },
    );
  });

  group('CSV import profiles', () {
    const mapping = CsvColumnMapping(
      hasHeaderRow: true,
      dateColumnIndex: 0,
      datePattern: 'dd/MM/yyyy',
      descriptionColumnIndexes: [1],
      amountConvention: CsvAmountConvention.signedColumn,
      signedAmountColumnIndex: 2,
      currency: 'USD',
    );
    const headerRow = ['Date', 'Description', 'Amount'];

    test(
      'a saved profile is found by an exact (normalized) header match',
      () async {
        await importRepository.saveProfile(
          name: 'My Bank',
          mapping: mapping,
          headerRow: headerRow,
        );

        final found = await importRepository.findProfileForHeaderRow([
          ' date ',
          'DESCRIPTION',
          'amount',
        ]);

        expect(found, isNotNull);
        expect(found!.name, 'My Bank');
        expect(found.mapping.dateColumnIndex, 0);
        expect(found.mapping.datePattern, 'dd/MM/yyyy');
        expect(found.mapping.currency, 'USD');
      },
    );

    test('a file with a differing header row does not match', () async {
      await importRepository.saveProfile(
        name: 'My Bank',
        mapping: mapping,
        headerRow: headerRow,
      );

      final found = await importRepository.findProfileForHeaderRow([
        'Date',
        'Memo',
        'Amount',
        'Balance',
      ]);

      expect(found, isNull);
    });

    test('rename and delete are reflected in watchProfiles()', () async {
      await importRepository.saveProfile(
        name: 'My Bank',
        mapping: mapping,
        headerRow: headerRow,
      );
      final saved = (await importRepository.watchProfiles().first).single;

      await importRepository.renameProfile(
        id: saved.id,
        newName: 'Renamed Bank',
      );
      final renamed = (await importRepository.watchProfiles().first).single;
      expect(renamed.name, 'Renamed Bank');

      await importRepository.deleteProfile(saved.id);
      final afterDelete = await importRepository.watchProfiles().first;
      expect(afterDelete, isEmpty);
    });
  });

  group('category rules', () {
    test('a saved rule appears in watchCategoryRules()', () async {
      final category = (await categoryRepository.watchCategories().first).first;

      await importRepository.saveCategoryRule(
        keyword: 'AMAZON',
        categoryId: category.id,
      );

      final rules = await importRepository.watchCategoryRules().first;
      expect(rules, hasLength(1));
      expect(rules.single.keyword, 'AMAZON');
      expect(rules.single.categoryId, category.id);
    });

    test('update changes the keyword and category', () async {
      final categories = await categoryRepository.watchCategories().first;
      final originalCategory = categories.first;
      final newCategory = categories.last;
      await importRepository.saveCategoryRule(
        keyword: 'AMAZON',
        categoryId: originalCategory.id,
      );
      final saved = (await importRepository.watchCategoryRules().first).single;

      await importRepository.updateCategoryRule(
        id: saved.id,
        keyword: 'AMZN',
        categoryId: newCategory.id,
      );

      final updated =
          (await importRepository.watchCategoryRules().first).single;
      expect(updated.keyword, 'AMZN');
      expect(updated.categoryId, newCategory.id);
    });

    test('delete removes the rule', () async {
      final category = (await categoryRepository.watchCategories().first).first;
      await importRepository.saveCategoryRule(
        keyword: 'AMAZON',
        categoryId: category.id,
      );
      final saved = (await importRepository.watchCategoryRules().first).single;

      await importRepository.deleteCategoryRule(saved.id);

      final afterDelete = await importRepository.watchCategoryRules().first;
      expect(afterDelete, isEmpty);
    });
  });
}
