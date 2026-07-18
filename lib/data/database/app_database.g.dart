// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AccountType>($AccountsTable.$convertertype);
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, archivedAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $AccountsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountType, String, String> $convertertype =
      const EnumNameConverter<AccountType>(AccountType.values);
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String id;
  final String name;
  final AccountType type;
  final DateTime? archivedAt;
  final DateTime createdAt;
  const AccountRow({
    required this.id,
    required this.name,
    required this.type,
    this.archivedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($AccountsTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      createdAt: Value(createdAt),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $AccountsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $AccountsTable.$convertertype.toJson(type),
      ),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AccountRow copyWith({
    String? id,
    String? name,
    AccountType? type,
    Value<DateTime?> archivedAt = const Value.absent(),
    DateTime? createdAt,
  }) => AccountRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, archivedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.archivedAt == this.archivedAt &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<AccountType> type;
  final Value<DateTime?> archivedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AccountType type,
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<DateTime>? archivedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<AccountType>? type,
    Value<DateTime?>? archivedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $AccountsTable.$convertertype.toSql(type.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<String> transactionDate = GeneratedColumn<String>(
    'transaction_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversesEntryIdMeta = const VerificationMeta(
    'reversesEntryId',
  );
  @override
  late final GeneratedColumn<String> reversesEntryId = GeneratedColumn<String>(
    'reverses_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journal_entries (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionDate,
    recordedAt,
    description,
    reversesEntryId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('reverses_entry_id')) {
      context.handle(
        _reversesEntryIdMeta,
        reversesEntryId.isAcceptableOrUnknown(
          data['reverses_entry_id']!,
          _reversesEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_date'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      reversesEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_entry_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntryRow extends DataClass implements Insertable<JournalEntryRow> {
  final String id;

  /// User-supplied, date only (no time-of-day) - stored as an ISO-8601
  /// date string ("YYYY-MM-DD"), never derived from [recordedAt].
  final String transactionDate;

  /// System-captured at the moment of posting via `DateTime.now()`.
  /// No code path accepts a client-provided value here.
  final DateTime recordedAt;
  final String? description;
  final String? reversesEntryId;
  final DateTime createdAt;
  const JournalEntryRow({
    required this.id,
    required this.transactionDate,
    required this.recordedAt,
    this.description,
    this.reversesEntryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_date'] = Variable<String>(transactionDate);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || reversesEntryId != null) {
      map['reverses_entry_id'] = Variable<String>(reversesEntryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      transactionDate: Value(transactionDate),
      recordedAt: Value(recordedAt),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      reversesEntryId: reversesEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesEntryId),
      createdAt: Value(createdAt),
    );
  }

  factory JournalEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntryRow(
      id: serializer.fromJson<String>(json['id']),
      transactionDate: serializer.fromJson<String>(json['transactionDate']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      description: serializer.fromJson<String?>(json['description']),
      reversesEntryId: serializer.fromJson<String?>(json['reversesEntryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionDate': serializer.toJson<String>(transactionDate),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'description': serializer.toJson<String?>(description),
      'reversesEntryId': serializer.toJson<String?>(reversesEntryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  JournalEntryRow copyWith({
    String? id,
    String? transactionDate,
    DateTime? recordedAt,
    Value<String?> description = const Value.absent(),
    Value<String?> reversesEntryId = const Value.absent(),
    DateTime? createdAt,
  }) => JournalEntryRow(
    id: id ?? this.id,
    transactionDate: transactionDate ?? this.transactionDate,
    recordedAt: recordedAt ?? this.recordedAt,
    description: description.present ? description.value : this.description,
    reversesEntryId: reversesEntryId.present
        ? reversesEntryId.value
        : this.reversesEntryId,
    createdAt: createdAt ?? this.createdAt,
  );
  JournalEntryRow copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntryRow(
      id: data.id.present ? data.id.value : this.id,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      description: data.description.present
          ? data.description.value
          : this.description,
      reversesEntryId: data.reversesEntryId.present
          ? data.reversesEntryId.value
          : this.reversesEntryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntryRow(')
          ..write('id: $id, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('description: $description, ')
          ..write('reversesEntryId: $reversesEntryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionDate,
    recordedAt,
    description,
    reversesEntryId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntryRow &&
          other.id == this.id &&
          other.transactionDate == this.transactionDate &&
          other.recordedAt == this.recordedAt &&
          other.description == this.description &&
          other.reversesEntryId == this.reversesEntryId &&
          other.createdAt == this.createdAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntryRow> {
  final Value<String> id;
  final Value<String> transactionDate;
  final Value<DateTime> recordedAt;
  final Value<String?> description;
  final Value<String?> reversesEntryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.description = const Value.absent(),
    this.reversesEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String transactionDate,
    required DateTime recordedAt,
    this.description = const Value.absent(),
    this.reversesEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : transactionDate = Value(transactionDate),
       recordedAt = Value(recordedAt);
  static Insertable<JournalEntryRow> custom({
    Expression<String>? id,
    Expression<String>? transactionDate,
    Expression<DateTime>? recordedAt,
    Expression<String>? description,
    Expression<String>? reversesEntryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (description != null) 'description': description,
      if (reversesEntryId != null) 'reverses_entry_id': reversesEntryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionDate,
    Value<DateTime>? recordedAt,
    Value<String?>? description,
    Value<String?>? reversesEntryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      transactionDate: transactionDate ?? this.transactionDate,
      recordedAt: recordedAt ?? this.recordedAt,
      description: description ?? this.description,
      reversesEntryId: reversesEntryId ?? this.reversesEntryId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<String>(transactionDate.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (reversesEntryId.present) {
      map['reverses_entry_id'] = Variable<String>(reversesEntryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('description: $description, ')
          ..write('reversesEntryId: $reversesEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostingsTable extends Postings
    with TableInfo<$PostingsTable, PostingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journal_entries (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineNumberMeta = const VerificationMeta(
    'lineNumber',
  );
  @override
  late final GeneratedColumn<int> lineNumber = GeneratedColumn<int>(
    'line_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    accountId,
    amountMinor,
    lineNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'postings';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('line_number')) {
      context.handle(
        _lineNumberMeta,
        lineNumber.isAcceptableOrUnknown(data['line_number']!, _lineNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      lineNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_number'],
      )!,
    );
  }

  @override
  $PostingsTable createAlias(String alias) {
    return $PostingsTable(attachedDatabase, alias);
  }
}

class PostingRow extends DataClass implements Insertable<PostingRow> {
  final String id;
  final String entryId;
  final String accountId;

  /// Signed minor-unit amount (e.g. cents). Recording money in sets the
  /// asset posting to +amount and the income-category posting to -amount;
  /// money out is the reverse.
  final int amountMinor;
  final int lineNumber;
  const PostingRow({
    required this.id,
    required this.entryId,
    required this.accountId,
    required this.amountMinor,
    required this.lineNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['account_id'] = Variable<String>(accountId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['line_number'] = Variable<int>(lineNumber);
    return map;
  }

  PostingsCompanion toCompanion(bool nullToAbsent) {
    return PostingsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      accountId: Value(accountId),
      amountMinor: Value(amountMinor),
      lineNumber: Value(lineNumber),
    );
  }

  factory PostingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostingRow(
      id: serializer.fromJson<String>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      lineNumber: serializer.fromJson<int>(json['lineNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryId': serializer.toJson<String>(entryId),
      'accountId': serializer.toJson<String>(accountId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'lineNumber': serializer.toJson<int>(lineNumber),
    };
  }

  PostingRow copyWith({
    String? id,
    String? entryId,
    String? accountId,
    int? amountMinor,
    int? lineNumber,
  }) => PostingRow(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    accountId: accountId ?? this.accountId,
    amountMinor: amountMinor ?? this.amountMinor,
    lineNumber: lineNumber ?? this.lineNumber,
  );
  PostingRow copyWithCompanion(PostingsCompanion data) {
    return PostingRow(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      lineNumber: data.lineNumber.present
          ? data.lineNumber.value
          : this.lineNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostingRow(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('accountId: $accountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('lineNumber: $lineNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entryId, accountId, amountMinor, lineNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostingRow &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.accountId == this.accountId &&
          other.amountMinor == this.amountMinor &&
          other.lineNumber == this.lineNumber);
}

class PostingsCompanion extends UpdateCompanion<PostingRow> {
  final Value<String> id;
  final Value<String> entryId;
  final Value<String> accountId;
  final Value<int> amountMinor;
  final Value<int> lineNumber;
  final Value<int> rowid;
  const PostingsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.lineNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostingsCompanion.insert({
    this.id = const Value.absent(),
    required String entryId,
    required String accountId,
    required int amountMinor,
    required int lineNumber,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       accountId = Value(accountId),
       amountMinor = Value(amountMinor),
       lineNumber = Value(lineNumber);
  static Insertable<PostingRow> custom({
    Expression<String>? id,
    Expression<String>? entryId,
    Expression<String>? accountId,
    Expression<int>? amountMinor,
    Expression<int>? lineNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (accountId != null) 'account_id': accountId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (lineNumber != null) 'line_number': lineNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostingsCompanion copyWith({
    Value<String>? id,
    Value<String>? entryId,
    Value<String>? accountId,
    Value<int>? amountMinor,
    Value<int>? lineNumber,
    Value<int>? rowid,
  }) {
    return PostingsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      accountId: accountId ?? this.accountId,
      amountMinor: amountMinor ?? this.amountMinor,
      lineNumber: lineNumber ?? this.lineNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (lineNumber.present) {
      map['line_number'] = Variable<int>(lineNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostingsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('accountId: $accountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('lineNumber: $lineNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $PostingsTable postings = $PostingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    journalEntries,
    postings,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      required String name,
      required AccountType type,
      Value<DateTime?> archivedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<AccountType> type,
      Value<DateTime?> archivedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PostingsTable, List<PostingRow>>
  _postingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.postings,
    aliasName: 'accounts__id__postings__account_id',
  );

  $$PostingsTableProcessedTableManager get postingsRefs {
    final manager = $$PostingsTableTableManager(
      $_db,
      $_db.postings,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_postingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountType, AccountType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> postingsRefs(
    Expression<bool> Function($$PostingsTableFilterComposer f) f,
  ) {
    final $$PostingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postings,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostingsTableFilterComposer(
            $db: $db,
            $table: $db.postings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> postingsRefs<T extends Object>(
    Expression<T> Function($$PostingsTableAnnotationComposer a) f,
  ) {
    final $$PostingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postings,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostingsTableAnnotationComposer(
            $db: $db,
            $table: $db.postings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRow, $$AccountsTableReferences),
          AccountRow,
          PrefetchHooks Function({bool postingsRefs})
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AccountType> type = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                type: type,
                archivedAt: archivedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required AccountType type,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                type: type,
                archivedAt: archivedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (postingsRefs) db.postings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postingsRefs)
                    await $_getPrefetchedData<
                      AccountRow,
                      $AccountsTable,
                      PostingRow
                    >(
                      currentTable: table,
                      referencedTable: $$AccountsTableReferences
                          ._postingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AccountsTableReferences(db, table, p0).postingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.accountId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, $$AccountsTableReferences),
      AccountRow,
      PrefetchHooks Function({bool postingsRefs})
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      required String transactionDate,
      required DateTime recordedAt,
      Value<String?> description,
      Value<String?> reversesEntryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<String> transactionDate,
      Value<DateTime> recordedAt,
      Value<String?> description,
      Value<String?> reversesEntryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$JournalEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntryRow> {
  $$JournalEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JournalEntriesTable _reversesEntryIdTable(_$AppDatabase db) => db
      .journalEntries
      .createAlias('journal_entries__reverses_entry_id__journal_entries__id');

  $$JournalEntriesTableProcessedTableManager? get reversesEntryId {
    final $_column = $_itemColumn<String>('reverses_entry_id');
    if ($_column == null) return null;
    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reversesEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PostingsTable, List<PostingRow>>
  _postingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.postings,
    aliasName: 'journal_entries__id__postings__entry_id',
  );

  $$PostingsTableProcessedTableManager get postingsRefs {
    final manager = $$PostingsTableTableManager(
      $_db,
      $_db.postings,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_postingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalEntriesTableFilterComposer get reversesEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesEntryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableFilterComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> postingsRefs(
    Expression<bool> Function($$PostingsTableFilterComposer f) f,
  ) {
    final $$PostingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postings,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostingsTableFilterComposer(
            $db: $db,
            $table: $db.postings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalEntriesTableOrderingComposer get reversesEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesEntryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$JournalEntriesTableAnnotationComposer get reversesEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesEntryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> postingsRefs<T extends Object>(
    Expression<T> Function($$PostingsTableAnnotationComposer a) f,
  ) {
    final $$PostingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postings,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostingsTableAnnotationComposer(
            $db: $db,
            $table: $db.postings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntryRow,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (JournalEntryRow, $$JournalEntriesTableReferences),
          JournalEntryRow,
          PrefetchHooks Function({bool reversesEntryId, bool postingsRefs})
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionDate = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> reversesEntryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                transactionDate: transactionDate,
                recordedAt: recordedAt,
                description: description,
                reversesEntryId: reversesEntryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String transactionDate,
                required DateTime recordedAt,
                Value<String?> description = const Value.absent(),
                Value<String?> reversesEntryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                transactionDate: transactionDate,
                recordedAt: recordedAt,
                description: description,
                reversesEntryId: reversesEntryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JournalEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({reversesEntryId = false, postingsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (postingsRefs) db.postings],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (reversesEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.reversesEntryId,
                                    referencedTable:
                                        $$JournalEntriesTableReferences
                                            ._reversesEntryIdTable(db),
                                    referencedColumn:
                                        $$JournalEntriesTableReferences
                                            ._reversesEntryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (postingsRefs)
                        await $_getPrefetchedData<
                          JournalEntryRow,
                          $JournalEntriesTable,
                          PostingRow
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._postingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).postingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntryRow,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (JournalEntryRow, $$JournalEntriesTableReferences),
      JournalEntryRow,
      PrefetchHooks Function({bool reversesEntryId, bool postingsRefs})
    >;
typedef $$PostingsTableCreateCompanionBuilder =
    PostingsCompanion Function({
      Value<String> id,
      required String entryId,
      required String accountId,
      required int amountMinor,
      required int lineNumber,
      Value<int> rowid,
    });
typedef $$PostingsTableUpdateCompanionBuilder =
    PostingsCompanion Function({
      Value<String> id,
      Value<String> entryId,
      Value<String> accountId,
      Value<int> amountMinor,
      Value<int> lineNumber,
      Value<int> rowid,
    });

final class $$PostingsTableReferences
    extends BaseReferences<_$AppDatabase, $PostingsTable, PostingRow> {
  $$PostingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JournalEntriesTable _entryIdTable(_$AppDatabase db) =>
      db.journalEntries.createAlias('postings__entry_id__journal_entries__id');

  $$JournalEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('postings__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PostingsTableFilterComposer
    extends Composer<_$AppDatabase, $PostingsTable> {
  $$PostingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalEntriesTableFilterComposer get entryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableFilterComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostingsTable> {
  $$PostingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalEntriesTableOrderingComposer get entryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostingsTable> {
  $$PostingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => column,
  );

  $$JournalEntriesTableAnnotationComposer get entryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostingsTable,
          PostingRow,
          $$PostingsTableFilterComposer,
          $$PostingsTableOrderingComposer,
          $$PostingsTableAnnotationComposer,
          $$PostingsTableCreateCompanionBuilder,
          $$PostingsTableUpdateCompanionBuilder,
          (PostingRow, $$PostingsTableReferences),
          PostingRow,
          PrefetchHooks Function({bool entryId, bool accountId})
        > {
  $$PostingsTableTableManager(_$AppDatabase db, $PostingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> lineNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostingsCompanion(
                id: id,
                entryId: entryId,
                accountId: accountId,
                amountMinor: amountMinor,
                lineNumber: lineNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String entryId,
                required String accountId,
                required int amountMinor,
                required int lineNumber,
                Value<int> rowid = const Value.absent(),
              }) => PostingsCompanion.insert(
                id: id,
                entryId: entryId,
                accountId: accountId,
                amountMinor: amountMinor,
                lineNumber: lineNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PostingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$PostingsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$PostingsTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable: $$PostingsTableReferences
                                    ._accountIdTable(db),
                                referencedColumn: $$PostingsTableReferences
                                    ._accountIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PostingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostingsTable,
      PostingRow,
      $$PostingsTableFilterComposer,
      $$PostingsTableOrderingComposer,
      $$PostingsTableAnnotationComposer,
      $$PostingsTableCreateCompanionBuilder,
      $$PostingsTableUpdateCompanionBuilder,
      (PostingRow, $$PostingsTableReferences),
      PostingRow,
      PrefetchHooks Function({bool entryId, bool accountId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$PostingsTableTableManager get postings =>
      $$PostingsTableTableManager(_db, _db.postings);
}
