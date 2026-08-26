import 'dart:async';

import 'package:drift/drift.dart';

import '../../domain/crypto/signing_key_service.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/home_overview.dart';
import '../../domain/models/integrity_event.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/money/currency_minor_units.dart';
import '../../domain/models/pending_transfer.dart';
import '../../domain/models/posting.dart';
import '../../domain/models/summary.dart';
import '../../domain/models/transaction_direction.dart';
import '../../domain/register/display_balance.dart' as display_balance;
import '../../domain/register/active_balance.dart';
import '../../domain/register/register_projection.dart';
import '../database/app_database.dart';
import '../database/tables/accounts_table.dart';
import 'account_chart_reader.dart';
import 'investment_holdings_logic.dart';
import 'ledger_chain_store.dart';
import 'ledger_posting.dart';
import 'repository_date_utils.dart';

/// Facade over ledger reads (register, overview, CSV) and [LedgerPosting]
/// writes. Exposes domain models, never Drift's generated row classes
/// (smara-tech-guidelines.md). Write paths delegate to [LedgerPosting];
/// chart reads go through [AccountChartReader]. No updateEntry/deleteEntry
/// method exists anywhere on this class - immutability is enforced by
/// omission (Golden Rule #7).
class LedgerRepository {
  LedgerRepository({
    required AppDatabase database,
    SigningKeyService? signingKeyService,
    AccountChartReader? chart,
    LedgerChainStore? chain,
  }) : _db = database {
    _chart = chart ?? AccountChartReader(database);
    final resolvedChain = chain ?? LedgerChainStore(database);
    _posting = LedgerPosting(
      database: database,
      chart: _chart,
      chain: resolvedChain,
      entriesForAccount: (id) => watchEntriesForAccount(id).first,
      signingKeyService: signingKeyService,
    );
  }

  final AppDatabase _db;
  late final AccountChartReader _chart;
  late final LedgerPosting _posting;

  /// Whether at least one journal entry has ever been recorded - used by
  /// the app router to know whether a first-time user still needs the
  /// guided first-entry screen before the recovery-phrase acknowledgment
  /// flow (deferred-onboarding-first-entry).
  Future<bool> hasAnyJournalEntries() async {
    final row = await (_db.select(
      _db.journalEntries,
    )..limit(1)).getSingleOrNull();
    return row != null;
  }

  /// Closes the underlying database connection. Only meaningful
  /// immediately before replacing the database file out from under it
  /// (see [LedgerBackupRepository.restoreLedgerBackup]) - this repository
  /// instance is unusable afterward.
  Future<void> close() => _db.close();

  // ---------------------------------------------------------------------
  // Register / summary reads.
  // ---------------------------------------------------------------------

  /// Reactive stream of the register: every posted entry with its
  /// postings, ordered chronologically by transaction date. Includes each
  /// entry's current verification status from `entry_verification_cache`
  /// (spec: "Quarantine of Entries After a Break").
  Stream<List<JournalEntry>> watchEntries() {
    final query =
        _db.select(_db.journalEntries).join([
          leftOuterJoin(
            _db.postings,
            _db.postings.entryId.equalsExp(_db.journalEntries.id),
          ),
          leftOuterJoin(
            _db.entryVerificationCache,
            _db.entryVerificationCache.entryId.equalsExp(_db.journalEntries.id),
          ),
        ])..orderBy([
          OrderingTerm.asc(_db.journalEntries.transactionDate),
          OrderingTerm.asc(_db.journalEntries.createdAt),
          OrderingTerm.asc(_db.postings.lineNumber),
        ]);

    return query.watch().map(_groupIntoEntries);
  }

