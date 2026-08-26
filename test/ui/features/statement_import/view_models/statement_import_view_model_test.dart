import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/payee_repository.dart';
import 'package:smara_accounting/data/repositories/statement_import_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/csv/csv_column_mapping.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/statement_import/view_models/statement_import_view_model.dart';

import '../../../../domain/crypto/in_memory_secure_key_storage.dart';

/// A realistic ICICI-style CSV export: separate withdrawal/deposit
/// columns (no single signed-amount column, and no reference-id column -
/// so duplicate detection here exercises the fallback match-key path, not
/// FITID) - used for csv-transaction-import task 5.3's end-to-end check.
const _icicCsvFixture =
    'Date,Narration,Withdrawal Amt.,Deposit Amt.\n'
    '02/02/2026,ATM WDL,500.00,\n'
    '04/02/2026,SWIGGY ORDER,350.75,\n'
    '06/02/2026,SALARY CREDIT,,45000.00\n';

/// A realistic OFX 2.x checking-account export (three transactions: two
/// debits and a payroll credit), the shape a real bank/card issuer would
/// produce - used to exercise the whole import pipeline (parse -> match
/// account -> dedupe -> post -> register) against a real, non-mocked
/// AppDatabase/LedgerRepository/StatementImportRepository stack. This is
/// the closest equivalent to ofx-transaction-import task 5.3's manual
/// end-to-end check that's achievable without a live, interactive GUI in
/// this environment.
const _bankStatementFixture = '''
<?xml version="1.0" encoding="UTF-8"?>
<?OFX OFXHEADER="200" VERSION="211" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>
<OFX>
  <SIGNONMSGSRSV1>
    <SONRS>
      <STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS>
      <DTSERVER>20260210120000</DTSERVER>
      <LANGUAGE>ENG</LANGUAGE>
    </SONRS>
  </SIGNONMSGSRSV1>
  <BANKMSGSRSV1>
    <STMTTRNRS>
      <TRNUID>1</TRNUID>
      <STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS>
      <STMTRS>
        <CURDEF>USD</CURDEF>
        <BANKACCTFROM><BANKID>021000021</BANKID><ACCTID>000123456789</ACCTID><ACCTTYPE>CHECKING</ACCTTYPE></BANKACCTFROM>
        <BANKTRANLIST>
          <DTSTART>20260201</DTSTART>
          <DTEND>20260210</DTEND>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260202</DTPOSTED>
            <TRNAMT>-64.53</TRNAMT>
            <FITID>202602020001</FITID>
            <NAME>WHOLE FOODS MARKET</NAME>
          </STMTTRN>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260204</DTPOSTED>
            <TRNAMT>-5.75</TRNAMT>
            <FITID>202602040002</FITID>
            <NAME>BLUE BOTTLE COFFEE</NAME>
          </STMTTRN>
          <STMTTRN>
            <TRNTYPE>CREDIT</TRNTYPE>
            <DTPOSTED>20260206</DTPOSTED>
            <TRNAMT>2450.00</TRNAMT>
            <FITID>202602060003</FITID>
            <NAME>ACME CORP PAYROLL</NAME>
          </STMTTRN>
        </BANKTRANLIST>
        <LEDGERBAL><BALAMT>3120.44</BALAMT><DTASOF>20260210</DTASOF></LEDGERBAL>
      </STMTRS>
    </STMTTRNRS>
  </BANKMSGSRSV1>
</OFX>
''';

