/// Effective spending-limit hint for claims (personal → company → none).
class ClaimLimitHint {
  const ClaimLimitHint({
    required this.amountMinor,
    this.unitLabel,
    required this.source,
  });

  final int amountMinor;
  final String? unitLabel;

  /// `personal`, `company`, or unused when null returned from lookup.
  final String source;
}

/// Shared lookup for Claimant and Approver screens (task 6.2).
ClaimLimitHint? resolveClaimLimitHint({
  required int? personalAmountMinor,
  required String? personalUnitLabel,
  required int? companyAmountMinor,
  required String? companyUnitLabel,
}) {
  if (personalAmountMinor != null) {
    return ClaimLimitHint(
      amountMinor: personalAmountMinor,
      unitLabel: personalUnitLabel,
      source: 'personal',
    );
  }
  if (companyAmountMinor != null) {
    return ClaimLimitHint(
      amountMinor: companyAmountMinor,
      unitLabel: companyUnitLabel,
      source: 'company',
    );
  }
  return null;
}

bool isAboveClaimLimit({
  required int amountMinor,
  required ClaimLimitHint? hint,
}) {
  if (hint == null) return false;
  return amountMinor > hint.amountMinor;
}
