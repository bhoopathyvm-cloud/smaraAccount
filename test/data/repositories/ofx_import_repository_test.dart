import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/ofx_import_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/ofx/ofx_import_batch.dart';
import 'package:smara_accounting/domain/ofx/parsed_ofx_transaction.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository ledgerRepository;
  late OfxImportRepository importRepository;
  late String accountId;
  late String otherAccountId;
  late String journalEntryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    ledgerRepository = LedgerRepository(
      database: db,
      signingKeyService: SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      ),
    );
    importRepository = OfxImportRepository(
      database: db,
      ledgerRepository: ledgerRepository,
    );

    final generated = await ledgerRepository.generateFirstIdentity();
    await ledgerRepository.confirmFirstIdentity(generated, currency: 'USD');
    accountId =
        (await ledgerRepository.watchFinancialAccounts().first).first.id;

    final assetGroup = (await ledgerRepository.watchAccountGroups().first)
        .firstWhere((g) => g.kind == AccountGroupKind.assetGroup);
    final otherAccount = await ledgerRepository.createFinancialAccount(
      name: 'Savings',
      type: AccountType.asset,
      groupId: assetGroup.id,
    );
    otherAccountId = otherAccount.id;

    final category = (await ledgerRepository.watchCategories().first).first;
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

  ParsedOfxTransaction transaction({
    String? fitid,
    String description = 'Row',
  }) {
    return ParsedOfxTransaction(
      transactionDate: DateTime(2026, 1, 5),
      amountMinor: 500,
      direction: TransactionDirection.moneyOut,
      description: description,
      currency: 'USD',
      fitid: fitid,
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

  group('parseFile', () {
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
      final result = importRepository.parseFile(utf8.encode(fixture));
      expect(result.transactions, hasLength(1));
      expect(result.statementCurrency, 'USD');
    });

    test('throws OfxParseException for a non-OFX payload', () {
      expect(
        () => importRepository.parseFile(utf8.encode('not an ofx file')),
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
        final category = (await ledgerRepository.watchCategories().first).first;
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

  group('postAcceptedRows', () {
    test(
      'posts a valid row and records it for future duplicate detection',
      () async {
        final category = (await ledgerRepository.watchCategories().first).first;
        final row = transaction(fitid: 'POST-1', description: 'New Row');

        final result = await importRepository.postAcceptedRows(
          financialAccountId: accountId,
          rows: [OfxAcceptedRow(transaction: row, categoryId: category.id)],
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
        final category = (await ledgerRepository.watchCategories().first).first;
        final badRow = ParsedOfxTransaction(
          transactionDate: DateTime(2026, 1, 6),
          amountMinor: 0,
          direction: TransactionDirection.moneyOut,
          description: 'Bad Row',
          currency: 'USD',
          fitid: 'BAD-1',
        );
        final goodRow = transaction(fitid: 'GOOD-1', description: 'Good Row');

        final result = await importRepository.postAcceptedRows(
          financialAccountId: accountId,
          rows: [
            OfxAcceptedRow(transaction: badRow, categoryId: category.id),
            OfxAcceptedRow(transaction: goodRow, categoryId: category.id),
          ],
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
        final category = (await ledgerRepository.watchCategories().first).first;
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
          rows: [OfxAcceptedRow(transaction: row, categoryId: category.id)],
        );

        expect(result.postedCount, 1);
        expect(await ledgerRepository.watchPendingTransfers().first, isEmpty);
      },
    );

    test(
      'a foreign-currency row posts through the existing provisional-entry path',
      () async {
        final category = (await ledgerRepository.watchCategories().first).first;
        final row = ParsedOfxTransaction(
          transactionDate: DateTime(2026, 1, 7),
          amountMinor: 4321,
          direction: TransactionDirection.moneyOut,
          description: 'Foreign currency row',
          currency: 'EUR', // seeded account's group currency is USD
          fitid: 'FX-1',
        );

        final result = await importRepository.postAcceptedRows(
          financialAccountId: accountId,
          rows: [OfxAcceptedRow(transaction: row, categoryId: category.id)],
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
}
