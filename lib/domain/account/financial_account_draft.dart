import '../models/account.dart';
import '../models/account_group.dart';

/// Mutable create-financial-account form state: asset/liability type, the
/// target group, an optional opening balance, and the two create-time-only
/// flags (credit card for liabilities, holds-investments for assets).
///
/// Owns the field coupling - switching type clears the group and the flag
/// that no longer applies, and the selection is kept valid as the caller's
/// type-filtered group list changes. The group list itself comes from
/// `AccountManagementViewModel.groupsAvailableForType` (the existing
/// account/group type-filter seam), so this module never re-implements that
/// rule and never touches Drift, a Repository, or Flutter.
class FinancialAccountDraft {
  FinancialAccountDraft({this.type = AccountType.asset});

  AccountType type;
  String? groupId;
  int? openingBalanceMinor;
  bool isCreditCard = false;
  bool holdsInvestments = false;

  /// Whether a target group is selected - the create dialog's submit gate.
  /// The account name is validated separately at submit time.
  bool get hasSelectedGroup => groupId != null;

  /// ISO currency of the selected group within [groupsForType], or null
  /// when no group is selected or it has no currency set. Drives the
  /// opening-balance field's minor-unit formatting.
  String? selectedGroupCurrency(List<AccountGroup> groupsForType) {
    for (final group in groupsForType) {
      if (group.id == groupId && group.currency != null) {
        return group.currency;
      }
    }
    return null;
  }

  /// Keep [groupId] valid within [groupsForType]: default to the first
  /// entry, or null when it is empty, whenever the current selection is no
  /// longer present. Idempotent - safe to call on every rebuild.
  void ensureValidGroupSelection(List<AccountGroup> groupsForType) {
    if (!groupsForType.any((group) => group.id == groupId)) {
      groupId = groupsForType.isEmpty ? null : groupsForType.first.id;
    }
  }

  /// Switch asset/liability [type], clearing the group selection and the
  /// flag that no longer applies: holds-investments is asset-only and
  /// credit-card is liability-only, each set once at creation.
  void setType(AccountType value) {
    if (type == value) return;
    type = value;
    groupId = null;
    if (type != AccountType.liability) isCreditCard = false;
    if (type != AccountType.asset) holdsInvestments = false;
  }
}