  List<JournalEntry> _groupIntoEntries(List<TypedResult> rows) {
    final entryRows = <String, JournalEntryRow>{};
    final postingsByEntry = <String, List<PostingRow>>{};
    final verificationByEntry = <String, EntryVerificationRow>{};

    for (final row in rows) {
      final entry = row.readTable(_db.journalEntries);
      entryRows[entry.id] = entry;
      final posting = row.readTableOrNull(_db.postings);
      if (posting != null) {
        postingsByEntry.putIfAbsent(entry.id, () => []).add(posting);
      }
      final verification = row.readTableOrNull(_db.entryVerificationCache);
      if (verification != null) {
        verificationByEntry[entry.id] = verification;
      }
    }

    final supersededEntryIds = <String>{
      for (final entry in entryRows.values) ?entry.migratedFromEntryId,
    };

    return entryRows.values
        .map(
          (entry) => _toDomainEntry(
            entry,
            postingsByEntry[entry.id] ?? const [],
            verificationByEntry[entry.id],
            supersededEntryIds.contains(entry.id),
          ),
        )
        .toList();
  }

  JournalEntry _toDomainEntry(
    JournalEntryRow entry,
    List<PostingRow> postings,
    EntryVerificationRow? verification,
    bool isSupersededByMigration,
  ) {
    return JournalEntry(
      id: entry.id,
      transactionDate: DateTime.parse(entry.transactionDate),
      recordedAt: entry.recordedAt,
      description: entry.description,
      reversesEntryId: entry.reversesEntryId,
      postings: postings.map(_toDomainPosting).toList(),
      deviceChainSequence: entry.deviceChainSequence,
      entryHash: entry.entryHash,
      signedByIdentityId: entry.signedByIdentityId,
      signature: entry.signature,
      migratedFromEntryId: entry.migratedFromEntryId,
      // No cache row yet (e.g. immediately after insert, before the next
      // verification pass populates it) defaults to verified - matches
      // the immediate cache write recordTransaction/reverseEntry already
      // perform for the entry they just created.
      isVerified: verification?.isVerified ?? true,
      breakReason: verification?.breakReason,
      isSupersededByMigration: isSupersededByMigration,
    );
  }

  Posting _toDomainPosting(PostingRow row) {
    return Posting(
      id: row.id,
      entryId: row.entryId,
      accountId: row.accountId,
      amountMinor: row.amountMinor,
      lineNumber: row.lineNumber,
    );
  }

  Future<String> recordTransaction({
    required int amountMinor,
    required TransactionDirection direction,
    required String categoryId,
    required String financialAccountId,
    required DateTime transactionDate,
    String? description,
    String? nativeCurrency,
    int? accountCurrencyAmountMinor,
  }) => _posting.recordTransaction(
    amountMinor: amountMinor,
    direction: direction,
    categoryId: categoryId,
    financialAccountId: financialAccountId,
    transactionDate: transactionDate,
    description: description,
    nativeCurrency: nativeCurrency,
    accountCurrencyAmountMinor: accountCurrencyAmountMinor,
  );

  Future<String> recordSplitTransaction({
    required int totalAmountMinor,
    required List<({String categoryId, int amountMinor})> splitLines,
    required TransactionDirection direction,
    required String financialAccountId,
    required DateTime transactionDate,
    String? description,
  }) => _posting.recordSplitTransaction(
    totalAmountMinor: totalAmountMinor,
    splitLines: splitLines,
    direction: direction,
    financialAccountId: financialAccountId,
    transactionDate: transactionDate,
    description: description,
  );

  Future<void> recordTransfer({
    required String fromAccountId,
    required String toAccountId,
    required int amountMinor,
    required DateTime transactionDate,
    String? description,
    int? destinationAmountMinor,
  }) => _posting.recordTransfer(
    fromAccountId: fromAccountId,
    toAccountId: toAccountId,
    amountMinor: amountMinor,
    transactionDate: transactionDate,
    description: description,
    destinationAmountMinor: destinationAmountMinor,
  );

  Future<void> postTransferEntry({
    required AccountRow fromAccount,
    required AccountRow toAccount,
    required int amountMinor,
    required DateTime transactionDate,
    String? description,
    int? destinationAmountMinor,
  }) => _posting.postTransferEntry(
    fromAccount: fromAccount,
    toAccount: toAccount,
    amountMinor: amountMinor,
    transactionDate: transactionDate,
    description: description,
    destinationAmountMinor: destinationAmountMinor,
  );

