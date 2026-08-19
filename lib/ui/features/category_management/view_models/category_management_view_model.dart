import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/summary.dart';

/// Rename/add/archive actions for Income/Expense categories. Always
/// watches all categories, including archived ones, so the management
/// screen can show both (Archive a category requirement: archived
/// categories stay visible, just excluded from new-transaction pickers).
///
/// Also the primary, always-available home for monthly-category-limits'
/// month-to-date spent-vs-limit progress (design.md Decision 2).
class CategoryManagementViewModel extends ChangeNotifier {
  CategoryManagementViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _subscription = _ledgerRepository
        .watchCategories(includeArchived: true)
        .listen(_onCategories);
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final lastOfMonth = DateTime(now.year, now.month + 1, 0);
    _categoryTotalsSubscription = _ledgerRepository
        .watchCategoryTotals(start: firstOfMonth, end: lastOfMonth)
        .listen((totals) {
          _spentByCategoryId = {
            for (final total in totals) total.categoryId: total.totalMinor,
          };
          notifyListeners();
        });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _subscription;
  late final StreamSubscription<List<CategoryTotal>>
  _categoryTotalsSubscription;

  List<Account> _categories = const [];
  List<Account> get categories => _categories;

  Map<String, int> _spentByCategoryId = const {};

  /// This calendar month's spend against [categoryId], or 0 if none yet.
  int monthToDateSpentFor(String categoryId) =>
      _spentByCategoryId[categoryId] ?? 0;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _onCategories(List<Account> categories) {
    _categories = categories;
    notifyListeners();
  }

  Future<void> addCategory({
    required String name,
    required AccountType type,
  }) async {
    try {
      await _ledgerRepository.addCategory(name: name, type: type);
      _errorMessage = null;
    } on ArgumentError {
      _errorMessage = 'Category must be Income or Expense.';
    }
    notifyListeners();
  }

  Future<void> renameCategory({required String id, required String newName}) {
    return _ledgerRepository.renameCategory(id: id, newName: newName);
  }

  Future<void> archiveCategory(String id) =>
      _ledgerRepository.archiveCategory(id);

  Future<void> unarchiveCategory(String id) =>
      _ledgerRepository.unarchiveCategory(id);

  /// Sets or clears (`monthlyLimitMinor: null`) a category's monthly
  /// limit. Returns whether it succeeded; a failure (wrong category type,
  /// non-positive amount) surfaces via [errorMessage].
  Future<bool> setCategoryMonthlyLimit({
    required String id,
    required int? monthlyLimitMinor,
  }) async {
    try {
      await _ledgerRepository.setCategoryMonthlyLimit(
        id: id,
        monthlyLimitMinor: monthlyLimitMinor,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } on InvalidTransactionAmountException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on ArgumentError {
      _errorMessage = 'Only an Expense category can have a monthly limit.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _categoryTotalsSubscription.cancel();
    super.dispose();
  }
}
