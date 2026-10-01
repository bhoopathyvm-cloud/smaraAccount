import 'dart:convert';

import 'sync_payloads.dart';

/// Sync message kinds for Claims (extends [SyncMessageKind]).
enum ClaimSyncMessageKind { claimBatch, advanceOps, receiptBlob }

/// One Claim (with items and decisions) as carried in a [ClaimBatch].
class SyncClaim {
  const SyncClaim({
    required this.id,
    required this.claimantDeviceId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.submittedAt,
    this.paidAt,
  });

  final String id;
  final String claimantDeviceId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final DateTime? paidAt;
  final List<SyncClaimItem> items;

  Map<String, Object?> toJson() => {
    'id': id,
    'claimantDeviceId': claimantDeviceId,
    'status': status,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'submittedAt': submittedAt?.toUtc().toIso8601String(),
    'paidAt': paidAt?.toUtc().toIso8601String(),
    'items': items.map((i) => i.toJson()).toList(),
  };

  static SyncClaim fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    if (itemsRaw is! List) {
      throw const FormatException('SyncClaim.items must be a list.');
    }
    return SyncClaim(
      id: json['id'] as String,
      claimantDeviceId: json['claimantDeviceId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      items: itemsRaw
          .map(
            (i) => SyncClaimItem.fromJson(Map<String, dynamic>.from(i as Map)),
          )
          .toList(),
    );
  }
}

class SyncClaimItem {
  const SyncClaimItem({
    required this.id,
    required this.claimId,
    required this.categoryId,
    required this.expenseDate,
    required this.paidCurrency,
    required this.paidAmountMinor,
    required this.companyCurrencyAmountMinor,
    required this.sortOrder,
    this.description,
    this.employeeStatedRate,
    this.rateUsed,
    this.receiptId,
    this.decision,
  });

  final String id;
  final String claimId;
  final String categoryId;
  final String expenseDate;
  final String? description;
  final String paidCurrency;
  final int paidAmountMinor;
  final double? employeeStatedRate;
  final double? rateUsed;
  final int companyCurrencyAmountMinor;
  final int sortOrder;
  final String? receiptId;
  final SyncClaimDecision? decision;

  Map<String, Object?> toJson() => {
    'id': id,
    'claimId': claimId,
    'categoryId': categoryId,
    'expenseDate': expenseDate,
    'description': description,
    'paidCurrency': paidCurrency,
    'paidAmountMinor': paidAmountMinor,
    'employeeStatedRate': employeeStatedRate,
    'rateUsed': rateUsed,
    'companyCurrencyAmountMinor': companyCurrencyAmountMinor,
    'sortOrder': sortOrder,
    'receiptId': receiptId,
    'decision': decision?.toJson(),
  };

  static SyncClaimItem fromJson(Map<String, dynamic> json) {
    final decisionRaw = json['decision'];
    return SyncClaimItem(
      id: json['id'] as String,
      claimId: json['claimId'] as String,
      categoryId: json['categoryId'] as String,
      expenseDate: json['expenseDate'] as String,
      description: json['description'] as String?,
      paidCurrency: json['paidCurrency'] as String,
      paidAmountMinor: json['paidAmountMinor'] as int,
      employeeStatedRate: (json['employeeStatedRate'] as num?)?.toDouble(),
      rateUsed: (json['rateUsed'] as num?)?.toDouble(),
      companyCurrencyAmountMinor: json['companyCurrencyAmountMinor'] as int,
      sortOrder: json['sortOrder'] as int,
      receiptId: json['receiptId'] as String?,
      decision: decisionRaw == null
          ? null
          : SyncClaimDecision.fromJson(
              Map<String, dynamic>.from(decisionRaw as Map),
            ),
    );
  }
}

class SyncClaimDecision {
  const SyncClaimDecision({
    required this.id,
    required this.claimItemId,
    required this.kind,
    required this.decidedByDeviceId,
    required this.decidedAt,
    this.approvedAmountMinor,
    this.reason,
    this.postedEntryId,
  });

  final String id;
  final String claimItemId;
  final String kind;
  final String decidedByDeviceId;
  final DateTime decidedAt;
  final int? approvedAmountMinor;
  final String? reason;
  final String? postedEntryId;

  Map<String, Object?> toJson() => {
    'id': id,
    'claimItemId': claimItemId,
    'kind': kind,
    'decidedByDeviceId': decidedByDeviceId,
    'decidedAt': decidedAt.toUtc().toIso8601String(),
    'approvedAmountMinor': approvedAmountMinor,
    'reason': reason,
    'postedEntryId': postedEntryId,
  };

  static SyncClaimDecision fromJson(Map<String, dynamic> json) =>
      SyncClaimDecision(
        id: json['id'] as String,
        claimItemId: json['claimItemId'] as String,
        kind: json['kind'] as String,
        decidedByDeviceId: json['decidedByDeviceId'] as String,
        decidedAt: DateTime.parse(json['decidedAt'] as String),
        approvedAmountMinor: json['approvedAmountMinor'] as int?,
        reason: json['reason'] as String?,
        postedEntryId: json['postedEntryId'] as String?,
      );
}

/// Batch of claims for Peer Sync. Rejects private-key fields.
class ClaimBatch {
  const ClaimBatch({required this.claims});

  final List<SyncClaim> claims;

