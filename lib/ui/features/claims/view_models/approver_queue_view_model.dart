import 'package:flutter/foundation.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/claim_repository.dart';
import '../../../../data/repositories/membership_repository.dart';
import '../../../../domain/app_error.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/claim.dart';
import '../../../../domain/models/claim_item_decision.dart';
import '../../../../domain/models/linked_device_role.dart';
import '../../../../l10n/l10n.dart';

/// One claimant balance the Owner/Approver can settle from the review screen.
class ClaimantBalanceRow {
  const ClaimantBalanceRow({
    required this.deviceId,
    required this.displayName,
    required this.balanceMinor,
  });

  final String deviceId;
  final String displayName;
  final int balanceMinor;
}

/// Approver review queue for submitted claims, plus Owner settlement payments.
class ApproverQueueViewModel extends ChangeNotifier {
  ApproverQueueViewModel({
    required ClaimRepository claims,
    required String actorDeviceId,
    MembershipRepository? membership,
    AccountRepository? accounts,
  }) : _claims = claims,
       _actorDeviceId = actorDeviceId,
       _membership = membership,
       _accounts = accounts;

  final ClaimRepository _claims;
  final String _actorDeviceId;
  final MembershipRepository? _membership;
  final AccountRepository? _accounts;

  List<Claim> queue = const [];
  List<ClaimantBalanceRow> balances = const [];
  String? bankAccountId;
  bool loading = true;
  String? error;
  String? lastActionError;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      queue = await _claims.listSubmittedForReview();
      await _loadBalances();
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadBalances() async {
    final membership = _membership;
    final accounts = _accounts;
    if (membership == null || accounts == null) {
      balances = const [];
      bankAccountId = null;
      return;
    }
    final devices = await membership.listActiveDevices();
    final rows = <ClaimantBalanceRow>[];
    for (final d in devices) {
      if (!d.hasRole(LinkedDeviceRole.claimant)) continue;
      final balance = await _claims.claimantBalanceMinor(d.deviceId);
      if (balance == 0) continue;
      rows.add(
        ClaimantBalanceRow(
          deviceId: d.deviceId,
          displayName: d.personDisplayName ?? d.displayName,
          balanceMinor: balance,
        ),
      );
    }
    balances = rows;
    final all = await accounts.watchFinancialAccounts().first;
    bankAccountId = all
        .where((a) => a.type == AccountType.asset && !a.archived)
        .map((a) => a.id)
        .firstOrNull;
  }

  Future<ClaimItemDecision?> approve({
    required String claimItemId,
    int? differentAmountMinor,
    String? reason,
  }) async {
    lastActionError = null;
    try {
      if (differentAmountMinor != null &&
          (reason == null || reason.trim().isEmpty)) {
        lastActionError = englishAppLocalizations.claimsReasonRequired;
        notifyListeners();
        return null;
      }
      final decision = await _claims.approveItem(
        claimItemId: claimItemId,
        actorDeviceId: _actorDeviceId,
        differentAmountMinor: differentAmountMinor,
        reason: reason,
      );
      await load();
      return decision;
    } on AppFailure catch (e) {
      lastActionError = e.debugMessage ?? e.code.name;
      notifyListeners();
      return null;
    }
  }

  Future<ClaimItemDecision?> reject({
    required String claimItemId,
    required String reason,
  }) async {
    lastActionError = null;
    if (reason.trim().isEmpty) {
      lastActionError = englishAppLocalizations.claimsReasonRequired;
      notifyListeners();
      return null;
    }
    try {
      final decision = await _claims.rejectItem(
        claimItemId: claimItemId,
        actorDeviceId: _actorDeviceId,
        reason: reason,
      );
      await load();
      return decision;
    } on AppFailure catch (e) {
      lastActionError = e.debugMessage ?? e.code.name;
      notifyListeners();
      return null;
    }
  }

  /// Pays a positive balance (company → claimant) for [deviceId].
  Future<bool> payBalance({
    required String deviceId,
    required int amountMinor,
  }) async {
    lastActionError = null;
    final bankId = bankAccountId;
    if (bankId == null) {
      lastActionError = 'No bank account';
      notifyListeners();
      return false;
    }
    if (amountMinor <= 0) {
      lastActionError = 'Nothing to pay';
      notifyListeners();
      return false;
    }
    try {
      await _claims.recordPayment(
        actorDeviceId: _actorDeviceId,
        claimantDeviceId: deviceId,
        bankAccountId: bankId,
        amountMinor: amountMinor,
      );
      await load();
      return true;
    } on AppFailure catch (e) {
      lastActionError = e.debugMessage ?? e.code.name;
      notifyListeners();
      return false;
    }
  }
}