/// Like [_bankStatementFixture], but with two rows sharing the same
/// 'WHOLE FOODS MARKET' description (different FITID/date/amount) so the
/// row-grouping tests have an actual multi-row group to exercise, plus one
/// row with a unique description.
const _duplicateDescriptionFixture = '''
<?xml version="1.0" encoding="UTF-8"?>
<?OFX OFXHEADER="200" VERSION="211" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>
<OFX>
  <SIGNONMSGSRSV1>
    <SONRS>
      <STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS>
      <DTSERVER>20260210120000</DTSERVER>
      <LANGUAGE>ENG</LANGUAGE>
    </SONRS>
  </SIGNONMSGSRSV1>
  <BANKMSGSRSV1>
    <STMTTRNRS>
      <TRNUID>1</TRNUID>
      <STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS>
      <STMTRS>
        <CURDEF>USD</CURDEF>
        <BANKACCTFROM><BANKID>021000021</BANKID><ACCTID>000123456789</ACCTID><ACCTTYPE>CHECKING</ACCTTYPE></BANKACCTFROM>
        <BANKTRANLIST>
          <DTSTART>20260201</DTSTART>
          <DTEND>20260210</DTEND>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260202</DTPOSTED>
            <TRNAMT>-64.53</TRNAMT>
            <FITID>202602020001</FITID>
            <NAME>WHOLE FOODS MARKET</NAME>
          </STMTTRN>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260205</DTPOSTED>
            <TRNAMT>-31.10</TRNAMT>
            <FITID>202602050004</FITID>
            <NAME>WHOLE FOODS MARKET</NAME>
          </STMTTRN>
          <STMTTRN>
            <TRNTYPE>CREDIT</TRNTYPE>
            <DTPOSTED>20260206</DTPOSTED>
            <TRNAMT>2450.00</TRNAMT>
            <FITID>202602060003</FITID>
            <NAME>ACME CORP PAYROLL</NAME>
          </STMTTRN>
        </BANKTRANLIST>
        <LEDGERBAL><BALAMT>3120.44</BALAMT><DTASOF>20260210</DTASOF></LEDGERBAL>
      </STMTRS>
    </STMTTRNRS>
  </BANKMSGSRSV1>
</OFX>
''';

