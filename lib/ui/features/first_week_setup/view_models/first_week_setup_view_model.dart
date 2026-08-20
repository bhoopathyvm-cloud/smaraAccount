import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/database/tables/account_groups_table.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../l10n/l10n.dart';

/// first-week-setup-wizard: a guided sequence over account creation the
/// app already supports (design.md Decision 1) - **correction, found
/// during implementation**: design.md's Context claimed no financial
/// account is auto-seeded, but `LedgerRepository.confirmFirstIdentity`
/// does seed one asset account named [financialAccountName] into
/// [groupCashEquivalentsId]. So the "main account" step here renames
/// that already-existing seeded account (found via [watchFinancialAccounts])
/// rather than creating a second one; the optional credit-card and cash
/// steps are unaffected and still call `createFinancialAccount` for real,
/// since nothing is seeded in those groups.
class FirstWeekSetupViewModel extends ChangeNotifier {
  FirstWeekSetupViewModel({
    required LedgerRepository ledgerRepository,
    required SettingsRepository settingsRepository,
  }) : _ledgerRepository = ledgerRepository,
       _settingsRepository = settingsRepository {
    _accountsSubscription = _ledgerRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      if (_seededMainAccount == null && accounts.isNotEmpty) {
        _seededMainAccount = accounts.first;
        _mainAccountName = accounts.first.name;
      }
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  final SettingsRepository _settingsRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;

  Account? _seededMainAccount;
  bool get isLoading => _seededMainAccount == null;

  String _mainAccountName = '';
  String get mainAccountName => _mainAccountName;
  void setMainAccountName(String value) {
    _mainAccountName = value;
    notifyListeners();
  }

  bool _hasCreditCard = false;
  bool get hasCreditCard => _hasCreditCard;
  void setHasCreditCard(bool value) {
    _hasCreditCard = value;
    notifyListeners();
  }

  String _creditCardName = '';
  String get creditCardName => _creditCardName;
  void setCreditCardName(String value) {
    _creditCardName = value;
    notifyListeners();
  }

  bool _hasCashAccount = false;
  bool get hasCashAccount => _hasCashAccount;
  void setHasCashAccount(bool value) {
    _hasCashAccount = value;
    notifyListeners();
  }

  String _cashAccountName = '';
  String get cashAccountName => _cashAccountName;
  void setCashAccountName(String value) {
    _cashAccountName = value;
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Renames the seeded main account to [mainAccountName] (required), then
  /// creates the optional credit card and/or cash account if the user
  /// asked for one and named it. Marks the wizard complete either way, so
  /// it's never shown again (spec: "First-Week Setup Wizard").
  Future<bool> finish() async {
    final mainAccount = _seededMainAccount;
    final name = _mainAccountName.trim();
    if (mainAccount == null) {
      _errorMessage = localizeVmError(
        const AppFailure(AppErrorCode.validationStillLoading),
      );
      notifyListeners();
      return false;
    }
    if (name.isEmpty) {
      _errorMessage = localizeVmError(
        const AppFailure(AppErrorCode.validationNameRequired),
      );
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    await _ledgerRepository.renameFinancialAccount(
      id: mainAccount.id,
      newName: name,
    );

    final cardName = _creditCardName.trim();
    if (_hasCreditCard && cardName.isNotEmpty) {
      await _ledgerRepository.createFinancialAccount(
        name: cardName,
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
      );
    }

    final cashName = _cashAccountName.trim();
    if (_hasCashAccount && cashName.isNotEmpty) {
      await _ledgerRepository.createFinancialAccount(
        name: cashName,
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      );
    }

    await _settingsRepository.setFirstWeekSetupCompleted(true);

    _isSubmitting = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _accountsSubscription.cancel();
    super.dispose();
  }
}