  Map<String, Object?> toJson() => {
    'kind': ClaimSyncMessageKind.claimBatch.name,
    'claims': claims.map((c) => c.toJson()).toList(),
  };

  static ClaimBatch fromJson(Map<String, dynamic> json) {
    if (syncPayloadContainsPrivateKeyMaterial(jsonEncode(json))) {
      throw const FormatException(
        'ClaimBatch must not include private key material.',
      );
    }
    final claimsRaw = json['claims'];
    if (claimsRaw is! List) {
      throw const FormatException('ClaimBatch.claims must be a list.');
    }
    return ClaimBatch(
      claims: claimsRaw
          .map((c) => SyncClaim.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList(),
    );
  }

  String encode() => jsonEncode(toJson());

  static ClaimBatch decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('ClaimBatch must be a JSON object.');
    }
    return fromJson(Map<String, dynamic>.from(decoded));
  }
}

class AdvanceOps {
  const AdvanceOps({required this.advances});

  final List<SyncAdvance> advances;

  Map<String, Object?> toJson() => {
    'kind': ClaimSyncMessageKind.advanceOps.name,
    'advances': advances.map((a) => a.toJson()).toList(),
  };

  static AdvanceOps fromJson(Map<String, dynamic> json) {
    if (syncPayloadContainsPrivateKeyMaterial(jsonEncode(json))) {
      throw const FormatException(
        'AdvanceOps must not include private key material.',
      );
    }
    final raw = json['advances'];
    if (raw is! List) {
      throw const FormatException('AdvanceOps.advances must be a list.');
    }
    return AdvanceOps(
      advances: raw
          .map((a) => SyncAdvance.fromJson(Map<String, dynamic>.from(a as Map)))
          .toList(),
    );
  }

  String encode() => jsonEncode(toJson());

  static AdvanceOps decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('AdvanceOps must be a JSON object.');
    }
    return fromJson(Map<String, dynamic>.from(decoded));
  }
}

class SyncAdvance {
  const SyncAdvance({
    required this.id,
    required this.claimantDeviceId,
    required this.amountMinor,
    required this.paidFromAccountId,
    required this.postedEntryId,
    required this.recordedAt,
    this.description,
  });

  final String id;
  final String claimantDeviceId;
  final int amountMinor;
  final String paidFromAccountId;
  final String postedEntryId;
  final DateTime recordedAt;
  final String? description;

  Map<String, Object?> toJson() => {
    'id': id,
    'claimantDeviceId': claimantDeviceId,
    'amountMinor': amountMinor,
    'paidFromAccountId': paidFromAccountId,
    'postedEntryId': postedEntryId,
    'recordedAt': recordedAt.toUtc().toIso8601String(),
    'description': description,
  };

  static SyncAdvance fromJson(Map<String, dynamic> json) => SyncAdvance(
    id: json['id'] as String,
    claimantDeviceId: json['claimantDeviceId'] as String,
    amountMinor: json['amountMinor'] as int,
    paidFromAccountId: json['paidFromAccountId'] as String,
    postedEntryId: json['postedEntryId'] as String,
    recordedAt: DateTime.parse(json['recordedAt'] as String),
    description: json['description'] as String?,
  );
}

/// Filters outbound sync content for a Claimant-only peer (design Decision 4).
abstract final class ClaimantSyncFilter {
  /// Keeps only claims belonging to [claimantDeviceId].
  static ClaimBatch filterClaims({
    required ClaimBatch batch,
    required String claimantDeviceId,
  }) {
    return ClaimBatch(
      claims: batch.claims
          .where((c) => c.claimantDeviceId == claimantDeviceId)
          .toList(),
    );
  }

  /// Keeps only advances for [claimantDeviceId].
  static AdvanceOps filterAdvances({
    required AdvanceOps ops,
    required String claimantDeviceId,
  }) {
    return AdvanceOps(
      advances: ops.advances
          .where((a) => a.claimantDeviceId == claimantDeviceId)
          .toList(),
    );
  }

  /// Entry batches for Claimant peers: only entries that post to one of
  /// [allowedAccountIds] (owed-to + allowlisted categories + payment banks
  /// already reflected on owed-to). Unrelated bank register entries are
  /// dropped.
  static EntryBatch filterEntryBatch({
    required EntryBatch batch,
    required Set<String> allowedAccountIds,
  }) {
    final kept = <SyncJournalEntry>[];
    for (final entry in batch.entries) {
      final touchesAllowed = entry.postings.any(
        (p) => allowedAccountIds.contains(p.accountId),
      );
      final onlyAllowed = entry.postings.every(
        (p) => allowedAccountIds.contains(p.accountId),
      );
      // Include when every posting is on an allowed account (claim approve /
      // pay / advance shape). Drop entries that touch other bank accounts.
      if (touchesAllowed && onlyAllowed) {
        kept.add(entry);
      }
    }
    return EntryBatch(entries: kept);
  }

  /// True when [json] looks like a full bank register dump that a Claimant
  /// must not receive (contract helper for tests).
  static bool containsForeignBankEntry({
    required EntryBatch batch,
    required Set<String> allowedAccountIds,
  }) {
    for (final entry in batch.entries) {
      for (final p in entry.postings) {
        if (!allowedAccountIds.contains(p.accountId)) return true;
      }
    }
    return false;
  }
}
