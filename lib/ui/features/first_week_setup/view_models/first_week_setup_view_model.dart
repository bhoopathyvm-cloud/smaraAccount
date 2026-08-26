import 'package:flutter/foundation.dart';

import '../../../../data/database/tables/account_groups_table.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../l10n/l10n.dart';

/// first-week-setup-wizard: optionally add a credit card and/or cash
/// account, each created via the existing financial-account creation path
/// (design.md Decision 1). **Correction, found during a later review**:
/// this wizard originally also renamed the seeded main account here, but
/// `deferred-onboarding-first-entry`'s guided first-entry flow (routed
/// strictly before this wizard - see `lib/ui/app_router.dart`) already
/// asks the user to name that same seeded account via
/// `FirstAccountNameView`/`FirstAccountNameViewModel`. Asking twice for
/// the one account's name added a redundant screen with no purpose, so
/// naming stays solely in the earlier step and this wizard is scoped to
/// just the optional credit-card and cash-account sub-steps.
class FirstWeekSetupViewModel extends ChangeNotifier with LocalizedErrorMixin {
  FirstWeekSetupViewModel({
    required AccountRepository accountRepository,
    required SettingsRepository settingsRepository,
  }) : _accountRepository = accountRepository,
       _settingsRepository = settingsRepository;

  final AccountRepository _accountRepository;
  final SettingsRepository _settingsRepository;

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

  /// Creates the optional credit card and/or cash account if the user
  /// asked for one and named it, then marks the wizard complete either
  /// way, so it's never shown again (spec: "First-Week Setup Wizard").
  Future<bool> finish() async {
    _isSubmitting = true;
    clearFailure();
    notifyListeners();

    try {
      final cardName = _creditCardName.trim();
      if (_hasCreditCard && cardName.isNotEmpty) {
        await _accountRepository.createFinancialAccount(
          name: cardName,
          type: AccountType.liability,
          groupId: groupCreditShortTermId,
        );
      }

      final cashName = _cashAccountName.trim();
      if (_hasCashAccount && cashName.isNotEmpty) {
        await _accountRepository.createFinancialAccount(
          name: cashName,
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
        );
      }
    } catch (e) {
      setFailure(
        const AppFailure(AppErrorCode.validationSaveAccountNameFailed),
      );
      _isSubmitting = false;
      notifyListeners();
      return false;
    }

    await _settingsRepository.setFirstWeekSetupCompleted(true);

    _isSubmitting = false;
    notifyListeners();
    return true;
  }
}
