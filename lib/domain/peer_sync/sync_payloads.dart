import 'dart:convert';

/// Length-prefixed sync message kinds (design Decision 2).
enum SyncMessageKind { entryBatch, metadataOps, noticeOps }

/// One signed journal entry (plus postings) as carried in an [EntryBatch].
/// Includes [previousEntryHash] so the peer can verify the chain link.
class SyncJournalEntry {
  const SyncJournalEntry({
    required this.id,
    required this.transactionDate,
    required this.recordedAt,
    required this.description,
    required this.reversesEntryId,
    required this.deviceChainSequence,
    required this.previousEntryHash,
    required this.entryHash,
    required this.signedByIdentityId,
    required this.signature,
    required this.postings,
    this.migratedFromEntryId,
  });

  final String id;
  final String transactionDate;
  final DateTime recordedAt;
  final String? description;
  final String? reversesEntryId;
  final int deviceChainSequence;
  final List<int> previousEntryHash;
  final List<int> entryHash;
  final String signedByIdentityId;
  final List<int> signature;
  final String? migratedFromEntryId;
  final List<SyncPosting> postings;

  Map<String, Object?> toJson() => {
    'id': id,
    'transactionDate': transactionDate,
    'recordedAt': recordedAt.toUtc().toIso8601String(),
    'description': description,
    'reversesEntryId': reversesEntryId,
    'deviceChainSequence': deviceChainSequence,
    'previousEntryHash': base64Encode(previousEntryHash),
    'entryHash': base64Encode(entryHash),
    'signedByIdentityId': signedByIdentityId,
    'signature': base64Encode(signature),
    'migratedFromEntryId': migratedFromEntryId,
    'postings': postings.map((p) => p.toJson()).toList(),
  };

  static SyncJournalEntry fromJson(Map<String, dynamic> json) {
    final postingsRaw = json['postings'];
    if (postingsRaw is! List) {
      throw const FormatException('SyncJournalEntry.postings must be a list.');
    }
    return SyncJournalEntry(
      id: json['id'] as String,
      transactionDate: json['transactionDate'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      description: json['description'] as String?,
      reversesEntryId: json['reversesEntryId'] as String?,
      deviceChainSequence: json['deviceChainSequence'] as int,
      previousEntryHash: base64Decode(json['previousEntryHash'] as String),
      entryHash: base64Decode(json['entryHash'] as String),
      signedByIdentityId: json['signedByIdentityId'] as String,
      signature: base64Decode(json['signature'] as String),
      migratedFromEntryId: json['migratedFromEntryId'] as String?,
      postings: postingsRaw
          .map((p) => SyncPosting.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList(),
    );
  }
}

class SyncPosting {
  const SyncPosting({
    required this.accountId,
    required this.amountMinor,
    required this.lineNumber,
  });

  final String accountId;
  final int amountMinor;
  final int lineNumber;

  Map<String, Object?> toJson() => {
    'accountId': accountId,
    'amountMinor': amountMinor,
    'lineNumber': lineNumber,
  };

  static SyncPosting fromJson(Map<String, dynamic> json) => SyncPosting(
    accountId: json['accountId'] as String,
    amountMinor: json['amountMinor'] as int,
    lineNumber: json['lineNumber'] as int,
  );
}

/// Ordered journal entries the peer is missing, keyed by identity +
/// `deviceChainSequence` (design Decision 2).
class EntryBatch {
  const EntryBatch({required this.entries});

  final List<SyncJournalEntry> entries;

  Map<String, Object?> toJson() => {
    'kind': SyncMessageKind.entryBatch.name,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  static EntryBatch fromJson(Map<String, dynamic> json) {
    _rejectPrivateKeys(json);
    final entriesRaw = json['entries'];
    if (entriesRaw is! List) {
      throw const FormatException('EntryBatch.entries must be a list.');
    }
    return EntryBatch(
      entries: entriesRaw
          .map(
            (e) =>
                SyncJournalEntry.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }

  String encode() => jsonEncode(toJson());

  static EntryBatch decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('EntryBatch must be a JSON object.');
    }
    return fromJson(Map<String, dynamic>.from(decoded));
  }
}

/// Category / account / payee / template / membership / translation /
/// settings ops with per-field timestamps (design Decision 2 / 7 / 9).
class MetadataOps {
  const MetadataOps({required this.operations});

  final List<MetadataOperation> operations;

  Map<String, Object?> toJson() => {
    'kind': SyncMessageKind.metadataOps.name,
    'operations': operations.map((o) => o.toJson()).toList(),
  };

  static MetadataOps fromJson(Map<String, dynamic> json) {
    _rejectPrivateKeys(json);
    final opsRaw = json['operations'];
    if (opsRaw is! List) {
      throw const FormatException('MetadataOps.operations must be a list.');
    }
    return MetadataOps(
      operations: opsRaw
          .map(
            (o) =>
                MetadataOperation.fromJson(Map<String, dynamic>.from(o as Map)),
          )
          .toList(),
    );
  }

  String encode() => jsonEncode(toJson());

  static MetadataOps decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('MetadataOps must be a JSON object.');
    }
    return fromJson(Map<String, dynamic>.from(decoded));
  }
}

class MetadataOperation {
  const MetadataOperation({
    required this.entityType,
    required this.entityId,
    required this.field,
    required this.value,
    required this.updatedAt,
    required this.updatedByIdentityId,
    this.hlcCounter = 0,
    this.hlcDeviceId = '',
  });

