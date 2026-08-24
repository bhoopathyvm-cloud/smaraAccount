import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';

class AccountManagementViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  AccountManagementViewModel({required AccountRepository accountRepository})
    : _accountRepository = accountRepository {
    _accountsSubscription = _accountRepository
        .watchFinancialAccounts(includeArchived: true)
        .listen((accounts) {
          _accounts = accounts;
          notifyListeners();
        });
    _groupsSubscription = _accountRepository
        .watchAccountGroups(includeArchived: true)
        .listen((groups) {
          _groups = groups;
          notifyListeners();
        });
  }

  final AccountRepository _accountRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<AccountGroup>> _groupsSubscription;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  List<AccountGroup> _groups = const [];
  List<AccountGroup> get groups => _groups;

  void clearError() => clearFailure();

  Future<bool> createAccount({
    required String name,
    required AccountType type,
    required String groupId,
    int? openingBalanceMinor,
    bool isCreditCard = false,
    bool holdsInvestments = false,
  }) {
    return _run(() async {
      await _accountRepository.createFinancialAccount(
        name: name,
        type: type,
        groupId: groupId,
        openingBalanceMinor: openingBalanceMinor,
        isCreditCard: isCreditCard,
        holdsInvestments: holdsInvestments,
      );
    });
  }

  Future<bool> renameAccount({required String id, required String newName}) {
    return _run(
      () => _accountRepository.renameFinancialAccount(id: id, newName: newName),
    );
  }

  Future<bool> archiveAccount(String id) {
    return _run(() => _accountRepository.archiveFinancialAccount(id));
  }

  Future<bool> unarchiveAccount(String id) {
    return _run(() => _accountRepository.unarchiveFinancialAccount(id));
  }

  Future<bool> reassignAccountGroup({
    required String id,
    required String groupId,
  }) {
    return _run(
      () => _accountRepository.reassignFinancialAccountGroup(
        id: id,
        groupId: groupId,
      ),
    );
  }

  Future<bool> renameGroup({required String id, required String newName}) {
    return _run(
      () => _accountRepository.renameAccountGroup(id: id, newName: newName),
    );
  }

  Future<bool> changeGroupCurrency({
    required String id,
    required String currency,
  }) {
    return _run(
      () => _accountRepository.changeAccountGroupCurrency(
        groupId: id,
        currency: currency,
      ),
    );
  }

  Future<bool> createGroup({
    required String name,
    required AccountGroupKind kind,
    required String currency,
  }) {
    return _run(
      () => _accountRepository.createAccountGroup(
        name: name,
        kind: kind,
        currency: currency,
      ),
    );
  }

  Future<bool> archiveGroup(String id) {
    return _run(() => _accountRepository.archiveAccountGroup(id));
  }

  Future<bool> unarchiveGroup(String id) {
    return _run(() => _accountRepository.unarchiveAccountGroup(id));
  }

  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      clearFailure();
      return true;
    } on LastActiveAccountException catch (error) {
      setFailure(error);
    } on AccountGroupException catch (error) {
      setFailure(error);
    } on InvalidOpeningBalanceException catch (error) {
      setFailure(error);
    }
    return false;
  }

  @override
  void dispose() {
    _accountsSubscription.cancel();
    _groupsSubscription.cancel();
    super.dispose();
  }
}
