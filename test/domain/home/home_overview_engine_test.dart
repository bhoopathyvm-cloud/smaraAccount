import 'package:test/test.dart';

import 'package:smara_accounting/domain/home/home_overview_engine.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/domain/models/instrument.dart';
import 'package:smara_accounting/domain/models/instrument_holding.dart';
import 'package:smara_accounting/domain/models/instrument_quote.dart';
import 'package:smara_accounting/domain/models/pending_transfer.dart';

void main() {
  group('investmentPortfolioTotals', () {
    test('sums cash with market and book inventory', () {
      final holdings = [
        InstrumentHolding(
          instrument: const Instrument(
            id: 'i1',
            name: 'A',
            kind: InstrumentKind.stock,
            archived: false,
          ),
          quantityScaled: 10000,
          averageCostMinor: 100,
          totalCostMinor: 100,
          sellableQuantityScaled: 10000,
          marketValueMinor: 150,
          unrealizedGainLossMinor: 50,
          quoteUse: QuoteUse.live,
        ),
      ];
      final totals = investmentPortfolioTotals(
        cashMinor: 50,
        holdings: holdings,
      );
      expect(totals.bookMinor, 150);
      expect(totals.portfolioMinor, 200);
    });
  });

  group('buildHomeOverview', () {
    final checking = const Account(
      id: 'a1',
      name: 'Checking',
      type: AccountType.asset,
      archived: false,
      groupId: 'g1',
    );
    final group = const AccountGroup(
      id: 'g1',
      name: 'USD',
      kind: AccountGroupKind.assetGroup,
      sortOrder: 0,
      isSystem: true,
      currency: 'USD',
      archived: false,
    );

    test('quarantined pending is listed but excluded from net assets', () {
      final pending = PendingTransfer(
        id: 'p1',
        kind: PendingTransferKind.transfer,
        sourceAccountId: 'a1',
        currency: 'USD',
        provisionalEntryId: 'e1',
        status: PendingTransferStatus.pending,
        initiatedAt: DateTime(2026, 1, 1),
        destinationAccountId: 'a2',
      );
      final overview = buildHomeOverview(
        groups: [group],
        accounts: [checking],
        rawSumByAccount: {'a1': 1000},
        investmentPortfolios: const {},
        pending: [
          HomeOverviewPendingInput(
            pendingTransfer: pending,
            sourceAccountName: 'Checking',
            currency: 'USD',
            amountMinor: 500,
            countsTowardNetPosition: false,
            destinationLabel: 'Other',
          ),
        ],
      );
      expect(overview.pendingTransfers, hasLength(1));
      expect(overview.netPositionsByCurrency.single.totalAssetsMinor, 1000);
    });

    test('active pending adds to net assets', () {
      final pending = PendingTransfer(
        id: 'p1',
        kind: PendingTransferKind.transfer,
        sourceAccountId: 'a1',
        currency: 'USD',
        provisionalEntryId: 'e1',
        status: PendingTransferStatus.pending,
        initiatedAt: DateTime(2026, 1, 1),
        destinationAccountId: 'a2',
      );
      final overview = buildHomeOverview(
        groups: [group],
        accounts: [checking],
        rawSumByAccount: {'a1': 1000},
        investmentPortfolios: const {},
        pending: [
          HomeOverviewPendingInput(
            pendingTransfer: pending,
            sourceAccountName: 'Checking',
            currency: 'USD',
            amountMinor: 500,
            countsTowardNetPosition: true,
          ),
        ],
      );
      expect(overview.netPositionsByCurrency.single.totalAssetsMinor, 1500);
    });

    test('investment account uses portfolio map', () {
      final invest = const Account(
        id: 'inv',
        name: 'Brokerage',
        type: AccountType.asset,
        archived: false,
        groupId: 'g1',
        holdsInvestments: true,
      );
      final overview = buildHomeOverview(
        groups: [group],
        accounts: [invest],
        rawSumByAccount: {'inv': 100},
        investmentPortfolios: {'inv': (portfolioMinor: 250, bookMinor: 180)},
        pending: const [],
      );
      final balance = overview.sections.single.accounts.single;
      expect(balance.displayBalanceMinor, 250);
      expect(balance.bookValueMinor, 180);
      expect(balance.isMarketEstimate, isTrue);
    });
  });
}
