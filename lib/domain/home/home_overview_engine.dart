import '../models/account.dart';
import '../models/account_group.dart';
import '../models/home_overview.dart';
import '../models/instrument_holding.dart';
import '../models/pending_transfer.dart';
import '../register/display_balance.dart';

/// Cash + inventory portfolio totals for an investment account.
({int portfolioMinor, int bookMinor}) investmentPortfolioTotals({
  required int cashMinor,
  required Iterable<InstrumentHolding> holdings,
}) {
  var marketInventory = 0;
  var bookInventory = 0;
  for (final holding in holdings) {
    marketInventory += holding.displayMarketValueMinor;
    bookInventory += holding.totalCostMinor;
  }
  return (
    portfolioMinor: cashMinor + marketInventory,
    bookMinor: cashMinor + bookInventory,
  );
}

/// Pending transfer already mapped from storage, with whether its
/// provisional amount should inflate the source currency's assets.
class HomeOverviewPendingInput {
  const HomeOverviewPendingInput({
    required this.pendingTransfer,
    required this.sourceAccountName,
    required this.currency,
    required this.amountMinor,
    required this.countsTowardNetPosition,
    this.destinationLabel,
  });

  final PendingTransfer pendingTransfer;
  final String sourceAccountName;
  final String? destinationLabel;
  final String currency;
  final int amountMinor;
  final bool countsTowardNetPosition;
}

/// Assembles [HomeOverview] from chart + raw posting sums + optional
/// investment portfolio totals + pending inputs. Pure: no Drift I/O.
HomeOverview buildHomeOverview({
  required List<AccountGroup> groups,
  required List<Account> accounts,
  required Map<String, int> rawSumByAccount,
  required Map<String, ({int portfolioMinor, int bookMinor})>
  investmentPortfolios,
  required List<HomeOverviewPendingInput> pending,
}) {
  final assetsByCurrency = <String, int>{};
  final liabilitiesByCurrency = <String, int>{};
  final sections = <AccountGroupSection>[];

  for (final group in groups) {
    final members = accounts.where((a) => a.groupId == group.id).toList()
      ..sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        return byOrder != 0 ? byOrder : a.name.compareTo(b.name);
      });
    if (members.isEmpty) continue;

    final currency = group.currency;
    final balances = <AccountBalance>[];
    var groupTotal = 0;
    for (final account in members) {
      final cashOrOwed = displayBalanceDeltaFor(
        accountType: account.type,
        postingAmountMinor: rawSumByAccount[account.id] ?? 0,
      );
      var display = cashOrOwed;
      int? bookValueMinor;
      var isMarketEstimate = false;
      final portfolio = investmentPortfolios[account.id];
      if (account.isInvestmentAccount && portfolio != null) {
        display = portfolio.portfolioMinor;
        bookValueMinor = portfolio.bookMinor;
        isMarketEstimate = true;
      }
      balances.add(
        AccountBalance(
          account: account,
          displayBalanceMinor: display,
          bookValueMinor: bookValueMinor,
          isMarketEstimate: isMarketEstimate,
        ),
      );
      groupTotal += display;
      if (currency != null) {
        if (account.type == AccountType.asset) {
          assetsByCurrency[currency] =
              (assetsByCurrency[currency] ?? 0) + display;
        } else if (account.type == AccountType.liability) {
          liabilitiesByCurrency[currency] =
              (liabilitiesByCurrency[currency] ?? 0) + display;
        }
      }
    }
    sections.add(
      AccountGroupSection(
        group: group,
        accounts: balances,
        totalDisplayBalanceMinor: groupTotal,
      ),
    );
  }

  final pendingSummaries = <PendingTransferSummary>[];
  for (final input in pending) {
    pendingSummaries.add(
      PendingTransferSummary(
        pendingTransfer: input.pendingTransfer,
        sourceAccountName: input.sourceAccountName,
        destinationLabel: input.destinationLabel,
        currency: input.currency,
        amountMinor: input.amountMinor,
      ),
    );
    if (input.countsTowardNetPosition) {
      assetsByCurrency[input.currency] =
          (assetsByCurrency[input.currency] ?? 0) + input.amountMinor;
    }
  }

  final currencies = {
    ...assetsByCurrency.keys,
    ...liabilitiesByCurrency.keys,
  }.toList()..sort();
  final netPositions = currencies
      .map(
        (currency) => CurrencyNetPosition(
          currency: currency,
          totalAssetsMinor: assetsByCurrency[currency] ?? 0,
          totalLiabilitiesMinor: liabilitiesByCurrency[currency] ?? 0,
        ),
      )
      .toList();

  return HomeOverview(
    sections: sections,
    netPositionsByCurrency: netPositions,
    pendingTransfers: pendingSummaries,
  );
}