  Future<void> reverseEntry(String entryId) => _posting.reverseEntry(entryId);

  Future<String> fixPostedTransaction({
    required String entryId,
    required int amountMinor,
    required TransactionDirection direction,
    required String categoryId,
    required String financialAccountId,
    required DateTime transactionDate,
    String? description,
  }) => _posting.fixPostedTransaction(
    entryId: entryId,
    amountMinor: amountMinor,
    direction: direction,
    categoryId: categoryId,
    financialAccountId: financialAccountId,
    transactionDate: transactionDate,
    description: description,
  );

  // ---------------------------------------------------------------------
  // Pending transfers / foreign-currency settlement (multi-currency-support).
  // ---------------------------------------------------------------------

  /// One row per unsettled pending transfer or foreign-currency
  /// transaction, ordered by initiation time - the Home overview's
  /// "Pending transfers" section (design.md Decision 4).
  Stream<List<PendingTransfer>> watchPendingTransfers() {
    final query = _db.select(_db.pendingTransfers)
      ..where((p) => p.status.equalsValue(PendingTransferStatus.pending))
      ..orderBy([(p) => OrderingTerm.asc(p.initiatedAt)]);
    return query.watch().map(
      (rows) => rows.map(_toDomainPendingTransfer).toList(),
    );
  }

  PendingTransfer _toDomainPendingTransfer(PendingTransferRow row) {
    return PendingTransfer(
      id: row.id,
      kind: row.kind,
      sourceAccountId: row.sourceAccountId,
      currency: row.currency,
      categoryId: row.categoryId,
      destinationAccountId: row.destinationAccountId,
      provisionalEntryId: row.provisionalEntryId,
      status: row.status,
      settlementEntryId: row.settlementEntryId,
      feeEntryId: row.feeEntryId,
      initiatedAt: row.initiatedAt,
      settledAt: row.settledAt,
    );
  }

  /// Joined settle-screen summary for [pendingTransferId], independent of
  /// Home overview state. Null when the id is unknown or already settled.
  Future<PendingTransferSummary?> pendingTransferSummary(
    String pendingTransferId,
  ) async {
    final row = await (_db.select(
      _db.pendingTransfers,
    )..where((p) => p.id.equals(pendingTransferId))).getSingleOrNull();
    if (row == null || row.status != PendingTransferStatus.pending) {
      return null;
    }
    final entries = await watchEntries().first;
    final entryById = {for (final e in entries) e.id: e};
    return _pendingTransferSummary(
      row: row,
      provisionalEntry: entryById[row.provisionalEntryId],
      nameById: await _accountNameById(),
    );
  }

  Future<Map<String, String>> _accountNameById() async {
    final allAccountRows = await _db.select(_db.accounts).get();
    return {for (final a in allAccountRows) a.id: a.name};
  }

  PendingTransferSummary? _pendingTransferSummary({
    required PendingTransferRow row,
    required JournalEntry? provisionalEntry,
    required Map<String, String> nameById,
  }) {
    if (provisionalEntry == null) return null;
    final clearingPosting = provisionalEntry.postings.firstWhere(
      (p) => p.accountId == transfersInTransitAccountId,
      orElse: () => provisionalEntry.postings.first,
    );
    return PendingTransferSummary(
      pendingTransfer: _toDomainPendingTransfer(row),
      sourceAccountName: nameById[row.sourceAccountId] ?? row.sourceAccountId,
      destinationLabel:
          nameById[row.destinationAccountId] ?? nameById[row.categoryId],
      currency: row.currency,
      amountMinor: clearingPosting.amountMinor.abs(),
    );
  }

  Future<void> settlePendingTransfer({
    required String pendingTransferId,
    required String settledToAccountId,
    required int settledAmountMinor,
    String? feeCategoryId,
  }) => _posting.settlePendingTransfer(
    pendingTransferId: pendingTransferId,
    settledToAccountId: settledToAccountId,
    settledAmountMinor: settledAmountMinor,
    feeCategoryId: feeCategoryId,
  );

