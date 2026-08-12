import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/database/tables/ofx_import_records_table.dart'
    show ImportSource;
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/statement_import_repository.dart';
import '../../../../domain/csv/csv_column_mapping.dart';
import '../../../../domain/csv/csv_import_profile.dart';
import '../../../../domain/csv/csv_parser.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/statement_import/parsed_statement_transaction.dart';
import '../../../../domain/statement_import/statement_import_batch.dart';

/// Which statement source the user is importing - chosen first, since CSV
/// needs a column-mapping step OFX never does (csv-transaction-import
/// design.md).
enum StatementSource { ofx, csv }

enum StatementImportStep {
  chooseSource,
  pickFile,
  selectAccount,
  mapColumns, // CSV only
  preview,
  summary,
}

/// One previewed row's mutable review state - selection and category are
/// edited in place by the view, not replaced wholesale, so a single row
/// edit doesn't require rebuilding the whole list.
class StatementImportPreviewRow {
  StatementImportPreviewRow({
    required this.transaction,
    required this.isDuplicate,
    String? categoryId,
  }) : selected = !isDuplicate, // duplicates default excluded from posting
       categoryId = categoryId;

  final ParsedStatementTransaction transaction;
  final bool isDuplicate;
  bool selected;
  String? categoryId;
}

/// Drives the whole statement import flow as one screen with internal
/// steps (ofx-transaction-import design.md, extended by
/// csv-transaction-import): choose a source, pick a file, pick the target
/// account, (CSV only) map columns, review/categorize parsed rows, post
/// the accepted ones.
class StatementImportViewModel extends ChangeNotifier {
  StatementImportViewModel({
    required StatementImportRepository importRepository,
    required LedgerRepository ledgerRepository,
    String? initialFinancialAccountId,
  }) : _importRepository = importRepository,
       _ledgerRepository = ledgerRepository,
       _initialFinancialAccountId = initialFinancialAccountId {
    _accountsSubscription = _ledgerRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _accounts = accounts;
      notifyListeners();
    });
    _categoriesSubscription = _ledgerRepository.watchCategories().listen((
      categories,
    ) {
      _categories = categories;
      notifyListeners();
    });
    _profilesSubscription = _importRepository.watchProfiles().listen((
      profiles,
    ) {
      _profiles = profiles;
      notifyListeners();
    });
  }

  final StatementImportRepository _importRepository;
  final LedgerRepository _ledgerRepository;
  final String? _initialFinancialAccountId;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  late final StreamSubscription<List<CsvImportProfile>> _profilesSubscription;
  bool _isDisposed = false;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  List<Account> _categories = const [];
  List<Account> get categories => _categories;

  List<CsvImportProfile> _profiles = const [];
  List<CsvImportProfile> get profiles => _profiles;

  StatementImportStep _step = StatementImportStep.chooseSource;
  StatementImportStep get step => _step;

  StatementSource? _source;
  StatementSource? get source => _source;

  void chooseSource(StatementSource source) {
    _source = source;
    _step = StatementImportStep.pickFile;
    notifyListeners();
  }

  String? _fileName;
  String? get fileName => _fileName;

  String? _parseError;
  String? get parseError => _parseError;

  /// Surfaces a failure from the platform file picker itself (e.g. a
  /// missing OS-level permission) on the same pick-file step as a parse
  /// error, so a picker failure is never silently invisible to the user.
  void reportPickFileError(String message) {
    _parseError = message;
    notifyListeners();
  }

  int _parsedTransactionCount = 0;
  int get parsedTransactionCount => _parsedTransactionCount;
  int _skippedRowCount = 0;
  int get skippedRowCount => _skippedRowCount;
  String? _statementCurrency;

  String? _selectedAccountId;
  String? get selectedAccountId => _selectedAccountId;

  bool _currencyMismatch = false;
  bool get currencyMismatch => _currencyMismatch;
  String? get statementCurrency => _statementCurrency;

  List<ParsedStatementTransaction> _transactions = const [];

  List<StatementImportPreviewRow> _rows = [];
  List<StatementImportPreviewRow> get rows => List.unmodifiable(_rows);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  StatementImportBatchResult? _batchResult;
  StatementImportBatchResult? get batchResult => _batchResult;

  // --- CSV-only mapping state -----------------------------------------

  List<int>? _csvBytes;
  List<String>? _csvHeaderRow;
  List<String>? get csvHeaderRow => _csvHeaderRow;
  int get csvColumnCount => _csvHeaderRow?.length ?? 0;

  bool csvHasHeaderRow = true;
  int? csvDateColumnIndex;
  String csvDatePattern = 'dd/MM/yyyy';
  List<int> csvDescriptionColumnIndexes = [];
  CsvAmountConvention csvAmountConvention = CsvAmountConvention.signedColumn;
  int? csvSignedAmountColumnIndex;
  int? csvDebitColumnIndex;
  int? csvCreditColumnIndex;
  int? csvReferenceIdColumnIndex;
  String csvDecimalSeparator = '.';
  String? csvCurrency;

  /// A matched profile pre-fills the mapping screen so the user can jump
  /// straight to preview without re-mapping (design.md Decision 6); still
  /// shown/editable rather than applied silently, so the user notices and
  /// can override it.
  CsvImportProfile? matchedProfile;

  void applyProfile(CsvImportProfile profile) {
    final mapping = profile.mapping;
    csvHasHeaderRow = mapping.hasHeaderRow;
    csvDateColumnIndex = mapping.dateColumnIndex;
    csvDatePattern = mapping.datePattern;
    csvDescriptionColumnIndexes = List.of(mapping.descriptionColumnIndexes);
    csvAmountConvention = mapping.amountConvention;
    csvSignedAmountColumnIndex = mapping.signedAmountColumnIndex;
    csvDebitColumnIndex = mapping.debitColumnIndex;
    csvCreditColumnIndex = mapping.creditColumnIndex;
    csvReferenceIdColumnIndex = mapping.referenceIdColumnIndex;
    csvDecimalSeparator = mapping.decimalSeparator;
    csvCurrency = mapping.currency;
    notifyListeners();
  }

  void updateCsvMapping({
    bool? hasHeaderRow,
    int? dateColumnIndex,
    String? datePattern,
    List<int>? descriptionColumnIndexes,
    CsvAmountConvention? amountConvention,
    int? signedAmountColumnIndex,
    int? debitColumnIndex,
    int? creditColumnIndex,
    int? referenceIdColumnIndex,
    String? decimalSeparator,
    String? currency,
  }) {
    if (hasHeaderRow != null) csvHasHeaderRow = hasHeaderRow;
    if (dateColumnIndex != null) csvDateColumnIndex = dateColumnIndex;
    if (datePattern != null) csvDatePattern = datePattern;
    if (descriptionColumnIndexes != null) {
      csvDescriptionColumnIndexes = descriptionColumnIndexes;
    }
    if (amountConvention != null) csvAmountConvention = amountConvention;
    if (signedAmountColumnIndex != null) {
      csvSignedAmountColumnIndex = signedAmountColumnIndex;
    }
    if (debitColumnIndex != null) csvDebitColumnIndex = debitColumnIndex;
    if (creditColumnIndex != null) csvCreditColumnIndex = creditColumnIndex;
    if (referenceIdColumnIndex != null) {
      csvReferenceIdColumnIndex = referenceIdColumnIndex;
    }
    if (decimalSeparator != null) csvDecimalSeparator = decimalSeparator;
    if (currency != null) csvCurrency = currency;
    notifyListeners();
  }

  bool get canConfirmCsvMapping {
    if (csvDateColumnIndex == null) return false;
    if (csvDescriptionColumnIndexes.isEmpty) return false;
    if (csvCurrency == null || csvCurrency!.isEmpty) return false;
    switch (csvAmountConvention) {
      case CsvAmountConvention.signedColumn:
        return csvSignedAmountColumnIndex != null;
      case CsvAmountConvention.debitCreditColumns:
        return csvDebitColumnIndex != null && csvCreditColumnIndex != null;
    }
  }

  CsvColumnMapping? _buildCsvMapping() {
    final currency = csvCurrency;
    final dateIndex = csvDateColumnIndex;
    if (currency == null || currency.isEmpty || dateIndex == null) {
      return null;
    }
    return CsvColumnMapping(
      hasHeaderRow: csvHasHeaderRow,
      dateColumnIndex: dateIndex,
      datePattern: csvDatePattern,
      descriptionColumnIndexes: csvDescriptionColumnIndexes,
      amountConvention: csvAmountConvention,
      signedAmountColumnIndex: csvSignedAmountColumnIndex,
      debitColumnIndex: csvDebitColumnIndex,
      creditColumnIndex: csvCreditColumnIndex,
      referenceIdColumnIndex: csvReferenceIdColumnIndex,
      decimalSeparator: csvDecimalSeparator,
      currency: currency,
    );
  }

  /// Best-effort re-parse of the already-loaded bytes under the
  /// in-progress mapping, so the mapping screen can show a live preview
  /// before the user commits (spec: "The mapping screen previews parsed
  /// rows before committing"). Never throws - an incomplete or invalid
  /// mapping just yields an empty preview.
  List<ParsedStatementTransaction> get csvMappingPreviewRows {
    final bytes = _csvBytes;
    final mapping = _buildCsvMapping();
    if (bytes == null || mapping == null) return const [];
    try {
      return _importRepository
          .parseCsvFile(bytes, mapping)
          .transactions
          .take(5)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Rows that never became a posting attempt: unparseable rows from the
  /// file itself, plus previewed rows that were deselected (including
  /// duplicates left at their default-excluded state) or left without a
  /// category. Shown in the post-import summary alongside posted/failed
  /// counts (spec: "Preview and Duplicate Detection Before Posting").
  int get skippedOrExcludedRowCount =>
      _skippedRowCount +
      _rows.where((row) => !(row.selected && row.categoryId != null)).length;

  /// Loads [bytes] and, on success, advances to the account-selection
  /// step. For OFX, the file is parsed immediately; an unrecognizable
  /// file stays on this step with [parseError] set (spec: "Unparseable
  /// file is rejected"). For CSV, only the header row is sniffed here -
  /// full parsing waits for a column mapping.
  Future<void> loadFile({
    required String name,
    required List<int> bytes,
  }) async {
    _fileName = name;
    _parseError = null;
    try {
      switch (_source) {
        case StatementSource.ofx || null:
          final result = _importRepository.parseOfxFile(bytes);
          _transactions = result.transactions;
          _parsedTransactionCount = result.transactions.length;
          _skippedRowCount = result.skippedRows.length;
          _statementCurrency = result.statementCurrency;
        case StatementSource.csv:
          _csvBytes = bytes;
          _csvHeaderRow = readCsvRows(bytes).first;
      }
      _step = StatementImportStep.selectAccount;

      final requested = _initialFinancialAccountId;
      final requestedIsActive =
          requested != null &&
          _accounts.any((a) => a.id == requested && !a.archived);
      if (requestedIsActive) {
        await selectAccount(requested);
        return;
      }
    } on OfxParseException catch (error) {
      _parseError = error.message;
    } on CsvParseException catch (error) {
      _parseError = error.message;
    }
    notifyListeners();
  }

  /// Chooses the target account. For OFX, immediately builds the preview.
  /// For CSV, always moves to the column-mapping step next; if a saved
  /// profile's fingerprint exactly matches the sniffed header row
  /// (design.md Decision 6), the mapping screen comes pre-filled from it -
  /// the user still confirms (a plain "Continue" tap, no re-mapping
  /// needed) rather than the file silently skipping straight to preview
  /// (spec: "confirming it skips directly to the preview step").
  Future<void> selectAccount(String accountId) async {
    _selectedAccountId = accountId;
    _isLoading = true;
    notifyListeners();

    switch (_source) {
      case StatementSource.ofx || null:
        await _checkCurrencyAndBuildPreview(accountId);
      case StatementSource.csv:
        final headerRow = _csvHeaderRow;
        final profile = headerRow == null
            ? null
            : await _importRepository.findProfileForHeaderRow(headerRow);
        matchedProfile = profile;
        final accountCurrency = await _importRepository.groupCurrencyFor(
          accountId,
        );
        csvCurrency ??= accountCurrency;

        if (_isDisposed) return;
        if (profile != null) applyProfile(profile);
        _isLoading = false;
        _step = StatementImportStep.mapColumns;
        notifyListeners();
    }
  }

  /// Parses the CSV file under the user's completed mapping, optionally
  /// saving it as a named profile first, then builds the preview -
  /// mirroring OFX's immediate-parse-then-preview flow (spec: "CSV Rows
  /// Flow Through the Shared Statement-Import Review and Posting
  /// Pipeline").
  Future<void> confirmCsvMapping({String? saveAsProfileName}) async {
    final accountId = _selectedAccountId;
    final bytes = _csvBytes;
    final headerRow = _csvHeaderRow;
    final mapping = _buildCsvMapping();
    if (accountId == null || bytes == null || mapping == null) return;

    _isLoading = true;
    notifyListeners();

    if (saveAsProfileName != null && saveAsProfileName.isNotEmpty) {
      await _importRepository.saveProfile(
        name: saveAsProfileName,
        mapping: mapping,
        headerRow: headerRow ?? const [],
      );
    }

    await _parseCsvAndBuildPreview(accountId, mapping);
  }

  Future<void> _parseCsvAndBuildPreview(
    String accountId,
    CsvColumnMapping mapping,
  ) async {
    try {
      final result = _importRepository.parseCsvFile(_csvBytes!, mapping);
      _transactions = result.transactions;
      _parsedTransactionCount = result.transactions.length;
      _skippedRowCount = result.skippedRows.length;
      _statementCurrency = result.statementCurrency;
    } on CsvParseException catch (error) {
      if (_isDisposed) return;
      _isLoading = false;
      _parseError = error.message;
      _step = StatementImportStep.pickFile;
      notifyListeners();
      return;
    }
    await _checkCurrencyAndBuildPreview(accountId);
  }

  Future<void> _checkCurrencyAndBuildPreview(String accountId) async {
    final accountCurrency = await _importRepository.groupCurrencyFor(accountId);
    final statementCurrency = _statementCurrency;
    _currencyMismatch =
        statementCurrency != null &&
        accountCurrency != null &&
        statementCurrency != accountCurrency;

    final duplicateIndexes = await _importRepository.findDuplicateIndexes(
      financialAccountId: accountId,
      transactions: _transactions,
    );

    final rows = <StatementImportPreviewRow>[];
    for (var i = 0; i < _transactions.length; i++) {
      final transaction = _transactions[i];
      final suggestedCategoryId = await _importRepository.suggestCategoryFor(
        financialAccountId: accountId,
        description: transaction.description,
      );
      rows.add(
        StatementImportPreviewRow(
          transaction: transaction,
          isDuplicate: duplicateIndexes.contains(i),
          categoryId: suggestedCategoryId,
        ),
      );
    }

    if (_isDisposed) return;
    _rows = rows;
    _isLoading = false;
    _step = StatementImportStep.preview;
    notifyListeners();
  }

  void toggleRowSelected(int index) {
    _rows[index].selected = !_rows[index].selected;
    notifyListeners();
  }

  void setRowCategory(int index, String? categoryId) {
    _rows[index].categoryId = categoryId;
    notifyListeners();
  }

  Future<void> renameProfile(String id, String newName) {
    return _importRepository.renameProfile(id: id, newName: newName);
  }

  Future<void> deleteProfile(String id) {
    return _importRepository.deleteProfile(id);
  }

  /// Posts every selected, categorized row. Deselected, uncategorized, and
  /// unparseable rows were never candidates in the first place (spec:
  /// "Post Accepted Rows as Ordinary Journal Entries").
  Future<void> confirmImport() async {
    final accountId = _selectedAccountId;
    if (accountId == null) return;

    final acceptedRows = <StatementAcceptedRow>[
      for (final row in _rows)
        if (row.selected && row.categoryId != null)
          StatementAcceptedRow(
            transaction: row.transaction,
            categoryId: row.categoryId!,
          ),
    ];

    _isSubmitting = true;
    notifyListeners();

    final result = await _importRepository.postAcceptedRows(
      financialAccountId: accountId,
      rows: acceptedRows,
      source: _source == StatementSource.csv
          ? ImportSource.csv
          : ImportSource.ofx,
    );

    if (_isDisposed) return;
    _batchResult = result;
    _isSubmitting = false;
    _step = StatementImportStep.summary;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _accountsSubscription.cancel();
    _categoriesSubscription.cancel();
    _profilesSubscription.cancel();
    super.dispose();
  }
}
