import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/ofx_import_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/ui/features/ofx_import/view_models/ofx_import_view_model.dart';

import '../../../../domain/crypto/in_memory_secure_key_storage.dart';

/// A realistic OFX 2.x checking-account export (three transactions: two
/// debits and a payroll credit), the shape a real bank/card issuer would
/// produce - used to exercise the whole import pipeline (parse -> match
/// account -> dedupe -> post -> register) against a real, non-mocked
/// AppDatabase/LedgerRepository/OfxImportRepository stack. This is the
/// closest equivalent to task 5.3's manual end-to-end check that's
/// achievable without a live, interactive GUI in this environment.
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

void main() {
  late AppDatabase db;
  late LedgerRepository ledgerRepository;
  late OfxImportRepository importRepository;
  late String accountId;

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
  });

  tearDown(() async {
    await db.close();
  });

  Future<OfxImportViewModel> importFileAndCategorizeAllRows(
    OfxImportViewModel viewModel,
  ) async {
    await viewModel.loadFile(
      name: 'chase_checking.ofx',
      bytes: utf8.encode(_bankStatementFixture),
    );
    await viewModel.selectAccount(accountId);

    final categories = await ledgerRepository.watchCategories().first;
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
      final firstImport = OfxImportViewModel(
        importRepository: importRepository,
        ledgerRepository: ledgerRepository,
      );
      addTearDown(firstImport.dispose);
      await importFileAndCategorizeAllRows(firstImport);

      expect(firstImport.step, OfxImportStep.preview);
      expect(firstImport.rows, hasLength(3));
      expect(firstImport.rows.every((row) => !row.isDuplicate), isTrue);
      expect(firstImport.rows.every((row) => row.selected), isTrue);

      await firstImport.confirmImport();

      expect(firstImport.step, OfxImportStep.summary);
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
      final secondImport = OfxImportViewModel(
        importRepository: importRepository,
        ledgerRepository: ledgerRepository,
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
      final viewModel = OfxImportViewModel(
        importRepository: importRepository,
        ledgerRepository: ledgerRepository,
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

      expect(viewModel.step, OfxImportStep.preview);
      expect(viewModel.selectedAccountId, accountId);
    },
  );
}
