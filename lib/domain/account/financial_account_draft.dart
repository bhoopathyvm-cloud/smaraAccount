import '../models/account.dart';
import '../models/account_group.dart';

/// Mutable create-financial-account form state: asset/liability type, the
/// target group, an optional opening balance, and the two create-time-only
/// flags (credit card for liabilities, holds-investments for assets).
///
/// Exposes the groups valid for the current [type], the selected group's
/// currency, and keeps [groupId] pointing at a still-valid group as the
/// type changes. Group snapshots are supplied by the dialog/ViewModel;
/// this module never touches Drift, a Repository, or Flutter.
class FinancialAccountDraft {
  FinancialAccountDraft({this.type = AccountType.asset});

  /// Live snapshot of every group (asset and liability, archived or not),
  /// refreshed by the dialog from the ViewModel on each rebuild.
  List<AccountGroup> groups = const [];

  AccountType type;
  String? groupId;
  int? openingBalanceMinor;
  bool isCreditCard = false;
  bool holdsInvestments = false;

  /// Active groups whose kind matches the current [type] (asset groups for
  /// an asset account, liability groups for a liability account).
  List<AccountGroup> get groupsForType {
    final kind = type == AccountType.asset
        ? AccountGroupKind.assetGroup
        : AccountGroupKind.liabilityGroup;
    return groups
        .where((group) => group.kind == kind && !group.archived)
        .toList();
  }

  /// ISO currency of the selected group, or null when no group is selected
  /// or the selected group has no currency set. Drives the opening-balance
  /// field's minor-unit formatting.
  String? get selectedGroupCurrency {
    for (final group in groupsForType) {
      if (group.id == groupId && group.currency != null) {
        return group.currency;
      }
    }
    return null;
  }

  /// Whether a target group is selected - the create dialog's submit gate.
  /// The account name is validated separately at submit time.
  bool get hasSelectedGroup => groupId != null;

  /// Keep [groupId] valid for the current [type]: default to the first
  /// group of that kind, or null when none exist, whenever the current
  /// selection is no longer in that list. Idempotent - safe to call on
  /// every rebuild.
  void ensureValidGroupSelection() {
    final available = groupsForType;
    if (!available.any((group) => group.id == groupId)) {
      groupId = available.isEmpty ? null : available.first.id;
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
