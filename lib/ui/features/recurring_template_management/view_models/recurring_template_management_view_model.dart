import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';
import '../../../../domain/models/recurring_template.dart';
import '../../../../domain/models/transaction_direction.dart';

/// Add/edit/delete for recurring templates (recurring-templates tasks.md
/// 11.2). Editing an existing template posts nothing itself - recording a
/// due one is a separate, explicit action ([LedgerRepository.recordDueTemplate]
/// via [HomeViewModel]).
class RecurringTemplateManagementViewModel extends ChangeNotifier {
  RecurringTemplateManagementViewModel({
    required LedgerRepository ledgerRepository,
  }) : _ledgerRepository = ledgerRepository {
    _templatesSubscription = _ledgerRepository.watchRecurringTemplates().listen(
      (templates) {
        _templates = templates;
        notifyListeners();
      },
    );
    _accountsSubscription = _ledgerRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _financialAccounts = accounts;
      notifyListeners();
    });
    _groupsSubscription = _ledgerRepository
        .watchAccountGroups(includeArchived: true)
        .listen((groups) {
          _groups = groups;
          notifyListeners();
        });
    _categoriesSubscription = _ledgerRepository.watchCategories().listen((
      categories,
    ) {
      _categories = categories;
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<RecurringTemplate>> _templatesSubscription;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<AccountGroup>> _groupsSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;

  List<RecurringTemplate> _templates = const [];
  List<RecurringTemplate> get templates => _templates;

  List<Account> _financialAccounts = const [];
  List<Account> get financialAccounts => _financialAccounts;

  List<AccountGroup> _groups = const [];

  List<Account> _categories = const [];

  /// Active categories matching [direction] (income for money-in, expense
  /// for money-out) - same filtering `RecordTransactionViewModel.categories`
  /// already applies.
  List<Account> categoriesFor(TransactionDirection direction) {
    final categoryType = direction == TransactionDirection.moneyIn
        ? AccountType.income
        : AccountType.expense;
    return _categories.where((a) => a.type == categoryType).toList();
  }

  /// The ISO 4217 currency of [accountId]'s group, for the amount field.
  String? currencyFor(String? accountId) {
    final account = _financialAccounts
        .where((a) => a.id == accountId)
        .cast<Account?>()
        .firstWhere((a) => a != null, orElse: () => null);
    if (account?.groupId == null) return null;
    return _groups
        .where((g) => g.id == account!.groupId)
        .cast<AccountGroup?>()
        .firstWhere((g) => g != null, orElse: () => null)
        ?.currency;
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> createTemplate({
    required String name,
    required TransactionDirection direction,
    required String financialAccountId,
    required String categoryId,
    required int amountMinor,
    required int dayOfMonth,
  }) => _save(
    () => _ledgerRepository.createRecurringTemplate(
      name: name,
      direction: direction,
      financialAccountId: financialAccountId,
      categoryId: categoryId,
      amountMinor: amountMinor,
      dayOfMonth: dayOfMonth,
    ),
  );

  Future<bool> updateTemplate({
    required String id,
    required String name,
    required TransactionDirection direction,
    required String financialAccountId,
    required String categoryId,
    required int amountMinor,
    required int dayOfMonth,
  }) => _save(
    () => _ledgerRepository.updateRecurringTemplate(
      id: id,
      name: name,
      direction: direction,
      financialAccountId: financialAccountId,
      categoryId: categoryId,
      amountMinor: amountMinor,
      dayOfMonth: dayOfMonth,
    ),
  );

  Future<bool> _save(Future<void> Function() action) async {
    try {
      await action();
      _errorMessage = null;
      notifyListeners();
      return true;
    } on InvalidTransactionAmountException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on ArgumentError catch (e) {
      _errorMessage = e.message?.toString() ?? 'Invalid template.';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTemplate(String id) =>
      _ledgerRepository.deleteRecurringTemplate(id);

  @override
  void dispose() {
    _templatesSubscription.cancel();
    _accountsSubscription.cancel();
    _groupsSubscription.cancel();
    _categoriesSubscription.cancel();
    super.dispose();
  }
}
