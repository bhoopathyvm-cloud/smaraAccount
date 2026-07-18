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

class $SigningIdentitiesTable extends SigningIdentities
    with TableInfo<$SigningIdentitiesTable, IdentityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SigningIdentitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _identityIdMeta = const VerificationMeta(
    'identityId',
  );
  @override
  late final GeneratedColumn<String> identityId = GeneratedColumn<String>(
    'identity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<Uint8List> publicKey = GeneratedColumn<Uint8List>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
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
  static const VerificationMeta _supersedesIdentityIdMeta =
      const VerificationMeta('supersedesIdentityId');
  @override
  late final GeneratedColumn<String> supersedesIdentityId =
      GeneratedColumn<String>(
        'supersedes_identity_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES signing_identities (identity_id)',
        ),
      );
  static const VerificationMeta _supersededAtMeta = const VerificationMeta(
    'supersededAt',
  );
  @override
  late final GeneratedColumn<DateTime> supersededAt = GeneratedColumn<DateTime>(
    'superseded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    identityId,
    publicKey,
    createdAt,
    supersedesIdentityId,
    supersededAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signing_identities';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdentityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('identity_id')) {
      context.handle(
        _identityIdMeta,
        identityId.isAcceptableOrUnknown(data['identity_id']!, _identityIdMeta),
      );
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('supersedes_identity_id')) {
      context.handle(
        _supersedesIdentityIdMeta,
        supersedesIdentityId.isAcceptableOrUnknown(
          data['supersedes_identity_id']!,
          _supersedesIdentityIdMeta,
        ),
      );
    }
    if (data.containsKey('superseded_at')) {
      context.handle(
        _supersededAtMeta,
        supersededAt.isAcceptableOrUnknown(
          data['superseded_at']!,
          _supersededAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {identityId};
  @override
  IdentityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentityRow(
      identityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_id'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}public_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      supersedesIdentityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_identity_id'],
      ),
      supersededAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}superseded_at'],
      ),
    );
  }

  @override
  $SigningIdentitiesTable createAlias(String alias) {
    return $SigningIdentitiesTable(attachedDatabase, alias);
  }
}

