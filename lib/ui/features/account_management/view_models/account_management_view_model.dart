import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';

class AccountManagementViewModel extends ChangeNotifier {
  AccountManagementViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _accountsSubscription = _ledgerRepository
        .watchFinancialAccounts(includeArchived: true)
        .listen((accounts) {
          _accounts = accounts;
          notifyListeners();
        });
    _groupsSubscription = _ledgerRepository.watchAccountGroups().listen((
      groups,
    ) {
      _groups = groups;
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<AccountGroup>> _groupsSubscription;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  List<AccountGroup> _groups = const [];
  List<AccountGroup> get groups => _groups;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> createAccount({
    required String name,
    required AccountType type,
    required String groupId,
    int? openingBalanceMinor,
  }) {
    return _run(() async {
      await _ledgerRepository.createFinancialAccount(
        name: name,
        type: type,
        groupId: groupId,
        openingBalanceMinor: openingBalanceMinor,
      );
    });
  }

  Future<bool> renameAccount({required String id, required String newName}) {
    return _run(
      () => _ledgerRepository.renameFinancialAccount(id: id, newName: newName),
    );
  }

  Future<bool> archiveAccount(String id) {
    return _run(() => _ledgerRepository.archiveFinancialAccount(id));
  }

  Future<bool> reassignAccountGroup({
    required String id,
    required String groupId,
  }) {
    return _run(
      () => _ledgerRepository.reassignFinancialAccountGroup(
        id: id,
        groupId: groupId,
      ),
    );
  }

  Future<bool> renameGroup({required String id, required String newName}) {
    return _run(
      () => _ledgerRepository.renameAccountGroup(id: id, newName: newName),
    );
  }

  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      _errorMessage = null;
      notifyListeners();
      return true;
    } on LastActiveAccountException catch (error) {
      _errorMessage = error.message;
    } on AccountGroupException catch (error) {
      _errorMessage = error.message;
    } on InvalidOpeningBalanceException catch (error) {
      _errorMessage = error.message;
    }
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _accountsSubscription.cancel();
    _groupsSubscription.cancel();
    super.dispose();
  }
}