  final String entityType;
  final String entityId;
  final String field;
  final Object? value;

  /// Wall component of the hybrid logical clock (UTC).
  final DateTime updatedAt;
  final String updatedByIdentityId;

  /// Logical counter within [updatedAt] (task 5.2).
  final int hlcCounter;

  /// Device id that minted the stamp (tie-break / HLC node id).
  final String hlcDeviceId;

  Map<String, Object?> toJson() => {
    'entityType': entityType,
    'entityId': entityId,
    'field': field,
    'value': value,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'updatedByIdentityId': updatedByIdentityId,
    'hlcCounter': hlcCounter,
    'hlcDeviceId': hlcDeviceId.isEmpty ? updatedByIdentityId : hlcDeviceId,
  };

  static MetadataOperation fromJson(Map<String, dynamic> json) =>
      MetadataOperation(
        entityType: json['entityType'] as String,
        entityId: json['entityId'] as String,
        field: json['field'] as String,
        value: json['value'],
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        updatedByIdentityId: json['updatedByIdentityId'] as String,
        hlcCounter: (json['hlcCounter'] as num?)?.toInt() ?? 0,
        hlcDeviceId:
            json['hlcDeviceId'] as String? ??
            json['updatedByIdentityId'] as String? ??
            '',
      );
}

/// Membership, reject, conflict, erase-status notices (design Decision 2).
class NoticeOps {
  const NoticeOps({required this.notices});

  final List<SyncNotice> notices;

  Map<String, Object?> toJson() => {
    'kind': SyncMessageKind.noticeOps.name,
    'notices': notices.map((n) => n.toJson()).toList(),
  };

  static NoticeOps fromJson(Map<String, dynamic> json) {
    _rejectPrivateKeys(json);
    final noticesRaw = json['notices'];
    if (noticesRaw is! List) {
      throw const FormatException('NoticeOps.notices must be a list.');
    }
    return NoticeOps(
      notices: noticesRaw
          .map((n) => SyncNotice.fromJson(Map<String, dynamic>.from(n as Map)))
          .toList(),
    );
  }

  String encode() => jsonEncode(toJson());

  static NoticeOps decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('NoticeOps must be a JSON object.');
    }
    return fromJson(Map<String, dynamic>.from(decoded));
  }
}

class SyncNotice {
  const SyncNotice({
    required this.noticeId,
    required this.kind,
    required this.createdAt,
    this.relatedDeviceId,
    this.relatedDisplayName,
    this.detail,
  });

  final String noticeId;
  final String kind;
  final DateTime createdAt;
  final String? relatedDeviceId;
  final String? relatedDisplayName;
  final String? detail;

  Map<String, Object?> toJson() => {
    'noticeId': noticeId,
    'kind': kind,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'relatedDeviceId': relatedDeviceId,
    'relatedDisplayName': relatedDisplayName,
    'detail': detail,
  };

  static SyncNotice fromJson(Map<String, dynamic> json) => SyncNotice(
    noticeId: json['noticeId'] as String,
    kind: json['kind'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    relatedDeviceId: json['relatedDeviceId'] as String?,
    relatedDisplayName: json['relatedDisplayName'] as String?,
    detail: json['detail'] as String?,
  );
}

const _privateKeyKeys = {
  'privateKey',
  'private_key',
  'signingPrivateKey',
  'signing_private_key',
  'secretKey',
  'secret_key',
};

void _rejectPrivateKeys(Map<String, dynamic> json) {
  for (final key in json.keys) {
    if (_privateKeyKeys.contains(key)) {
      throw FormatException(
        'Sync payload must not include private key material ($key).',
      );
    }
  }
  for (final value in json.values) {
    if (value is Map) {
      _rejectPrivateKeys(Map<String, dynamic>.from(value));
    } else if (value is List) {
      for (final item in value) {
        if (item is Map) {
          _rejectPrivateKeys(Map<String, dynamic>.from(item));
        }
      }
    }
  }
}

/// True when [raw] JSON contains any known private-key field name.
bool syncPayloadContainsPrivateKeyMaterial(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return false;
    try {
      _rejectPrivateKeys(Map<String, dynamic>.from(decoded));
      return false;
    } on FormatException {
      return true;
    }
  } on FormatException {
    return false;
  }
}
