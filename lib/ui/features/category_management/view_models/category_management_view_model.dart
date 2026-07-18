import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/account.dart';

/// Rename/add/archive actions for Income/Expense categories. Always
/// watches all categories, including archived ones, so the management
/// screen can show both (Archive a category requirement: archived
/// categories stay visible, just excluded from new-transaction pickers).
class CategoryManagementViewModel extends ChangeNotifier {
  CategoryManagementViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _subscription = _ledgerRepository
        .watchCategories(includeArchived: true)
        .listen(_onCategories);
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _subscription;

  List<Account> _categories = const [];
  List<Account> get categories => _categories;

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

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