void main() {
  late AppDatabase db;
  late LedgerRepository ledgerRepository;
  late AccountRepository accountRepository;
  late CategoryRepository categoryRepository;
  late PayeeRepository payeeRepository;
  late StatementImportRepository importRepository;
  late String accountId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    ledgerRepository = LedgerRepository(database: db, signingKeyService: keys);
    accountRepository = AccountRepository(
      database: db,
      ledgerRepository: ledgerRepository,
    );
    categoryRepository = CategoryRepository(database: db);
    payeeRepository = PayeeRepository(database: db);
    importRepository = StatementImportRepository(
      database: db,
      ledgerRepository: ledgerRepository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
    );
    final identityRepository = IdentityRepository(
      database: db,
      accountRepository: accountRepository,
      signingKeyService: keys,
    );
    final generated = await identityRepository.generateFirstIdentity();
    await identityRepository.confirmFirstIdentity(generated, currency: 'USD');
    accountId =
        (await accountRepository.watchFinancialAccounts().first).first.id;
  });

  tearDown(() async {
    await db.close();
  });

  Future<StatementImportViewModel> importFileAndCategorizeAllRows(
    StatementImportViewModel viewModel,
  ) async {
    await viewModel.loadFile(
      name: 'chase_checking.ofx',
      bytes: utf8.encode(_bankStatementFixture),
    );
    await viewModel.selectAccount(accountId);

    final categories = await categoryRepository.watchCategories().first;
    final expenseCategoryId = categories
        .firstWhere((c) => c.type == AccountType.expense)
        .id;
    final incomeCategoryId = categories
        .firstWhere((c) => c.type == AccountType.income)
        .id;
    for (var i = 0; i < viewModel.rows.length; i++) {
      final row = viewModel.rows[i];
      viewModel.setRowCategory(
        i,
        row.transaction.description.contains('PAYROLL')
            ? incomeCategoryId
            : expenseCategoryId,
      );
    }
    return viewModel;
  }

  test(
    'end-to-end: importing a real bank statement posts entries visible in the register, '
    'and re-importing the same file flags every row as a duplicate and posts nothing new',
    () async {
      // First import: three fresh rows, none flagged as duplicates.
      final firstImport = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
      );
      addTearDown(firstImport.dispose);
      await importFileAndCategorizeAllRows(firstImport);

      expect(firstImport.step, StatementImportStep.preview);
      expect(firstImport.rows, hasLength(3));
      expect(firstImport.rows.every((row) => !row.isDuplicate), isTrue);
      expect(firstImport.rows.every((row) => row.selected), isTrue);

      await firstImport.confirmImport();

      expect(firstImport.step, StatementImportStep.summary);
      expect(firstImport.batchResult?.postedCount, 3);
      expect(firstImport.batchResult?.failedCount, 0);

      final registerAfterFirstImport = await ledgerRepository
          .watchEntriesForAccount(accountId)
          .first;
      final descriptions = registerAfterFirstImport
          .map((e) => e.description)
          .toSet();
      expect(descriptions, contains('WHOLE FOODS MARKET'));
      expect(descriptions, contains('BLUE BOTTLE COFFEE'));
      expect(descriptions, contains('ACME CORP PAYROLL'));

      // Second import of the exact same file: every row's FITID was
      // already recorded, so all three are flagged and excluded by
      // default (spec: "Preview and Duplicate Detection Before Posting").
      final secondImport = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
      );
      addTearDown(secondImport.dispose);
      await importFileAndCategorizeAllRows(secondImport);

      expect(secondImport.rows, hasLength(3));
      expect(secondImport.rows.every((row) => row.isDuplicate), isTrue);
      expect(secondImport.rows.every((row) => !row.selected), isTrue);

      await secondImport.confirmImport();

      expect(secondImport.batchResult?.postedCount, 0);
      expect(secondImport.batchResult?.failedCount, 0);

      // The register still shows exactly the three original entries - the
      // duplicate re-import posted nothing new.
      final registerAfterSecondImport = await ledgerRepository
          .watchEntriesForAccount(accountId)
          .first;
      expect(registerAfterSecondImport, hasLength(3));
    },
  );

  test(
    'loadFile pre-selects and moves straight to preview when launched with a valid initial account',
    () async {
      final viewModel = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
        initialFinancialAccountId: accountId,
      );
      addTearDown(viewModel.dispose);
      // Let the accounts stream deliver its first emission before loading
      // the file, matching how the real register-launched flow behaves.
      await Future<void>.delayed(Duration.zero);

      await viewModel.loadFile(
        name: 'chase_checking.ofx',
        bytes: utf8.encode(_bankStatementFixture),
      );

      expect(viewModel.step, StatementImportStep.preview);
      expect(viewModel.selectedAccountId, accountId);
    },
  );

  test(
    'end-to-end CSV: mapping columns and saving a profile posts entries visible '
    'in the register, and re-importing the same file auto-offers the saved '
    'profile and flags every row as a duplicate',
    () async {
      final categories = await categoryRepository.watchCategories().first;
      final expenseCategoryId = categories
          .firstWhere((c) => c.type == AccountType.expense)
          .id;
      final incomeCategoryId = categories
          .firstWhere((c) => c.type == AccountType.income)
          .id;

      // First import: no saved profile yet, so mapping columns by hand.
      final firstImport = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
      );
      addTearDown(firstImport.dispose);
      firstImport.chooseSource(StatementSource.csv);
      await firstImport.loadFile(
        name: 'icici_statement.csv',
        bytes: utf8.encode(_icicCsvFixture),
      );
      await firstImport.selectAccount(accountId);

      expect(firstImport.step, StatementImportStep.mapColumns);
      expect(firstImport.matchedProfile, isNull);

      firstImport.updateCsvMapping(
        dateColumnIndex: 0,
        datePattern: 'dd/MM/yyyy',
        descriptionColumnIndexes: [1],
        amountConvention: CsvAmountConvention.debitCreditColumns,
        debitColumnIndex: 2,
        creditColumnIndex: 3,
      );
      expect(firstImport.canConfirmCsvMapping, isTrue);

      await firstImport.confirmCsvMapping(saveAsProfileName: 'ICICI Savings');

      expect(firstImport.step, StatementImportStep.preview);
      expect(firstImport.rows, hasLength(3));
      expect(firstImport.rows.every((row) => !row.isDuplicate), isTrue);

      for (var i = 0; i < firstImport.rows.length; i++) {
        final row = firstImport.rows[i];
        firstImport.setRowCategory(
          i,
          row.transaction.description.contains('SALARY')
              ? incomeCategoryId
              : expenseCategoryId,
        );
      }
      await firstImport.confirmImport();

      expect(firstImport.batchResult?.postedCount, 3);
      expect(firstImport.batchResult?.failedCount, 0);

      final registerAfterFirstImport = await ledgerRepository
          .watchEntriesForAccount(accountId)
          .first;
      final descriptions = registerAfterFirstImport
          .map((e) => e.description)
          .toSet();
      expect(descriptions, contains('ATM WDL'));
      expect(descriptions, contains('SWIGGY ORDER'));
      expect(descriptions, contains('SALARY CREDIT'));

      // Second import of the exact same file: the saved profile should
      // auto-offer (pre-filling the mapping screen), and every row should
      // be flagged as a duplicate via the fallback match key (this CSV has
      // no reference-id column).
      final secondImport = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
      );
      addTearDown(secondImport.dispose);
      secondImport.chooseSource(StatementSource.csv);
      await secondImport.loadFile(
        name: 'icici_statement.csv',
        bytes: utf8.encode(_icicCsvFixture),
      );
      await secondImport.selectAccount(accountId);

      expect(secondImport.step, StatementImportStep.mapColumns);
      expect(secondImport.matchedProfile?.name, 'ICICI Savings');
      expect(secondImport.canConfirmCsvMapping, isTrue);

      await secondImport.confirmCsvMapping();

      expect(secondImport.step, StatementImportStep.preview);
      expect(secondImport.rows, hasLength(3));
      expect(secondImport.rows.every((row) => row.isDuplicate), isTrue);
      expect(secondImport.rows.every((row) => !row.selected), isTrue);

      await secondImport.confirmImport();

      expect(secondImport.batchResult?.postedCount, 0);
      expect(secondImport.batchResult?.failedCount, 0);

      final registerAfterSecondImport = await ledgerRepository
          .watchEntriesForAccount(accountId)
          .first;
      expect(registerAfterSecondImport, hasLength(3));
    },
  );

  group('category rule priority', () {
    test(
      'a saved rule wins over an exact-memo match to a different category',
      () async {
        final categories = await categoryRepository.watchCategories().first;
        final groceries = categories.firstWhere(
          (c) => c.type == AccountType.expense && c.name == 'Groceries',
        );
        final transport = categories.firstWhere(
          (c) => c.type == AccountType.expense && c.name == 'Transport',
        );

        // An exact-memo match exists for 'WHOLE FOODS MARKET', pointing at
        // the *wrong* category - if the rule didn't take priority, this is
        // what suggestCategoryFor's fallback would return instead.
        await ledgerRepository.recordTransaction(
          amountMinor: 100,
          direction: TransactionDirection.moneyOut,
          categoryId: transport.id,
          financialAccountId: accountId,
          transactionDate: DateTime(2026, 1, 1),
          description: 'WHOLE FOODS MARKET',
        );
        await importRepository.saveCategoryRule(
          keyword: 'WHOLE FOODS',
          categoryId: groceries.id,
        );

        final viewModel = StatementImportViewModel(
          importRepository: importRepository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
          payeeRepository: payeeRepository,
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);
        await viewModel.loadFile(
          name: 'chase_checking.ofx',
          bytes: utf8.encode(_bankStatementFixture),
        );
        await viewModel.selectAccount(accountId);

        final row = viewModel.rows.firstWhere(
          (r) => r.transaction.description == 'WHOLE FOODS MARKET',
        );
        expect(row.categoryId, groceries.id);
      },
    );

    test('falls back to the exact-memo match when no rule matches', () async {
      final categories = await categoryRepository.watchCategories().first;
      final groceries = categories.firstWhere(
        (c) => c.type == AccountType.expense && c.name == 'Groceries',
      );
      await ledgerRepository.recordTransaction(
        amountMinor: 100,
        direction: TransactionDirection.moneyOut,
        categoryId: groceries.id,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 1),
        description: 'WHOLE FOODS MARKET',
      );
      // No category rule saved.

      final viewModel = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);
      await viewModel.loadFile(
        name: 'chase_checking.ofx',
        bytes: utf8.encode(_bankStatementFixture),
      );
      await viewModel.selectAccount(accountId);

      final row = viewModel.rows.firstWhere(
        (r) => r.transaction.description == 'WHOLE FOODS MARKET',
      );
      expect(row.categoryId, groceries.id);
    });

    test(
      'a row with neither a matching rule nor a prior exact-memo match is left uncategorized',
      () async {
        final viewModel = StatementImportViewModel(
          importRepository: importRepository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
          payeeRepository: payeeRepository,
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);
        await viewModel.loadFile(
          name: 'chase_checking.ofx',
          bytes: utf8.encode(_bankStatementFixture),
        );
        await viewModel.selectAccount(accountId);

        final row = viewModel.rows.firstWhere(
          (r) => r.transaction.description == 'WHOLE FOODS MARKET',
        );
        expect(row.categoryId, isNull);
      },
    );
  });

  group('row grouping', () {
    test('rows with identical (normalized) descriptions are grouped, and a '
        'unique description gets its own single-row group', () async {
      final viewModel = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);
      await viewModel.loadFile(
        name: 'chase_checking.ofx',
        bytes: utf8.encode(_duplicateDescriptionFixture),
      );
      await viewModel.selectAccount(accountId);

      final groups = viewModel.rowGroups;
      final wholeFoodsGroup = groups.firstWhere(
        (g) => g.key == 'whole foods market',
      );
      expect(wholeFoodsGroup.isSingleRow, isFalse);
      expect(wholeFoodsGroup.rowIndexes, hasLength(2));

      final payrollGroup = groups.firstWhere(
        (g) => g.key == 'acme corp payroll',
      );
      expect(payrollGroup.isSingleRow, isTrue);

      expect(
        groups.map((g) => g.rowIndexes.length).reduce((a, b) => a + b),
        viewModel.rows.length,
      );
    });

    test(
      'setCategoryForGroup sets the category on every row in the group',
      () async {
        final categories = await categoryRepository.watchCategories().first;
        final groceries = categories.firstWhere(
          (c) => c.type == AccountType.expense && c.name == 'Groceries',
        );

        final viewModel = StatementImportViewModel(
          importRepository: importRepository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
          payeeRepository: payeeRepository,
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);
        await viewModel.loadFile(
          name: 'chase_checking.ofx',
          bytes: utf8.encode(_duplicateDescriptionFixture),
        );
        await viewModel.selectAccount(accountId);

        final group = viewModel.rowGroups.firstWhere(
          (g) => g.key == 'whole foods market',
        );
        expect(group.rowIndexes, hasLength(2));
        viewModel.setCategoryForGroup(group.key, groceries.id);

        for (final index in group.rowIndexes) {
          expect(viewModel.rows[index].categoryId, groceries.id);
        }
      },
    );
  });

  group('saving a category rule from the view model', () {
    test('a saved rule is picked up by a later import', () async {
      final categories = await categoryRepository.watchCategories().first;
      final groceries = categories.firstWhere(
        (c) => c.type == AccountType.expense && c.name == 'Groceries',
      );

      final firstImport = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
      );
      addTearDown(firstImport.dispose);
      await Future<void>.delayed(Duration.zero);
      await firstImport.saveCategoryRule(
        keyword: 'WHOLE FOODS',
        categoryId: groceries.id,
      );

      final secondImport = StatementImportViewModel(
        importRepository: importRepository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        payeeRepository: payeeRepository,
      );
      addTearDown(secondImport.dispose);
      await Future<void>.delayed(Duration.zero);
      await secondImport.loadFile(
        name: 'chase_checking.ofx',
        bytes: utf8.encode(_bankStatementFixture),
      );
      await secondImport.selectAccount(accountId);

      final row = secondImport.rows.firstWhere(
        (r) => r.transaction.description == 'WHOLE FOODS MARKET',
      );
      expect(row.categoryId, groceries.id);
    });
  });
}
