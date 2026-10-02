import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/app_error.dart';
import '../../domain/claims/claim_status_derivation.dart';
import '../../domain/models/claim.dart';
import '../../domain/models/claim_advance.dart';
import '../../domain/models/claim_item.dart';
import '../../domain/models/claim_item_decision.dart';
import '../../domain/models/claim_item_decision_kind.dart';
import '../../domain/models/claim_receipt.dart';
import '../../domain/models/claim_spending_hint.dart';
import '../../domain/models/claim_status.dart';
import '../../domain/models/linked_device_role.dart';
import '../database/app_database.dart';
import 'claim_receipt_store.dart';
import 'ledger_repository.dart';
import 'membership_repository.dart';
import 'repository_date_utils.dart';

/// Claim / Claim Item / Advance lifecycle outside the posted ledger until
/// approval (shared-accounts-and-expense-claims design Decisions 1–3, 10).
///
/// Depends on [AppDatabase], [MembershipRepository], [LedgerRepository],
/// and optional [ClaimReceiptStore]. Does not depend on AccountRepository
/// (uses membership.owedToAccountId + ledger appendSignedEntry).
class ClaimRepository {
  ClaimRepository({
    required AppDatabase database,
    required MembershipRepository membership,
    required LedgerRepository ledger,
    ClaimReceiptStore? receipts,
    DateTime Function()? clock,
    Uuid? uuid,
  }) : _db = database,
       _membership = membership,
       _ledger = ledger,
       _receipts = receipts,
       _clock = clock ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final MembershipRepository _membership;
  final LedgerRepository _ledger;
  final ClaimReceiptStore? _receipts;
  final DateTime Function() _clock;
  final Uuid _uuid;

  // ---------------------------------------------------------------------------
  // Draft / submit
  // ---------------------------------------------------------------------------

  Future<Claim> createDraft({required String claimantDeviceId}) async {
    await _requireClaimant(claimantDeviceId);
    final now = _clock();
    final id = _uuid.v4();
    await _db
        .into(_db.claims)
        .insert(
          ClaimsCompanion.insert(
            id: id,
            claimantDeviceId: claimantDeviceId,
            status: ClaimStatus.draft,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return (await getClaim(id))!;
  }

  Future<ClaimItem> addItem({
    required String claimId,
    required String actorDeviceId,
    required String categoryId,
    required DateTime expenseDate,
    required String paidCurrency,
    required int paidAmountMinor,
    required int companyCurrencyAmountMinor,
    String? description,
    double? employeeStatedRate,
    double? rateUsed,
  }) async {
    final claim = await _requireEditableClaim(claimId, actorDeviceId);
    await _requireAllowlisted(categoryId);
    if (paidAmountMinor <= 0 || companyCurrencyAmountMinor <= 0) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claim item amounts must be positive.',
      );
    }
    final resolvedRate =
        rateUsed ??
        employeeStatedRate ??
        (paidCurrency.isNotEmpty && paidAmountMinor > 0
            ? companyCurrencyAmountMinor / paidAmountMinor
            : null);
    final existing = await (_db.select(
      _db.claimItems,
    )..where((t) => t.claimId.equals(claim.id))).get();
    final id = _uuid.v4();
    await _db
        .into(_db.claimItems)
        .insert(
          ClaimItemsCompanion.insert(
            id: Value(id),
            claimId: claim.id,
            categoryId: categoryId,
            expenseDate: dateOnly(expenseDate),
            description: Value(description),
            paidCurrency: paidCurrency,
            paidAmountMinor: paidAmountMinor,
            employeeStatedRate: Value(employeeStatedRate),
            rateUsed: Value(resolvedRate),
            companyCurrencyAmountMinor: companyCurrencyAmountMinor,
            sortOrder: Value(existing.length),
          ),
        );
    await _touch(claim.id);
    return (await _loadItem(id))!;
  }