  Future<({int portfolioMinor, int bookMinor})> _portfolioForInvestmentAccount({
    required String accountId,
    required int cashMinor,
    required String groupCurrency,
  }) async {
    final holdings = await computeInstrumentHoldingsForAccount(
      _db,
      accountId: accountId,
      groupCurrency: groupCurrency,
    );
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

  Stream<void> _tickOn(Iterable<Stream<dynamic>> streams) {
    late StreamController<void> controller;
    final subs = <StreamSubscription<dynamic>>[];
    controller = StreamController<void>(
      onListen: () {
        for (final stream in streams) {
          subs.add(
            stream.listen((_) {
              if (!controller.isClosed) controller.add(null);
            }),
          );
        }
      },
      onCancel: () async {
        for (final sub in subs) {
          await sub.cancel();
        }
      },
    );
    return controller.stream;
  }

  Future<String> appendSignedEntry({
    required String transactionDate,
    String? description,
    String? reversesEntryId,
    required List<({String accountId, int amountMinor, int lineNumber})>
    postings,
  }) => _posting.appendSignedEntry(
    transactionDate: transactionDate,
    description: description,
    reversesEntryId: reversesEntryId,
    postings: postings,
  );

  Stream<List<JournalEntry>> watchEntriesForAccount(String financialAccountId) {
    return watchEntries().map(
      (entries) => entries
          .where(
            (e) => e.postings.any((p) => p.accountId == financialAccountId),
          )
          .toList(),
    );
  }

  /// Display-balance contribution of one posting on a financial account.
  /// Asset: raw amount. Liability owed: negated amount (Option A).
  static int displayBalanceDeltaFor({
    required AccountType accountType,
    required int postingAmountMinor,
  }) => display_balance.displayBalanceDeltaFor(
    accountType: accountType,
    postingAmountMinor: postingAmountMinor,
  );

  /// Current display balance for a financial account (quarantine/supersession
  /// exclusions applied).
  Future<int> displayBalanceMinor(String financialAccountId) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(financialAccountId))).getSingle();
    final entries = await watchEntriesForAccount(financialAccountId).first;
    return displayBalanceForAccount(
      entries: entries,
      accountId: financialAccountId,
      accountType: account.type,
    );
  }

  /// A CSV of [financialAccountId]'s transactions between [start] and
  /// [end] (inclusive, by transaction date), oldest first (spec:
  /// "Ledger Data Export"). Never includes signing-key material - only
  /// the same date/description/category/amount data already shown in
  /// that account's Register.
  ///
  /// One row per category leg: an ordinary transaction has exactly one,
  /// so this reduces to one row per entry; a split-transactions entry
  /// gets one row per category line, each with that line's own amount
  /// (not the entry's total) so the exported rows sum correctly per
  /// entry. A transfer's row uses the counterparty account's name; an
  /// opening-balance entry is labeled as such. A "Verified" column notes
  /// whether the entry's signature still chains correctly - a quarantined
  /// entry is still exported, never silently dropped, matching the
  /// Register's own "still shown, never hidden" treatment.
  Future<String> exportLedgerCsv({
    required String financialAccountId,
    required DateTime start,
    required DateTime end,
  }) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(financialAccountId))).getSingleOrNull();
    if (account == null ||
        (account.type != AccountType.asset &&
            account.type != AccountType.liability)) {
      throw AccountGroupException(
        'Account $financialAccountId is not a financial account.',
        code: AppErrorCode.accountNotFinancial,
      );
    }
    final startDate = dateOnly(start);
    final endDate = dateOnly(end);

    final entries = await watchEntriesForAccount(financialAccountId).first;
    final inRange = entries.where((e) {
      final entryDate = dateOnly(e.transactionDate);
      return entryDate.compareTo(startDate) >= 0 &&
          entryDate.compareTo(endDate) <= 0;
    }).toList()..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    final categories = await _chart
        .watchCategories(includeArchived: true)
        .first;
    final categoriesById = {for (final c in categories) c.id: c};
    final allAccounts = await _chart
        .watchFinancialAccounts(includeArchived: true)
        .first;
    final accountsById = {for (final a in allAccounts) a.id: a};

    final buffer = StringBuffer()
      ..writeln('Date,Description,Category,Direction,Amount,Currency,Verified');
    final currency = await _chart.groupCurrencyFor(account);

    // Projection returns newest-first (Register UI). CSV is oldest-first.
    final projected = projectRegisterEntries(
      entries: inRange,
      viewedAccountId: financialAccountId,
      viewedAccountType: account.type,
      currency: currency,
      accountsById: accountsById,
      categoriesById: categoriesById,
      openingBalanceAccountId: openingBalanceEquityAccountId,
    );
    for (final item in projected.reversed) {
      final direction = item.row.direction == TransactionDirection.moneyIn
          ? 'Received'
          : 'Spent';
      for (final leg in item.legs) {
        buffer.writeln(
          [
            dateOnly(item.row.transactionDate),
            _csvField(item.row.description ?? ''),
            _csvField(leg.label),
            direction,
            _csvAmount(leg.amountMinor, currency),
            currency,
            item.row.isVerified ? 'Yes' : 'No',
          ].join(','),
        );
      }
    }
    return buffer.toString();
  }

  /// A plain, locale-independent decimal string (period decimal, no
  /// grouping) for [amountMinor] in [currency] - never [formatAmountMinor]'s
  /// locale-grouped display form, which for a currency like EUR uses a
  /// comma as its *decimal* separator and would silently break this CSV's
  /// own comma delimiting. Still uses each currency's real minor-unit
  /// digit count (0 for JPY, 2 for most others), so the value itself is
  /// accurate - only the presentation is deliberately plain.
  String _csvAmount(int amountMinor, String currency) {
    final digits = minorUnitDigitsForCurrency(currency);
    final major = amountMinor / _pow10(digits);
    return major.toStringAsFixed(digits);
  }

  static int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  String _csvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Stream<HomeOverview> watchHomeOverview() {
    return _tickOn([
      watchEntries(),
      _chart.watchFinancialAccounts(includeArchived: true),
      _db.select(_db.instrumentQuotes).watch(),
    ]).asyncMap((_) => _buildHomeOverview());
  }

  Future<HomeOverview> _buildHomeOverview() async {
    final groups = await _chart.watchAccountGroups(includeArchived: true).first;
    final accounts = await _chart
        .watchFinancialAccounts(includeArchived: true)
        .first;
    final entries = await watchEntries().first;
    final pendingRows = await (_db.select(
      _db.pendingTransfers,
    )..where((p) => p.status.equalsValue(PendingTransferStatus.pending))).get();

    final rawSumByAccount = rawPostingSumsByAccount(entries);

    int displayFor(Account account) {
      final raw = rawSumByAccount[account.id] ?? 0;
      return displayBalanceDeltaFor(
        accountType: account.type,
        postingAmountMinor: raw,
      );
    }

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
        final cashOrOwed = displayFor(account);
        var display = cashOrOwed;
        int? bookValueMinor;
        var isMarketEstimate = false;
        if (account.isInvestmentAccount && currency != null) {
          final valued = await _portfolioForInvestmentAccount(
            accountId: account.id,
            cashMinor: cashOrOwed,
            groupCurrency: currency,
          );
          display = valued.portfolioMinor;
          bookValueMinor = valued.bookMinor;
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

    // Pending transfers: shown as their own line items, and their
    // provisional amount counts toward their source currency's net
    // position while unsettled - unless the provisional entry itself is
    // quarantined or migration-superseded, in which case it's excluded
    // from the totals but still listed for review (multi-currency-support
    // design.md Decision 2 / spec "A quarantined or superseded provisional
    // entry does not distort net worth").
    final entryById = {for (final e in entries) e.id: e};
    final nameById = await _accountNameById();
    final pendingSummaries = <PendingTransferSummary>[];

    for (final row in pendingRows) {
      final summary = _pendingTransferSummary(
        row: row,
        provisionalEntry: entryById[row.provisionalEntryId],
        nameById: nameById,
      );
      if (summary == null) continue;
      pendingSummaries.add(summary);

      final provisionalEntry = entryById[row.provisionalEntryId]!;
      final isExcluded =
          !provisionalEntry.isVerified ||
          provisionalEntry.isSupersededByMigration;
      if (!isExcluded) {
        assetsByCurrency[summary.currency] =
            (assetsByCurrency[summary.currency] ?? 0) + summary.amountMinor;
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

  /// Total income and total expense posted within [start]..[end]
  /// (inclusive), based on transaction date. Both totals are positive
  /// magnitudes; a reversed entry's postings net out automatically since
  /// they carry opposite signs to the original. Postings belonging to a
  /// quarantined (unverified) entry are excluded (spec: "Quarantine of
  /// Entries After a Break"). Transfers and opening balances are excluded
  /// because only income/expense account types accumulate. Optional
  /// [financialAccountId] filters to entries that affect that account.
  Stream<LedgerSummary> watchSummary({
    required DateTime start,
    required DateTime end,
    String? financialAccountId,
  }) {
    final startDate = dateOnly(start);
    final endDate = dateOnly(end);

    final query =
        _db.select(_db.postings).join([
          innerJoin(
            _db.journalEntries,
            _db.journalEntries.id.equalsExp(_db.postings.entryId),
          ),
          innerJoin(
            _db.accounts,
            _db.accounts.id.equalsExp(_db.postings.accountId),
          ),
          leftOuterJoin(
            _db.entryVerificationCache,
            _db.entryVerificationCache.entryId.equalsExp(_db.postings.entryId),
          ),
        ])..where(
          _db.journalEntries.transactionDate.isBiggerOrEqualValue(startDate) &
              _db.journalEntries.transactionDate.isSmallerOrEqualValue(endDate),
        );

    return query.watch().asyncMap((rows) async {
      final supersededEntryIds = <String>{
        for (final row in rows)
          ?row.readTable(_db.journalEntries).migratedFromEntryId,
      };

      Set<String>? entryIdsTouchingAccount;
      if (financialAccountId != null) {
        entryIdsTouchingAccount = {
          for (final row in rows)
            if (row.readTable(_db.postings).accountId == financialAccountId)
              row.readTable(_db.journalEntries).id,
        };
      }

      var totalIncomeMinor = 0;
      var totalExpenseMinor = 0;
      for (final row in rows) {
        final entry = row.readTable(_db.journalEntries);
        if (supersededEntryIds.contains(entry.id)) continue;
        if (entryIdsTouchingAccount != null &&
            !entryIdsTouchingAccount.contains(entry.id)) {
          continue;
        }

        final verification = row.readTableOrNull(_db.entryVerificationCache);
        if (verification != null && !verification.isVerified) continue;

        final account = row.readTable(_db.accounts);
        final posting = row.readTable(_db.postings);
        switch (account.type) {
          case AccountType.income:
            totalIncomeMinor -= posting.amountMinor;
          case AccountType.expense:
            totalExpenseMinor += posting.amountMinor;
          case AccountType.asset:
          case AccountType.liability:
          case AccountType.equity:
          case AccountType.clearing:
          case AccountType.inventory:
            break;
        }
      }
      return LedgerSummary(
        totalIncomeMinor: totalIncomeMinor,
        totalExpenseMinor: totalExpenseMinor,
      );
    });
  }

  /// The append-only audit log of chain breaks, re-anchors, and key
  /// migrations, newest first.
  Stream<List<IntegrityEvent>> watchIntegrityEvents() {
    final query = _db.select(_db.integrityEvents)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => IntegrityEvent(
              eventId: row.eventId,
              eventType: row.eventType,
              occurredAt: row.occurredAt,
              relatedEntryId: row.relatedEntryId,
              relatedIdentityId: row.relatedIdentityId,
              detail: row.detail,
            ),
          )
          .toList(),
    );
  }
}
