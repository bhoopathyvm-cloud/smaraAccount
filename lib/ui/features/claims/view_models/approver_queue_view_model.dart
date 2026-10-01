import 'package:flutter/foundation.dart';

import '../../../../data/repositories/claim_repository.dart';
import '../../../../domain/app_error.dart';
import '../../../../domain/models/claim.dart';
import '../../../../domain/models/claim_item_decision.dart';

/// Approver review queue for submitted claims.
class ApproverQueueViewModel extends ChangeNotifier {
  ApproverQueueViewModel({
    required ClaimRepository claims,
    required String actorDeviceId,
  }) : _claims = claims,
       _actorDeviceId = actorDeviceId;

  final ClaimRepository _claims;
  final String _actorDeviceId;

  List<Claim> queue = const [];
  bool loading = true;
  String? error;
  String? lastActionError;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      queue = await _claims.listSubmittedForReview();
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
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
        lastActionError = 'A reason is required for a different amount.';
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
      lastActionError = 'A reason is required to reject.';
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
}
