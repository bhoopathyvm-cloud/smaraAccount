import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/home_overview.dart';
import '../../../../domain/models/recurring_template.dart';
import '../../../../domain/models/summary.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _subscription = _ledgerRepository.watchHomeOverview().listen((overview) {
      _overview = overview;
      _isLoading = false;
      notifyListeners();
    });
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final lastOfMonth = DateTime(now.year, now.month + 1, 0);
    _categoryTotalsSubscription = _ledgerRepository
        .watchCategoryTotals(start: firstOfMonth, end: lastOfMonth)
        .listen((totals) {
          _categoryTotals = totals;
          notifyListeners();
        });
    _dueTemplatesSubscription = _ledgerRepository
        .watchDueRecurringTemplates()
        .listen((due) {
          _dueTemplates = due;
          notifyListeners();
        });
    // monthly-category-limits: additive surfacing on this section, if it
    // exists (design.md Decision 2) - just enough of watchCategories to
    // look up a limited Expense category's limit by id.
    _categoriesSubscription = _ledgerRepository.watchCategories().listen((
      categories,
    ) {
      _limitByCategoryId = {
        for (final category in categories)
          if (category.monthlyLimitMinor != null)
            category.id: category.monthlyLimitMinor!,
      };
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<HomeOverview> _subscription;
  late final StreamSubscription<List<CategoryTotal>>
  _categoryTotalsSubscription;
  late final StreamSubscription<List<DueRecurringTemplate>>
  _dueTemplatesSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;

  Map<String, int> _limitByCategoryId = const {};

  /// This calendar month's limit for [categoryId], or null if it has
  /// none set (monthly-category-limits).
  int? monthlyLimitFor(String categoryId) => _limitByCategoryId[categoryId];

  List<DueRecurringTemplate> _dueTemplates = const [];

  /// Due recurring templates (recurring-templates), for a Home "DUE
  /// TODAY" section - recording one is a separate explicit action
  /// ([recordDueTemplate]), never automatic.
  List<DueRecurringTemplate> get dueTemplates => _dueTemplates;

  Future<void> recordDueTemplate(String templateId) {
    return _ledgerRepository.recordDueTemplate(templateId);
  }

  HomeOverview? _overview;
  HomeOverview? get overview => _overview;

  List<CategoryTotal> _categoryTotals = const [];

  /// This calendar month's expense-category totals (home-hub-capture),
  /// highest-spending first.
  List<CategoryTotal> get thisMonthExpenseTotals {
    final totals = _categoryTotals.where((t) => !t.isIncome).toList()
      ..sort((a, b) => b.totalMinor.compareTo(a.totalMinor));
    return totals;
  }

  /// This calendar month's income-category totals (home-hub-capture),
  /// highest-received first.
  List<CategoryTotal> get thisMonthIncomeTotals {
    final totals = _categoryTotals.where((t) => t.isIncome).toList()
      ..sort((a, b) => b.totalMinor.compareTo(a.totalMinor));
    return totals;
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _subscription.cancel();
    _categoryTotalsSubscription.cancel();
    _dueTemplatesSubscription.cancel();
    _categoriesSubscription.cancel();
    super.dispose();
  }
}