class IdentityRow extends DataClass implements Insertable<IdentityRow> {
  final String identityId;
  final Uint8List publicKey;
  final DateTime createdAt;
  final String? supersedesIdentityId;
  final DateTime? supersededAt;
  const IdentityRow({
    required this.identityId,
    required this.publicKey,
    required this.createdAt,
    this.supersedesIdentityId,
    this.supersededAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['identity_id'] = Variable<String>(identityId);
    map['public_key'] = Variable<Uint8List>(publicKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || supersedesIdentityId != null) {
      map['supersedes_identity_id'] = Variable<String>(supersedesIdentityId);
    }
    if (!nullToAbsent || supersededAt != null) {
      map['superseded_at'] = Variable<DateTime>(supersededAt);
    }
    return map;
  }

  SigningIdentitiesCompanion toCompanion(bool nullToAbsent) {
    return SigningIdentitiesCompanion(
      identityId: Value(identityId),
      publicKey: Value(publicKey),
      createdAt: Value(createdAt),
      supersedesIdentityId: supersedesIdentityId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersedesIdentityId),
      supersededAt: supersededAt == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededAt),
    );
  }

  factory IdentityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentityRow(
      identityId: serializer.fromJson<String>(json['identityId']),
      publicKey: serializer.fromJson<Uint8List>(json['publicKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      supersedesIdentityId: serializer.fromJson<String?>(
        json['supersedesIdentityId'],
      ),
      supersededAt: serializer.fromJson<DateTime?>(json['supersededAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identityId': serializer.toJson<String>(identityId),
      'publicKey': serializer.toJson<Uint8List>(publicKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'supersedesIdentityId': serializer.toJson<String?>(supersedesIdentityId),
      'supersededAt': serializer.toJson<DateTime?>(supersededAt),
    };
  }

  IdentityRow copyWith({
    String? identityId,
    Uint8List? publicKey,
    DateTime? createdAt,
    Value<String?> supersedesIdentityId = const Value.absent(),
    Value<DateTime?> supersededAt = const Value.absent(),
  }) => IdentityRow(
    identityId: identityId ?? this.identityId,
    publicKey: publicKey ?? this.publicKey,
    createdAt: createdAt ?? this.createdAt,
    supersedesIdentityId: supersedesIdentityId.present
        ? supersedesIdentityId.value
        : this.supersedesIdentityId,
    supersededAt: supersededAt.present ? supersededAt.value : this.supersededAt,
  );
  IdentityRow copyWithCompanion(SigningIdentitiesCompanion data) {
    return IdentityRow(
      identityId: data.identityId.present
          ? data.identityId.value
          : this.identityId,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      supersedesIdentityId: data.supersedesIdentityId.present
          ? data.supersedesIdentityId.value
          : this.supersedesIdentityId,
      supersededAt: data.supersededAt.present
          ? data.supersededAt.value
          : this.supersededAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentityRow(')
          ..write('identityId: $identityId, ')
          ..write('publicKey: $publicKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('supersedesIdentityId: $supersedesIdentityId, ')
          ..write('supersededAt: $supersededAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    identityId,
    $driftBlobEquality.hash(publicKey),
    createdAt,
    supersedesIdentityId,
    supersededAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentityRow &&
          other.identityId == this.identityId &&
          $driftBlobEquality.equals(other.publicKey, this.publicKey) &&
          other.createdAt == this.createdAt &&
          other.supersedesIdentityId == this.supersedesIdentityId &&
          other.supersededAt == this.supersededAt);
}

class SigningIdentitiesCompanion extends UpdateCompanion<IdentityRow> {
  final Value<String> identityId;
  final Value<Uint8List> publicKey;
  final Value<DateTime> createdAt;
  final Value<String?> supersedesIdentityId;
  final Value<DateTime?> supersededAt;
  final Value<int> rowid;
  const SigningIdentitiesCompanion({
    this.identityId = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.supersedesIdentityId = const Value.absent(),
    this.supersededAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SigningIdentitiesCompanion.insert({
    this.identityId = const Value.absent(),
    required Uint8List publicKey,
    this.createdAt = const Value.absent(),
    this.supersedesIdentityId = const Value.absent(),
    this.supersededAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : publicKey = Value(publicKey);
  static Insertable<IdentityRow> custom({
    Expression<String>? identityId,
    Expression<Uint8List>? publicKey,
    Expression<DateTime>? createdAt,
    Expression<String>? supersedesIdentityId,
    Expression<DateTime>? supersededAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (identityId != null) 'identity_id': identityId,
      if (publicKey != null) 'public_key': publicKey,
      if (createdAt != null) 'created_at': createdAt,
      if (supersedesIdentityId != null)
        'supersedes_identity_id': supersedesIdentityId,
      if (supersededAt != null) 'superseded_at': supersededAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SigningIdentitiesCompanion copyWith({
    Value<String>? identityId,
    Value<Uint8List>? publicKey,
    Value<DateTime>? createdAt,
    Value<String?>? supersedesIdentityId,
    Value<DateTime?>? supersededAt,
    Value<int>? rowid,
  }) {
    return SigningIdentitiesCompanion(
      identityId: identityId ?? this.identityId,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
      supersedesIdentityId: supersedesIdentityId ?? this.supersedesIdentityId,
      supersededAt: supersededAt ?? this.supersededAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (identityId.present) {
      map['identity_id'] = Variable<String>(identityId.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<Uint8List>(publicKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (supersedesIdentityId.present) {
      map['supersedes_identity_id'] = Variable<String>(
        supersedesIdentityId.value,
      );
    }
    if (supersededAt.present) {
      map['superseded_at'] = Variable<DateTime>(supersededAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SigningIdentitiesCompanion(')
          ..write('identityId: $identityId, ')
          ..write('publicKey: $publicKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('supersedesIdentityId: $supersedesIdentityId, ')
          ..write('supersededAt: $supersededAt, ')
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
  static const VerificationMeta _deviceChainSequenceMeta =
      const VerificationMeta('deviceChainSequence');
  @override
  late final GeneratedColumn<int> deviceChainSequence = GeneratedColumn<int>(
    'device_chain_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _previousEntryHashMeta = const VerificationMeta(
    'previousEntryHash',
  );
  @override
  late final GeneratedColumn<Uint8List> previousEntryHash =
      GeneratedColumn<Uint8List>(
        'previous_entry_hash',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _entryHashMeta = const VerificationMeta(
    'entryHash',
  );
  @override
  late final GeneratedColumn<Uint8List> entryHash = GeneratedColumn<Uint8List>(
    'entry_hash',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signedByIdentityIdMeta =
      const VerificationMeta('signedByIdentityId');
  @override
  late final GeneratedColumn<String> signedByIdentityId =
      GeneratedColumn<String>(
        'signed_by_identity_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES signing_identities (identity_id)',
        ),
      );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<Uint8List> signature = GeneratedColumn<Uint8List>(
    'signature',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _migratedFromEntryIdMeta =
      const VerificationMeta('migratedFromEntryId');
  @override
  late final GeneratedColumn<String> migratedFromEntryId =
      GeneratedColumn<String>(
        'migrated_from_entry_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES journal_entries (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionDate,
    recordedAt,
    description,
    reversesEntryId,
    createdAt,
    deviceChainSequence,
    previousEntryHash,
    entryHash,
    signedByIdentityId,
    signature,
    migratedFromEntryId,
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
    if (data.containsKey('device_chain_sequence')) {
      context.handle(
        _deviceChainSequenceMeta,
        deviceChainSequence.isAcceptableOrUnknown(
          data['device_chain_sequence']!,
          _deviceChainSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceChainSequenceMeta);
    }
    if (data.containsKey('previous_entry_hash')) {
      context.handle(
        _previousEntryHashMeta,
        previousEntryHash.isAcceptableOrUnknown(
          data['previous_entry_hash']!,
          _previousEntryHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousEntryHashMeta);
    }
    if (data.containsKey('entry_hash')) {
      context.handle(
        _entryHashMeta,
        entryHash.isAcceptableOrUnknown(data['entry_hash']!, _entryHashMeta),
      );
    } else if (isInserting) {
      context.missing(_entryHashMeta);
    }
    if (data.containsKey('signed_by_identity_id')) {
      context.handle(
        _signedByIdentityIdMeta,
        signedByIdentityId.isAcceptableOrUnknown(
          data['signed_by_identity_id']!,
          _signedByIdentityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signedByIdentityIdMeta);
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('migrated_from_entry_id')) {
      context.handle(
        _migratedFromEntryIdMeta,
        migratedFromEntryId.isAcceptableOrUnknown(
          data['migrated_from_entry_id']!,
          _migratedFromEntryIdMeta,
        ),
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
      deviceChainSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_chain_sequence'],
      )!,
      previousEntryHash: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}previous_entry_hash'],
      )!,
      entryHash: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}entry_hash'],
      )!,
      signedByIdentityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signed_by_identity_id'],
      )!,
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signature'],
      )!,
      migratedFromEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}migrated_from_entry_id'],
      ),
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

  /// Gapless, ascending position in this device's chain (ledger-integrity-signing
  /// design.md - named `device_chain_sequence`, not `sequence`, for the
  /// per-device chain this becomes once multi-device sync exists).
  final int deviceChainSequence;

  /// 32 zero bytes for the genesis entry (see [genesisPreviousEntryHash] in
  /// domain/crypto/entry_canonical_hash.dart) - never an arbitrary null.
  final Uint8List previousEntryHash;
  final Uint8List entryHash;
  final String signedByIdentityId;
  final Uint8List signature;

  /// Set only on an entry created by the true-key-loss migration flow;
  /// points at the legacy entry whose content this row preserves. The
  /// legacy row itself is left exactly as-is, never edited.
  final String? migratedFromEntryId;
  const JournalEntryRow({
    required this.id,
    required this.transactionDate,
    required this.recordedAt,
    this.description,
    this.reversesEntryId,
    required this.createdAt,
    required this.deviceChainSequence,
    required this.previousEntryHash,
    required this.entryHash,
    required this.signedByIdentityId,
    required this.signature,
    this.migratedFromEntryId,
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
    map['device_chain_sequence'] = Variable<int>(deviceChainSequence);
    map['previous_entry_hash'] = Variable<Uint8List>(previousEntryHash);
    map['entry_hash'] = Variable<Uint8List>(entryHash);
    map['signed_by_identity_id'] = Variable<String>(signedByIdentityId);
    map['signature'] = Variable<Uint8List>(signature);
    if (!nullToAbsent || migratedFromEntryId != null) {
      map['migrated_from_entry_id'] = Variable<String>(migratedFromEntryId);
    }
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
      deviceChainSequence: Value(deviceChainSequence),
      previousEntryHash: Value(previousEntryHash),
      entryHash: Value(entryHash),
      signedByIdentityId: Value(signedByIdentityId),
      signature: Value(signature),
      migratedFromEntryId: migratedFromEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(migratedFromEntryId),
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
      deviceChainSequence: serializer.fromJson<int>(
        json['deviceChainSequence'],
      ),
      previousEntryHash: serializer.fromJson<Uint8List>(
        json['previousEntryHash'],
      ),
      entryHash: serializer.fromJson<Uint8List>(json['entryHash']),
      signedByIdentityId: serializer.fromJson<String>(
        json['signedByIdentityId'],
      ),
      signature: serializer.fromJson<Uint8List>(json['signature']),
      migratedFromEntryId: serializer.fromJson<String?>(
        json['migratedFromEntryId'],
      ),
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
      'deviceChainSequence': serializer.toJson<int>(deviceChainSequence),
      'previousEntryHash': serializer.toJson<Uint8List>(previousEntryHash),
      'entryHash': serializer.toJson<Uint8List>(entryHash),
      'signedByIdentityId': serializer.toJson<String>(signedByIdentityId),
      'signature': serializer.toJson<Uint8List>(signature),
      'migratedFromEntryId': serializer.toJson<String?>(migratedFromEntryId),
    };
  }

  JournalEntryRow copyWith({
    String? id,
    String? transactionDate,
    DateTime? recordedAt,
    Value<String?> description = const Value.absent(),
    Value<String?> reversesEntryId = const Value.absent(),
    DateTime? createdAt,
    int? deviceChainSequence,
    Uint8List? previousEntryHash,
    Uint8List? entryHash,
    String? signedByIdentityId,
    Uint8List? signature,
    Value<String?> migratedFromEntryId = const Value.absent(),
  }) => JournalEntryRow(
    id: id ?? this.id,
    transactionDate: transactionDate ?? this.transactionDate,
    recordedAt: recordedAt ?? this.recordedAt,
    description: description.present ? description.value : this.description,
    reversesEntryId: reversesEntryId.present
        ? reversesEntryId.value
        : this.reversesEntryId,
    createdAt: createdAt ?? this.createdAt,
    deviceChainSequence: deviceChainSequence ?? this.deviceChainSequence,
    previousEntryHash: previousEntryHash ?? this.previousEntryHash,
    entryHash: entryHash ?? this.entryHash,
    signedByIdentityId: signedByIdentityId ?? this.signedByIdentityId,
    signature: signature ?? this.signature,
    migratedFromEntryId: migratedFromEntryId.present
        ? migratedFromEntryId.value
        : this.migratedFromEntryId,
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
      deviceChainSequence: data.deviceChainSequence.present
          ? data.deviceChainSequence.value
          : this.deviceChainSequence,
      previousEntryHash: data.previousEntryHash.present
          ? data.previousEntryHash.value
          : this.previousEntryHash,
      entryHash: data.entryHash.present ? data.entryHash.value : this.entryHash,
      signedByIdentityId: data.signedByIdentityId.present
          ? data.signedByIdentityId.value
          : this.signedByIdentityId,
      signature: data.signature.present ? data.signature.value : this.signature,
      migratedFromEntryId: data.migratedFromEntryId.present
          ? data.migratedFromEntryId.value
          : this.migratedFromEntryId,
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
          ..write('createdAt: $createdAt, ')
          ..write('deviceChainSequence: $deviceChainSequence, ')
          ..write('previousEntryHash: $previousEntryHash, ')
          ..write('entryHash: $entryHash, ')
          ..write('signedByIdentityId: $signedByIdentityId, ')
          ..write('signature: $signature, ')
          ..write('migratedFromEntryId: $migratedFromEntryId')
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
    deviceChainSequence,
    $driftBlobEquality.hash(previousEntryHash),
    $driftBlobEquality.hash(entryHash),
    signedByIdentityId,
    $driftBlobEquality.hash(signature),
    migratedFromEntryId,
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
          other.createdAt == this.createdAt &&
          other.deviceChainSequence == this.deviceChainSequence &&
          $driftBlobEquality.equals(
            other.previousEntryHash,
            this.previousEntryHash,
          ) &&
          $driftBlobEquality.equals(other.entryHash, this.entryHash) &&
          other.signedByIdentityId == this.signedByIdentityId &&
          $driftBlobEquality.equals(other.signature, this.signature) &&
          other.migratedFromEntryId == this.migratedFromEntryId);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntryRow> {
  final Value<String> id;
  final Value<String> transactionDate;
  final Value<DateTime> recordedAt;
  final Value<String?> description;
  final Value<String?> reversesEntryId;
  final Value<DateTime> createdAt;
  final Value<int> deviceChainSequence;
  final Value<Uint8List> previousEntryHash;
  final Value<Uint8List> entryHash;
  final Value<String> signedByIdentityId;
  final Value<Uint8List> signature;
  final Value<String?> migratedFromEntryId;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.description = const Value.absent(),
    this.reversesEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deviceChainSequence = const Value.absent(),
    this.previousEntryHash = const Value.absent(),
    this.entryHash = const Value.absent(),
    this.signedByIdentityId = const Value.absent(),
    this.signature = const Value.absent(),
    this.migratedFromEntryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String transactionDate,
    required DateTime recordedAt,
    this.description = const Value.absent(),
    this.reversesEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int deviceChainSequence,
    required Uint8List previousEntryHash,
    required Uint8List entryHash,
    required String signedByIdentityId,
    required Uint8List signature,
    this.migratedFromEntryId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : transactionDate = Value(transactionDate),
       recordedAt = Value(recordedAt),
       deviceChainSequence = Value(deviceChainSequence),
       previousEntryHash = Value(previousEntryHash),
       entryHash = Value(entryHash),
       signedByIdentityId = Value(signedByIdentityId),
       signature = Value(signature);
  static Insertable<JournalEntryRow> custom({
    Expression<String>? id,
    Expression<String>? transactionDate,
    Expression<DateTime>? recordedAt,
    Expression<String>? description,
    Expression<String>? reversesEntryId,
    Expression<DateTime>? createdAt,
    Expression<int>? deviceChainSequence,
    Expression<Uint8List>? previousEntryHash,
    Expression<Uint8List>? entryHash,
    Expression<String>? signedByIdentityId,
    Expression<Uint8List>? signature,
    Expression<String>? migratedFromEntryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (description != null) 'description': description,
      if (reversesEntryId != null) 'reverses_entry_id': reversesEntryId,
      if (createdAt != null) 'created_at': createdAt,
      if (deviceChainSequence != null)
        'device_chain_sequence': deviceChainSequence,
      if (previousEntryHash != null) 'previous_entry_hash': previousEntryHash,
      if (entryHash != null) 'entry_hash': entryHash,
      if (signedByIdentityId != null)
        'signed_by_identity_id': signedByIdentityId,
      if (signature != null) 'signature': signature,
      if (migratedFromEntryId != null)
        'migrated_from_entry_id': migratedFromEntryId,
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
    Value<int>? deviceChainSequence,
    Value<Uint8List>? previousEntryHash,
    Value<Uint8List>? entryHash,
    Value<String>? signedByIdentityId,
    Value<Uint8List>? signature,
    Value<String?>? migratedFromEntryId,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      transactionDate: transactionDate ?? this.transactionDate,
      recordedAt: recordedAt ?? this.recordedAt,
      description: description ?? this.description,
      reversesEntryId: reversesEntryId ?? this.reversesEntryId,
      createdAt: createdAt ?? this.createdAt,
      deviceChainSequence: deviceChainSequence ?? this.deviceChainSequence,
      previousEntryHash: previousEntryHash ?? this.previousEntryHash,
      entryHash: entryHash ?? this.entryHash,
      signedByIdentityId: signedByIdentityId ?? this.signedByIdentityId,
      signature: signature ?? this.signature,
      migratedFromEntryId: migratedFromEntryId ?? this.migratedFromEntryId,
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
    if (deviceChainSequence.present) {
      map['device_chain_sequence'] = Variable<int>(deviceChainSequence.value);
    }
    if (previousEntryHash.present) {
      map['previous_entry_hash'] = Variable<Uint8List>(previousEntryHash.value);
    }
    if (entryHash.present) {
      map['entry_hash'] = Variable<Uint8List>(entryHash.value);
    }
    if (signedByIdentityId.present) {
      map['signed_by_identity_id'] = Variable<String>(signedByIdentityId.value);
    }
    if (signature.present) {
      map['signature'] = Variable<Uint8List>(signature.value);
    }
    if (migratedFromEntryId.present) {
      map['migrated_from_entry_id'] = Variable<String>(
        migratedFromEntryId.value,
      );
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
          ..write('deviceChainSequence: $deviceChainSequence, ')
          ..write('previousEntryHash: $previousEntryHash, ')
          ..write('entryHash: $entryHash, ')
          ..write('signedByIdentityId: $signedByIdentityId, ')
          ..write('signature: $signature, ')
          ..write('migratedFromEntryId: $migratedFromEntryId, ')
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

class $EntryVerificationCacheTable extends EntryVerificationCache
    with TableInfo<$EntryVerificationCacheTable, EntryVerificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryVerificationCacheTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _isVerifiedMeta = const VerificationMeta(
    'isVerified',
  );
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
    'is_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_verified" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<VerificationBreakReason?, String>
  breakReason =
      GeneratedColumn<String>(
        'break_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<VerificationBreakReason?>(
        $EntryVerificationCacheTable.$converterbreakReasonn,
      );
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entryId,
    isVerified,
    breakReason,
    checkedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_verification_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryVerificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('is_verified')) {
      context.handle(
        _isVerifiedMeta,
        isVerified.isAcceptableOrUnknown(data['is_verified']!, _isVerifiedMeta),
      );
    } else if (isInserting) {
      context.missing(_isVerifiedMeta);
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_checkedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId};
  @override
  EntryVerificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryVerificationRow(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      isVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_verified'],
      )!,
      breakReason: $EntryVerificationCacheTable.$converterbreakReasonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}break_reason'],
        ),
      ),
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      )!,
    );
  }

  @override
  $EntryVerificationCacheTable createAlias(String alias) {
    return $EntryVerificationCacheTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<VerificationBreakReason, String, String>
  $converterbreakReason = const EnumNameConverter<VerificationBreakReason>(
    VerificationBreakReason.values,
  );
  static JsonTypeConverter2<VerificationBreakReason?, String?, String?>
  $converterbreakReasonn = JsonTypeConverter2.asNullable($converterbreakReason);
}

class EntryVerificationRow extends DataClass
    implements Insertable<EntryVerificationRow> {
  final String entryId;
  final bool isVerified;

  /// Null when [isVerified] is true.
  final VerificationBreakReason? breakReason;
  final DateTime checkedAt;
  const EntryVerificationRow({
    required this.entryId,
    required this.isVerified,
    this.breakReason,
    required this.checkedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['is_verified'] = Variable<bool>(isVerified);
    if (!nullToAbsent || breakReason != null) {
      map['break_reason'] = Variable<String>(
        $EntryVerificationCacheTable.$converterbreakReasonn.toSql(breakReason),
      );
    }
    map['checked_at'] = Variable<DateTime>(checkedAt);
    return map;
  }

  EntryVerificationCacheCompanion toCompanion(bool nullToAbsent) {
    return EntryVerificationCacheCompanion(
      entryId: Value(entryId),
      isVerified: Value(isVerified),
      breakReason: breakReason == null && nullToAbsent
          ? const Value.absent()
          : Value(breakReason),
      checkedAt: Value(checkedAt),
    );
  }

  factory EntryVerificationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryVerificationRow(
      entryId: serializer.fromJson<String>(json['entryId']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      breakReason: $EntryVerificationCacheTable.$converterbreakReasonn.fromJson(
        serializer.fromJson<String?>(json['breakReason']),
      ),
      checkedAt: serializer.fromJson<DateTime>(json['checkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'isVerified': serializer.toJson<bool>(isVerified),
      'breakReason': serializer.toJson<String?>(
        $EntryVerificationCacheTable.$converterbreakReasonn.toJson(breakReason),
      ),
      'checkedAt': serializer.toJson<DateTime>(checkedAt),
    };
  }

  EntryVerificationRow copyWith({
    String? entryId,
    bool? isVerified,
    Value<VerificationBreakReason?> breakReason = const Value.absent(),
    DateTime? checkedAt,
  }) => EntryVerificationRow(
    entryId: entryId ?? this.entryId,
    isVerified: isVerified ?? this.isVerified,
    breakReason: breakReason.present ? breakReason.value : this.breakReason,
    checkedAt: checkedAt ?? this.checkedAt,
  );
  EntryVerificationRow copyWithCompanion(EntryVerificationCacheCompanion data) {
    return EntryVerificationRow(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      isVerified: data.isVerified.present
          ? data.isVerified.value
          : this.isVerified,
      breakReason: data.breakReason.present
          ? data.breakReason.value
          : this.breakReason,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryVerificationRow(')
          ..write('entryId: $entryId, ')
          ..write('isVerified: $isVerified, ')
          ..write('breakReason: $breakReason, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, isVerified, breakReason, checkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryVerificationRow &&
          other.entryId == this.entryId &&
          other.isVerified == this.isVerified &&
          other.breakReason == this.breakReason &&
          other.checkedAt == this.checkedAt);
}

class EntryVerificationCacheCompanion
    extends UpdateCompanion<EntryVerificationRow> {
  final Value<String> entryId;
  final Value<bool> isVerified;
  final Value<VerificationBreakReason?> breakReason;
  final Value<DateTime> checkedAt;
  final Value<int> rowid;
  const EntryVerificationCacheCompanion({
    this.entryId = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.breakReason = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryVerificationCacheCompanion.insert({
    required String entryId,
    required bool isVerified,
    this.breakReason = const Value.absent(),
    required DateTime checkedAt,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       isVerified = Value(isVerified),
       checkedAt = Value(checkedAt);
  static Insertable<EntryVerificationRow> custom({
    Expression<String>? entryId,
    Expression<bool>? isVerified,
    Expression<String>? breakReason,
    Expression<DateTime>? checkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (isVerified != null) 'is_verified': isVerified,
      if (breakReason != null) 'break_reason': breakReason,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryVerificationCacheCompanion copyWith({
    Value<String>? entryId,
    Value<bool>? isVerified,
    Value<VerificationBreakReason?>? breakReason,
    Value<DateTime>? checkedAt,
    Value<int>? rowid,
  }) {
    return EntryVerificationCacheCompanion(
      entryId: entryId ?? this.entryId,
      isVerified: isVerified ?? this.isVerified,
      breakReason: breakReason ?? this.breakReason,
      checkedAt: checkedAt ?? this.checkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (breakReason.present) {
      map['break_reason'] = Variable<String>(
        $EntryVerificationCacheTable.$converterbreakReasonn.toSql(
          breakReason.value,
        ),
      );
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryVerificationCacheCompanion(')
          ..write('entryId: $entryId, ')
          ..write('isVerified: $isVerified, ')
          ..write('breakReason: $breakReason, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerChainStateTable extends LedgerChainState
    with TableInfo<$LedgerChainStateTable, ChainStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerChainStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trustedTipEntryIdMeta = const VerificationMeta(
    'trustedTipEntryId',
  );
  @override
  late final GeneratedColumn<String> trustedTipEntryId =
      GeneratedColumn<String>(
        'trusted_tip_entry_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES journal_entries (id)',
        ),
      );
  static const VerificationMeta _trustedTipHashMeta = const VerificationMeta(
    'trustedTipHash',
  );
  @override
  late final GeneratedColumn<Uint8List> trustedTipHash =
      GeneratedColumn<Uint8List>(
        'trusted_tip_hash',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextDeviceChainSequenceMeta =
      const VerificationMeta('nextDeviceChainSequence');
  @override
  late final GeneratedColumn<int> nextDeviceChainSequence =
      GeneratedColumn<int>(
        'next_device_chain_sequence',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trustedTipEntryId,
    trustedTipHash,
    nextDeviceChainSequence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_chain_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChainStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trusted_tip_entry_id')) {
      context.handle(
        _trustedTipEntryIdMeta,
        trustedTipEntryId.isAcceptableOrUnknown(
          data['trusted_tip_entry_id']!,
          _trustedTipEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('trusted_tip_hash')) {
      context.handle(
        _trustedTipHashMeta,
        trustedTipHash.isAcceptableOrUnknown(
          data['trusted_tip_hash']!,
          _trustedTipHashMeta,
        ),
      );
    }
    if (data.containsKey('next_device_chain_sequence')) {
      context.handle(
        _nextDeviceChainSequenceMeta,
        nextDeviceChainSequence.isAcceptableOrUnknown(
          data['next_device_chain_sequence']!,
          _nextDeviceChainSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextDeviceChainSequenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChainStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChainStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trustedTipEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trusted_tip_entry_id'],
      ),
      trustedTipHash: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}trusted_tip_hash'],
      ),
      nextDeviceChainSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_device_chain_sequence'],
      )!,
    );
  }

  @override
  $LedgerChainStateTable createAlias(String alias) {
    return $LedgerChainStateTable(attachedDatabase, alias);
  }
}

class ChainStateRow extends DataClass implements Insertable<ChainStateRow> {
  /// Fixed value 'singleton' - this table always has exactly one row.
  final String id;
  final String? trustedTipEntryId;
  final Uint8List? trustedTipHash;
  final int nextDeviceChainSequence;
  const ChainStateRow({
    required this.id,
    this.trustedTipEntryId,
    this.trustedTipHash,
    required this.nextDeviceChainSequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || trustedTipEntryId != null) {
      map['trusted_tip_entry_id'] = Variable<String>(trustedTipEntryId);
    }
    if (!nullToAbsent || trustedTipHash != null) {
      map['trusted_tip_hash'] = Variable<Uint8List>(trustedTipHash);
    }
    map['next_device_chain_sequence'] = Variable<int>(nextDeviceChainSequence);
    return map;
  }

  LedgerChainStateCompanion toCompanion(bool nullToAbsent) {
    return LedgerChainStateCompanion(
      id: Value(id),
      trustedTipEntryId: trustedTipEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(trustedTipEntryId),
      trustedTipHash: trustedTipHash == null && nullToAbsent
          ? const Value.absent()
          : Value(trustedTipHash),
      nextDeviceChainSequence: Value(nextDeviceChainSequence),
    );
  }

  factory ChainStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChainStateRow(
      id: serializer.fromJson<String>(json['id']),
      trustedTipEntryId: serializer.fromJson<String?>(
        json['trustedTipEntryId'],
      ),
      trustedTipHash: serializer.fromJson<Uint8List?>(json['trustedTipHash']),
      nextDeviceChainSequence: serializer.fromJson<int>(
        json['nextDeviceChainSequence'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trustedTipEntryId': serializer.toJson<String?>(trustedTipEntryId),
      'trustedTipHash': serializer.toJson<Uint8List?>(trustedTipHash),
      'nextDeviceChainSequence': serializer.toJson<int>(
        nextDeviceChainSequence,
      ),
    };
  }

  ChainStateRow copyWith({
    String? id,
    Value<String?> trustedTipEntryId = const Value.absent(),
    Value<Uint8List?> trustedTipHash = const Value.absent(),
    int? nextDeviceChainSequence,
  }) => ChainStateRow(
    id: id ?? this.id,
    trustedTipEntryId: trustedTipEntryId.present
        ? trustedTipEntryId.value
        : this.trustedTipEntryId,
    trustedTipHash: trustedTipHash.present
        ? trustedTipHash.value
        : this.trustedTipHash,
    nextDeviceChainSequence:
        nextDeviceChainSequence ?? this.nextDeviceChainSequence,
  );
  ChainStateRow copyWithCompanion(LedgerChainStateCompanion data) {
    return ChainStateRow(
      id: data.id.present ? data.id.value : this.id,
      trustedTipEntryId: data.trustedTipEntryId.present
          ? data.trustedTipEntryId.value
          : this.trustedTipEntryId,
      trustedTipHash: data.trustedTipHash.present
          ? data.trustedTipHash.value
          : this.trustedTipHash,
      nextDeviceChainSequence: data.nextDeviceChainSequence.present
          ? data.nextDeviceChainSequence.value
          : this.nextDeviceChainSequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChainStateRow(')
          ..write('id: $id, ')
          ..write('trustedTipEntryId: $trustedTipEntryId, ')
          ..write('trustedTipHash: $trustedTipHash, ')
          ..write('nextDeviceChainSequence: $nextDeviceChainSequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trustedTipEntryId,
    $driftBlobEquality.hash(trustedTipHash),
    nextDeviceChainSequence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChainStateRow &&
          other.id == this.id &&
          other.trustedTipEntryId == this.trustedTipEntryId &&
          $driftBlobEquality.equals(
            other.trustedTipHash,
            this.trustedTipHash,
          ) &&
          other.nextDeviceChainSequence == this.nextDeviceChainSequence);
}

class LedgerChainStateCompanion extends UpdateCompanion<ChainStateRow> {
  final Value<String> id;
  final Value<String?> trustedTipEntryId;
  final Value<Uint8List?> trustedTipHash;
  final Value<int> nextDeviceChainSequence;
  final Value<int> rowid;
  const LedgerChainStateCompanion({
    this.id = const Value.absent(),
    this.trustedTipEntryId = const Value.absent(),
    this.trustedTipHash = const Value.absent(),
    this.nextDeviceChainSequence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerChainStateCompanion.insert({
    required String id,
    this.trustedTipEntryId = const Value.absent(),
    this.trustedTipHash = const Value.absent(),
    required int nextDeviceChainSequence,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nextDeviceChainSequence = Value(nextDeviceChainSequence);
  static Insertable<ChainStateRow> custom({
    Expression<String>? id,
    Expression<String>? trustedTipEntryId,
    Expression<Uint8List>? trustedTipHash,
    Expression<int>? nextDeviceChainSequence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trustedTipEntryId != null) 'trusted_tip_entry_id': trustedTipEntryId,
      if (trustedTipHash != null) 'trusted_tip_hash': trustedTipHash,
      if (nextDeviceChainSequence != null)
        'next_device_chain_sequence': nextDeviceChainSequence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerChainStateCompanion copyWith({
    Value<String>? id,
    Value<String?>? trustedTipEntryId,
    Value<Uint8List?>? trustedTipHash,
    Value<int>? nextDeviceChainSequence,
    Value<int>? rowid,
  }) {
    return LedgerChainStateCompanion(
      id: id ?? this.id,
      trustedTipEntryId: trustedTipEntryId ?? this.trustedTipEntryId,
      trustedTipHash: trustedTipHash ?? this.trustedTipHash,
      nextDeviceChainSequence:
          nextDeviceChainSequence ?? this.nextDeviceChainSequence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trustedTipEntryId.present) {
      map['trusted_tip_entry_id'] = Variable<String>(trustedTipEntryId.value);
    }
    if (trustedTipHash.present) {
      map['trusted_tip_hash'] = Variable<Uint8List>(trustedTipHash.value);
    }
    if (nextDeviceChainSequence.present) {
      map['next_device_chain_sequence'] = Variable<int>(
        nextDeviceChainSequence.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerChainStateCompanion(')
          ..write('id: $id, ')
          ..write('trustedTipEntryId: $trustedTipEntryId, ')
          ..write('trustedTipHash: $trustedTipHash, ')
          ..write('nextDeviceChainSequence: $nextDeviceChainSequence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IntegrityEventsTable extends IntegrityEvents
    with TableInfo<$IntegrityEventsTable, IntegrityEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntegrityEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  @override
  late final GeneratedColumnWithTypeConverter<IntegrityEventType, String>
  eventType =
      GeneratedColumn<String>(
        'event_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<IntegrityEventType>(
        $IntegrityEventsTable.$convertereventType,
      );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _relatedEntryIdMeta = const VerificationMeta(
    'relatedEntryId',
  );
  @override
  late final GeneratedColumn<String> relatedEntryId = GeneratedColumn<String>(
    'related_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journal_entries (id)',
    ),
  );
  static const VerificationMeta _relatedIdentityIdMeta = const VerificationMeta(
    'relatedIdentityId',
  );
  @override
  late final GeneratedColumn<String> relatedIdentityId =
      GeneratedColumn<String>(
        'related_identity_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES signing_identities (identity_id)',
        ),
      );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    eventType,
    occurredAt,
    relatedEntryId,
    relatedIdentityId,
    detail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'integrity_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntegrityEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    }
    if (data.containsKey('related_entry_id')) {
      context.handle(
        _relatedEntryIdMeta,
        relatedEntryId.isAcceptableOrUnknown(
          data['related_entry_id']!,
          _relatedEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('related_identity_id')) {
      context.handle(
        _relatedIdentityIdMeta,
        relatedIdentityId.isAcceptableOrUnknown(
          data['related_identity_id']!,
          _relatedIdentityIdMeta,
        ),
      );
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  IntegrityEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntegrityEventRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      eventType: $IntegrityEventsTable.$convertereventType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}event_type'],
        )!,
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      relatedEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_entry_id'],
      ),
      relatedIdentityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_identity_id'],
      ),
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
    );
  }

  @override
  $IntegrityEventsTable createAlias(String alias) {
    return $IntegrityEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IntegrityEventType, String, String>
  $convertereventType = const EnumNameConverter<IntegrityEventType>(
    IntegrityEventType.values,
  );
}

class IntegrityEventRow extends DataClass
    implements Insertable<IntegrityEventRow> {
  final String eventId;
  final IntegrityEventType eventType;
  final DateTime occurredAt;
  final String? relatedEntryId;
  final String? relatedIdentityId;
  final String? detail;
  const IntegrityEventRow({
    required this.eventId,
    required this.eventType,
    required this.occurredAt,
    this.relatedEntryId,
    this.relatedIdentityId,
    this.detail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    {
      map['event_type'] = Variable<String>(
        $IntegrityEventsTable.$convertereventType.toSql(eventType),
      );
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || relatedEntryId != null) {
      map['related_entry_id'] = Variable<String>(relatedEntryId);
    }
    if (!nullToAbsent || relatedIdentityId != null) {
      map['related_identity_id'] = Variable<String>(relatedIdentityId);
    }
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  IntegrityEventsCompanion toCompanion(bool nullToAbsent) {
    return IntegrityEventsCompanion(
      eventId: Value(eventId),
      eventType: Value(eventType),
      occurredAt: Value(occurredAt),
      relatedEntryId: relatedEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEntryId),
      relatedIdentityId: relatedIdentityId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedIdentityId),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
    );
  }

  factory IntegrityEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntegrityEventRow(
      eventId: serializer.fromJson<String>(json['eventId']),
      eventType: $IntegrityEventsTable.$convertereventType.fromJson(
        serializer.fromJson<String>(json['eventType']),
      ),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      relatedEntryId: serializer.fromJson<String?>(json['relatedEntryId']),
      relatedIdentityId: serializer.fromJson<String?>(
        json['relatedIdentityId'],
      ),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'eventType': serializer.toJson<String>(
        $IntegrityEventsTable.$convertereventType.toJson(eventType),
      ),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'relatedEntryId': serializer.toJson<String?>(relatedEntryId),
      'relatedIdentityId': serializer.toJson<String?>(relatedIdentityId),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  IntegrityEventRow copyWith({
    String? eventId,
    IntegrityEventType? eventType,
    DateTime? occurredAt,
    Value<String?> relatedEntryId = const Value.absent(),
    Value<String?> relatedIdentityId = const Value.absent(),
    Value<String?> detail = const Value.absent(),
  }) => IntegrityEventRow(
    eventId: eventId ?? this.eventId,
    eventType: eventType ?? this.eventType,
    occurredAt: occurredAt ?? this.occurredAt,
    relatedEntryId: relatedEntryId.present
        ? relatedEntryId.value
        : this.relatedEntryId,
    relatedIdentityId: relatedIdentityId.present
        ? relatedIdentityId.value
        : this.relatedIdentityId,
    detail: detail.present ? detail.value : this.detail,
  );
  IntegrityEventRow copyWithCompanion(IntegrityEventsCompanion data) {
    return IntegrityEventRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      relatedEntryId: data.relatedEntryId.present
          ? data.relatedEntryId.value
          : this.relatedEntryId,
      relatedIdentityId: data.relatedIdentityId.present
          ? data.relatedIdentityId.value
          : this.relatedIdentityId,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntegrityEventRow(')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('relatedEntryId: $relatedEntryId, ')
          ..write('relatedIdentityId: $relatedIdentityId, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    eventType,
    occurredAt,
    relatedEntryId,
    relatedIdentityId,
    detail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntegrityEventRow &&
          other.eventId == this.eventId &&
          other.eventType == this.eventType &&
          other.occurredAt == this.occurredAt &&
          other.relatedEntryId == this.relatedEntryId &&
          other.relatedIdentityId == this.relatedIdentityId &&
          other.detail == this.detail);
}

class IntegrityEventsCompanion extends UpdateCompanion<IntegrityEventRow> {
  final Value<String> eventId;
  final Value<IntegrityEventType> eventType;
  final Value<DateTime> occurredAt;
  final Value<String?> relatedEntryId;
  final Value<String?> relatedIdentityId;
  final Value<String?> detail;
  final Value<int> rowid;
  const IntegrityEventsCompanion({
    this.eventId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.relatedEntryId = const Value.absent(),
    this.relatedIdentityId = const Value.absent(),
    this.detail = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IntegrityEventsCompanion.insert({
    this.eventId = const Value.absent(),
    required IntegrityEventType eventType,
    this.occurredAt = const Value.absent(),
    this.relatedEntryId = const Value.absent(),
    this.relatedIdentityId = const Value.absent(),
    this.detail = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventType = Value(eventType);
  static Insertable<IntegrityEventRow> custom({
    Expression<String>? eventId,
    Expression<String>? eventType,
    Expression<DateTime>? occurredAt,
    Expression<String>? relatedEntryId,
    Expression<String>? relatedIdentityId,
    Expression<String>? detail,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (eventType != null) 'event_type': eventType,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (relatedEntryId != null) 'related_entry_id': relatedEntryId,
      if (relatedIdentityId != null) 'related_identity_id': relatedIdentityId,
      if (detail != null) 'detail': detail,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IntegrityEventsCompanion copyWith({
    Value<String>? eventId,
    Value<IntegrityEventType>? eventType,
    Value<DateTime>? occurredAt,
    Value<String?>? relatedEntryId,
    Value<String?>? relatedIdentityId,
    Value<String?>? detail,
    Value<int>? rowid,
  }) {
    return IntegrityEventsCompanion(
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      occurredAt: occurredAt ?? this.occurredAt,
      relatedEntryId: relatedEntryId ?? this.relatedEntryId,
      relatedIdentityId: relatedIdentityId ?? this.relatedIdentityId,
      detail: detail ?? this.detail,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(
        $IntegrityEventsTable.$convertereventType.toSql(eventType.value),
      );
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (relatedEntryId.present) {
      map['related_entry_id'] = Variable<String>(relatedEntryId.value);
    }
    if (relatedIdentityId.present) {
      map['related_identity_id'] = Variable<String>(relatedIdentityId.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntegrityEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('relatedEntryId: $relatedEntryId, ')
          ..write('relatedIdentityId: $relatedIdentityId, ')
          ..write('detail: $detail, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $SigningIdentitiesTable signingIdentities =
      $SigningIdentitiesTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $PostingsTable postings = $PostingsTable(this);
  late final $EntryVerificationCacheTable entryVerificationCache =
      $EntryVerificationCacheTable(this);
  late final $LedgerChainStateTable ledgerChainState = $LedgerChainStateTable(
    this,
  );
  late final $IntegrityEventsTable integrityEvents = $IntegrityEventsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    signingIdentities,
    journalEntries,
    postings,
    entryVerificationCache,
    ledgerChainState,
    integrityEvents,
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
typedef $$SigningIdentitiesTableCreateCompanionBuilder =
    SigningIdentitiesCompanion Function({
      Value<String> identityId,
      required Uint8List publicKey,
      Value<DateTime> createdAt,
      Value<String?> supersedesIdentityId,
      Value<DateTime?> supersededAt,
      Value<int> rowid,
    });
typedef $$SigningIdentitiesTableUpdateCompanionBuilder =
    SigningIdentitiesCompanion Function({
      Value<String> identityId,
      Value<Uint8List> publicKey,
      Value<DateTime> createdAt,
      Value<String?> supersedesIdentityId,
      Value<DateTime?> supersededAt,
      Value<int> rowid,
    });

final class $$SigningIdentitiesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SigningIdentitiesTable, IdentityRow> {
  $$SigningIdentitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SigningIdentitiesTable _supersedesIdentityIdTable(
    _$AppDatabase db,
  ) => db.signingIdentities.createAlias(
    'signing_identities__supersedes_identity_id__signing_identities__identity_id',
  );

  $$SigningIdentitiesTableProcessedTableManager? get supersedesIdentityId {
    final $_column = $_itemColumn<String>('supersedes_identity_id');
    if ($_column == null) return null;
    final manager = $$SigningIdentitiesTableTableManager(
      $_db,
      $_db.signingIdentities,
    ).filter((f) => f.identityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _supersedesIdentityIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$JournalEntriesTable, List<JournalEntryRow>>
  _journalEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.journalEntries,
    aliasName:
        'signing_identities__identity_id__journal_entries__signed_by_identity_id',
  );

  $$JournalEntriesTableProcessedTableManager get journalEntriesRefs {
    final manager = $$JournalEntriesTableTableManager($_db, $_db.journalEntries)
        .filter(
          (f) => f.signedByIdentityId.identityId.sqlEquals(
            $_itemColumn<String>('identity_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_journalEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IntegrityEventsTable, List<IntegrityEventRow>>
  _integrityEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.integrityEvents,
    aliasName:
        'signing_identities__identity_id__integrity_events__related_identity_id',
  );

  $$IntegrityEventsTableProcessedTableManager get integrityEventsRefs {
    final manager =
        $$IntegrityEventsTableTableManager($_db, $_db.integrityEvents).filter(
          (f) => f.relatedIdentityId.identityId.sqlEquals(
            $_itemColumn<String>('identity_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _integrityEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SigningIdentitiesTableFilterComposer
    extends Composer<_$AppDatabase, $SigningIdentitiesTable> {
  $$SigningIdentitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get identityId => $composableBuilder(
    column: $table.identityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supersededAt => $composableBuilder(
    column: $table.supersededAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SigningIdentitiesTableFilterComposer get supersedesIdentityId {
    final $$SigningIdentitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesIdentityId,
      referencedTable: $db.signingIdentities,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SigningIdentitiesTableFilterComposer(
            $db: $db,
            $table: $db.signingIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> journalEntriesRefs(
    Expression<bool> Function($$JournalEntriesTableFilterComposer f) f,
  ) {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.signedByIdentityId,
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
    return f(composer);
  }

  Expression<bool> integrityEventsRefs(
    Expression<bool> Function($$IntegrityEventsTableFilterComposer f) f,
  ) {
    final $$IntegrityEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.integrityEvents,
      getReferencedColumn: (t) => t.relatedIdentityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntegrityEventsTableFilterComposer(
            $db: $db,
            $table: $db.integrityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SigningIdentitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $SigningIdentitiesTable> {
  $$SigningIdentitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get identityId => $composableBuilder(
    column: $table.identityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supersededAt => $composableBuilder(
    column: $table.supersededAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SigningIdentitiesTableOrderingComposer get supersedesIdentityId {
    final $$SigningIdentitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesIdentityId,
      referencedTable: $db.signingIdentities,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SigningIdentitiesTableOrderingComposer(
            $db: $db,
            $table: $db.signingIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SigningIdentitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SigningIdentitiesTable> {
  $$SigningIdentitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get identityId => $composableBuilder(
    column: $table.identityId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get supersededAt => $composableBuilder(
    column: $table.supersededAt,
    builder: (column) => column,
  );

  $$SigningIdentitiesTableAnnotationComposer get supersedesIdentityId {
    final $$SigningIdentitiesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.supersedesIdentityId,
          referencedTable: $db.signingIdentities,
          getReferencedColumn: (t) => t.identityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SigningIdentitiesTableAnnotationComposer(
                $db: $db,
                $table: $db.signingIdentities,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> journalEntriesRefs<T extends Object>(
    Expression<T> Function($$JournalEntriesTableAnnotationComposer a) f,
  ) {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.signedByIdentityId,
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
    return f(composer);
  }

  Expression<T> integrityEventsRefs<T extends Object>(
    Expression<T> Function($$IntegrityEventsTableAnnotationComposer a) f,
  ) {
    final $$IntegrityEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.integrityEvents,
      getReferencedColumn: (t) => t.relatedIdentityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntegrityEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.integrityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SigningIdentitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SigningIdentitiesTable,
          IdentityRow,
          $$SigningIdentitiesTableFilterComposer,
          $$SigningIdentitiesTableOrderingComposer,
          $$SigningIdentitiesTableAnnotationComposer,
          $$SigningIdentitiesTableCreateCompanionBuilder,
          $$SigningIdentitiesTableUpdateCompanionBuilder,
          (IdentityRow, $$SigningIdentitiesTableReferences),
          IdentityRow,
          PrefetchHooks Function({
            bool supersedesIdentityId,
            bool journalEntriesRefs,
            bool integrityEventsRefs,
          })
        > {
  $$SigningIdentitiesTableTableManager(
    _$AppDatabase db,
    $SigningIdentitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SigningIdentitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SigningIdentitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SigningIdentitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> identityId = const Value.absent(),
                Value<Uint8List> publicKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> supersedesIdentityId = const Value.absent(),
                Value<DateTime?> supersededAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SigningIdentitiesCompanion(
                identityId: identityId,
                publicKey: publicKey,
                createdAt: createdAt,
                supersedesIdentityId: supersedesIdentityId,
                supersededAt: supersededAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> identityId = const Value.absent(),
                required Uint8List publicKey,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> supersedesIdentityId = const Value.absent(),
                Value<DateTime?> supersededAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SigningIdentitiesCompanion.insert(
                identityId: identityId,
                publicKey: publicKey,
                createdAt: createdAt,
                supersedesIdentityId: supersedesIdentityId,
                supersededAt: supersededAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SigningIdentitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supersedesIdentityId = false,
                journalEntriesRefs = false,
                integrityEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (journalEntriesRefs) db.journalEntries,
                    if (integrityEventsRefs) db.integrityEvents,
                  ],
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
                        if (supersedesIdentityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supersedesIdentityId,
                                    referencedTable:
                                        $$SigningIdentitiesTableReferences
                                            ._supersedesIdentityIdTable(db),
                                    referencedColumn:
                                        $$SigningIdentitiesTableReferences
                                            ._supersedesIdentityIdTable(db)
                                            .identityId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (journalEntriesRefs)
                        await $_getPrefetchedData<
                          IdentityRow,
                          $SigningIdentitiesTable,
                          JournalEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$SigningIdentitiesTableReferences
                              ._journalEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SigningIdentitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).journalEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.signedByIdentityId == item.identityId,
                              ),
                          typedResults: items,
                        ),
                      if (integrityEventsRefs)
                        await $_getPrefetchedData<
                          IdentityRow,
                          $SigningIdentitiesTable,
                          IntegrityEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$SigningIdentitiesTableReferences
                              ._integrityEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SigningIdentitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).integrityEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.relatedIdentityId == item.identityId,
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

typedef $$SigningIdentitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SigningIdentitiesTable,
      IdentityRow,
      $$SigningIdentitiesTableFilterComposer,
      $$SigningIdentitiesTableOrderingComposer,
      $$SigningIdentitiesTableAnnotationComposer,
      $$SigningIdentitiesTableCreateCompanionBuilder,
      $$SigningIdentitiesTableUpdateCompanionBuilder,
      (IdentityRow, $$SigningIdentitiesTableReferences),
      IdentityRow,
      PrefetchHooks Function({
        bool supersedesIdentityId,
        bool journalEntriesRefs,
        bool integrityEventsRefs,
      })
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      required String transactionDate,
      required DateTime recordedAt,
      Value<String?> description,
      Value<String?> reversesEntryId,
      Value<DateTime> createdAt,
      required int deviceChainSequence,
      required Uint8List previousEntryHash,
      required Uint8List entryHash,
      required String signedByIdentityId,
      required Uint8List signature,
      Value<String?> migratedFromEntryId,
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
      Value<int> deviceChainSequence,
      Value<Uint8List> previousEntryHash,
      Value<Uint8List> entryHash,
      Value<String> signedByIdentityId,
      Value<Uint8List> signature,
      Value<String?> migratedFromEntryId,
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

  static $SigningIdentitiesTable _signedByIdentityIdTable(
    _$AppDatabase db,
  ) => db.signingIdentities.createAlias(
    'journal_entries__signed_by_identity_id__signing_identities__identity_id',
  );

  $$SigningIdentitiesTableProcessedTableManager get signedByIdentityId {
    final $_column = $_itemColumn<String>('signed_by_identity_id')!;

    final manager = $$SigningIdentitiesTableTableManager(
      $_db,
      $_db.signingIdentities,
    ).filter((f) => f.identityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_signedByIdentityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JournalEntriesTable _migratedFromEntryIdTable(_$AppDatabase db) =>
      db.journalEntries.createAlias(
        'journal_entries__migrated_from_entry_id__journal_entries__id',
      );

  $$JournalEntriesTableProcessedTableManager? get migratedFromEntryId {
    final $_column = $_itemColumn<String>('migrated_from_entry_id');
    if ($_column == null) return null;
    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_migratedFromEntryIdTable($_db));
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

  static MultiTypedResultKey<
    $EntryVerificationCacheTable,
    List<EntryVerificationRow>
  >
  _entryVerificationCacheRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.entryVerificationCache,
        aliasName: 'journal_entries__id__entry_verification_cache__entry_id',
      );

  $$EntryVerificationCacheTableProcessedTableManager
  get entryVerificationCacheRefs {
    final manager = $$EntryVerificationCacheTableTableManager(
      $_db,
      $_db.entryVerificationCache,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entryVerificationCacheRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LedgerChainStateTable, List<ChainStateRow>>
  _ledgerChainStateRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ledgerChainState,
    aliasName: 'journal_entries__id__ledger_chain_state__trusted_tip_entry_id',
  );

  $$LedgerChainStateTableProcessedTableManager get ledgerChainStateRefs {
    final manager =
        $$LedgerChainStateTableTableManager($_db, $_db.ledgerChainState).filter(
          (f) => f.trustedTipEntryId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _ledgerChainStateRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IntegrityEventsTable, List<IntegrityEventRow>>
  _integrityEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.integrityEvents,
    aliasName: 'journal_entries__id__integrity_events__related_entry_id',
  );

  $$IntegrityEventsTableProcessedTableManager get integrityEventsRefs {
    final manager = $$IntegrityEventsTableTableManager(
      $_db,
      $_db.integrityEvents,
    ).filter((f) => f.relatedEntryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _integrityEventsRefsTable($_db),
    );
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

  ColumnFilters<int> get deviceChainSequence => $composableBuilder(
    column: $table.deviceChainSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get previousEntryHash => $composableBuilder(
    column: $table.previousEntryHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get entryHash => $composableBuilder(
    column: $table.entryHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signature => $composableBuilder(
    column: $table.signature,
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

  $$SigningIdentitiesTableFilterComposer get signedByIdentityId {
    final $$SigningIdentitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signedByIdentityId,
      referencedTable: $db.signingIdentities,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SigningIdentitiesTableFilterComposer(
            $db: $db,
            $table: $db.signingIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JournalEntriesTableFilterComposer get migratedFromEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.migratedFromEntryId,
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

  Expression<bool> entryVerificationCacheRefs(
    Expression<bool> Function($$EntryVerificationCacheTableFilterComposer f) f,
  ) {
    final $$EntryVerificationCacheTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.entryVerificationCache,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EntryVerificationCacheTableFilterComposer(
                $db: $db,
                $table: $db.entryVerificationCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> ledgerChainStateRefs(
    Expression<bool> Function($$LedgerChainStateTableFilterComposer f) f,
  ) {
    final $$LedgerChainStateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerChainState,
      getReferencedColumn: (t) => t.trustedTipEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerChainStateTableFilterComposer(
            $db: $db,
            $table: $db.ledgerChainState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> integrityEventsRefs(
    Expression<bool> Function($$IntegrityEventsTableFilterComposer f) f,
  ) {
    final $$IntegrityEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.integrityEvents,
      getReferencedColumn: (t) => t.relatedEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntegrityEventsTableFilterComposer(
            $db: $db,
            $table: $db.integrityEvents,
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

  ColumnOrderings<int> get deviceChainSequence => $composableBuilder(
    column: $table.deviceChainSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get previousEntryHash => $composableBuilder(
    column: $table.previousEntryHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get entryHash => $composableBuilder(
    column: $table.entryHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signature => $composableBuilder(
    column: $table.signature,
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

  $$SigningIdentitiesTableOrderingComposer get signedByIdentityId {
    final $$SigningIdentitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signedByIdentityId,
      referencedTable: $db.signingIdentities,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SigningIdentitiesTableOrderingComposer(
            $db: $db,
            $table: $db.signingIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JournalEntriesTableOrderingComposer get migratedFromEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.migratedFromEntryId,
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

  GeneratedColumn<int> get deviceChainSequence => $composableBuilder(
    column: $table.deviceChainSequence,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get previousEntryHash => $composableBuilder(
    column: $table.previousEntryHash,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get entryHash =>
      $composableBuilder(column: $table.entryHash, builder: (column) => column);

  GeneratedColumn<Uint8List> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

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

  $$SigningIdentitiesTableAnnotationComposer get signedByIdentityId {
    final $$SigningIdentitiesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.signedByIdentityId,
          referencedTable: $db.signingIdentities,
          getReferencedColumn: (t) => t.identityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SigningIdentitiesTableAnnotationComposer(
                $db: $db,
                $table: $db.signingIdentities,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$JournalEntriesTableAnnotationComposer get migratedFromEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.migratedFromEntryId,
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

  Expression<T> entryVerificationCacheRefs<T extends Object>(
    Expression<T> Function($$EntryVerificationCacheTableAnnotationComposer a) f,
  ) {
    final $$EntryVerificationCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.entryVerificationCache,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EntryVerificationCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.entryVerificationCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ledgerChainStateRefs<T extends Object>(
    Expression<T> Function($$LedgerChainStateTableAnnotationComposer a) f,
  ) {
    final $$LedgerChainStateTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerChainState,
      getReferencedColumn: (t) => t.trustedTipEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerChainStateTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerChainState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> integrityEventsRefs<T extends Object>(
    Expression<T> Function($$IntegrityEventsTableAnnotationComposer a) f,
  ) {
    final $$IntegrityEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.integrityEvents,
      getReferencedColumn: (t) => t.relatedEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntegrityEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.integrityEvents,
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
          PrefetchHooks Function({
            bool reversesEntryId,
            bool signedByIdentityId,
            bool migratedFromEntryId,
            bool postingsRefs,
            bool entryVerificationCacheRefs,
            bool ledgerChainStateRefs,
            bool integrityEventsRefs,
          })
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
                Value<int> deviceChainSequence = const Value.absent(),
                Value<Uint8List> previousEntryHash = const Value.absent(),
                Value<Uint8List> entryHash = const Value.absent(),
                Value<String> signedByIdentityId = const Value.absent(),
                Value<Uint8List> signature = const Value.absent(),
                Value<String?> migratedFromEntryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                transactionDate: transactionDate,
                recordedAt: recordedAt,
                description: description,
                reversesEntryId: reversesEntryId,
                createdAt: createdAt,
                deviceChainSequence: deviceChainSequence,
                previousEntryHash: previousEntryHash,
                entryHash: entryHash,
                signedByIdentityId: signedByIdentityId,
                signature: signature,
                migratedFromEntryId: migratedFromEntryId,
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
                required int deviceChainSequence,
                required Uint8List previousEntryHash,
                required Uint8List entryHash,
                required String signedByIdentityId,
                required Uint8List signature,
                Value<String?> migratedFromEntryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                transactionDate: transactionDate,
                recordedAt: recordedAt,
                description: description,
                reversesEntryId: reversesEntryId,
                createdAt: createdAt,
                deviceChainSequence: deviceChainSequence,
                previousEntryHash: previousEntryHash,
                entryHash: entryHash,
                signedByIdentityId: signedByIdentityId,
                signature: signature,
                migratedFromEntryId: migratedFromEntryId,
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
              ({
                reversesEntryId = false,
                signedByIdentityId = false,
                migratedFromEntryId = false,
                postingsRefs = false,
                entryVerificationCacheRefs = false,
                ledgerChainStateRefs = false,
                integrityEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (postingsRefs) db.postings,
                    if (entryVerificationCacheRefs) db.entryVerificationCache,
                    if (ledgerChainStateRefs) db.ledgerChainState,
                    if (integrityEventsRefs) db.integrityEvents,
                  ],
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
                        if (signedByIdentityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.signedByIdentityId,
                                    referencedTable:
                                        $$JournalEntriesTableReferences
                                            ._signedByIdentityIdTable(db),
                                    referencedColumn:
                                        $$JournalEntriesTableReferences
                                            ._signedByIdentityIdTable(db)
                                            .identityId,
                                  )
                                  as T;
                        }
                        if (migratedFromEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.migratedFromEntryId,
                                    referencedTable:
                                        $$JournalEntriesTableReferences
                                            ._migratedFromEntryIdTable(db),
                                    referencedColumn:
                                        $$JournalEntriesTableReferences
                                            ._migratedFromEntryIdTable(db)
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
                      if (entryVerificationCacheRefs)
                        await $_getPrefetchedData<
                          JournalEntryRow,
                          $JournalEntriesTable,
                          EntryVerificationRow
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._entryVerificationCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entryVerificationCacheRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ledgerChainStateRefs)
                        await $_getPrefetchedData<
                          JournalEntryRow,
                          $JournalEntriesTable,
                          ChainStateRow
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._ledgerChainStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).ledgerChainStateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trustedTipEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (integrityEventsRefs)
                        await $_getPrefetchedData<
                          JournalEntryRow,
                          $JournalEntriesTable,
                          IntegrityEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._integrityEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).integrityEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.relatedEntryId == item.id,
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
      PrefetchHooks Function({
        bool reversesEntryId,
        bool signedByIdentityId,
        bool migratedFromEntryId,
        bool postingsRefs,
        bool entryVerificationCacheRefs,
        bool ledgerChainStateRefs,
        bool integrityEventsRefs,
      })
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
typedef $$EntryVerificationCacheTableCreateCompanionBuilder =
    EntryVerificationCacheCompanion Function({
      required String entryId,
      required bool isVerified,
      Value<VerificationBreakReason?> breakReason,
      required DateTime checkedAt,
      Value<int> rowid,
    });
typedef $$EntryVerificationCacheTableUpdateCompanionBuilder =
    EntryVerificationCacheCompanion Function({
      Value<String> entryId,
      Value<bool> isVerified,
      Value<VerificationBreakReason?> breakReason,
      Value<DateTime> checkedAt,
      Value<int> rowid,
    });

final class $$EntryVerificationCacheTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EntryVerificationCacheTable,
          EntryVerificationRow
        > {
  $$EntryVerificationCacheTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JournalEntriesTable _entryIdTable(_$AppDatabase db) => db
      .journalEntries
      .createAlias('entry_verification_cache__entry_id__journal_entries__id');

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
}

class $$EntryVerificationCacheTableFilterComposer
    extends Composer<_$AppDatabase, $EntryVerificationCacheTable> {
  $$EntryVerificationCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    VerificationBreakReason?,
    VerificationBreakReason,
    String
  >
  get breakReason => $composableBuilder(
    column: $table.breakReason,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
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
}

class $$EntryVerificationCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryVerificationCacheTable> {
  $$EntryVerificationCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breakReason => $composableBuilder(
    column: $table.breakReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
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
}

class $$EntryVerificationCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryVerificationCacheTable> {
  $$EntryVerificationCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<VerificationBreakReason?, String>
  get breakReason => $composableBuilder(
    column: $table.breakReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

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
}

class $$EntryVerificationCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryVerificationCacheTable,
          EntryVerificationRow,
          $$EntryVerificationCacheTableFilterComposer,
          $$EntryVerificationCacheTableOrderingComposer,
          $$EntryVerificationCacheTableAnnotationComposer,
          $$EntryVerificationCacheTableCreateCompanionBuilder,
          $$EntryVerificationCacheTableUpdateCompanionBuilder,
          (EntryVerificationRow, $$EntryVerificationCacheTableReferences),
          EntryVerificationRow,
          PrefetchHooks Function({bool entryId})
        > {
  $$EntryVerificationCacheTableTableManager(
    _$AppDatabase db,
    $EntryVerificationCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryVerificationCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$EntryVerificationCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EntryVerificationCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<bool> isVerified = const Value.absent(),
                Value<VerificationBreakReason?> breakReason =
                    const Value.absent(),
                Value<DateTime> checkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryVerificationCacheCompanion(
                entryId: entryId,
                isVerified: isVerified,
                breakReason: breakReason,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required bool isVerified,
                Value<VerificationBreakReason?> breakReason =
                    const Value.absent(),
                required DateTime checkedAt,
                Value<int> rowid = const Value.absent(),
              }) => EntryVerificationCacheCompanion.insert(
                entryId: entryId,
                isVerified: isVerified,
                breakReason: breakReason,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntryVerificationCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
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
                                referencedTable:
                                    $$EntryVerificationCacheTableReferences
                                        ._entryIdTable(db),
                                referencedColumn:
                                    $$EntryVerificationCacheTableReferences
                                        ._entryIdTable(db)
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

typedef $$EntryVerificationCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryVerificationCacheTable,
      EntryVerificationRow,
      $$EntryVerificationCacheTableFilterComposer,
      $$EntryVerificationCacheTableOrderingComposer,
      $$EntryVerificationCacheTableAnnotationComposer,
      $$EntryVerificationCacheTableCreateCompanionBuilder,
      $$EntryVerificationCacheTableUpdateCompanionBuilder,
      (EntryVerificationRow, $$EntryVerificationCacheTableReferences),
      EntryVerificationRow,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$LedgerChainStateTableCreateCompanionBuilder =
    LedgerChainStateCompanion Function({
      required String id,
      Value<String?> trustedTipEntryId,
      Value<Uint8List?> trustedTipHash,
      required int nextDeviceChainSequence,
      Value<int> rowid,
    });
typedef $$LedgerChainStateTableUpdateCompanionBuilder =
    LedgerChainStateCompanion Function({
      Value<String> id,
      Value<String?> trustedTipEntryId,
      Value<Uint8List?> trustedTipHash,
      Value<int> nextDeviceChainSequence,
      Value<int> rowid,
    });

final class $$LedgerChainStateTableReferences
    extends
        BaseReferences<_$AppDatabase, $LedgerChainStateTable, ChainStateRow> {
  $$LedgerChainStateTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JournalEntriesTable _trustedTipEntryIdTable(_$AppDatabase db) =>
      db.journalEntries.createAlias(
        'ledger_chain_state__trusted_tip_entry_id__journal_entries__id',
      );

  $$JournalEntriesTableProcessedTableManager? get trustedTipEntryId {
    final $_column = $_itemColumn<String>('trusted_tip_entry_id');
    if ($_column == null) return null;
    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trustedTipEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LedgerChainStateTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerChainStateTable> {
  $$LedgerChainStateTableFilterComposer({
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

  ColumnFilters<Uint8List> get trustedTipHash => $composableBuilder(
    column: $table.trustedTipHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextDeviceChainSequence => $composableBuilder(
    column: $table.nextDeviceChainSequence,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalEntriesTableFilterComposer get trustedTipEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trustedTipEntryId,
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
}

class $$LedgerChainStateTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerChainStateTable> {
  $$LedgerChainStateTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get trustedTipHash => $composableBuilder(
    column: $table.trustedTipHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextDeviceChainSequence => $composableBuilder(
    column: $table.nextDeviceChainSequence,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalEntriesTableOrderingComposer get trustedTipEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trustedTipEntryId,
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

class $$LedgerChainStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerChainStateTable> {
  $$LedgerChainStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get trustedTipHash => $composableBuilder(
    column: $table.trustedTipHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextDeviceChainSequence => $composableBuilder(
    column: $table.nextDeviceChainSequence,
    builder: (column) => column,
  );

  $$JournalEntriesTableAnnotationComposer get trustedTipEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trustedTipEntryId,
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
}

class $$LedgerChainStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerChainStateTable,
          ChainStateRow,
          $$LedgerChainStateTableFilterComposer,
          $$LedgerChainStateTableOrderingComposer,
          $$LedgerChainStateTableAnnotationComposer,
          $$LedgerChainStateTableCreateCompanionBuilder,
          $$LedgerChainStateTableUpdateCompanionBuilder,
          (ChainStateRow, $$LedgerChainStateTableReferences),
          ChainStateRow,
          PrefetchHooks Function({bool trustedTipEntryId})
        > {
  $$LedgerChainStateTableTableManager(
    _$AppDatabase db,
    $LedgerChainStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerChainStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerChainStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerChainStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> trustedTipEntryId = const Value.absent(),
                Value<Uint8List?> trustedTipHash = const Value.absent(),
                Value<int> nextDeviceChainSequence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerChainStateCompanion(
                id: id,
                trustedTipEntryId: trustedTipEntryId,
                trustedTipHash: trustedTipHash,
                nextDeviceChainSequence: nextDeviceChainSequence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> trustedTipEntryId = const Value.absent(),
                Value<Uint8List?> trustedTipHash = const Value.absent(),
                required int nextDeviceChainSequence,
                Value<int> rowid = const Value.absent(),
              }) => LedgerChainStateCompanion.insert(
                id: id,
                trustedTipEntryId: trustedTipEntryId,
                trustedTipHash: trustedTipHash,
                nextDeviceChainSequence: nextDeviceChainSequence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LedgerChainStateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trustedTipEntryId = false}) {
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
                    if (trustedTipEntryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trustedTipEntryId,
                                referencedTable:
                                    $$LedgerChainStateTableReferences
                                        ._trustedTipEntryIdTable(db),
                                referencedColumn:
                                    $$LedgerChainStateTableReferences
                                        ._trustedTipEntryIdTable(db)
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

typedef $$LedgerChainStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerChainStateTable,
      ChainStateRow,
      $$LedgerChainStateTableFilterComposer,
      $$LedgerChainStateTableOrderingComposer,
      $$LedgerChainStateTableAnnotationComposer,
      $$LedgerChainStateTableCreateCompanionBuilder,
      $$LedgerChainStateTableUpdateCompanionBuilder,
      (ChainStateRow, $$LedgerChainStateTableReferences),
      ChainStateRow,
      PrefetchHooks Function({bool trustedTipEntryId})
    >;
typedef $$IntegrityEventsTableCreateCompanionBuilder =
    IntegrityEventsCompanion Function({
      Value<String> eventId,
      required IntegrityEventType eventType,
      Value<DateTime> occurredAt,
      Value<String?> relatedEntryId,
      Value<String?> relatedIdentityId,
      Value<String?> detail,
      Value<int> rowid,
    });
typedef $$IntegrityEventsTableUpdateCompanionBuilder =
    IntegrityEventsCompanion Function({
      Value<String> eventId,
      Value<IntegrityEventType> eventType,
      Value<DateTime> occurredAt,
      Value<String?> relatedEntryId,
      Value<String?> relatedIdentityId,
      Value<String?> detail,
      Value<int> rowid,
    });

final class $$IntegrityEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IntegrityEventsTable,
          IntegrityEventRow
        > {
  $$IntegrityEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JournalEntriesTable _relatedEntryIdTable(_$AppDatabase db) => db
      .journalEntries
      .createAlias('integrity_events__related_entry_id__journal_entries__id');

  $$JournalEntriesTableProcessedTableManager? get relatedEntryId {
    final $_column = $_itemColumn<String>('related_entry_id');
    if ($_column == null) return null;
    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_relatedEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SigningIdentitiesTable _relatedIdentityIdTable(
    _$AppDatabase db,
  ) => db.signingIdentities.createAlias(
    'integrity_events__related_identity_id__signing_identities__identity_id',
  );

  $$SigningIdentitiesTableProcessedTableManager? get relatedIdentityId {
    final $_column = $_itemColumn<String>('related_identity_id');
    if ($_column == null) return null;
    final manager = $$SigningIdentitiesTableTableManager(
      $_db,
      $_db.signingIdentities,
    ).filter((f) => f.identityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_relatedIdentityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IntegrityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $IntegrityEventsTable> {
  $$IntegrityEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IntegrityEventType, IntegrityEventType, String>
  get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalEntriesTableFilterComposer get relatedEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedEntryId,
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

  $$SigningIdentitiesTableFilterComposer get relatedIdentityId {
    final $$SigningIdentitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedIdentityId,
      referencedTable: $db.signingIdentities,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SigningIdentitiesTableFilterComposer(
            $db: $db,
            $table: $db.signingIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntegrityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $IntegrityEventsTable> {
  $$IntegrityEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalEntriesTableOrderingComposer get relatedEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedEntryId,
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

  $$SigningIdentitiesTableOrderingComposer get relatedIdentityId {
    final $$SigningIdentitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedIdentityId,
      referencedTable: $db.signingIdentities,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SigningIdentitiesTableOrderingComposer(
            $db: $db,
            $table: $db.signingIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntegrityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntegrityEventsTable> {
  $$IntegrityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IntegrityEventType, String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  $$JournalEntriesTableAnnotationComposer get relatedEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedEntryId,
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

  $$SigningIdentitiesTableAnnotationComposer get relatedIdentityId {
    final $$SigningIdentitiesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.relatedIdentityId,
          referencedTable: $db.signingIdentities,
          getReferencedColumn: (t) => t.identityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SigningIdentitiesTableAnnotationComposer(
                $db: $db,
                $table: $db.signingIdentities,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$IntegrityEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntegrityEventsTable,
          IntegrityEventRow,
          $$IntegrityEventsTableFilterComposer,
          $$IntegrityEventsTableOrderingComposer,
          $$IntegrityEventsTableAnnotationComposer,
          $$IntegrityEventsTableCreateCompanionBuilder,
          $$IntegrityEventsTableUpdateCompanionBuilder,
          (IntegrityEventRow, $$IntegrityEventsTableReferences),
          IntegrityEventRow,
          PrefetchHooks Function({bool relatedEntryId, bool relatedIdentityId})
        > {
  $$IntegrityEventsTableTableManager(
    _$AppDatabase db,
    $IntegrityEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntegrityEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntegrityEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntegrityEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<IntegrityEventType> eventType = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> relatedEntryId = const Value.absent(),
                Value<String?> relatedIdentityId = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntegrityEventsCompanion(
                eventId: eventId,
                eventType: eventType,
                occurredAt: occurredAt,
                relatedEntryId: relatedEntryId,
                relatedIdentityId: relatedIdentityId,
                detail: detail,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                required IntegrityEventType eventType,
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> relatedEntryId = const Value.absent(),
                Value<String?> relatedIdentityId = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntegrityEventsCompanion.insert(
                eventId: eventId,
                eventType: eventType,
                occurredAt: occurredAt,
                relatedEntryId: relatedEntryId,
                relatedIdentityId: relatedIdentityId,
                detail: detail,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IntegrityEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({relatedEntryId = false, relatedIdentityId = false}) {
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
                        if (relatedEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.relatedEntryId,
                                    referencedTable:
                                        $$IntegrityEventsTableReferences
                                            ._relatedEntryIdTable(db),
                                    referencedColumn:
                                        $$IntegrityEventsTableReferences
                                            ._relatedEntryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (relatedIdentityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.relatedIdentityId,
                                    referencedTable:
                                        $$IntegrityEventsTableReferences
                                            ._relatedIdentityIdTable(db),
                                    referencedColumn:
                                        $$IntegrityEventsTableReferences
                                            ._relatedIdentityIdTable(db)
                                            .identityId,
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

typedef $$IntegrityEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntegrityEventsTable,
      IntegrityEventRow,
      $$IntegrityEventsTableFilterComposer,
      $$IntegrityEventsTableOrderingComposer,
      $$IntegrityEventsTableAnnotationComposer,
      $$IntegrityEventsTableCreateCompanionBuilder,
      $$IntegrityEventsTableUpdateCompanionBuilder,
      (IntegrityEventRow, $$IntegrityEventsTableReferences),
      IntegrityEventRow,
      PrefetchHooks Function({bool relatedEntryId, bool relatedIdentityId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$SigningIdentitiesTableTableManager get signingIdentities =>
      $$SigningIdentitiesTableTableManager(_db, _db.signingIdentities);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$PostingsTableTableManager get postings =>
      $$PostingsTableTableManager(_db, _db.postings);
  $$EntryVerificationCacheTableTableManager get entryVerificationCache =>
      $$EntryVerificationCacheTableTableManager(
        _db,
        _db.entryVerificationCache,
      );
  $$LedgerChainStateTableTableManager get ledgerChainState =>
      $$LedgerChainStateTableTableManager(_db, _db.ledgerChainState);
  $$IntegrityEventsTableTableManager get integrityEvents =>
      $$IntegrityEventsTableTableManager(_db, _db.integrityEvents);
}