  /// Updates a Draft Claim Item. Only the Claimant who owns the claim may
  /// edit; amounts must stay positive when provided.
  Future<ClaimItem> updateItem({
    required String claimItemId,
    required String actorDeviceId,
    String? categoryId,
    DateTime? expenseDate,
    String? paidCurrency,
    int? paidAmountMinor,
    int? companyCurrencyAmountMinor,
    String? description,
    bool clearDescription = false,
    double? employeeStatedRate,
    bool clearEmployeeStatedRate = false,
    double? rateUsed,
  }) async {
    final existing = await _requireItem(claimItemId);
    await _requireEditableClaim(existing.claimId, actorDeviceId);
    if (categoryId != null) {
      await _requireAllowlisted(categoryId);
    }
    final nextPaid = paidAmountMinor ?? existing.paidAmountMinor;
    final nextCompany =
        companyCurrencyAmountMinor ?? existing.companyCurrencyAmountMinor;
    if (nextPaid <= 0 || nextCompany <= 0) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claim item amounts must be positive.',
      );
    }
    final nextPaidCurrency = paidCurrency ?? existing.paidCurrency;
    final nextStatedRate = clearEmployeeStatedRate
        ? null
        : (employeeStatedRate ?? existing.employeeStatedRate);
    final resolvedRate =
        rateUsed ??
        nextStatedRate ??
        (nextPaidCurrency.isNotEmpty && nextPaid > 0
            ? nextCompany / nextPaid
            : existing.rateUsed);
    await (_db.update(
      _db.claimItems,
    )..where((t) => t.id.equals(claimItemId))).write(
      ClaimItemsCompanion(
        categoryId: categoryId != null
            ? Value(categoryId)
            : const Value.absent(),
        expenseDate: expenseDate != null
            ? Value(dateOnly(expenseDate))
            : const Value.absent(),
        description: clearDescription
            ? const Value(null)
            : (description != null ? Value(description) : const Value.absent()),
        paidCurrency: paidCurrency != null
            ? Value(paidCurrency)
            : const Value.absent(),
        paidAmountMinor: paidAmountMinor != null
            ? Value(paidAmountMinor)
            : const Value.absent(),
        employeeStatedRate:
            clearEmployeeStatedRate || employeeStatedRate != null
            ? Value(nextStatedRate)
            : const Value.absent(),
        rateUsed: Value(resolvedRate),
        companyCurrencyAmountMinor: companyCurrencyAmountMinor != null
            ? Value(companyCurrencyAmountMinor)
            : const Value.absent(),
      ),
    );
    await _touch(existing.claimId);
    return (await _loadItem(claimItemId))!;
  }

  /// Removes a Draft Claim Item. Receipt metadata rows for the item are
  /// removed for FK integrity; receipt blob files remain on disk (Decision 8
  /// never auto-deletes blobs).
  Future<void> removeItem({
    required String claimItemId,
    required String actorDeviceId,
  }) async {
    final existing = await _requireItem(claimItemId);
    await _requireEditableClaim(existing.claimId, actorDeviceId);
    await (_db.delete(
      _db.claimReceipts,
    )..where((t) => t.claimItemId.equals(claimItemId))).go();
    await (_db.delete(
      _db.claimItems,
    )..where((t) => t.id.equals(claimItemId))).go();
    await _touch(existing.claimId);
  }

  Future<void> updateItemRate({
    required String claimItemId,
    required String actorDeviceId,
    required double rateUsed,
    required int companyCurrencyAmountMinor,
  }) async {
    final item = await _requireItem(claimItemId);
    final claim = await _requireClaim(item.claimId);
    if (claim.status != ClaimStatus.draft &&
        claim.status != ClaimStatus.submitted &&
        claim.status != ClaimStatus.partlyApproved) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Cannot change rate on a closed claim item.',
      );
    }
    // Claimant may edit own draft; Approver may correct before approve.
    final actor = await _membership.findByDeviceId(actorDeviceId);
    if (actor == null || !actor.isActive) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Unknown actor.',
      );
    }
    final isOwnerClaimant =
        claim.claimantDeviceId == actorDeviceId && claim.isEditable;
    final isApprover = MembershipRoleGates.canApproveClaims(actor.roles);
    if (!isOwnerClaimant && !isApprover) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Not allowed to change claim item rate.',
      );
    }
    if (item.decision != null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Cannot change rate after a decision.',
      );
    }
    await (_db.update(
      _db.claimItems,
    )..where((t) => t.id.equals(claimItemId))).write(
      ClaimItemsCompanion(
        rateUsed: Value(rateUsed),
        companyCurrencyAmountMinor: Value(companyCurrencyAmountMinor),
      ),
    );
    await _touch(claim.id);
  }

  /// Submits a Draft Claim. Does **not** create Journal Entries.
  Future<Claim> submit({
    required String claimId,
    required String actorDeviceId,
  }) async {
    final claim = await _requireEditableClaim(claimId, actorDeviceId);
    final items = await _loadItems(claim.id);
    if (items.isEmpty) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Add at least one item before submitting.',
      );
    }
    final threshold = await receiptRequiredAboveMinor();
    for (final item in items) {
      await _requireAllowlisted(item.categoryId);
      if (item.companyCurrencyAmountMinor > threshold && item.receipt == null) {
        throw const AppFailure(
          AppErrorCode.generic,
          debugMessage: 'A receipt is required for this claim item.',
        );
      }
    }
    final now = _clock();
    await (_db.update(_db.claims)..where((t) => t.id.equals(claim.id))).write(
      ClaimsCompanion(
        status: const Value(ClaimStatus.submitted),
        submittedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return (await getClaim(claim.id))!;
  }

  // ---------------------------------------------------------------------------
  // Approver decisions + posting
  // ---------------------------------------------------------------------------

  Future<ClaimItemDecision> approveItem({
    required String claimItemId,
    required String actorDeviceId,
    int? differentAmountMinor,
    String? reason,
  }) async {
    await _requireApprover(actorDeviceId);
    final item = await _requireItem(claimItemId);
    if (item.decision != null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claim item already decided.',
      );
    }
    final claim = await _requireClaim(item.claimId);
    if (claim.status == ClaimStatus.draft) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Cannot decide a draft claim.',
      );
    }
    final claimant = await _membership.findByDeviceId(claim.claimantDeviceId);
    final owedTo = claimant?.owedToAccountId;
    if (owedTo == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claimant has no Owed-to account.',
      );
    }

    final isDifferent =
        differentAmountMinor != null &&
        differentAmountMinor != item.companyCurrencyAmountMinor;
    if (isDifferent && (reason == null || reason.trim().isEmpty)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'A reason is required when approving a different amount.',
      );
    }
    final approvedAmount =
        differentAmountMinor ?? item.companyCurrencyAmountMinor;
    if (approvedAmount <= 0) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Approved amount must be positive.',
      );
    }

    // Expense category (+amount as money-out category? Option A:
    // expense posts positive amountMinor on category for money out paired
    // with negative on financial. For liability "Owed to": when we owe the
    // employee more, liability increases — Option A liability owed display
    // is negated raw; posting expense +A / liability −A increases owed.
    // Actually for money-out expense: financial −A, expense +A.
    // Here expense is the category and liability is the "financial":
    // expense +approved, owed-to −approved (liability increases owed).
    final entryId = await _ledger.appendSignedEntry(
      transactionDate: dateOnly(item.expenseDate),
      description: 'Claim ${claim.id} item ${item.id}',
      reversesEntryId: null,
      postings: [
        (
          accountId: item.categoryId,
          amountMinor: approvedAmount,
          lineNumber: 1,
        ),
        (accountId: owedTo, amountMinor: -approvedAmount, lineNumber: 2),
      ],
    );

    final kind = isDifferent
        ? ClaimItemDecisionKind.approveDifferentAmount
        : ClaimItemDecisionKind.approve;
    final decisionId = _uuid.v4();
    final now = _clock();
    await _db
        .into(_db.claimItemDecisions)
        .insert(
          ClaimItemDecisionsCompanion.insert(
            id: Value(decisionId),
            claimItemId: claimItemId,
            kind: kind,
            approvedAmountMinor: Value(approvedAmount),
            reason: Value(reason),
            decidedByDeviceId: actorDeviceId,
            decidedAt: now,
            postedEntryId: Value(entryId),
          ),
        );
    await _refreshClaimStatus(claim.id);
    return (await _loadDecision(decisionId))!;
  }

  Future<ClaimItemDecision> rejectItem({
    required String claimItemId,
    required String actorDeviceId,
    required String reason,
  }) async {
    await _requireApprover(actorDeviceId);
    if (reason.trim().isEmpty) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'A reason is required to reject a claim item.',
      );
    }
    final item = await _requireItem(claimItemId);
    if (item.decision != null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claim item already decided.',
      );
    }
    final claim = await _requireClaim(item.claimId);
    if (claim.status == ClaimStatus.draft) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Cannot decide a draft claim.',
      );
    }
    final decisionId = _uuid.v4();
    final now = _clock();
    await _db
        .into(_db.claimItemDecisions)
        .insert(
          ClaimItemDecisionsCompanion.insert(
            id: Value(decisionId),
            claimItemId: claimItemId,
            kind: ClaimItemDecisionKind.reject,
            reason: Value(reason),
            decidedByDeviceId: actorDeviceId,
            decidedAt: now,
          ),
        );
    await _refreshClaimStatus(claim.id);
    return (await _loadDecision(decisionId))!;
  }

  /// Pays approved amounts: Owed-to ↔ bank/cash. Marks claim Paid when
  /// settled.
  Future<String> recordPayment({
    required String actorDeviceId,
    required String claimantDeviceId,
    required String bankAccountId,
    required int amountMinor,
    String? claimId,
    String? description,
  }) async {
    await _requireApprover(actorDeviceId);
    if (amountMinor <= 0) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Payment amount must be positive.',
      );
    }
    final claimant = await _membership.findByDeviceId(claimantDeviceId);
    final owedTo = claimant?.owedToAccountId;
    if (owedTo == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claimant has no Owed-to account.',
      );
    }
    // Paying the employee: reduce liability (owed-to +amount) and reduce
    // bank (−amount).
    final entryId = await _ledger.appendSignedEntry(
      transactionDate: dateOnly(_clock()),
      description: description ?? 'Claim payment',
      reversesEntryId: null,
      postings: [
        (accountId: owedTo, amountMinor: amountMinor, lineNumber: 1),
        (accountId: bankAccountId, amountMinor: -amountMinor, lineNumber: 2),
      ],
    );
    if (claimId != null) {
      await _refreshClaimStatus(claimId, forcePaidCheck: true);
    }
    return entryId;
  }

  /// Records an Advance: bank → Owed-to (company prepaid the employee).
  Future<ClaimAdvance> recordAdvance({
    required String actorDeviceId,
    required String claimantDeviceId,
    required String bankAccountId,
    required int amountMinor,
    String? description,
  }) async {
    await _requireApprover(actorDeviceId);
    if (amountMinor <= 0) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Advance amount must be positive.',
      );
    }
    final claimant = await _membership.findByDeviceId(claimantDeviceId);
    final owedTo = claimant?.owedToAccountId;
    if (owedTo == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claimant has no Owed-to account.',
      );
    }
    // Advance: bank −A, owed-to +A (employee owes company / prepaid).
    final entryId = await _ledger.appendSignedEntry(
      transactionDate: dateOnly(_clock()),
      description: description ?? 'Advance',
      reversesEntryId: null,
      postings: [
        (accountId: bankAccountId, amountMinor: -amountMinor, lineNumber: 1),
        (accountId: owedTo, amountMinor: amountMinor, lineNumber: 2),
      ],
    );
    final id = _uuid.v4();
    final now = _clock();
    await _db
        .into(_db.claimAdvances)
        .insert(
          ClaimAdvancesCompanion.insert(
            id: Value(id),
            claimantDeviceId: claimantDeviceId,
            amountMinor: amountMinor,
            paidFromAccountId: bankAccountId,
            postedEntryId: entryId,
            description: Value(description),
            recordedAt: now,
          ),
        );
    return ClaimAdvance(
      id: id,
      claimantDeviceId: claimantDeviceId,
      amountMinor: amountMinor,
      paidFromAccountId: bankAccountId,
      postedEntryId: entryId,
      recordedAt: now,
      description: description,
    );
  }

  // ---------------------------------------------------------------------------
  // Allowlist / hints / settings
  // ---------------------------------------------------------------------------

  Future<void> setAllowlistedCategories(Set<String> categoryIds) async {
    await _db.delete(_db.claimCategoryAllowlist).go();
    for (final id in categoryIds) {
      await _db
          .into(_db.claimCategoryAllowlist)
          .insert(ClaimCategoryAllowlistCompanion.insert(categoryId: id));
    }
  }

  Future<List<String>> allowlistedCategoryIds() async {
    final rows = await _db.select(_db.claimCategoryAllowlist).get();
    return rows.map((r) => r.categoryId).toList();
  }

  Future<void> setSpendingHint({
    required String categoryId,
    required int maxAmountMinor,
    required String unitLabel,
  }) async {
    await _db
        .into(_db.claimSpendingHints)
        .insertOnConflictUpdate(
          ClaimSpendingHintsCompanion.insert(
            categoryId: categoryId,
            maxAmountMinor: maxAmountMinor,
            unitLabel: unitLabel,
          ),
        );
  }

  Future<List<ClaimSpendingHint>> spendingHints() async {
    final rows = await _db.select(_db.claimSpendingHints).get();
    return rows
        .map(
          (r) => ClaimSpendingHint(
            categoryId: r.categoryId,
            maxAmountMinor: r.maxAmountMinor,
            unitLabel: r.unitLabel,
          ),
        )
        .toList();
  }

  Future<int> receiptRequiredAboveMinor() async {
    final rows = await _db.select(_db.booksSetMetadata).get();
    if (rows.isEmpty) return 0;
    return rows.first.receiptRequiredAboveMinor;
  }

  Future<void> setReceiptRequiredAboveMinor(int amountMinor) async {
    final rows = await _db.select(_db.booksSetMetadata).get();
    if (rows.isEmpty) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Books set metadata missing.',
      );
    }
    await (_db.update(
      _db.booksSetMetadata,
    )..where((t) => t.id.equals(rows.first.id))).write(
      BooksSetMetadataCompanion(receiptRequiredAboveMinor: Value(amountMinor)),
    );
  }

  // ---------------------------------------------------------------------------
  // Reads / balance
  // ---------------------------------------------------------------------------

  Future<Claim?> getClaim(String claimId) async {
    final row = await (_db.select(
      _db.claims,
    )..where((t) => t.id.equals(claimId))).getSingleOrNull();
    if (row == null) return null;
    final items = await _loadItems(claimId);
    return Claim(
      id: row.id,
      claimantDeviceId: row.claimantDeviceId,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      submittedAt: row.submittedAt,
      paidAt: row.paidAt,
      items: items,
    );
  }

  Future<List<Claim>> listClaimsForClaimant(String claimantDeviceId) async {
    final rows = await (_db.select(
      _db.claims,
    )..where((t) => t.claimantDeviceId.equals(claimantDeviceId))).get();
    rows.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final out = <Claim>[];
    for (final row in rows) {
      out.add((await getClaim(row.id))!);
    }
    return out;
  }

  Future<List<Claim>> listSubmittedForReview() async {
    final rows = await _db.select(_db.claims).get();
    final out = <Claim>[];
    for (final row in rows) {
      if (row.status == ClaimStatus.draft) continue;
      out.add((await getClaim(row.id))!);
    }
    return out;
  }

  Future<List<ClaimAdvance>> listAdvances(String claimantDeviceId) async {
    final rows = await (_db.select(
      _db.claimAdvances,
    )..where((t) => t.claimantDeviceId.equals(claimantDeviceId))).get();
    rows.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return rows
        .map(
          (r) => ClaimAdvance(
            id: r.id,
            claimantDeviceId: r.claimantDeviceId,
            amountMinor: r.amountMinor,
            paidFromAccountId: r.paidFromAccountId,
            postedEntryId: r.postedEntryId,
            recordedAt: r.recordedAt,
            description: r.description,
          ),
        )
        .toList();
  }

  /// Company-currency balance for a Claimant from their owed-to account
  /// display balance. Positive display = company owes claimant (typical
  /// after approve before pay). Negative = claimant owes company (advance).
  Future<int> claimantBalanceMinor(String claimantDeviceId) async {
    final claimant = await _membership.findByDeviceId(claimantDeviceId);
    final owedTo = claimant?.owedToAccountId;
    if (owedTo == null) return 0;
    return _ledger.displayBalanceMinor(owedTo);
  }

  /// Warning info before removing a person.
  Future<({int openClaims, int balanceMinor})> removalWarning({
    required String targetDeviceId,
  }) async {
    final claims = await listClaimsForClaimant(targetDeviceId);
    final open = claims
        .where(
          (c) =>
              c.status == ClaimStatus.draft ||
              c.status == ClaimStatus.submitted ||
              c.status == ClaimStatus.partlyApproved ||
              c.status == ClaimStatus.approved,
        )
        .length;
    final balance = await claimantBalanceMinor(targetDeviceId);
    return (openClaims: open, balanceMinor: balance);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<void> _requireClaimant(String deviceId) async {
    final device = await _membership.findByDeviceId(deviceId);
    if (device == null ||
        !device.isActive ||
        !MembershipRoleGates.canSubmitOwnClaims(device.roles)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Only a Claimant can create claims.',
      );
    }
  }

  Future<void> _requireApprover(String deviceId) async {
    final device = await _membership.findByDeviceId(deviceId);
    if (device == null ||
        !device.isActive ||
        !MembershipRoleGates.canApproveClaims(device.roles)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Only an Approver or Owner can decide claims.',
      );
    }
  }

  Future<Claim> _requireClaim(String claimId) async {
    final claim = await getClaim(claimId);
    if (claim == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claim not found.',
      );
    }
    return claim;
  }

  Future<Claim> _requireEditableClaim(
    String claimId,
    String actorDeviceId,
  ) async {
    final claim = await _requireClaim(claimId);
    if (!claim.isEditable) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claim is not editable.',
      );
    }
    if (claim.claimantDeviceId != actorDeviceId) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Only the Claimant can edit this claim.',
      );
    }
    return claim;
  }

  Future<ClaimItem> _requireItem(String claimItemId) async {
    final item = await _loadItem(claimItemId);
    if (item == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claim item not found.',
      );
    }
    return item;
  }

  Future<void> _requireAllowlisted(String categoryId) async {
    final allowed = await allowlistedCategoryIds();
    // Empty allowlist = all expense categories allowed (fresh books).
    if (allowed.isEmpty) return;
    if (!allowed.contains(categoryId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Category is not allowed for claims.',
      );
    }
  }

  Future<void> _touch(String claimId) async {
    await (_db.update(_db.claims)..where((t) => t.id.equals(claimId))).write(
      ClaimsCompanion(updatedAt: Value(_clock())),
    );
  }

  Future<void> _refreshClaimStatus(
    String claimId, {
    bool forcePaidCheck = false,
  }) async {
    final claim = await _requireClaim(claimId);
    final items = claim.items;
    var settled = false;
    if (forcePaidCheck ||
        claim.status == ClaimStatus.approved ||
        claim.status == ClaimStatus.paid) {
      final approvedTotal = claim.approvedCompanyCurrencyTotalMinor;
      // Settled when owed balance contribution for this claim is cleared:
      // approximate via paidAt already set, or approved total == 0.
      // Full settlement tracking uses payment entries; for v1, caller
      // passes forcePaidCheck after a payment that covers the claim.
      settled = forcePaidCheck || approvedTotal == 0;
    }
    final status = ClaimStatusDerivation.derive(
      isSubmitted: claim.submittedAt != null,
      items: items,
      approvedAmountFullySettled:
          settled &&
          items.every((i) => !i.isPendingDecision) &&
          items.any((i) => i.decision?.isApproved == true),
    );
    await (_db.update(_db.claims)..where((t) => t.id.equals(claimId))).write(
      ClaimsCompanion(
        status: Value(status),
        paidAt: status == ClaimStatus.paid
            ? Value(_clock())
            : const Value.absent(),
        updatedAt: Value(_clock()),
      ),
    );
  }

  Future<List<ClaimItem>> _loadItems(String claimId) async {
    final rows = await (_db.select(
      _db.claimItems,
    )..where((t) => t.claimId.equals(claimId))).get();
    rows.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final out = <ClaimItem>[];
    for (final row in rows) {
      out.add((await _loadItem(row.id))!);
    }
    return out;
  }

  Future<ClaimItem?> _loadItem(String id) async {
    final row = await (_db.select(
      _db.claimItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    ClaimReceipt? receipt;
    if (_receipts != null) {
      receipt = await _receipts.findForItem(id);
    } else {
      final r = await (_db.select(
        _db.claimReceipts,
      )..where((t) => t.claimItemId.equals(id))).getSingleOrNull();
      if (r != null) {
        receipt = ClaimReceipt(
          id: r.id,
          claimItemId: r.claimItemId,
          contentType: r.contentType,
          fileName: r.fileName,
          byteSize: r.byteSize,
          contentHash: r.contentHash,
          createdAt: r.createdAt,
        );
      }
    }
    final decisionRow = await (_db.select(
      _db.claimItemDecisions,
    )..where((t) => t.claimItemId.equals(id))).getSingleOrNull();
    ClaimItemDecision? decision;
    if (decisionRow != null) {
      decision = ClaimItemDecision(
        id: decisionRow.id,
        claimItemId: decisionRow.claimItemId,
        kind: decisionRow.kind,
        decidedByDeviceId: decisionRow.decidedByDeviceId,
        decidedAt: decisionRow.decidedAt,
        approvedAmountMinor: decisionRow.approvedAmountMinor,
        reason: decisionRow.reason,
        postedEntryId: decisionRow.postedEntryId,
      );
    }
    return ClaimItem(
      id: row.id,
      claimId: row.claimId,
      categoryId: row.categoryId,
      expenseDate: DateTime.parse(row.expenseDate),
      description: row.description,
      paidCurrency: row.paidCurrency,
      paidAmountMinor: row.paidAmountMinor,
      employeeStatedRate: row.employeeStatedRate,
      rateUsed: row.rateUsed,
      companyCurrencyAmountMinor: row.companyCurrencyAmountMinor,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      receipt: receipt,
      decision: decision,
    );
  }

  Future<ClaimItemDecision?> _loadDecision(String id) async {
    final row = await (_db.select(
      _db.claimItemDecisions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return ClaimItemDecision(
      id: row.id,
      claimItemId: row.claimItemId,
      kind: row.kind,
      decidedByDeviceId: row.decidedByDeviceId,
      decidedAt: row.decidedAt,
      approvedAmountMinor: row.approvedAmountMinor,
      reason: row.reason,
      postedEntryId: row.postedEntryId,
    );
  }
}
