import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../l10n/l10n.dart';

/// deferred-onboarding-first-entry: name the seeded starter account
/// before the guided first Spent/Received and before the recovery phrase.
class FirstAccountNameViewModel extends ChangeNotifier {
  FirstAccountNameViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _accountsSubscription = _ledgerRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      if (_seededAccount == null && accounts.isNotEmpty) {
        _seededAccount = accounts.first;
        _name = accounts.first.name;
      }
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> submit() async {
    final account = _seededAccount;
    final trimmed = _name.trim();
    if (account == null) {
      _errorMessage = localizeVmError(
        const AppFailure(AppErrorCode.validationStillLoading),
      );
      notifyListeners();
      return false;
    }
    if (trimmed.isEmpty) {
      _errorMessage = localizeVmError(
        const AppFailure(AppErrorCode.validationNameRequired),
      );
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ledgerRepository.renameFinancialAccount(
        id: account.id,
        newName: trimmed,
      );
      return true;
    } catch (e) {
      _errorMessage = localizeVmError(
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
