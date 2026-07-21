import 'account.dart';
import 'account_group.dart';

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

/// One account group section on the home overview.
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

/// Home overview snapshot: group sections + overall net position.
class HomeOverview {
  const HomeOverview({
    required this.sections,
    required this.netPositionMinor,
    required this.totalAssetsMinor,
    required this.totalLiabilitiesMinor,
  });

  /// Only groups that have at least one member financial account.
  final List<AccountGroupSection> sections;

  /// Total assets − total liabilities (amounts owed).
  final int netPositionMinor;
  final int totalAssetsMinor;
  final int totalLiabilitiesMinor;
}
