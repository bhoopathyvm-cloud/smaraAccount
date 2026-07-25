import 'account.dart';
import 'account_group.dart';
import 'pending_transfer.dart';

/// One financial account plus its current display balance for Home / pickers.
class AccountBalance {
  const AccountBalance({
    required this.account,
    required this.displayBalanceMinor,
  });

  final Account account;

  /// Asset: funds held. Liability: amount owed. Always the UI-facing figure.
  final int displayBalanceMinor;
}

/// One account group section on the home overview. [group.currency] labels
/// [totalDisplayBalanceMinor] and every member's balance.
class AccountGroupSection {
  const AccountGroupSection({
    required this.group,
    required this.accounts,
    required this.totalDisplayBalanceMinor,
  });

  final AccountGroup group;
  final List<AccountBalance> accounts;
  final int totalDisplayBalanceMinor;
}

/// Net position for a single currency (multi-currency-support design.md
/// Decision 2) - never combined or converted with any other currency's.
class CurrencyNetPosition {
  const CurrencyNetPosition({
    required this.currency,
    required this.totalAssetsMinor,
    required this.totalLiabilitiesMinor,
  });

  final String currency;
  final int totalAssetsMinor;
  final int totalLiabilitiesMinor;

  int get netPositionMinor => totalAssetsMinor - totalLiabilitiesMinor;
}

/// One line item in the Home overview's "Pending transfers" section
/// (multi-currency-support design.md Decision 4) - a transfer or
/// foreign-currency transaction whose settlement is still outstanding.
class PendingTransferSummary {
  const PendingTransferSummary({
    required this.pendingTransfer,
    required this.sourceAccountName,
    required this.currency,
    required this.amountMinor,
    this.destinationLabel,
  });

  final PendingTransfer pendingTransfer;
  final String sourceAccountName;

  /// The planned destination account's name (a transfer), or the
  /// category's name (a foreign-currency transaction), whichever applies -
  /// null only if the referenced account/category can't be resolved.
  final String? destinationLabel;

  /// The source currency - what the provisional entry was posted in.
  final String currency;

  /// Always positive; the provisional amount awaiting settlement.
  final int amountMinor;
}

/// Home overview snapshot: group sections, one net position per currency,
/// and unsettled pending transfers.
class HomeOverview {
  const HomeOverview({
    required this.sections,
    required this.netPositionsByCurrency,
    required this.pendingTransfers,
  });

  /// Only groups that have at least one member financial account.
  final List<AccountGroupSection> sections;

  /// One entry per currency present - never a single blended figure
  /// (multi-currency-support design.md Decision 2).
  final List<CurrencyNetPosition> netPositionsByCurrency;

  /// Every unsettled pending transfer/transaction, oldest first.
  final List<PendingTransferSummary> pendingTransfers;
}
