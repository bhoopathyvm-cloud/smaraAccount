import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/recurring_template_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_currency_catalog.dart';
import '../../../../domain/models/recurring_template.dart';
import '../../../../domain/models/transaction_direction.dart';

/// Add/edit/delete for recurring templates (recurring-templates tasks.md
/// 11.2). Editing an existing template posts nothing itself - recording a
/// due one is a separate, explicit action ([LedgerRepository.recordDueTemplate]
/// via [HomeViewModel]).
class RecurringTemplateManagementViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  RecurringTemplateManagementViewModel({
    required RecurringTemplateRepository recurringTemplateRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
  }) : _recurringTemplateRepository = recurringTemplateRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository {
    _templatesSubscription = _recurringTemplateRepository
        .watchRecurringTemplates()
        .listen((templates) {
          _templates = templates;
          notifyListeners();
        });
    _accountsSubscription = _accountRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _financialAccounts = accounts;
      notifyListeners();
    });
    _currenciesSubscription = _accountRepository
        .watchAccountCurrencies(includeArchived: true)
        .listen((catalog) {
          _currencies = catalog;
          notifyListeners();
        });
    _categoriesSubscription = _categoryRepository.watchCategories().listen((
      categories,
    ) {
      _categories = categories;
      notifyListeners();
    });
  }

  final RecurringTemplateRepository _recurringTemplateRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  late final StreamSubscription<List<RecurringTemplate>> _templatesSubscription;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<AccountCurrencyCatalog> _currenciesSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;

  List<RecurringTemplate> _templates = const [];
  List<RecurringTemplate> get templates => _templates;

  List<Account> _financialAccounts = const [];
  List<Account> get financialAccounts => _financialAccounts;

  AccountCurrencyCatalog _currencies = AccountCurrencyCatalog.empty;

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
  String? currencyFor(String? accountId) => _currencies.currencyFor(accountId);

  void clearError() => clearFailure();

  Future<bool> createTemplate({
    required String name,
    required TransactionDirection direction,
    required String financialAccountId,
    required String categoryId,
    required int amountMinor,
    required int dayOfMonth,
  }) => _save(
    () => _recurringTemplateRepository.createRecurringTemplate(
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
    () => _recurringTemplateRepository.updateRecurringTemplate(
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
      clearFailure();
      return true;
    } on InvalidTransactionAmountException catch (e) {
      setFailure(e);
      return false;
    } on ArgumentError {
      setFailure(const AppFailure(AppErrorCode.validationInvalidTemplate));
      return false;
    }
  }

  Future<void> deleteTemplate(String id) =>
      _recurringTemplateRepository.deleteRecurringTemplate(id);

  @override
  void dispose() {
    _templatesSubscription.cancel();
    _accountsSubscription.cancel();
    _currenciesSubscription.cancel();
    _categoriesSubscription.cancel();
    super.dispose();
  }
}
