import 'package:flutter/foundation.dart';

import '../../../../data/repositories/claim_repository.dart';
import '../../../../domain/models/claim.dart';
import '../../../../domain/models/claim_advance.dart';
import '../../../../domain/models/claim_status.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Claimant claims list + balance surface.
class ClaimsListViewModel extends ChangeNotifier {
  ClaimsListViewModel({
    required ClaimRepository claims,
    required String localDeviceId,
    required this.companyDisplayName,
  }) : _claims = claims,
       _localDeviceId = localDeviceId;

  final ClaimRepository _claims;
  final String _localDeviceId;
  final String companyDisplayName;

  List<Claim> items = const [];
  List<ClaimAdvance> advances = const [];
  int balanceMinor = 0;
  bool loading = true;
  String? error;

  /// Balance copy: positive → company owes you; negative → you owe company.
  String balanceCopy(AppLocalizations l10n) {
    if (balanceMinor > 0) {
      return l10n.claimsBalanceCompanyOwesYou(companyDisplayName);
    }
    if (balanceMinor < 0) {
      return l10n.claimsBalanceYouOweCompany(companyDisplayName);
    }
    return l10n.claimsBalanceSettled(companyDisplayName);
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

  static String statusLabel(ClaimStatus status, AppLocalizations l10n) =>
      switch (status) {
        ClaimStatus.draft => l10n.claimsStatusDraft,
        ClaimStatus.submitted => l10n.claimsStatusSubmitted,
        ClaimStatus.partlyApproved => l10n.claimsStatusPartlyApproved,
        ClaimStatus.approved => l10n.claimsStatusApproved,
        ClaimStatus.paid => l10n.claimsStatusPaid,
        ClaimStatus.rejected => l10n.claimsStatusRejected,
      };
}
