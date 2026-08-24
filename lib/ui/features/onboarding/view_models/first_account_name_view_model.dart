import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../l10n/l10n.dart';

/// deferred-onboarding-first-entry: name the seeded starter account
/// before the guided first Spent/Received and before the recovery phrase.
class FirstAccountNameViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  FirstAccountNameViewModel({required AccountRepository accountRepository})
    : _accountRepository = accountRepository {
    _accountsSubscription = _accountRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      if (_seededAccount == null && accounts.isNotEmpty) {
        _seededAccount = accounts.first;
        _name = accounts.first.name;
      }
      notifyListeners();
    });
  }

  final AccountRepository _accountRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;

  Account? _seededAccount;
  bool get isLoading => _seededAccount == null;

  String _name = '';
  String get name => _name;
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> submit() async {
    final account = _seededAccount;
    final trimmed = _name.trim();
    if (account == null) {
      setFailure(const AppFailure(AppErrorCode.validationStillLoading));
      return false;
    }
    if (trimmed.isEmpty) {
      setFailure(const AppFailure(AppErrorCode.validationNameRequired));
      return false;
    }

    _isSubmitting = true;
    clearFailure();
    notifyListeners();

    try {
      await _accountRepository.renameFinancialAccount(
        id: account.id,
        newName: trimmed,
      );
      return true;
    } catch (e) {
      setFailure(
        const AppFailure(AppErrorCode.validationSaveAccountNameFailed),
      );
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _accountsSubscription.cancel();
    super.dispose();
  }
}
