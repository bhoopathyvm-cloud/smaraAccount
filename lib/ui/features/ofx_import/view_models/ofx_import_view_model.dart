import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/ofx_import_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/ofx/ofx_import_batch.dart';
import '../../../../domain/ofx/parsed_ofx_transaction.dart';

enum OfxImportStep { pickFile, selectAccount, preview, summary }

/// One previewed row's mutable review state - selection and category are
/// edited in place by the view, not replaced wholesale, so a single row
/// edit doesn't require rebuilding the whole list.
class OfxImportPreviewRow {
  OfxImportPreviewRow({
    required this.transaction,
    required this.isDuplicate,
    String? categoryId,
  }) : selected = !isDuplicate, // duplicates default excluded from posting
       categoryId = categoryId;

  final ParsedOfxTransaction transaction;
  final bool isDuplicate;
  bool selected;
  String? categoryId;
}

/// Drives the whole OFX import flow as one screen with internal steps
/// (ofx-transaction-import design.md): pick a file, pick the target
/// account, review/categorize parsed rows, post the accepted ones.
class OfxImportViewModel extends ChangeNotifier {
  OfxImportViewModel({
    required OfxImportRepository importRepository,
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
  }

  final OfxImportRepository _importRepository;
  final LedgerRepository _ledgerRepository;
  final String? _initialFinancialAccountId;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  bool _isDisposed = false;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  List<Account> _categories = const [];
  List<Account> get categories => _categories;

  OfxImportStep _step = OfxImportStep.pickFile;
  OfxImportStep get step => _step;

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

  List<ParsedOfxTransaction> _transactions = const [];

  List<OfxImportPreviewRow> _rows = [];
  List<OfxImportPreviewRow> get rows => List.unmodifiable(_rows);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  OfxImportBatchResult? _batchResult;
  OfxImportBatchResult? get batchResult => _batchResult;

  /// Rows that never became a posting attempt: unparseable rows from the
  /// file itself, plus previewed rows that were deselected (including
  /// duplicates left at their default-excluded state) or left without a
  /// category. Shown in the post-import summary alongside posted/failed
  /// counts (spec: "Preview and Duplicate Detection Before Posting").
  int get skippedOrExcludedRowCount =>
      _skippedRowCount +
      _rows.where((row) => !(row.selected && row.categoryId != null)).length;

  /// Parses [bytes] and, on success, advances to the account-selection
  /// step. A file that isn't recognizable as OFX at all stays on this
  /// step with [parseError] set (spec: "Unparseable file is rejected").
  Future<void> loadFile({
    required String name,
    required List<int> bytes,
  }) async {
    _fileName = name;
    _parseError = null;
    try {
      final result = _importRepository.parseFile(bytes);
      _transactions = result.transactions;
      _parsedTransactionCount = result.transactions.length;
      _skippedRowCount = result.skippedRows.length;
      _statementCurrency = result.statementCurrency;
      _step = OfxImportStep.selectAccount;

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
    }
    notifyListeners();
  }

  /// Chooses the target account and builds the preview rows: duplicate
  /// flags default unselected rows to excluded, and each row gets a
  /// category suggestion where one exists (spec: "Preview and Duplicate
  /// Detection Before Posting", "Categorize Rows Before Posting").
  Future<void> selectAccount(String accountId) async {
    _selectedAccountId = accountId;
    _isLoading = true;
    notifyListeners();

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

    final rows = <OfxImportPreviewRow>[];
    for (var i = 0; i < _transactions.length; i++) {
      final transaction = _transactions[i];
      final suggestedCategoryId = await _importRepository.suggestCategoryFor(
        financialAccountId: accountId,
        description: transaction.description,
      );
      rows.add(
        OfxImportPreviewRow(
          transaction: transaction,
          isDuplicate: duplicateIndexes.contains(i),
          categoryId: suggestedCategoryId,
        ),
      );
    }

    if (_isDisposed) return;
    _rows = rows;
    _isLoading = false;
    _step = OfxImportStep.preview;
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

  /// Posts every selected, categorized row. Deselected, uncategorized, and
  /// unparseable rows were never candidates in the first place (spec:
  /// "Post Accepted Rows as Ordinary Journal Entries").
  Future<void> confirmImport() async {
    final accountId = _selectedAccountId;
    if (accountId == null) return;

    final acceptedRows = <OfxAcceptedRow>[
      for (final row in _rows)
        if (row.selected && row.categoryId != null)
          OfxAcceptedRow(
            transaction: row.transaction,
            categoryId: row.categoryId!,
          ),
    ];

    _isSubmitting = true;
    notifyListeners();

    final result = await _importRepository.postAcceptedRows(
      financialAccountId: accountId,
      rows: acceptedRows,
    );

    if (_isDisposed) return;
    _batchResult = result;
    _isSubmitting = false;
    _step = OfxImportStep.summary;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _accountsSubscription.cancel();
    _categoriesSubscription.cancel();
    super.dispose();
  }
}
