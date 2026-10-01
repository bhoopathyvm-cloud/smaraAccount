import 'package:flutter/foundation.dart';

import '../../../../data/repositories/claim_repository.dart';
import '../../../../domain/models/claim.dart';
import '../../../../domain/models/claim_advance.dart';
import '../../../../domain/models/claim_status.dart';

/// Claimant claims list + balance surface.
class ClaimsListViewModel extends ChangeNotifier {
  ClaimsListViewModel({
    required ClaimRepository claims,
    required String localDeviceId,
    required String companyDisplayName,
  }) : _claims = claims,
       _localDeviceId = localDeviceId,
       companyDisplayName = companyDisplayName;

  final ClaimRepository _claims;
  final String _localDeviceId;
  final String companyDisplayName;

  List<Claim> items = const [];
  List<ClaimAdvance> advances = const [];
  int balanceMinor = 0;
  bool loading = true;
  String? error;

  /// Balance copy: positive → company owes you; negative → you owe company.
  String balanceCopy() {
    if (balanceMinor > 0) {
      return '$companyDisplayName owes you';
    }
    if (balanceMinor < 0) {
      return 'You owe $companyDisplayName';
    }
    return 'Settled with $companyDisplayName';
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _claims.listClaimsForClaimant(_localDeviceId);
      advances = await _claims.listAdvances(_localDeviceId);
      balanceMinor = await _claims.claimantBalanceMinor(_localDeviceId);
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Claim> createDraft() =>
      _claims.createDraft(claimantDeviceId: _localDeviceId);

  static String statusLabel(ClaimStatus status) => switch (status) {
    ClaimStatus.draft => 'Draft',
    ClaimStatus.submitted => 'Submitted',
    ClaimStatus.partlyApproved => 'Partly approved',
    ClaimStatus.approved => 'Approved',
    ClaimStatus.paid => 'Paid',
    ClaimStatus.rejected => 'Rejected',
  };
}
