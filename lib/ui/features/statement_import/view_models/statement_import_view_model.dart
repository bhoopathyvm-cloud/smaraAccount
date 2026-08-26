import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/database/tables/ofx_import_records_table.dart'
    show ImportSource;
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/payee_repository.dart';
import '../../../../data/repositories/statement_import_repository.dart';
import '../../../../domain/csv/csv_column_mapping.dart';
import '../../../../domain/csv/csv_import_profile.dart';
import '../../../../domain/csv/csv_parser.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/statement_import/category_rule.dart';
import '../../../../domain/statement_import/parsed_statement_transaction.dart';
import '../../../../domain/statement_import/statement_import_batch.dart';
import '../../../../domain/statement_import/statement_import_session.dart';

export '../../../../domain/statement_import/statement_import_session.dart';

/// Drives the whole statement import flow as one screen with internal
/// steps (ofx-transaction-import design.md, extended by
/// csv-transaction-import): choose a source, pick a file, pick the target
/// account, (CSV only) map columns, review/categorize parsed rows, post
/// the accepted ones.
class StatementImportViewModel extends ChangeNotifier {
  StatementImportViewModel({
    required StatementImportRepository importRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required PayeeRepository payeeRepository,
    String? initialFinancialAccountId,
  }) : _importRepository = importRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository,
       _payeeRepository = payeeRepository,
       _initialFinancialAccountId = initialFinancialAccountId {
    _accountsSubscription = _accountRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _accounts = accounts;
      notifyListeners();
    });
    _categoriesSubscription = _categoryRepository.watchCategories().listen((
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
    _categoryRulesSubscription = _importRepository.watchCategoryRules().listen((
      rules,
    ) {
      _categoryRules = rules;
      notifyListeners();
    });
  }

  final StatementImportRepository _importRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final PayeeRepository _payeeRepository;
  final String? _initialFinancialAccountId;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  late final StreamSubscription<List<CsvImportProfile>> _profilesSubscription;
  late final StreamSubscription<List<CategoryRule>> _categoryRulesSubscription;
  bool _isDisposed = false;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  List<Account> _categories = const [];
  List<Account> get categories => _categories;

  List<CsvImportProfile> _profiles = const [];
  List<CsvImportProfile> get profiles => _profiles;

  List<CategoryRule> _categoryRules = const [];
  List<CategoryRule> get categoryRules => _categoryRules;

  final _session = StatementImportSession();

  StatementImportStep get step => _session.step;

  StatementSource? get source => _session.source;

  void chooseSource(StatementSource source) {
    _session.chooseSource(source);
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
  List<StatementSkippedRow> _skippedRows = const [];

  /// Rows the parser could not turn into a transaction, with the reason
  /// each was skipped (spec: "Skipped-Row Reasons Are Shown to the User").
  List<StatementSkippedRow> get skippedRows => List.unmodifiable(_skippedRows);
  int get skippedRowCount => _skippedRows.length;
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

  bool get csvHasHeaderRow => _session.csvMapping.hasHeaderRow;
  int? get csvDateColumnIndex => _session.csvMapping.dateColumnIndex;
  String get csvDatePattern => _session.csvMapping.datePattern;
  List<int> get csvDescriptionColumnIndexes =>
      _session.csvMapping.descriptionColumnIndexes;
  CsvAmountConvention get csvAmountConvention =>
      _session.csvMapping.amountConvention;
  int? get csvSignedAmountColumnIndex =>
      _session.csvMapping.signedAmountColumnIndex;
  int? get csvDebitColumnIndex => _session.csvMapping.debitColumnIndex;
  int? get csvCreditColumnIndex => _session.csvMapping.creditColumnIndex;
  int? get csvReferenceIdColumnIndex =>
      _session.csvMapping.referenceIdColumnIndex;
  String get csvDecimalSeparator => _session.csvMapping.decimalSeparator;
  String? get csvCurrency => _session.csvMapping.currency;

  /// A matched profile pre-fills the mapping screen so the user can jump
  /// straight to preview without re-mapping (design.md Decision 6); still
  /// shown/editable rather than applied silently, so the user notices and
  /// can override it.
  CsvImportProfile? matchedProfile;

  void applyProfile(CsvImportProfile profile) {
    _session.csvMapping.applyProfile(profile);
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
    final mapping = _session.csvMapping;
    if (hasHeaderRow != null) mapping.hasHeaderRow = hasHeaderRow;
    if (dateColumnIndex != null) mapping.dateColumnIndex = dateColumnIndex;
    if (datePattern != null) mapping.datePattern = datePattern;
    if (descriptionColumnIndexes != null) {
      mapping.descriptionColumnIndexes = descriptionColumnIndexes;
    }
    if (amountConvention != null) mapping.amountConvention = amountConvention;
    if (signedAmountColumnIndex != null) {
      mapping.signedAmountColumnIndex = signedAmountColumnIndex;
    }
    if (debitColumnIndex != null) mapping.debitColumnIndex = debitColumnIndex;
    if (creditColumnIndex != null) {
      mapping.creditColumnIndex = creditColumnIndex;
    }
    if (referenceIdColumnIndex != null) {
      mapping.referenceIdColumnIndex = referenceIdColumnIndex;
    }
    if (decimalSeparator != null) mapping.decimalSeparator = decimalSeparator;
    if (currency != null) mapping.currency = currency;
    notifyListeners();
  }

  bool get canConfirmCsvMapping => _session.canConfirmCsvMapping;

  CsvColumnMapping? _buildCsvMapping() => _session.csvMapping.toMapping();

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
      skippedRowCount +
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
      switch (_session.source) {
        case StatementSource.ofx || null:
          final result = _importRepository.parseOfxFile(bytes);
          _transactions = result.transactions;
          _parsedTransactionCount = result.transactions.length;
          _skippedRows = result.skippedRows;
          _statementCurrency = result.statementCurrency;
        case StatementSource.csv:
          _csvBytes = bytes;
          _csvHeaderRow = readCsvRows(bytes).first;
      }
      _session.step = StatementImportStep.selectAccount;

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

    switch (_session.source) {
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
        _session.csvMapping.currency ??= accountCurrency;

        if (_isDisposed) return;
        if (profile != null) applyProfile(profile);
        _isLoading = false;
        _session.step = StatementImportStep.mapColumns;
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
      _skippedRows = result.skippedRows;
      _statementCurrency = result.statementCurrency;
    } on CsvParseException catch (error) {
      if (_isDisposed) return;
      _isLoading = false;
      _parseError = error.message;
      _session.step = StatementImportStep.pickFile;
      notifyListeners();
      return;
    }
    await _checkCurrencyAndBuildPreview(accountId);
  }

  Future<void> _checkCurrencyAndBuildPreview(String accountId) async {
    final preview = await _importRepository.buildPreviewRows(
      financialAccountId: accountId,
      transactions: _transactions,
      rules: _categoryRules,
    );
    final statementCurrency = _statementCurrency;
    _currencyMismatch =
        statementCurrency != null &&
        preview.accountCurrency != null &&
        statementCurrency != preview.accountCurrency;

    final rows = <StatementImportPreviewRow>[
      for (final draft in preview.rows)
        StatementImportPreviewRow(
          transaction: draft.transaction,
          isDuplicate: draft.isDuplicate,
          categoryId: draft.suggestedCategoryId,
        ),
    ];

    if (_isDisposed) return;
    _rows = rows;
    _isLoading = false;
    _session.step = StatementImportStep.preview;
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

  /// Preview rows grouped by normalized description (trim + case-fold),
  /// preserving each group's first-seen order (spec: "Group Preview Rows
  /// by Matching Description"). A row with a description no other row
  /// shares still gets its own single-row group, so it's bulk-assignable
  /// through the same action as a multi-row group.
  List<StatementImportRowGroup> get rowGroups => groupPreviewRows(_rows);

  /// Sets [categoryId] on every row currently in the group identified by
  /// [groupKey] - not retroactive to rows added afterward, since it only
  /// touches the rows present in [_rows] at call time (spec: "Assigning a
  /// category to a group sets it on every row in the group").
  void setCategoryForGroup(String groupKey, String? categoryId) {
    for (final row in _rows) {
      if (normalizeDescription(row.transaction.description) == groupKey) {
        row.categoryId = categoryId;
      }
    }
    notifyListeners();
  }

  Future<void> renameProfile(String id, String newName) {
    return _importRepository.renameProfile(id: id, newName: newName);
  }

  Future<void> deleteProfile(String id) {
    return _importRepository.deleteProfile(id);
  }

  Future<void> saveCategoryRule({
    required String keyword,
    required String categoryId,
  }) {
    return _importRepository.saveCategoryRule(
      keyword: keyword,
      categoryId: categoryId,
    );
  }

  /// payees-and-spending-memory: "Saving a rule offers to link a payee too"
  /// scenario - links an existing payee matching [keyword] or creates one,
  /// with [categoryId] as its default. Called only when the user opts in
  /// from the save-rule dialog; declining leaves the rule exactly as it
  /// would without this option.
  Future<void> linkPayeeToRule({
    required String keyword,
    required String categoryId,
  }) {
    return _payeeRepository.findOrCreatePayeeByName(
      name: keyword,
      defaultCategoryId: categoryId,
    );
  }

  Future<void> updateCategoryRule({
    required String id,
    required String keyword,
    required String categoryId,
  }) {
    return _importRepository.updateCategoryRule(
      id: id,
      keyword: keyword,
      categoryId: categoryId,
    );
  }

  Future<void> deleteCategoryRule(String id) {
    return _importRepository.deleteCategoryRule(id);
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
      source: _session.source == StatementSource.csv
          ? ImportSource.csv
          : ImportSource.ofx,
    );

    if (_isDisposed) return;
    _batchResult = result;
    _isSubmitting = false;
    _session.step = StatementImportStep.summary;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _accountsSubscription.cancel();
    _categoriesSubscription.cancel();
    _profilesSubscription.cancel();
    _categoryRulesSubscription.cancel();
    super.dispose();
  }
}
