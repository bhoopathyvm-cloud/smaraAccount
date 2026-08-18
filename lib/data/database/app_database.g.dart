// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountGroupsTable extends AccountGroups
    with TableInfo<$AccountGroupsTable, AccountGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountGroupsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<AccountGroupKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AccountGroupKind>($AccountGroupsTable.$converterkind);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    sortOrder,
    isSystem,
    currency,
    archivedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountGroupRow> instance, {
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
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    } else if (isInserting) {
      context.missing(_isSystemMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
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
  AccountGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $AccountGroupsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
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
  $AccountGroupsTable createAlias(String alias) {
    return $AccountGroupsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountGroupKind, String, String> $converterkind =
      const EnumNameConverter<AccountGroupKind>(AccountGroupKind.values);
}

class AccountGroupRow extends DataClass implements Insertable<AccountGroupRow> {
  /// A user-created group has no well-known constant id, so it needs a
  /// client-generated default, matching `Accounts.id`'s existing
  /// convention - the five system-group seeds are unaffected since they
  /// always pass an explicit id, which overrides this default.
  final String id;
  final String name;
  final AccountGroupKind kind;
  final int sortOrder;
  final bool isSystem;

  /// ISO 4217 code (e.g. 'USD', 'EUR') - a group is single-currency
  /// (multi-currency-support design.md Decision 1). Nullable only to
  /// represent the transient post-upgrade state for a database migrated
  /// from schemaVersion 3, before the user has supplied the one-time
  /// currency-backfill value; every group created through the Repository
  /// (fresh install or backfill) always has this set.
  final String? currency;

  /// Set only for a user-created group the user has archived (soft flag,
  /// matching `accounts.archived_at`'s shape) - never set for one of the
  /// five system groups, which are permanent and un-archivable
  /// (custom-account-groups design.md Decision 2).
  final DateTime? archivedAt;
  final DateTime createdAt;
  const AccountGroupRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.sortOrder,
    required this.isSystem,
    this.currency,
    this.archivedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $AccountGroupsTable.$converterkind.toSql(kind),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_system'] = Variable<bool>(isSystem);
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountGroupsCompanion toCompanion(bool nullToAbsent) {
    return AccountGroupsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      sortOrder: Value(sortOrder),
      isSystem: Value(isSystem),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      createdAt: Value(createdAt),
    );
  }

  factory AccountGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountGroupRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $AccountGroupsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      currency: serializer.fromJson<String?>(json['currency']),
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
      'kind': serializer.toJson<String>(
        $AccountGroupsTable.$converterkind.toJson(kind),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isSystem': serializer.toJson<bool>(isSystem),
      'currency': serializer.toJson<String?>(currency),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AccountGroupRow copyWith({
    String? id,
    String? name,
    AccountGroupKind? kind,
    int? sortOrder,
    bool? isSystem,
    Value<String?> currency = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    DateTime? createdAt,
  }) => AccountGroupRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    sortOrder: sortOrder ?? this.sortOrder,
    isSystem: isSystem ?? this.isSystem,
    currency: currency.present ? currency.value : this.currency,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  AccountGroupRow copyWithCompanion(AccountGroupsCompanion data) {
    return AccountGroupRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      currency: data.currency.present ? data.currency.value : this.currency,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountGroupRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('currency: $currency, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    sortOrder,
    isSystem,
    currency,
    archivedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountGroupRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.sortOrder == this.sortOrder &&
          other.isSystem == this.isSystem &&
          other.currency == this.currency &&
          other.archivedAt == this.archivedAt &&
          other.createdAt == this.createdAt);
}

class AccountGroupsCompanion extends UpdateCompanion<AccountGroupRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<AccountGroupKind> kind;
  final Value<int> sortOrder;
  final Value<bool> isSystem;
  final Value<String?> currency;
  final Value<DateTime?> archivedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AccountGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.currency = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AccountGroupKind kind,
    required int sortOrder,
    required bool isSystem,
    this.currency = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind),
       sortOrder = Value(sortOrder),
       isSystem = Value(isSystem);
  static Insertable<AccountGroupRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? sortOrder,
    Expression<bool>? isSystem,
    Expression<String>? currency,
    Expression<DateTime>? archivedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isSystem != null) 'is_system': isSystem,
      if (currency != null) 'currency': currency,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<AccountGroupKind>? kind,
    Value<int>? sortOrder,
    Value<bool>? isSystem,
    Value<String?>? currency,
    Value<DateTime?>? archivedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AccountGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      currency: currency ?? this.currency,
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
    if (kind.present) {
      map['kind'] = Variable<String>(
        $AccountGroupsTable.$converterkind.toSql(kind.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
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
    return (StringBuffer('AccountGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('currency: $currency, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _holdsInvestmentsMeta = const VerificationMeta(
    'holdsInvestments',
  );
  @override
  late final GeneratedColumn<bool> holdsInvestments = GeneratedColumn<bool>(
    'holds_investments',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("holds_investments" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _investmentOwnerAccountIdMeta =
      const VerificationMeta('investmentOwnerAccountId');
  @override
  late final GeneratedColumn<String> investmentOwnerAccountId =
      GeneratedColumn<String>(
        'investment_owner_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES accounts (id)',
        ),
      );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    holdsInvestments,
    investmentOwnerAccountId,
    groupId,
    sortOrder,
    archivedAt,
    createdAt,
  ];
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
    if (data.containsKey('holds_investments')) {
      context.handle(
        _holdsInvestmentsMeta,
        holdsInvestments.isAcceptableOrUnknown(
          data['holds_investments']!,
          _holdsInvestmentsMeta,
        ),
      );
    }
    if (data.containsKey('investment_owner_account_id')) {
      context.handle(
        _investmentOwnerAccountIdMeta,
        investmentOwnerAccountId.isAcceptableOrUnknown(
          data['investment_owner_account_id']!,
          _investmentOwnerAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
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
      holdsInvestments: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}holds_investments'],
      )!,
      investmentOwnerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investment_owner_account_id'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
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
  final bool holdsInvestments;
  final String? investmentOwnerAccountId;

  /// Required for asset/liability; NULL for income/expense/equity.
  final String? groupId;
  final int sortOrder;
  final DateTime? archivedAt;
  final DateTime createdAt;
  const AccountRow({
    required this.id,
    required this.name,
    required this.type,
    required this.holdsInvestments,
    this.investmentOwnerAccountId,
    this.groupId,
    required this.sortOrder,
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
    map['holds_investments'] = Variable<bool>(holdsInvestments);
    if (!nullToAbsent || investmentOwnerAccountId != null) {
      map['investment_owner_account_id'] = Variable<String>(
        investmentOwnerAccountId,
      );
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
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
      holdsInvestments: Value(holdsInvestments),
      investmentOwnerAccountId: investmentOwnerAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(investmentOwnerAccountId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      sortOrder: Value(sortOrder),
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
      holdsInvestments: serializer.fromJson<bool>(json['holdsInvestments']),
      investmentOwnerAccountId: serializer.fromJson<String?>(
        json['investmentOwnerAccountId'],
      ),
      groupId: serializer.fromJson<String?>(json['groupId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
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
      'holdsInvestments': serializer.toJson<bool>(holdsInvestments),
      'investmentOwnerAccountId': serializer.toJson<String?>(
        investmentOwnerAccountId,
      ),
      'groupId': serializer.toJson<String?>(groupId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AccountRow copyWith({
    String? id,
    String? name,
    AccountType? type,
    bool? holdsInvestments,
    Value<String?> investmentOwnerAccountId = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
    int? sortOrder,
    Value<DateTime?> archivedAt = const Value.absent(),
    DateTime? createdAt,
  }) => AccountRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    holdsInvestments: holdsInvestments ?? this.holdsInvestments,
    investmentOwnerAccountId: investmentOwnerAccountId.present
        ? investmentOwnerAccountId.value
        : this.investmentOwnerAccountId,
    groupId: groupId.present ? groupId.value : this.groupId,
    sortOrder: sortOrder ?? this.sortOrder,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      holdsInvestments: data.holdsInvestments.present
          ? data.holdsInvestments.value
          : this.holdsInvestments,
      investmentOwnerAccountId: data.investmentOwnerAccountId.present
          ? data.investmentOwnerAccountId.value
          : this.investmentOwnerAccountId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
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
          ..write('holdsInvestments: $holdsInvestments, ')
          ..write('investmentOwnerAccountId: $investmentOwnerAccountId, ')
          ..write('groupId: $groupId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    holdsInvestments,
    investmentOwnerAccountId,
    groupId,
    sortOrder,
    archivedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.holdsInvestments == this.holdsInvestments &&
          other.investmentOwnerAccountId == this.investmentOwnerAccountId &&
          other.groupId == this.groupId &&
          other.sortOrder == this.sortOrder &&
          other.archivedAt == this.archivedAt &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<AccountType> type;
  final Value<bool> holdsInvestments;
  final Value<String?> investmentOwnerAccountId;
  final Value<String?> groupId;
  final Value<int> sortOrder;
  final Value<DateTime?> archivedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.holdsInvestments = const Value.absent(),
    this.investmentOwnerAccountId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AccountType type,
    this.holdsInvestments = const Value.absent(),
    this.investmentOwnerAccountId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<bool>? holdsInvestments,
    Expression<String>? investmentOwnerAccountId,
    Expression<String>? groupId,
    Expression<int>? sortOrder,
    Expression<DateTime>? archivedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (holdsInvestments != null) 'holds_investments': holdsInvestments,
      if (investmentOwnerAccountId != null)
        'investment_owner_account_id': investmentOwnerAccountId,
      if (groupId != null) 'group_id': groupId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<AccountType>? type,
    Value<bool>? holdsInvestments,
    Value<String?>? investmentOwnerAccountId,
    Value<String?>? groupId,
    Value<int>? sortOrder,
    Value<DateTime?>? archivedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      holdsInvestments: holdsInvestments ?? this.holdsInvestments,
      investmentOwnerAccountId:
          investmentOwnerAccountId ?? this.investmentOwnerAccountId,
      groupId: groupId ?? this.groupId,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (holdsInvestments.present) {
      map['holds_investments'] = Variable<bool>(holdsInvestments.value);
    }
    if (investmentOwnerAccountId.present) {
      map['investment_owner_account_id'] = Variable<String>(
        investmentOwnerAccountId.value,
      );
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
          ..write('holdsInvestments: $holdsInvestments, ')
          ..write('investmentOwnerAccountId: $investmentOwnerAccountId, ')
          ..write('groupId: $groupId, ')
          ..write('sortOrder: $sortOrder, ')
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

class $InstrumentsTable extends Instruments
    with TableInfo<$InstrumentsTable, InstrumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstrumentsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<InstrumentKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<InstrumentKind>($InstrumentsTable.$converterkind);
  static const VerificationMeta _tickerMeta = const VerificationMeta('ticker');
  @override
  late final GeneratedColumn<String> ticker = GeneratedColumn<String>(
    'ticker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    ticker,
    isin,
    archivedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instruments';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstrumentRow> instance, {
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
    if (data.containsKey('ticker')) {
      context.handle(
        _tickerMeta,
        ticker.isAcceptableOrUnknown(data['ticker']!, _tickerMeta),
      );
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
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
  InstrumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstrumentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $InstrumentsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      ticker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticker'],
      ),
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
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
  $InstrumentsTable createAlias(String alias) {
    return $InstrumentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<InstrumentKind, String, String> $converterkind =
      const EnumNameConverter<InstrumentKind>(InstrumentKind.values);
}

class InstrumentRow extends DataClass implements Insertable<InstrumentRow> {
  final String id;
  final String name;
  final InstrumentKind kind;
  final String? ticker;
  final String? isin;
  final DateTime? archivedAt;
  final DateTime createdAt;
  const InstrumentRow({
    required this.id,
    required this.name,
    required this.kind,
    this.ticker,
    this.isin,
    this.archivedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $InstrumentsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || ticker != null) {
      map['ticker'] = Variable<String>(ticker);
    }
    if (!nullToAbsent || isin != null) {
      map['isin'] = Variable<String>(isin);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InstrumentsCompanion toCompanion(bool nullToAbsent) {
    return InstrumentsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      ticker: ticker == null && nullToAbsent
          ? const Value.absent()
          : Value(ticker),
      isin: isin == null && nullToAbsent ? const Value.absent() : Value(isin),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      createdAt: Value(createdAt),
    );
  }

  factory InstrumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstrumentRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $InstrumentsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      ticker: serializer.fromJson<String?>(json['ticker']),
      isin: serializer.fromJson<String?>(json['isin']),
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
      'kind': serializer.toJson<String>(
        $InstrumentsTable.$converterkind.toJson(kind),
      ),
      'ticker': serializer.toJson<String?>(ticker),
      'isin': serializer.toJson<String?>(isin),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InstrumentRow copyWith({
    String? id,
    String? name,
    InstrumentKind? kind,
    Value<String?> ticker = const Value.absent(),
    Value<String?> isin = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    DateTime? createdAt,
  }) => InstrumentRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    ticker: ticker.present ? ticker.value : this.ticker,
    isin: isin.present ? isin.value : this.isin,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  InstrumentRow copyWithCompanion(InstrumentsCompanion data) {
    return InstrumentRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      ticker: data.ticker.present ? data.ticker.value : this.ticker,
      isin: data.isin.present ? data.isin.value : this.isin,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('ticker: $ticker, ')
          ..write('isin: $isin, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, kind, ticker, isin, archivedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstrumentRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.ticker == this.ticker &&
          other.isin == this.isin &&
          other.archivedAt == this.archivedAt &&
          other.createdAt == this.createdAt);
}

class InstrumentsCompanion extends UpdateCompanion<InstrumentRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<InstrumentKind> kind;
  final Value<String?> ticker;
  final Value<String?> isin;
  final Value<DateTime?> archivedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InstrumentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.ticker = const Value.absent(),
    this.isin = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstrumentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required InstrumentKind kind,
    this.ticker = const Value.absent(),
    this.isin = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind);
  static Insertable<InstrumentRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? ticker,
    Expression<String>? isin,
    Expression<DateTime>? archivedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (ticker != null) 'ticker': ticker,
      if (isin != null) 'isin': isin,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstrumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<InstrumentKind>? kind,
    Value<String?>? ticker,
    Value<String?>? isin,
    Value<DateTime?>? archivedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InstrumentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      ticker: ticker ?? this.ticker,
      isin: isin ?? this.isin,
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
    if (kind.present) {
      map['kind'] = Variable<String>(
        $InstrumentsTable.$converterkind.toSql(kind.value),
      );
    }
    if (ticker.present) {
      map['ticker'] = Variable<String>(ticker.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
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
    return (StringBuffer('InstrumentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('ticker: $ticker, ')
          ..write('isin: $isin, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentLotsTable extends InvestmentLots
    with TableInfo<$InvestmentLotsTable, InvestmentLotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentLotsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (id)',
    ),
  );
  static const VerificationMeta _quantityScaledMeta = const VerificationMeta(
    'quantityScaled',
  );
  @override
  late final GeneratedColumn<int> quantityScaled = GeneratedColumn<int>(
    'quantity_scaled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMinorMeta = const VerificationMeta(
    'unitCostMinor',
  );
  @override
  late final GeneratedColumn<int> unitCostMinor = GeneratedColumn<int>(
    'unit_cost_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LotSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LotSource>($InvestmentLotsTable.$convertersource);
  static const VerificationMeta _acquiredAtMeta = const VerificationMeta(
    'acquiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> acquiredAt = GeneratedColumn<DateTime>(
    'acquired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedUntilMeta = const VerificationMeta(
    'lockedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
    'locked_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    accountId,
    instrumentId,
    quantityScaled,
    unitCostMinor,
    source,
    acquiredAt,
    lockedUntil,
    journalEntryId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_lots';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentLotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('quantity_scaled')) {
      context.handle(
        _quantityScaledMeta,
        quantityScaled.isAcceptableOrUnknown(
          data['quantity_scaled']!,
          _quantityScaledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityScaledMeta);
    }
    if (data.containsKey('unit_cost_minor')) {
      context.handle(
        _unitCostMinorMeta,
        unitCostMinor.isAcceptableOrUnknown(
          data['unit_cost_minor']!,
          _unitCostMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostMinorMeta);
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_acquiredAtMeta);
    }
    if (data.containsKey('locked_until')) {
      context.handle(
        _lockedUntilMeta,
        lockedUntil.isAcceptableOrUnknown(
          data['locked_until']!,
          _lockedUntilMeta,
        ),
      );
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_journalEntryIdMeta);
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
  InvestmentLotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentLotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      quantityScaled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_scaled'],
      )!,
      unitCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_minor'],
      )!,
      source: $InvestmentLotsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_at'],
      )!,
      lockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_until'],
      ),
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InvestmentLotsTable createAlias(String alias) {
    return $InvestmentLotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LotSource, String, String> $convertersource =
      const EnumNameConverter<LotSource>(LotSource.values);
}

class InvestmentLotRow extends DataClass
    implements Insertable<InvestmentLotRow> {
  final String id;
  final String accountId;
  final String instrumentId;
  final int quantityScaled;
  final int unitCostMinor;
  final LotSource source;
  final DateTime acquiredAt;
  final DateTime? lockedUntil;
  final String journalEntryId;
  final DateTime createdAt;
  const InvestmentLotRow({
    required this.id,
    required this.accountId,
    required this.instrumentId,
    required this.quantityScaled,
    required this.unitCostMinor,
    required this.source,
    required this.acquiredAt,
    this.lockedUntil,
    required this.journalEntryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['quantity_scaled'] = Variable<int>(quantityScaled);
    map['unit_cost_minor'] = Variable<int>(unitCostMinor);
    {
      map['source'] = Variable<String>(
        $InvestmentLotsTable.$convertersource.toSql(source),
      );
    }
    map['acquired_at'] = Variable<DateTime>(acquiredAt);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    map['journal_entry_id'] = Variable<String>(journalEntryId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvestmentLotsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentLotsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      instrumentId: Value(instrumentId),
      quantityScaled: Value(quantityScaled),
      unitCostMinor: Value(unitCostMinor),
      source: Value(source),
      acquiredAt: Value(acquiredAt),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
      journalEntryId: Value(journalEntryId),
      createdAt: Value(createdAt),
    );
  }

  factory InvestmentLotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentLotRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      quantityScaled: serializer.fromJson<int>(json['quantityScaled']),
      unitCostMinor: serializer.fromJson<int>(json['unitCostMinor']),
      source: $InvestmentLotsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      acquiredAt: serializer.fromJson<DateTime>(json['acquiredAt']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
      journalEntryId: serializer.fromJson<String>(json['journalEntryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'quantityScaled': serializer.toJson<int>(quantityScaled),
      'unitCostMinor': serializer.toJson<int>(unitCostMinor),
      'source': serializer.toJson<String>(
        $InvestmentLotsTable.$convertersource.toJson(source),
      ),
      'acquiredAt': serializer.toJson<DateTime>(acquiredAt),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
      'journalEntryId': serializer.toJson<String>(journalEntryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InvestmentLotRow copyWith({
    String? id,
    String? accountId,
    String? instrumentId,
    int? quantityScaled,
    int? unitCostMinor,
    LotSource? source,
    DateTime? acquiredAt,
    Value<DateTime?> lockedUntil = const Value.absent(),
    String? journalEntryId,
    DateTime? createdAt,
  }) => InvestmentLotRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    instrumentId: instrumentId ?? this.instrumentId,
    quantityScaled: quantityScaled ?? this.quantityScaled,
    unitCostMinor: unitCostMinor ?? this.unitCostMinor,
    source: source ?? this.source,
    acquiredAt: acquiredAt ?? this.acquiredAt,
    lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
    journalEntryId: journalEntryId ?? this.journalEntryId,
    createdAt: createdAt ?? this.createdAt,
  );
  InvestmentLotRow copyWithCompanion(InvestmentLotsCompanion data) {
    return InvestmentLotRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      quantityScaled: data.quantityScaled.present
          ? data.quantityScaled.value
          : this.quantityScaled,
      unitCostMinor: data.unitCostMinor.present
          ? data.unitCostMinor.value
          : this.unitCostMinor,
      source: data.source.present ? data.source.value : this.source,
      acquiredAt: data.acquiredAt.present
          ? data.acquiredAt.value
          : this.acquiredAt,
      lockedUntil: data.lockedUntil.present
          ? data.lockedUntil.value
          : this.lockedUntil,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentLotRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('quantityScaled: $quantityScaled, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('source: $source, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    instrumentId,
    quantityScaled,
    unitCostMinor,
    source,
    acquiredAt,
    lockedUntil,
    journalEntryId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentLotRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.instrumentId == this.instrumentId &&
          other.quantityScaled == this.quantityScaled &&
          other.unitCostMinor == this.unitCostMinor &&
          other.source == this.source &&
          other.acquiredAt == this.acquiredAt &&
          other.lockedUntil == this.lockedUntil &&
          other.journalEntryId == this.journalEntryId &&
          other.createdAt == this.createdAt);
}

class InvestmentLotsCompanion extends UpdateCompanion<InvestmentLotRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> instrumentId;
  final Value<int> quantityScaled;
  final Value<int> unitCostMinor;
  final Value<LotSource> source;
  final Value<DateTime> acquiredAt;
  final Value<DateTime?> lockedUntil;
  final Value<String> journalEntryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvestmentLotsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.quantityScaled = const Value.absent(),
    this.unitCostMinor = const Value.absent(),
    this.source = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentLotsCompanion.insert({
    this.id = const Value.absent(),
    required String accountId,
    required String instrumentId,
    required int quantityScaled,
    required int unitCostMinor,
    required LotSource source,
    required DateTime acquiredAt,
    this.lockedUntil = const Value.absent(),
    required String journalEntryId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       instrumentId = Value(instrumentId),
       quantityScaled = Value(quantityScaled),
       unitCostMinor = Value(unitCostMinor),
       source = Value(source),
       acquiredAt = Value(acquiredAt),
       journalEntryId = Value(journalEntryId);
  static Insertable<InvestmentLotRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? instrumentId,
    Expression<int>? quantityScaled,
    Expression<int>? unitCostMinor,
    Expression<String>? source,
    Expression<DateTime>? acquiredAt,
    Expression<DateTime>? lockedUntil,
    Expression<String>? journalEntryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (quantityScaled != null) 'quantity_scaled': quantityScaled,
      if (unitCostMinor != null) 'unit_cost_minor': unitCostMinor,
      if (source != null) 'source': source,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentLotsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? instrumentId,
    Value<int>? quantityScaled,
    Value<int>? unitCostMinor,
    Value<LotSource>? source,
    Value<DateTime>? acquiredAt,
    Value<DateTime?>? lockedUntil,
    Value<String>? journalEntryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InvestmentLotsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      instrumentId: instrumentId ?? this.instrumentId,
      quantityScaled: quantityScaled ?? this.quantityScaled,
      unitCostMinor: unitCostMinor ?? this.unitCostMinor,
      source: source ?? this.source,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      journalEntryId: journalEntryId ?? this.journalEntryId,
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
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (quantityScaled.present) {
      map['quantity_scaled'] = Variable<int>(quantityScaled.value);
    }
    if (unitCostMinor.present) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $InvestmentLotsTable.$convertersource.toSql(source.value),
      );
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
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
    return (StringBuffer('InvestmentLotsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('quantityScaled: $quantityScaled, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('source: $source, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentSellsTable extends InvestmentSells
    with TableInfo<$InvestmentSellsTable, InvestmentSellRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentSellsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (id)',
    ),
  );
  static const VerificationMeta _quantityScaledMeta = const VerificationMeta(
    'quantityScaled',
  );
  @override
  late final GeneratedColumn<int> quantityScaled = GeneratedColumn<int>(
    'quantity_scaled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    accountId,
    instrumentId,
    quantityScaled,
    journalEntryId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_sells';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentSellRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('quantity_scaled')) {
      context.handle(
        _quantityScaledMeta,
        quantityScaled.isAcceptableOrUnknown(
          data['quantity_scaled']!,
          _quantityScaledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityScaledMeta);
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_journalEntryIdMeta);
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
  InvestmentSellRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentSellRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      quantityScaled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_scaled'],
      )!,
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InvestmentSellsTable createAlias(String alias) {
    return $InvestmentSellsTable(attachedDatabase, alias);
  }
}

class InvestmentSellRow extends DataClass
    implements Insertable<InvestmentSellRow> {
  final String id;
  final String accountId;
  final String instrumentId;
  final int quantityScaled;
  final String journalEntryId;
  final DateTime createdAt;
  const InvestmentSellRow({
    required this.id,
    required this.accountId,
    required this.instrumentId,
    required this.quantityScaled,
    required this.journalEntryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['quantity_scaled'] = Variable<int>(quantityScaled);
    map['journal_entry_id'] = Variable<String>(journalEntryId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvestmentSellsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentSellsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      instrumentId: Value(instrumentId),
      quantityScaled: Value(quantityScaled),
      journalEntryId: Value(journalEntryId),
      createdAt: Value(createdAt),
    );
  }

  factory InvestmentSellRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentSellRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      quantityScaled: serializer.fromJson<int>(json['quantityScaled']),
      journalEntryId: serializer.fromJson<String>(json['journalEntryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'quantityScaled': serializer.toJson<int>(quantityScaled),
      'journalEntryId': serializer.toJson<String>(journalEntryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InvestmentSellRow copyWith({
    String? id,
    String? accountId,
    String? instrumentId,
    int? quantityScaled,
    String? journalEntryId,
    DateTime? createdAt,
  }) => InvestmentSellRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    instrumentId: instrumentId ?? this.instrumentId,
    quantityScaled: quantityScaled ?? this.quantityScaled,
    journalEntryId: journalEntryId ?? this.journalEntryId,
    createdAt: createdAt ?? this.createdAt,
  );
  InvestmentSellRow copyWithCompanion(InvestmentSellsCompanion data) {
    return InvestmentSellRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      quantityScaled: data.quantityScaled.present
          ? data.quantityScaled.value
          : this.quantityScaled,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentSellRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('quantityScaled: $quantityScaled, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    instrumentId,
    quantityScaled,
    journalEntryId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentSellRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.instrumentId == this.instrumentId &&
          other.quantityScaled == this.quantityScaled &&
          other.journalEntryId == this.journalEntryId &&
          other.createdAt == this.createdAt);
}

class InvestmentSellsCompanion extends UpdateCompanion<InvestmentSellRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> instrumentId;
  final Value<int> quantityScaled;
  final Value<String> journalEntryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvestmentSellsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.quantityScaled = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentSellsCompanion.insert({
    this.id = const Value.absent(),
    required String accountId,
    required String instrumentId,
    required int quantityScaled,
    required String journalEntryId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       instrumentId = Value(instrumentId),
       quantityScaled = Value(quantityScaled),
       journalEntryId = Value(journalEntryId);
  static Insertable<InvestmentSellRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? instrumentId,
    Expression<int>? quantityScaled,
    Expression<String>? journalEntryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (quantityScaled != null) 'quantity_scaled': quantityScaled,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentSellsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? instrumentId,
    Value<int>? quantityScaled,
    Value<String>? journalEntryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InvestmentSellsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      instrumentId: instrumentId ?? this.instrumentId,
      quantityScaled: quantityScaled ?? this.quantityScaled,
      journalEntryId: journalEntryId ?? this.journalEntryId,
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
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (quantityScaled.present) {
      map['quantity_scaled'] = Variable<int>(quantityScaled.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
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
    return (StringBuffer('InvestmentSellsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('quantityScaled: $quantityScaled, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstrumentQuotesTable extends InstrumentQuotes
    with TableInfo<$InstrumentQuotesTable, InstrumentQuoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstrumentQuotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (id)',
    ),
  );
  static const VerificationMeta _priceMinorMeta = const VerificationMeta(
    'priceMinor',
  );
  @override
  late final GeneratedColumn<int> priceMinor = GeneratedColumn<int>(
    'price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    instrumentId,
    priceMinor,
    currency,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instrument_quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstrumentQuoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('price_minor')) {
      context.handle(
        _priceMinorMeta,
        priceMinor.isAcceptableOrUnknown(data['price_minor']!, _priceMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstrumentQuoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstrumentQuoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      priceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $InstrumentQuotesTable createAlias(String alias) {
    return $InstrumentQuotesTable(attachedDatabase, alias);
  }
}

class InstrumentQuoteRow extends DataClass
    implements Insertable<InstrumentQuoteRow> {
  final String id;
  final String instrumentId;
  final int priceMinor;
  final String currency;
  final DateTime fetchedAt;
  const InstrumentQuoteRow({
    required this.id,
    required this.instrumentId,
    required this.priceMinor,
    required this.currency,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['price_minor'] = Variable<int>(priceMinor);
    map['currency'] = Variable<String>(currency);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  InstrumentQuotesCompanion toCompanion(bool nullToAbsent) {
    return InstrumentQuotesCompanion(
      id: Value(id),
      instrumentId: Value(instrumentId),
      priceMinor: Value(priceMinor),
      currency: Value(currency),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory InstrumentQuoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstrumentQuoteRow(
      id: serializer.fromJson<String>(json['id']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      priceMinor: serializer.fromJson<int>(json['priceMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'priceMinor': serializer.toJson<int>(priceMinor),
      'currency': serializer.toJson<String>(currency),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  InstrumentQuoteRow copyWith({
    String? id,
    String? instrumentId,
    int? priceMinor,
    String? currency,
    DateTime? fetchedAt,
  }) => InstrumentQuoteRow(
    id: id ?? this.id,
    instrumentId: instrumentId ?? this.instrumentId,
    priceMinor: priceMinor ?? this.priceMinor,
    currency: currency ?? this.currency,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  InstrumentQuoteRow copyWithCompanion(InstrumentQuotesCompanion data) {
    return InstrumentQuoteRow(
      id: data.id.present ? data.id.value : this.id,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      priceMinor: data.priceMinor.present
          ? data.priceMinor.value
          : this.priceMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentQuoteRow(')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, instrumentId, priceMinor, currency, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstrumentQuoteRow &&
          other.id == this.id &&
          other.instrumentId == this.instrumentId &&
          other.priceMinor == this.priceMinor &&
          other.currency == this.currency &&
          other.fetchedAt == this.fetchedAt);
}

class InstrumentQuotesCompanion extends UpdateCompanion<InstrumentQuoteRow> {
  final Value<String> id;
  final Value<String> instrumentId;
  final Value<int> priceMinor;
  final Value<String> currency;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const InstrumentQuotesCompanion({
    this.id = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.priceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstrumentQuotesCompanion.insert({
    this.id = const Value.absent(),
    required String instrumentId,
    required int priceMinor,
    required String currency,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : instrumentId = Value(instrumentId),
       priceMinor = Value(priceMinor),
       currency = Value(currency),
       fetchedAt = Value(fetchedAt);
  static Insertable<InstrumentQuoteRow> custom({
    Expression<String>? id,
    Expression<String>? instrumentId,
    Expression<int>? priceMinor,
    Expression<String>? currency,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (priceMinor != null) 'price_minor': priceMinor,
      if (currency != null) 'currency': currency,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstrumentQuotesCompanion copyWith({
    Value<String>? id,
    Value<String>? instrumentId,
    Value<int>? priceMinor,
    Value<String>? currency,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return InstrumentQuotesCompanion(
      id: id ?? this.id,
      instrumentId: instrumentId ?? this.instrumentId,
      priceMinor: priceMinor ?? this.priceMinor,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (priceMinor.present) {
      map['price_minor'] = Variable<int>(priceMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentQuotesCompanion(')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingTransfersTable extends PendingTransfers
    with TableInfo<$PendingTransfersTable, PendingTransferRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingTransfersTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<PendingTransferKind, String>
  kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PendingTransferKind>($PendingTransfersTable.$converterkind);
  static const VerificationMeta _sourceAccountIdMeta = const VerificationMeta(
    'sourceAccountId',
  );
  @override
  late final GeneratedColumn<String> sourceAccountId = GeneratedColumn<String>(
    'source_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES accounts (id)',
        ),
      );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _provisionalEntryIdMeta =
      const VerificationMeta('provisionalEntryId');
  @override
  late final GeneratedColumn<String> provisionalEntryId =
      GeneratedColumn<String>(
        'provisional_entry_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES journal_entries (id)',
        ),
      );
  @override
  late final GeneratedColumnWithTypeConverter<PendingTransferStatus, String>
  status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PendingTransferStatus>(
        $PendingTransfersTable.$converterstatus,
      );
  static const VerificationMeta _settlementEntryIdMeta = const VerificationMeta(
    'settlementEntryId',
  );
  @override
  late final GeneratedColumn<String> settlementEntryId =
      GeneratedColumn<String>(
        'settlement_entry_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES journal_entries (id)',
        ),
      );
  static const VerificationMeta _feeEntryIdMeta = const VerificationMeta(
    'feeEntryId',
  );
  @override
  late final GeneratedColumn<String> feeEntryId = GeneratedColumn<String>(
    'fee_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journal_entries (id)',
    ),
  );
  static const VerificationMeta _initiatedAtMeta = const VerificationMeta(
    'initiatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> initiatedAt = GeneratedColumn<DateTime>(
    'initiated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    sourceAccountId,
    categoryId,
    destinationAccountId,
    currency,
    provisionalEntryId,
    status,
    settlementEntryId,
    feeEntryId,
    initiatedAt,
    settledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingTransferRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_account_id')) {
      context.handle(
        _sourceAccountIdMeta,
        sourceAccountId.isAcceptableOrUnknown(
          data['source_account_id']!,
          _sourceAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceAccountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('provisional_entry_id')) {
      context.handle(
        _provisionalEntryIdMeta,
        provisionalEntryId.isAcceptableOrUnknown(
          data['provisional_entry_id']!,
          _provisionalEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_provisionalEntryIdMeta);
    }
    if (data.containsKey('settlement_entry_id')) {
      context.handle(
        _settlementEntryIdMeta,
        settlementEntryId.isAcceptableOrUnknown(
          data['settlement_entry_id']!,
          _settlementEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('fee_entry_id')) {
      context.handle(
        _feeEntryIdMeta,
        feeEntryId.isAcceptableOrUnknown(
          data['fee_entry_id']!,
          _feeEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('initiated_at')) {
      context.handle(
        _initiatedAtMeta,
        initiatedAt.isAcceptableOrUnknown(
          data['initiated_at']!,
          _initiatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initiatedAtMeta);
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingTransferRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingTransferRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $PendingTransfersTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      sourceAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      provisionalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provisional_entry_id'],
      )!,
      status: $PendingTransfersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      settlementEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_entry_id'],
      ),
      feeEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fee_entry_id'],
      ),
      initiatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}initiated_at'],
      )!,
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_at'],
      ),
    );
  }

  @override
  $PendingTransfersTable createAlias(String alias) {
    return $PendingTransfersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PendingTransferKind, String, String>
  $converterkind = const EnumNameConverter<PendingTransferKind>(
    PendingTransferKind.values,
  );
  static JsonTypeConverter2<PendingTransferStatus, String, String>
  $converterstatus = const EnumNameConverter<PendingTransferStatus>(
    PendingTransferStatus.values,
  );
}

class PendingTransferRow extends DataClass
    implements Insertable<PendingTransferRow> {
  final String id;
  final PendingTransferKind kind;
  final String sourceAccountId;

  /// Set only when [kind] is [PendingTransferKind.foreignTransaction].
  final String? categoryId;

  /// Planned destination; set only when [kind] is
  /// [PendingTransferKind.transfer] - a foreign-currency transaction has no
  /// natural "to" account the way a transfer does.
  final String? destinationAccountId;

  /// The currency the provisional entry's clearing leg was actually posted
  /// in - the source account's own group currency for a `transfer`, or the
  /// transaction's native currency for a `foreignTransaction` (which can
  /// differ from the financial account's own currency - the whole reason
  /// this pending item exists). Snapshotted at creation time since neither
  /// value is otherwise recoverable later (categories aren't group-scoped
  /// and carry no currency of their own).
  final String currency;
  final String provisionalEntryId;
  final PendingTransferStatus status;
  final String? settlementEntryId;
  final String? feeEntryId;
  final DateTime initiatedAt;
  final DateTime? settledAt;
  const PendingTransferRow({
    required this.id,
    required this.kind,
    required this.sourceAccountId,
    this.categoryId,
    this.destinationAccountId,
    required this.currency,
    required this.provisionalEntryId,
    required this.status,
    this.settlementEntryId,
    this.feeEntryId,
    required this.initiatedAt,
    this.settledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<String>(
        $PendingTransfersTable.$converterkind.toSql(kind),
      );
    }
    map['source_account_id'] = Variable<String>(sourceAccountId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    map['currency'] = Variable<String>(currency);
    map['provisional_entry_id'] = Variable<String>(provisionalEntryId);
    {
      map['status'] = Variable<String>(
        $PendingTransfersTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || settlementEntryId != null) {
      map['settlement_entry_id'] = Variable<String>(settlementEntryId);
    }
    if (!nullToAbsent || feeEntryId != null) {
      map['fee_entry_id'] = Variable<String>(feeEntryId);
    }
    map['initiated_at'] = Variable<DateTime>(initiatedAt);
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<DateTime>(settledAt);
    }
    return map;
  }

  PendingTransfersCompanion toCompanion(bool nullToAbsent) {
    return PendingTransfersCompanion(
      id: Value(id),
      kind: Value(kind),
      sourceAccountId: Value(sourceAccountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      currency: Value(currency),
      provisionalEntryId: Value(provisionalEntryId),
      status: Value(status),
      settlementEntryId: settlementEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(settlementEntryId),
      feeEntryId: feeEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(feeEntryId),
      initiatedAt: Value(initiatedAt),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
    );
  }

  factory PendingTransferRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingTransferRow(
      id: serializer.fromJson<String>(json['id']),
      kind: $PendingTransfersTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      sourceAccountId: serializer.fromJson<String>(json['sourceAccountId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      destinationAccountId: serializer.fromJson<String?>(
        json['destinationAccountId'],
      ),
      currency: serializer.fromJson<String>(json['currency']),
      provisionalEntryId: serializer.fromJson<String>(
        json['provisionalEntryId'],
      ),
      status: $PendingTransfersTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      settlementEntryId: serializer.fromJson<String?>(
        json['settlementEntryId'],
      ),
      feeEntryId: serializer.fromJson<String?>(json['feeEntryId']),
      initiatedAt: serializer.fromJson<DateTime>(json['initiatedAt']),
      settledAt: serializer.fromJson<DateTime?>(json['settledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(
        $PendingTransfersTable.$converterkind.toJson(kind),
      ),
      'sourceAccountId': serializer.toJson<String>(sourceAccountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'currency': serializer.toJson<String>(currency),
      'provisionalEntryId': serializer.toJson<String>(provisionalEntryId),
      'status': serializer.toJson<String>(
        $PendingTransfersTable.$converterstatus.toJson(status),
      ),
      'settlementEntryId': serializer.toJson<String?>(settlementEntryId),
      'feeEntryId': serializer.toJson<String?>(feeEntryId),
      'initiatedAt': serializer.toJson<DateTime>(initiatedAt),
      'settledAt': serializer.toJson<DateTime?>(settledAt),
    };
  }

  PendingTransferRow copyWith({
    String? id,
    PendingTransferKind? kind,
    String? sourceAccountId,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> destinationAccountId = const Value.absent(),
    String? currency,
    String? provisionalEntryId,
    PendingTransferStatus? status,
    Value<String?> settlementEntryId = const Value.absent(),
    Value<String?> feeEntryId = const Value.absent(),
    DateTime? initiatedAt,
    Value<DateTime?> settledAt = const Value.absent(),
  }) => PendingTransferRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    sourceAccountId: sourceAccountId ?? this.sourceAccountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    currency: currency ?? this.currency,
    provisionalEntryId: provisionalEntryId ?? this.provisionalEntryId,
    status: status ?? this.status,
    settlementEntryId: settlementEntryId.present
        ? settlementEntryId.value
        : this.settlementEntryId,
    feeEntryId: feeEntryId.present ? feeEntryId.value : this.feeEntryId,
    initiatedAt: initiatedAt ?? this.initiatedAt,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
  );
  PendingTransferRow copyWithCompanion(PendingTransfersCompanion data) {
    return PendingTransferRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      sourceAccountId: data.sourceAccountId.present
          ? data.sourceAccountId.value
          : this.sourceAccountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      currency: data.currency.present ? data.currency.value : this.currency,
      provisionalEntryId: data.provisionalEntryId.present
          ? data.provisionalEntryId.value
          : this.provisionalEntryId,
      status: data.status.present ? data.status.value : this.status,
      settlementEntryId: data.settlementEntryId.present
          ? data.settlementEntryId.value
          : this.settlementEntryId,
      feeEntryId: data.feeEntryId.present
          ? data.feeEntryId.value
          : this.feeEntryId,
      initiatedAt: data.initiatedAt.present
          ? data.initiatedAt.value
          : this.initiatedAt,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingTransferRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('currency: $currency, ')
          ..write('provisionalEntryId: $provisionalEntryId, ')
          ..write('status: $status, ')
          ..write('settlementEntryId: $settlementEntryId, ')
          ..write('feeEntryId: $feeEntryId, ')
          ..write('initiatedAt: $initiatedAt, ')
          ..write('settledAt: $settledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    sourceAccountId,
    categoryId,
    destinationAccountId,
    currency,
    provisionalEntryId,
    status,
    settlementEntryId,
    feeEntryId,
    initiatedAt,
    settledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingTransferRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.sourceAccountId == this.sourceAccountId &&
          other.categoryId == this.categoryId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.currency == this.currency &&
          other.provisionalEntryId == this.provisionalEntryId &&
          other.status == this.status &&
          other.settlementEntryId == this.settlementEntryId &&
          other.feeEntryId == this.feeEntryId &&
          other.initiatedAt == this.initiatedAt &&
          other.settledAt == this.settledAt);
}

class PendingTransfersCompanion extends UpdateCompanion<PendingTransferRow> {
  final Value<String> id;
  final Value<PendingTransferKind> kind;
  final Value<String> sourceAccountId;
  final Value<String?> categoryId;
  final Value<String?> destinationAccountId;
  final Value<String> currency;
  final Value<String> provisionalEntryId;
  final Value<PendingTransferStatus> status;
  final Value<String?> settlementEntryId;
  final Value<String?> feeEntryId;
  final Value<DateTime> initiatedAt;
  final Value<DateTime?> settledAt;
  final Value<int> rowid;
  const PendingTransfersCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.sourceAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.currency = const Value.absent(),
    this.provisionalEntryId = const Value.absent(),
    this.status = const Value.absent(),
    this.settlementEntryId = const Value.absent(),
    this.feeEntryId = const Value.absent(),
    this.initiatedAt = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingTransfersCompanion.insert({
    this.id = const Value.absent(),
    required PendingTransferKind kind,
    required String sourceAccountId,
    this.categoryId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    required String currency,
    required String provisionalEntryId,
    required PendingTransferStatus status,
    this.settlementEntryId = const Value.absent(),
    this.feeEntryId = const Value.absent(),
    required DateTime initiatedAt,
    this.settledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       sourceAccountId = Value(sourceAccountId),
       currency = Value(currency),
       provisionalEntryId = Value(provisionalEntryId),
       status = Value(status),
       initiatedAt = Value(initiatedAt);
  static Insertable<PendingTransferRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? sourceAccountId,
    Expression<String>? categoryId,
    Expression<String>? destinationAccountId,
    Expression<String>? currency,
    Expression<String>? provisionalEntryId,
    Expression<String>? status,
    Expression<String>? settlementEntryId,
    Expression<String>? feeEntryId,
    Expression<DateTime>? initiatedAt,
    Expression<DateTime>? settledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (sourceAccountId != null) 'source_account_id': sourceAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (currency != null) 'currency': currency,
      if (provisionalEntryId != null)
        'provisional_entry_id': provisionalEntryId,
      if (status != null) 'status': status,
      if (settlementEntryId != null) 'settlement_entry_id': settlementEntryId,
      if (feeEntryId != null) 'fee_entry_id': feeEntryId,
      if (initiatedAt != null) 'initiated_at': initiatedAt,
      if (settledAt != null) 'settled_at': settledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingTransfersCompanion copyWith({
    Value<String>? id,
    Value<PendingTransferKind>? kind,
    Value<String>? sourceAccountId,
    Value<String?>? categoryId,
    Value<String?>? destinationAccountId,
    Value<String>? currency,
    Value<String>? provisionalEntryId,
    Value<PendingTransferStatus>? status,
    Value<String?>? settlementEntryId,
    Value<String?>? feeEntryId,
    Value<DateTime>? initiatedAt,
    Value<DateTime?>? settledAt,
    Value<int>? rowid,
  }) {
    return PendingTransfersCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      categoryId: categoryId ?? this.categoryId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      currency: currency ?? this.currency,
      provisionalEntryId: provisionalEntryId ?? this.provisionalEntryId,
      status: status ?? this.status,
      settlementEntryId: settlementEntryId ?? this.settlementEntryId,
      feeEntryId: feeEntryId ?? this.feeEntryId,
      initiatedAt: initiatedAt ?? this.initiatedAt,
      settledAt: settledAt ?? this.settledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PendingTransfersTable.$converterkind.toSql(kind.value),
      );
    }
    if (sourceAccountId.present) {
      map['source_account_id'] = Variable<String>(sourceAccountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (provisionalEntryId.present) {
      map['provisional_entry_id'] = Variable<String>(provisionalEntryId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PendingTransfersTable.$converterstatus.toSql(status.value),
      );
    }
    if (settlementEntryId.present) {
      map['settlement_entry_id'] = Variable<String>(settlementEntryId.value);
    }
    if (feeEntryId.present) {
      map['fee_entry_id'] = Variable<String>(feeEntryId.value);
    }
    if (initiatedAt.present) {
      map['initiated_at'] = Variable<DateTime>(initiatedAt.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingTransfersCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('currency: $currency, ')
          ..write('provisionalEntryId: $provisionalEntryId, ')
          ..write('status: $status, ')
          ..write('settlementEntryId: $settlementEntryId, ')
          ..write('feeEntryId: $feeEntryId, ')
          ..write('initiatedAt: $initiatedAt, ')
          ..write('settledAt: $settledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfxImportRecordsTable extends OfxImportRecords
    with TableInfo<$OfxImportRecordsTable, OfxImportRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfxImportRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _financialAccountIdMeta =
      const VerificationMeta('financialAccountId');
  @override
  late final GeneratedColumn<String> financialAccountId =
      GeneratedColumn<String>(
        'financial_account_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES accounts (id)',
        ),
      );
  static const VerificationMeta _fitidMeta = const VerificationMeta('fitid');
  @override
  late final GeneratedColumn<String> fitid = GeneratedColumn<String>(
    'fitid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fallbackMatchKeyMeta = const VerificationMeta(
    'fallbackMatchKey',
  );
  @override
  late final GeneratedColumn<String> fallbackMatchKey = GeneratedColumn<String>(
    'fallback_match_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journal_entries (id)',
    ),
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ImportSource?, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<ImportSource?>($OfxImportRecordsTable.$convertersourcen);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    financialAccountId,
    fitid,
    fallbackMatchKey,
    journalEntryId,
    importedAt,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ofx_import_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfxImportRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('financial_account_id')) {
      context.handle(
        _financialAccountIdMeta,
        financialAccountId.isAcceptableOrUnknown(
          data['financial_account_id']!,
          _financialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialAccountIdMeta);
    }
    if (data.containsKey('fitid')) {
      context.handle(
        _fitidMeta,
        fitid.isAcceptableOrUnknown(data['fitid']!, _fitidMeta),
      );
    }
    if (data.containsKey('fallback_match_key')) {
      context.handle(
        _fallbackMatchKeyMeta,
        fallbackMatchKey.isAcceptableOrUnknown(
          data['fallback_match_key']!,
          _fallbackMatchKeyMeta,
        ),
      );
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_journalEntryIdMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfxImportRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfxImportRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      financialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_account_id'],
      )!,
      fitid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fitid'],
      ),
      fallbackMatchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fallback_match_key'],
      ),
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      source: $OfxImportRecordsTable.$convertersourcen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        ),
      ),
    );
  }

  @override
  $OfxImportRecordsTable createAlias(String alias) {
    return $OfxImportRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ImportSource, String, String> $convertersource =
      const EnumNameConverter<ImportSource>(ImportSource.values);
  static JsonTypeConverter2<ImportSource?, String?, String?> $convertersourcen =
      JsonTypeConverter2.asNullable($convertersource);
}

class OfxImportRecordRow extends DataClass
    implements Insertable<OfxImportRecordRow> {
  final String id;
  final String financialAccountId;

  /// The source's own stable transaction id, when the source file provided
  /// one - OFX's `FITID`, or a CSV row's mapped reference-id column.
  /// Authoritative de-duplication key when present.
  final String? fitid;

  /// Fallback de-duplication key (`transactionDate|amountMinor|memo`) used
  /// when [fitid] is absent, per design.md Decision 2.
  final String? fallbackMatchKey;
  final String journalEntryId;
  final DateTime importedAt;

  /// Null for rows written before this column existed - all of which were
  /// necessarily OFX imports, since CSV import didn't exist yet.
  final ImportSource? source;
  const OfxImportRecordRow({
    required this.id,
    required this.financialAccountId,
    this.fitid,
    this.fallbackMatchKey,
    required this.journalEntryId,
    required this.importedAt,
    this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['financial_account_id'] = Variable<String>(financialAccountId);
    if (!nullToAbsent || fitid != null) {
      map['fitid'] = Variable<String>(fitid);
    }
    if (!nullToAbsent || fallbackMatchKey != null) {
      map['fallback_match_key'] = Variable<String>(fallbackMatchKey);
    }
    map['journal_entry_id'] = Variable<String>(journalEntryId);
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(
        $OfxImportRecordsTable.$convertersourcen.toSql(source),
      );
    }
    return map;
  }

  OfxImportRecordsCompanion toCompanion(bool nullToAbsent) {
    return OfxImportRecordsCompanion(
      id: Value(id),
      financialAccountId: Value(financialAccountId),
      fitid: fitid == null && nullToAbsent
          ? const Value.absent()
          : Value(fitid),
      fallbackMatchKey: fallbackMatchKey == null && nullToAbsent
          ? const Value.absent()
          : Value(fallbackMatchKey),
      journalEntryId: Value(journalEntryId),
      importedAt: Value(importedAt),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
    );
  }

  factory OfxImportRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfxImportRecordRow(
      id: serializer.fromJson<String>(json['id']),
      financialAccountId: serializer.fromJson<String>(
        json['financialAccountId'],
      ),
      fitid: serializer.fromJson<String?>(json['fitid']),
      fallbackMatchKey: serializer.fromJson<String?>(json['fallbackMatchKey']),
      journalEntryId: serializer.fromJson<String>(json['journalEntryId']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      source: $OfxImportRecordsTable.$convertersourcen.fromJson(
        serializer.fromJson<String?>(json['source']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'financialAccountId': serializer.toJson<String>(financialAccountId),
      'fitid': serializer.toJson<String?>(fitid),
      'fallbackMatchKey': serializer.toJson<String?>(fallbackMatchKey),
      'journalEntryId': serializer.toJson<String>(journalEntryId),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'source': serializer.toJson<String?>(
        $OfxImportRecordsTable.$convertersourcen.toJson(source),
      ),
    };
  }

  OfxImportRecordRow copyWith({
    String? id,
    String? financialAccountId,
    Value<String?> fitid = const Value.absent(),
    Value<String?> fallbackMatchKey = const Value.absent(),
    String? journalEntryId,
    DateTime? importedAt,
    Value<ImportSource?> source = const Value.absent(),
  }) => OfxImportRecordRow(
    id: id ?? this.id,
    financialAccountId: financialAccountId ?? this.financialAccountId,
    fitid: fitid.present ? fitid.value : this.fitid,
    fallbackMatchKey: fallbackMatchKey.present
        ? fallbackMatchKey.value
        : this.fallbackMatchKey,
    journalEntryId: journalEntryId ?? this.journalEntryId,
    importedAt: importedAt ?? this.importedAt,
    source: source.present ? source.value : this.source,
  );
  OfxImportRecordRow copyWithCompanion(OfxImportRecordsCompanion data) {
    return OfxImportRecordRow(
      id: data.id.present ? data.id.value : this.id,
      financialAccountId: data.financialAccountId.present
          ? data.financialAccountId.value
          : this.financialAccountId,
      fitid: data.fitid.present ? data.fitid.value : this.fitid,
      fallbackMatchKey: data.fallbackMatchKey.present
          ? data.fallbackMatchKey.value
          : this.fallbackMatchKey,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfxImportRecordRow(')
          ..write('id: $id, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('fitid: $fitid, ')
          ..write('fallbackMatchKey: $fallbackMatchKey, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('importedAt: $importedAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    financialAccountId,
    fitid,
    fallbackMatchKey,
    journalEntryId,
    importedAt,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfxImportRecordRow &&
          other.id == this.id &&
          other.financialAccountId == this.financialAccountId &&
          other.fitid == this.fitid &&
          other.fallbackMatchKey == this.fallbackMatchKey &&
          other.journalEntryId == this.journalEntryId &&
          other.importedAt == this.importedAt &&
          other.source == this.source);
}

class OfxImportRecordsCompanion extends UpdateCompanion<OfxImportRecordRow> {
  final Value<String> id;
  final Value<String> financialAccountId;
  final Value<String?> fitid;
  final Value<String?> fallbackMatchKey;
  final Value<String> journalEntryId;
  final Value<DateTime> importedAt;
  final Value<ImportSource?> source;
  final Value<int> rowid;
  const OfxImportRecordsCompanion({
    this.id = const Value.absent(),
    this.financialAccountId = const Value.absent(),
    this.fitid = const Value.absent(),
    this.fallbackMatchKey = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfxImportRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String financialAccountId,
    this.fitid = const Value.absent(),
    this.fallbackMatchKey = const Value.absent(),
    required String journalEntryId,
    required DateTime importedAt,
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : financialAccountId = Value(financialAccountId),
       journalEntryId = Value(journalEntryId),
       importedAt = Value(importedAt);
  static Insertable<OfxImportRecordRow> custom({
    Expression<String>? id,
    Expression<String>? financialAccountId,
    Expression<String>? fitid,
    Expression<String>? fallbackMatchKey,
    Expression<String>? journalEntryId,
    Expression<DateTime>? importedAt,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (financialAccountId != null)
        'financial_account_id': financialAccountId,
      if (fitid != null) 'fitid': fitid,
      if (fallbackMatchKey != null) 'fallback_match_key': fallbackMatchKey,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (importedAt != null) 'imported_at': importedAt,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfxImportRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? financialAccountId,
    Value<String?>? fitid,
    Value<String?>? fallbackMatchKey,
    Value<String>? journalEntryId,
    Value<DateTime>? importedAt,
    Value<ImportSource?>? source,
    Value<int>? rowid,
  }) {
    return OfxImportRecordsCompanion(
      id: id ?? this.id,
      financialAccountId: financialAccountId ?? this.financialAccountId,
      fitid: fitid ?? this.fitid,
      fallbackMatchKey: fallbackMatchKey ?? this.fallbackMatchKey,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      importedAt: importedAt ?? this.importedAt,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (financialAccountId.present) {
      map['financial_account_id'] = Variable<String>(financialAccountId.value);
    }
    if (fitid.present) {
      map['fitid'] = Variable<String>(fitid.value);
    }
    if (fallbackMatchKey.present) {
      map['fallback_match_key'] = Variable<String>(fallbackMatchKey.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $OfxImportRecordsTable.$convertersourcen.toSql(source.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfxImportRecordsCompanion(')
          ..write('id: $id, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('fitid: $fitid, ')
          ..write('fallbackMatchKey: $fallbackMatchKey, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('importedAt: $importedAt, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CsvImportProfilesTable extends CsvImportProfiles
    with TableInfo<$CsvImportProfilesTable, CsvImportProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CsvImportProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _headerFingerprintMeta = const VerificationMeta(
    'headerFingerprint',
  );
  @override
  late final GeneratedColumn<String> headerFingerprint =
      GeneratedColumn<String>(
        'header_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _columnMappingMeta = const VerificationMeta(
    'columnMapping',
  );
  @override
  late final GeneratedColumn<String> columnMapping = GeneratedColumn<String>(
    'column_mapping',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    headerFingerprint,
    columnMapping,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'csv_import_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CsvImportProfileRow> instance, {
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
    if (data.containsKey('header_fingerprint')) {
      context.handle(
        _headerFingerprintMeta,
        headerFingerprint.isAcceptableOrUnknown(
          data['header_fingerprint']!,
          _headerFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_headerFingerprintMeta);
    }
    if (data.containsKey('column_mapping')) {
      context.handle(
        _columnMappingMeta,
        columnMapping.isAcceptableOrUnknown(
          data['column_mapping']!,
          _columnMappingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_columnMappingMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CsvImportProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CsvImportProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      headerFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}header_fingerprint'],
      )!,
      columnMapping: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}column_mapping'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CsvImportProfilesTable createAlias(String alias) {
    return $CsvImportProfilesTable(attachedDatabase, alias);
  }
}

class CsvImportProfileRow extends DataClass
    implements Insertable<CsvImportProfileRow> {
  final String id;
  final String name;

  /// JSON-encoded ordered list of normalized header cells - the exact-match
  /// fingerprint a later file's header row is compared against.
  final String headerFingerprint;

  /// JSON-encoded `CsvColumnMapping`.
  final String columnMapping;
  final DateTime createdAt;
  const CsvImportProfileRow({
    required this.id,
    required this.name,
    required this.headerFingerprint,
    required this.columnMapping,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['header_fingerprint'] = Variable<String>(headerFingerprint);
    map['column_mapping'] = Variable<String>(columnMapping);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CsvImportProfilesCompanion toCompanion(bool nullToAbsent) {
    return CsvImportProfilesCompanion(
      id: Value(id),
      name: Value(name),
      headerFingerprint: Value(headerFingerprint),
      columnMapping: Value(columnMapping),
      createdAt: Value(createdAt),
    );
  }

  factory CsvImportProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CsvImportProfileRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      headerFingerprint: serializer.fromJson<String>(json['headerFingerprint']),
      columnMapping: serializer.fromJson<String>(json['columnMapping']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'headerFingerprint': serializer.toJson<String>(headerFingerprint),
      'columnMapping': serializer.toJson<String>(columnMapping),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CsvImportProfileRow copyWith({
    String? id,
    String? name,
    String? headerFingerprint,
    String? columnMapping,
    DateTime? createdAt,
  }) => CsvImportProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    headerFingerprint: headerFingerprint ?? this.headerFingerprint,
    columnMapping: columnMapping ?? this.columnMapping,
    createdAt: createdAt ?? this.createdAt,
  );
  CsvImportProfileRow copyWithCompanion(CsvImportProfilesCompanion data) {
    return CsvImportProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      headerFingerprint: data.headerFingerprint.present
          ? data.headerFingerprint.value
          : this.headerFingerprint,
      columnMapping: data.columnMapping.present
          ? data.columnMapping.value
          : this.columnMapping,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CsvImportProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('headerFingerprint: $headerFingerprint, ')
          ..write('columnMapping: $columnMapping, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, headerFingerprint, columnMapping, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CsvImportProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.headerFingerprint == this.headerFingerprint &&
          other.columnMapping == this.columnMapping &&
          other.createdAt == this.createdAt);
}

class CsvImportProfilesCompanion extends UpdateCompanion<CsvImportProfileRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> headerFingerprint;
  final Value<String> columnMapping;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CsvImportProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.headerFingerprint = const Value.absent(),
    this.columnMapping = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CsvImportProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String headerFingerprint,
    required String columnMapping,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       headerFingerprint = Value(headerFingerprint),
       columnMapping = Value(columnMapping),
       createdAt = Value(createdAt);
  static Insertable<CsvImportProfileRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? headerFingerprint,
    Expression<String>? columnMapping,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (headerFingerprint != null) 'header_fingerprint': headerFingerprint,
      if (columnMapping != null) 'column_mapping': columnMapping,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CsvImportProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? headerFingerprint,
    Value<String>? columnMapping,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CsvImportProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      headerFingerprint: headerFingerprint ?? this.headerFingerprint,
      columnMapping: columnMapping ?? this.columnMapping,
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
    if (headerFingerprint.present) {
      map['header_fingerprint'] = Variable<String>(headerFingerprint.value);
    }
    if (columnMapping.present) {
      map['column_mapping'] = Variable<String>(columnMapping.value);
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
    return (StringBuffer('CsvImportProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('headerFingerprint: $headerFingerprint, ')
          ..write('columnMapping: $columnMapping, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryRulesTable extends CategoryRules
    with TableInfo<$CategoryRulesTable, CategoryRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, keyword, categoryId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoryRulesTable createAlias(String alias) {
    return $CategoryRulesTable(attachedDatabase, alias);
  }
}

class CategoryRuleRow extends DataClass implements Insertable<CategoryRuleRow> {
  final String id;
  final String keyword;
  final String categoryId;
  final DateTime createdAt;
  const CategoryRuleRow({
    required this.id,
    required this.keyword,
    required this.categoryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['keyword'] = Variable<String>(keyword);
    map['category_id'] = Variable<String>(categoryId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoryRulesCompanion toCompanion(bool nullToAbsent) {
    return CategoryRulesCompanion(
      id: Value(id),
      keyword: Value(keyword),
      categoryId: Value(categoryId),
      createdAt: Value(createdAt),
    );
  }

  factory CategoryRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRuleRow(
      id: serializer.fromJson<String>(json['id']),
      keyword: serializer.fromJson<String>(json['keyword']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'keyword': serializer.toJson<String>(keyword),
      'categoryId': serializer.toJson<String>(categoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CategoryRuleRow copyWith({
    String? id,
    String? keyword,
    String? categoryId,
    DateTime? createdAt,
  }) => CategoryRuleRow(
    id: id ?? this.id,
    keyword: keyword ?? this.keyword,
    categoryId: categoryId ?? this.categoryId,
    createdAt: createdAt ?? this.createdAt,
  );
  CategoryRuleRow copyWithCompanion(CategoryRulesCompanion data) {
    return CategoryRuleRow(
      id: data.id.present ? data.id.value : this.id,
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRuleRow(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, keyword, categoryId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRuleRow &&
          other.id == this.id &&
          other.keyword == this.keyword &&
          other.categoryId == this.categoryId &&
          other.createdAt == this.createdAt);
}

class CategoryRulesCompanion extends UpdateCompanion<CategoryRuleRow> {
  final Value<String> id;
  final Value<String> keyword;
  final Value<String> categoryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoryRulesCompanion({
    this.id = const Value.absent(),
    this.keyword = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryRulesCompanion.insert({
    this.id = const Value.absent(),
    required String keyword,
    required String categoryId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : keyword = Value(keyword),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt);
  static Insertable<CategoryRuleRow> custom({
    Expression<String>? id,
    Expression<String>? keyword,
    Expression<String>? categoryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (keyword != null) 'keyword': keyword,
      if (categoryId != null) 'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? keyword,
    Value<String>? categoryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoryRulesCompanion(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      categoryId: categoryId ?? this.categoryId,
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
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
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
    return (StringBuffer('CategoryRulesCompanion(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountGroupsTable accountGroups = $AccountGroupsTable(this);
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
  late final $InstrumentsTable instruments = $InstrumentsTable(this);
  late final $InvestmentLotsTable investmentLots = $InvestmentLotsTable(this);
  late final $InvestmentSellsTable investmentSells = $InvestmentSellsTable(
    this,
  );
  late final $InstrumentQuotesTable instrumentQuotes = $InstrumentQuotesTable(
    this,
  );
  late final $PendingTransfersTable pendingTransfers = $PendingTransfersTable(
    this,
  );
  late final $OfxImportRecordsTable ofxImportRecords = $OfxImportRecordsTable(
    this,
  );
  late final $CsvImportProfilesTable csvImportProfiles =
      $CsvImportProfilesTable(this);
  late final $CategoryRulesTable categoryRules = $CategoryRulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accountGroups,
    accounts,
    signingIdentities,
    journalEntries,
    postings,
    entryVerificationCache,
    ledgerChainState,
    integrityEvents,
    instruments,
    investmentLots,
    investmentSells,
    instrumentQuotes,
    pendingTransfers,
    ofxImportRecords,
    csvImportProfiles,
    categoryRules,
  ];
}

typedef $$AccountGroupsTableCreateCompanionBuilder =
    AccountGroupsCompanion Function({
      Value<String> id,
      required String name,
      required AccountGroupKind kind,
      required int sortOrder,
      required bool isSystem,
      Value<String?> currency,
      Value<DateTime?> archivedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AccountGroupsTableUpdateCompanionBuilder =
    AccountGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<AccountGroupKind> kind,
      Value<int> sortOrder,
      Value<bool> isSystem,
      Value<String?> currency,
      Value<DateTime?> archivedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AccountGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountGroupsTable> {
  $$AccountGroupsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<AccountGroupKind, AccountGroupKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountGroupsTable> {
  $$AccountGroupsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
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

class $$AccountGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountGroupsTable> {
  $$AccountGroupsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<AccountGroupKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountGroupsTable,
          AccountGroupRow,
          $$AccountGroupsTableFilterComposer,
          $$AccountGroupsTableOrderingComposer,
          $$AccountGroupsTableAnnotationComposer,
          $$AccountGroupsTableCreateCompanionBuilder,
          $$AccountGroupsTableUpdateCompanionBuilder,
          (
            AccountGroupRow,
            BaseReferences<_$AppDatabase, $AccountGroupsTable, AccountGroupRow>,
          ),
          AccountGroupRow,
          PrefetchHooks Function()
        > {
  $$AccountGroupsTableTableManager(_$AppDatabase db, $AccountGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AccountGroupKind> kind = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountGroupsCompanion(
                id: id,
                name: name,
                kind: kind,
                sortOrder: sortOrder,
                isSystem: isSystem,
                currency: currency,
                archivedAt: archivedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required AccountGroupKind kind,
                required int sortOrder,
                required bool isSystem,
                Value<String?> currency = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountGroupsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                sortOrder: sortOrder,
                isSystem: isSystem,
                currency: currency,
                archivedAt: archivedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountGroupsTable,
      AccountGroupRow,
      $$AccountGroupsTableFilterComposer,
      $$AccountGroupsTableOrderingComposer,
      $$AccountGroupsTableAnnotationComposer,
      $$AccountGroupsTableCreateCompanionBuilder,
      $$AccountGroupsTableUpdateCompanionBuilder,
      (
        AccountGroupRow,
        BaseReferences<_$AppDatabase, $AccountGroupsTable, AccountGroupRow>,
      ),
      AccountGroupRow,
      PrefetchHooks Function()
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      required String name,
      required AccountType type,
      Value<bool> holdsInvestments,
      Value<String?> investmentOwnerAccountId,
      Value<String?> groupId,
      Value<int> sortOrder,
      Value<DateTime?> archivedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<AccountType> type,
      Value<bool> holdsInvestments,
      Value<String?> investmentOwnerAccountId,
      Value<String?> groupId,
      Value<int> sortOrder,
      Value<DateTime?> archivedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _investmentOwnerAccountIdTable(_$AppDatabase db) => db
      .accounts
      .createAlias('accounts__investment_owner_account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get investmentOwnerAccountId {
    final $_column = $_itemColumn<String>('investment_owner_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _investmentOwnerAccountIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

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

  static MultiTypedResultKey<$InvestmentLotsTable, List<InvestmentLotRow>>
  _investmentLotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investmentLots,
    aliasName: 'accounts__id__investment_lots__account_id',
  );

  $$InvestmentLotsTableProcessedTableManager get investmentLotsRefs {
    final manager = $$InvestmentLotsTableTableManager(
      $_db,
      $_db.investmentLots,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_investmentLotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestmentSellsTable, List<InvestmentSellRow>>
  _investmentSellsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investmentSells,
    aliasName: 'accounts__id__investment_sells__account_id',
  );

  $$InvestmentSellsTableProcessedTableManager get investmentSellsRefs {
    final manager = $$InvestmentSellsTableTableManager(
      $_db,
      $_db.investmentSells,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _investmentSellsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OfxImportRecordsTable, List<OfxImportRecordRow>>
  _ofxImportRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ofxImportRecords,
    aliasName: 'accounts__id__ofx_import_records__financial_account_id',
  );

  $$OfxImportRecordsTableProcessedTableManager get ofxImportRecordsRefs {
    final manager =
        $$OfxImportRecordsTableTableManager($_db, $_db.ofxImportRecords).filter(
          (f) => f.financialAccountId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _ofxImportRecordsRefsTable($_db),
    );
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

  ColumnFilters<bool> get holdsInvestments => $composableBuilder(
    column: $table.holdsInvestments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get investmentOwnerAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentOwnerAccountId,
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

  Expression<bool> investmentLotsRefs(
    Expression<bool> Function($$InvestmentLotsTableFilterComposer f) f,
  ) {
    final $$InvestmentLotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentLots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentLotsTableFilterComposer(
            $db: $db,
            $table: $db.investmentLots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investmentSellsRefs(
    Expression<bool> Function($$InvestmentSellsTableFilterComposer f) f,
  ) {
    final $$InvestmentSellsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentSells,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentSellsTableFilterComposer(
            $db: $db,
            $table: $db.investmentSells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ofxImportRecordsRefs(
    Expression<bool> Function($$OfxImportRecordsTableFilterComposer f) f,
  ) {
    final $$OfxImportRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ofxImportRecords,
      getReferencedColumn: (t) => t.financialAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OfxImportRecordsTableFilterComposer(
            $db: $db,
            $table: $db.ofxImportRecords,
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

  ColumnOrderings<bool> get holdsInvestments => $composableBuilder(
    column: $table.holdsInvestments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  $$AccountsTableOrderingComposer get investmentOwnerAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentOwnerAccountId,
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

  GeneratedColumn<bool> get holdsInvestments => $composableBuilder(
    column: $table.holdsInvestments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get investmentOwnerAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentOwnerAccountId,
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

  Expression<T> investmentLotsRefs<T extends Object>(
    Expression<T> Function($$InvestmentLotsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentLotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentLots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentLotsTableAnnotationComposer(
            $db: $db,
            $table: $db.investmentLots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investmentSellsRefs<T extends Object>(
    Expression<T> Function($$InvestmentSellsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentSellsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentSells,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentSellsTableAnnotationComposer(
            $db: $db,
            $table: $db.investmentSells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ofxImportRecordsRefs<T extends Object>(
    Expression<T> Function($$OfxImportRecordsTableAnnotationComposer a) f,
  ) {
    final $$OfxImportRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ofxImportRecords,
      getReferencedColumn: (t) => t.financialAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OfxImportRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.ofxImportRecords,
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
          PrefetchHooks Function({
            bool investmentOwnerAccountId,
            bool postingsRefs,
            bool investmentLotsRefs,
            bool investmentSellsRefs,
            bool ofxImportRecordsRefs,
          })
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
                Value<bool> holdsInvestments = const Value.absent(),
                Value<String?> investmentOwnerAccountId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                type: type,
                holdsInvestments: holdsInvestments,
                investmentOwnerAccountId: investmentOwnerAccountId,
                groupId: groupId,
                sortOrder: sortOrder,
                archivedAt: archivedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required AccountType type,
                Value<bool> holdsInvestments = const Value.absent(),
                Value<String?> investmentOwnerAccountId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                type: type,
                holdsInvestments: holdsInvestments,
                investmentOwnerAccountId: investmentOwnerAccountId,
                groupId: groupId,
                sortOrder: sortOrder,
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
          prefetchHooksCallback:
              ({
                investmentOwnerAccountId = false,
                postingsRefs = false,
                investmentLotsRefs = false,
                investmentSellsRefs = false,
                ofxImportRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (postingsRefs) db.postings,
                    if (investmentLotsRefs) db.investmentLots,
                    if (investmentSellsRefs) db.investmentSells,
                    if (ofxImportRecordsRefs) db.ofxImportRecords,
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
                        if (investmentOwnerAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.investmentOwnerAccountId,
                                    referencedTable: $$AccountsTableReferences
                                        ._investmentOwnerAccountIdTable(db),
                                    referencedColumn: $$AccountsTableReferences
                                        ._investmentOwnerAccountIdTable(db)
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
                          AccountRow,
                          $AccountsTable,
                          PostingRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._postingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).postingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investmentLotsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          InvestmentLotRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._investmentLotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentLotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investmentSellsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          InvestmentSellRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._investmentSellsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentSellsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ofxImportRecordsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          OfxImportRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._ofxImportRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).ofxImportRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.financialAccountId == item.id,
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
      PrefetchHooks Function({
        bool investmentOwnerAccountId,
        bool postingsRefs,
        bool investmentLotsRefs,
        bool investmentSellsRefs,
        bool ofxImportRecordsRefs,
      })
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

  static MultiTypedResultKey<$InvestmentLotsTable, List<InvestmentLotRow>>
  _investmentLotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investmentLots,
    aliasName: 'journal_entries__id__investment_lots__journal_entry_id',
  );

  $$InvestmentLotsTableProcessedTableManager get investmentLotsRefs {
    final manager = $$InvestmentLotsTableTableManager(
      $_db,
      $_db.investmentLots,
    ).filter((f) => f.journalEntryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_investmentLotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestmentSellsTable, List<InvestmentSellRow>>
  _investmentSellsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investmentSells,
    aliasName: 'journal_entries__id__investment_sells__journal_entry_id',
  );

  $$InvestmentSellsTableProcessedTableManager get investmentSellsRefs {
    final manager = $$InvestmentSellsTableTableManager(
      $_db,
      $_db.investmentSells,
    ).filter((f) => f.journalEntryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _investmentSellsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OfxImportRecordsTable, List<OfxImportRecordRow>>
  _ofxImportRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ofxImportRecords,
    aliasName: 'journal_entries__id__ofx_import_records__journal_entry_id',
  );

  $$OfxImportRecordsTableProcessedTableManager get ofxImportRecordsRefs {
    final manager = $$OfxImportRecordsTableTableManager(
      $_db,
      $_db.ofxImportRecords,
    ).filter((f) => f.journalEntryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ofxImportRecordsRefsTable($_db),
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

  Expression<bool> investmentLotsRefs(
    Expression<bool> Function($$InvestmentLotsTableFilterComposer f) f,
  ) {
    final $$InvestmentLotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentLots,
      getReferencedColumn: (t) => t.journalEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentLotsTableFilterComposer(
            $db: $db,
            $table: $db.investmentLots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investmentSellsRefs(
    Expression<bool> Function($$InvestmentSellsTableFilterComposer f) f,
  ) {
    final $$InvestmentSellsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentSells,
      getReferencedColumn: (t) => t.journalEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentSellsTableFilterComposer(
            $db: $db,
            $table: $db.investmentSells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ofxImportRecordsRefs(
    Expression<bool> Function($$OfxImportRecordsTableFilterComposer f) f,
  ) {
    final $$OfxImportRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ofxImportRecords,
      getReferencedColumn: (t) => t.journalEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OfxImportRecordsTableFilterComposer(
            $db: $db,
            $table: $db.ofxImportRecords,
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

  Expression<T> investmentLotsRefs<T extends Object>(
    Expression<T> Function($$InvestmentLotsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentLotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentLots,
      getReferencedColumn: (t) => t.journalEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentLotsTableAnnotationComposer(
            $db: $db,
            $table: $db.investmentLots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investmentSellsRefs<T extends Object>(
    Expression<T> Function($$InvestmentSellsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentSellsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentSells,
      getReferencedColumn: (t) => t.journalEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentSellsTableAnnotationComposer(
            $db: $db,
            $table: $db.investmentSells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ofxImportRecordsRefs<T extends Object>(
    Expression<T> Function($$OfxImportRecordsTableAnnotationComposer a) f,
  ) {
    final $$OfxImportRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ofxImportRecords,
      getReferencedColumn: (t) => t.journalEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OfxImportRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.ofxImportRecords,
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
            bool investmentLotsRefs,
            bool investmentSellsRefs,
            bool ofxImportRecordsRefs,
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
                investmentLotsRefs = false,
                investmentSellsRefs = false,
                ofxImportRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (postingsRefs) db.postings,
                    if (entryVerificationCacheRefs) db.entryVerificationCache,
                    if (ledgerChainStateRefs) db.ledgerChainState,
                    if (integrityEventsRefs) db.integrityEvents,
                    if (investmentLotsRefs) db.investmentLots,
                    if (investmentSellsRefs) db.investmentSells,
                    if (ofxImportRecordsRefs) db.ofxImportRecords,
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
                      if (investmentLotsRefs)
                        await $_getPrefetchedData<
                          JournalEntryRow,
                          $JournalEntriesTable,
                          InvestmentLotRow
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._investmentLotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentLotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.journalEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investmentSellsRefs)
                        await $_getPrefetchedData<
                          JournalEntryRow,
                          $JournalEntriesTable,
                          InvestmentSellRow
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._investmentSellsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentSellsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.journalEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ofxImportRecordsRefs)
                        await $_getPrefetchedData<
                          JournalEntryRow,
                          $JournalEntriesTable,
                          OfxImportRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._ofxImportRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).ofxImportRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.journalEntryId == item.id,
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
        bool investmentLotsRefs,
        bool investmentSellsRefs,
        bool ofxImportRecordsRefs,
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
typedef $$InstrumentsTableCreateCompanionBuilder =
    InstrumentsCompanion Function({
      Value<String> id,
      required String name,
      required InstrumentKind kind,
      Value<String?> ticker,
      Value<String?> isin,
      Value<DateTime?> archivedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$InstrumentsTableUpdateCompanionBuilder =
    InstrumentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<InstrumentKind> kind,
      Value<String?> ticker,
      Value<String?> isin,
      Value<DateTime?> archivedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InstrumentsTableReferences
    extends BaseReferences<_$AppDatabase, $InstrumentsTable, InstrumentRow> {
  $$InstrumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvestmentLotsTable, List<InvestmentLotRow>>
  _investmentLotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investmentLots,
    aliasName: 'instruments__id__investment_lots__instrument_id',
  );

  $$InvestmentLotsTableProcessedTableManager get investmentLotsRefs {
    final manager = $$InvestmentLotsTableTableManager(
      $_db,
      $_db.investmentLots,
    ).filter((f) => f.instrumentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_investmentLotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestmentSellsTable, List<InvestmentSellRow>>
  _investmentSellsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investmentSells,
    aliasName: 'instruments__id__investment_sells__instrument_id',
  );

  $$InvestmentSellsTableProcessedTableManager get investmentSellsRefs {
    final manager = $$InvestmentSellsTableTableManager(
      $_db,
      $_db.investmentSells,
    ).filter((f) => f.instrumentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _investmentSellsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InstrumentQuotesTable, List<InstrumentQuoteRow>>
  _instrumentQuotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.instrumentQuotes,
    aliasName: 'instruments__id__instrument_quotes__instrument_id',
  );

  $$InstrumentQuotesTableProcessedTableManager get instrumentQuotesRefs {
    final manager = $$InstrumentQuotesTableTableManager(
      $_db,
      $_db.instrumentQuotes,
    ).filter((f) => f.instrumentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _instrumentQuotesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InstrumentsTableFilterComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<InstrumentKind, InstrumentKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> investmentLotsRefs(
    Expression<bool> Function($$InvestmentLotsTableFilterComposer f) f,
  ) {
    final $$InvestmentLotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentLots,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentLotsTableFilterComposer(
            $db: $db,
            $table: $db.investmentLots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investmentSellsRefs(
    Expression<bool> Function($$InvestmentSellsTableFilterComposer f) f,
  ) {
    final $$InvestmentSellsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentSells,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentSellsTableFilterComposer(
            $db: $db,
            $table: $db.investmentSells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> instrumentQuotesRefs(
    Expression<bool> Function($$InstrumentQuotesTableFilterComposer f) f,
  ) {
    final $$InstrumentQuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.instrumentQuotes,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentQuotesTableFilterComposer(
            $db: $db,
            $table: $db.instrumentQuotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstrumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
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

class $$InstrumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<InstrumentKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get ticker =>
      $composableBuilder(column: $table.ticker, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> investmentLotsRefs<T extends Object>(
    Expression<T> Function($$InvestmentLotsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentLotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentLots,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentLotsTableAnnotationComposer(
            $db: $db,
            $table: $db.investmentLots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investmentSellsRefs<T extends Object>(
    Expression<T> Function($$InvestmentSellsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentSellsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentSells,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentSellsTableAnnotationComposer(
            $db: $db,
            $table: $db.investmentSells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> instrumentQuotesRefs<T extends Object>(
    Expression<T> Function($$InstrumentQuotesTableAnnotationComposer a) f,
  ) {
    final $$InstrumentQuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.instrumentQuotes,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentQuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.instrumentQuotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstrumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstrumentsTable,
          InstrumentRow,
          $$InstrumentsTableFilterComposer,
          $$InstrumentsTableOrderingComposer,
          $$InstrumentsTableAnnotationComposer,
          $$InstrumentsTableCreateCompanionBuilder,
          $$InstrumentsTableUpdateCompanionBuilder,
          (InstrumentRow, $$InstrumentsTableReferences),
          InstrumentRow,
          PrefetchHooks Function({
            bool investmentLotsRefs,
            bool investmentSellsRefs,
            bool instrumentQuotesRefs,
          })
        > {
  $$InstrumentsTableTableManager(_$AppDatabase db, $InstrumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstrumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstrumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstrumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<InstrumentKind> kind = const Value.absent(),
                Value<String?> ticker = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion(
                id: id,
                name: name,
                kind: kind,
                ticker: ticker,
                isin: isin,
                archivedAt: archivedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required InstrumentKind kind,
                Value<String?> ticker = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                ticker: ticker,
                isin: isin,
                archivedAt: archivedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InstrumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                investmentLotsRefs = false,
                investmentSellsRefs = false,
                instrumentQuotesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (investmentLotsRefs) db.investmentLots,
                    if (investmentSellsRefs) db.investmentSells,
                    if (instrumentQuotesRefs) db.instrumentQuotes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (investmentLotsRefs)
                        await $_getPrefetchedData<
                          InstrumentRow,
                          $InstrumentsTable,
                          InvestmentLotRow
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._investmentLotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentLotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investmentSellsRefs)
                        await $_getPrefetchedData<
                          InstrumentRow,
                          $InstrumentsTable,
                          InvestmentSellRow
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._investmentSellsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentSellsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (instrumentQuotesRefs)
                        await $_getPrefetchedData<
                          InstrumentRow,
                          $InstrumentsTable,
                          InstrumentQuoteRow
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._instrumentQuotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).instrumentQuotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.id,
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

typedef $$InstrumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstrumentsTable,
      InstrumentRow,
      $$InstrumentsTableFilterComposer,
      $$InstrumentsTableOrderingComposer,
      $$InstrumentsTableAnnotationComposer,
      $$InstrumentsTableCreateCompanionBuilder,
      $$InstrumentsTableUpdateCompanionBuilder,
      (InstrumentRow, $$InstrumentsTableReferences),
      InstrumentRow,
      PrefetchHooks Function({
        bool investmentLotsRefs,
        bool investmentSellsRefs,
        bool instrumentQuotesRefs,
      })
    >;
typedef $$InvestmentLotsTableCreateCompanionBuilder =
    InvestmentLotsCompanion Function({
      Value<String> id,
      required String accountId,
      required String instrumentId,
      required int quantityScaled,
      required int unitCostMinor,
      required LotSource source,
      required DateTime acquiredAt,
      Value<DateTime?> lockedUntil,
      required String journalEntryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$InvestmentLotsTableUpdateCompanionBuilder =
    InvestmentLotsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String> instrumentId,
      Value<int> quantityScaled,
      Value<int> unitCostMinor,
      Value<LotSource> source,
      Value<DateTime> acquiredAt,
      Value<DateTime?> lockedUntil,
      Value<String> journalEntryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InvestmentLotsTableReferences
    extends
        BaseReferences<_$AppDatabase, $InvestmentLotsTable, InvestmentLotRow> {
  $$InvestmentLotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('investment_lots__account_id__accounts__id');

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

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('investment_lots__instrument_id__instruments__id');

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JournalEntriesTable _journalEntryIdTable(_$AppDatabase db) => db
      .journalEntries
      .createAlias('investment_lots__journal_entry_id__journal_entries__id');

  $$JournalEntriesTableProcessedTableManager get journalEntryId {
    final $_column = $_itemColumn<String>('journal_entry_id')!;

    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_journalEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvestmentLotsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentLotsTable> {
  $$InvestmentLotsTableFilterComposer({
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

  ColumnFilters<int> get quantityScaled => $composableBuilder(
    column: $table.quantityScaled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LotSource, LotSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

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

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JournalEntriesTableFilterComposer get journalEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalEntryId,
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

class $$InvestmentLotsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentLotsTable> {
  $$InvestmentLotsTableOrderingComposer({
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

  ColumnOrderings<int> get quantityScaled => $composableBuilder(
    column: $table.quantityScaled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

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

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JournalEntriesTableOrderingComposer get journalEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalEntryId,
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

class $$InvestmentLotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentLotsTable> {
  $$InvestmentLotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantityScaled => $composableBuilder(
    column: $table.quantityScaled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LotSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JournalEntriesTableAnnotationComposer get journalEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalEntryId,
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

class $$InvestmentLotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentLotsTable,
          InvestmentLotRow,
          $$InvestmentLotsTableFilterComposer,
          $$InvestmentLotsTableOrderingComposer,
          $$InvestmentLotsTableAnnotationComposer,
          $$InvestmentLotsTableCreateCompanionBuilder,
          $$InvestmentLotsTableUpdateCompanionBuilder,
          (InvestmentLotRow, $$InvestmentLotsTableReferences),
          InvestmentLotRow,
          PrefetchHooks Function({
            bool accountId,
            bool instrumentId,
            bool journalEntryId,
          })
        > {
  $$InvestmentLotsTableTableManager(
    _$AppDatabase db,
    $InvestmentLotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentLotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentLotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentLotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<int> quantityScaled = const Value.absent(),
                Value<int> unitCostMinor = const Value.absent(),
                Value<LotSource> source = const Value.absent(),
                Value<DateTime> acquiredAt = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<String> journalEntryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentLotsCompanion(
                id: id,
                accountId: accountId,
                instrumentId: instrumentId,
                quantityScaled: quantityScaled,
                unitCostMinor: unitCostMinor,
                source: source,
                acquiredAt: acquiredAt,
                lockedUntil: lockedUntil,
                journalEntryId: journalEntryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String accountId,
                required String instrumentId,
                required int quantityScaled,
                required int unitCostMinor,
                required LotSource source,
                required DateTime acquiredAt,
                Value<DateTime?> lockedUntil = const Value.absent(),
                required String journalEntryId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentLotsCompanion.insert(
                id: id,
                accountId: accountId,
                instrumentId: instrumentId,
                quantityScaled: quantityScaled,
                unitCostMinor: unitCostMinor,
                source: source,
                acquiredAt: acquiredAt,
                lockedUntil: lockedUntil,
                journalEntryId: journalEntryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestmentLotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                instrumentId = false,
                journalEntryId = false,
              }) {
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
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$InvestmentLotsTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$InvestmentLotsTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (instrumentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.instrumentId,
                                    referencedTable:
                                        $$InvestmentLotsTableReferences
                                            ._instrumentIdTable(db),
                                    referencedColumn:
                                        $$InvestmentLotsTableReferences
                                            ._instrumentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (journalEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.journalEntryId,
                                    referencedTable:
                                        $$InvestmentLotsTableReferences
                                            ._journalEntryIdTable(db),
                                    referencedColumn:
                                        $$InvestmentLotsTableReferences
                                            ._journalEntryIdTable(db)
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

typedef $$InvestmentLotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentLotsTable,
      InvestmentLotRow,
      $$InvestmentLotsTableFilterComposer,
      $$InvestmentLotsTableOrderingComposer,
      $$InvestmentLotsTableAnnotationComposer,
      $$InvestmentLotsTableCreateCompanionBuilder,
      $$InvestmentLotsTableUpdateCompanionBuilder,
      (InvestmentLotRow, $$InvestmentLotsTableReferences),
      InvestmentLotRow,
      PrefetchHooks Function({
        bool accountId,
        bool instrumentId,
        bool journalEntryId,
      })
    >;
typedef $$InvestmentSellsTableCreateCompanionBuilder =
    InvestmentSellsCompanion Function({
      Value<String> id,
      required String accountId,
      required String instrumentId,
      required int quantityScaled,
      required String journalEntryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$InvestmentSellsTableUpdateCompanionBuilder =
    InvestmentSellsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String> instrumentId,
      Value<int> quantityScaled,
      Value<String> journalEntryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InvestmentSellsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InvestmentSellsTable,
          InvestmentSellRow
        > {
  $$InvestmentSellsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('investment_sells__account_id__accounts__id');

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

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('investment_sells__instrument_id__instruments__id');

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JournalEntriesTable _journalEntryIdTable(_$AppDatabase db) => db
      .journalEntries
      .createAlias('investment_sells__journal_entry_id__journal_entries__id');

  $$JournalEntriesTableProcessedTableManager get journalEntryId {
    final $_column = $_itemColumn<String>('journal_entry_id')!;

    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_journalEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvestmentSellsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentSellsTable> {
  $$InvestmentSellsTableFilterComposer({
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

  ColumnFilters<int> get quantityScaled => $composableBuilder(
    column: $table.quantityScaled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

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

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JournalEntriesTableFilterComposer get journalEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalEntryId,
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

class $$InvestmentSellsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentSellsTable> {
  $$InvestmentSellsTableOrderingComposer({
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

  ColumnOrderings<int> get quantityScaled => $composableBuilder(
    column: $table.quantityScaled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

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

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JournalEntriesTableOrderingComposer get journalEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalEntryId,
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

class $$InvestmentSellsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentSellsTable> {
  $$InvestmentSellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantityScaled => $composableBuilder(
    column: $table.quantityScaled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JournalEntriesTableAnnotationComposer get journalEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalEntryId,
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

class $$InvestmentSellsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentSellsTable,
          InvestmentSellRow,
          $$InvestmentSellsTableFilterComposer,
          $$InvestmentSellsTableOrderingComposer,
          $$InvestmentSellsTableAnnotationComposer,
          $$InvestmentSellsTableCreateCompanionBuilder,
          $$InvestmentSellsTableUpdateCompanionBuilder,
          (InvestmentSellRow, $$InvestmentSellsTableReferences),
          InvestmentSellRow,
          PrefetchHooks Function({
            bool accountId,
            bool instrumentId,
            bool journalEntryId,
          })
        > {
  $$InvestmentSellsTableTableManager(
    _$AppDatabase db,
    $InvestmentSellsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentSellsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentSellsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentSellsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<int> quantityScaled = const Value.absent(),
                Value<String> journalEntryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentSellsCompanion(
                id: id,
                accountId: accountId,
                instrumentId: instrumentId,
                quantityScaled: quantityScaled,
                journalEntryId: journalEntryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String accountId,
                required String instrumentId,
                required int quantityScaled,
                required String journalEntryId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentSellsCompanion.insert(
                id: id,
                accountId: accountId,
                instrumentId: instrumentId,
                quantityScaled: quantityScaled,
                journalEntryId: journalEntryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestmentSellsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                instrumentId = false,
                journalEntryId = false,
              }) {
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
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$InvestmentSellsTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$InvestmentSellsTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (instrumentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.instrumentId,
                                    referencedTable:
                                        $$InvestmentSellsTableReferences
                                            ._instrumentIdTable(db),
                                    referencedColumn:
                                        $$InvestmentSellsTableReferences
                                            ._instrumentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (journalEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.journalEntryId,
                                    referencedTable:
                                        $$InvestmentSellsTableReferences
                                            ._journalEntryIdTable(db),
                                    referencedColumn:
                                        $$InvestmentSellsTableReferences
                                            ._journalEntryIdTable(db)
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

typedef $$InvestmentSellsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentSellsTable,
      InvestmentSellRow,
      $$InvestmentSellsTableFilterComposer,
      $$InvestmentSellsTableOrderingComposer,
      $$InvestmentSellsTableAnnotationComposer,
      $$InvestmentSellsTableCreateCompanionBuilder,
      $$InvestmentSellsTableUpdateCompanionBuilder,
      (InvestmentSellRow, $$InvestmentSellsTableReferences),
      InvestmentSellRow,
      PrefetchHooks Function({
        bool accountId,
        bool instrumentId,
        bool journalEntryId,
      })
    >;
typedef $$InstrumentQuotesTableCreateCompanionBuilder =
    InstrumentQuotesCompanion Function({
      Value<String> id,
      required String instrumentId,
      required int priceMinor,
      required String currency,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$InstrumentQuotesTableUpdateCompanionBuilder =
    InstrumentQuotesCompanion Function({
      Value<String> id,
      Value<String> instrumentId,
      Value<int> priceMinor,
      Value<String> currency,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

final class $$InstrumentQuotesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InstrumentQuotesTable,
          InstrumentQuoteRow
        > {
  $$InstrumentQuotesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('instrument_quotes__instrument_id__instruments__id');

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InstrumentQuotesTableFilterComposer
    extends Composer<_$AppDatabase, $InstrumentQuotesTable> {
  $$InstrumentQuotesTableFilterComposer({
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

  ColumnFilters<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstrumentQuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $InstrumentQuotesTable> {
  $$InstrumentQuotesTableOrderingComposer({
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

  ColumnOrderings<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstrumentQuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstrumentQuotesTable> {
  $$InstrumentQuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstrumentQuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstrumentQuotesTable,
          InstrumentQuoteRow,
          $$InstrumentQuotesTableFilterComposer,
          $$InstrumentQuotesTableOrderingComposer,
          $$InstrumentQuotesTableAnnotationComposer,
          $$InstrumentQuotesTableCreateCompanionBuilder,
          $$InstrumentQuotesTableUpdateCompanionBuilder,
          (InstrumentQuoteRow, $$InstrumentQuotesTableReferences),
          InstrumentQuoteRow,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$InstrumentQuotesTableTableManager(
    _$AppDatabase db,
    $InstrumentQuotesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstrumentQuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstrumentQuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstrumentQuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<int> priceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentQuotesCompanion(
                id: id,
                instrumentId: instrumentId,
                priceMinor: priceMinor,
                currency: currency,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String instrumentId,
                required int priceMinor,
                required String currency,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => InstrumentQuotesCompanion.insert(
                id: id,
                instrumentId: instrumentId,
                priceMinor: priceMinor,
                currency: currency,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InstrumentQuotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
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
                    if (instrumentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.instrumentId,
                                referencedTable:
                                    $$InstrumentQuotesTableReferences
                                        ._instrumentIdTable(db),
                                referencedColumn:
                                    $$InstrumentQuotesTableReferences
                                        ._instrumentIdTable(db)
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

typedef $$InstrumentQuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstrumentQuotesTable,
      InstrumentQuoteRow,
      $$InstrumentQuotesTableFilterComposer,
      $$InstrumentQuotesTableOrderingComposer,
      $$InstrumentQuotesTableAnnotationComposer,
      $$InstrumentQuotesTableCreateCompanionBuilder,
      $$InstrumentQuotesTableUpdateCompanionBuilder,
      (InstrumentQuoteRow, $$InstrumentQuotesTableReferences),
      InstrumentQuoteRow,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$PendingTransfersTableCreateCompanionBuilder =
    PendingTransfersCompanion Function({
      Value<String> id,
      required PendingTransferKind kind,
      required String sourceAccountId,
      Value<String?> categoryId,
      Value<String?> destinationAccountId,
      required String currency,
      required String provisionalEntryId,
      required PendingTransferStatus status,
      Value<String?> settlementEntryId,
      Value<String?> feeEntryId,
      required DateTime initiatedAt,
      Value<DateTime?> settledAt,
      Value<int> rowid,
    });
typedef $$PendingTransfersTableUpdateCompanionBuilder =
    PendingTransfersCompanion Function({
      Value<String> id,
      Value<PendingTransferKind> kind,
      Value<String> sourceAccountId,
      Value<String?> categoryId,
      Value<String?> destinationAccountId,
      Value<String> currency,
      Value<String> provisionalEntryId,
      Value<PendingTransferStatus> status,
      Value<String?> settlementEntryId,
      Value<String?> feeEntryId,
      Value<DateTime> initiatedAt,
      Value<DateTime?> settledAt,
      Value<int> rowid,
    });

final class $$PendingTransfersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PendingTransfersTable,
          PendingTransferRow
        > {
  $$PendingTransfersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _sourceAccountIdTable(_$AppDatabase db) => db.accounts
      .createAlias('pending_transfers__source_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get sourceAccountId {
    final $_column = $_itemColumn<String>('source_account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _categoryIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('pending_transfers__category_id__accounts__id');

  $$AccountsTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _destinationAccountIdTable(_$AppDatabase db) => db
      .accounts
      .createAlias('pending_transfers__destination_account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get destinationAccountId {
    final $_column = $_itemColumn<String>('destination_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _destinationAccountIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JournalEntriesTable _provisionalEntryIdTable(_$AppDatabase db) =>
      db.journalEntries.createAlias(
        'pending_transfers__provisional_entry_id__journal_entries__id',
      );

  $$JournalEntriesTableProcessedTableManager get provisionalEntryId {
    final $_column = $_itemColumn<String>('provisional_entry_id')!;

    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_provisionalEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JournalEntriesTable _settlementEntryIdTable(_$AppDatabase db) =>
      db.journalEntries.createAlias(
        'pending_transfers__settlement_entry_id__journal_entries__id',
      );

  $$JournalEntriesTableProcessedTableManager? get settlementEntryId {
    final $_column = $_itemColumn<String>('settlement_entry_id');
    if ($_column == null) return null;
    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_settlementEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JournalEntriesTable _feeEntryIdTable(_$AppDatabase db) => db
      .journalEntries
      .createAlias('pending_transfers__fee_entry_id__journal_entries__id');

  $$JournalEntriesTableProcessedTableManager? get feeEntryId {
    final $_column = $_itemColumn<String>('fee_entry_id');
    if ($_column == null) return null;
    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feeEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PendingTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $PendingTransfersTable> {
  $$PendingTransfersTableFilterComposer({
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

  ColumnWithTypeConverterFilters<
    PendingTransferKind,
    PendingTransferKind,
    String
  >
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    PendingTransferStatus,
    PendingTransferStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get initiatedAt => $composableBuilder(
    column: $table.initiatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get sourceAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceAccountId,
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

  $$AccountsTableFilterComposer get categoryId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
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

  $$AccountsTableFilterComposer get destinationAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationAccountId,
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

  $$JournalEntriesTableFilterComposer get provisionalEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.provisionalEntryId,
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

  $$JournalEntriesTableFilterComposer get settlementEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.settlementEntryId,
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

  $$JournalEntriesTableFilterComposer get feeEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feeEntryId,
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

class $$PendingTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingTransfersTable> {
  $$PendingTransfersTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get initiatedAt => $composableBuilder(
    column: $table.initiatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get sourceAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceAccountId,
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

  $$AccountsTableOrderingComposer get categoryId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
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

  $$AccountsTableOrderingComposer get destinationAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationAccountId,
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

  $$JournalEntriesTableOrderingComposer get provisionalEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.provisionalEntryId,
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

  $$JournalEntriesTableOrderingComposer get settlementEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.settlementEntryId,
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

  $$JournalEntriesTableOrderingComposer get feeEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feeEntryId,
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

class $$PendingTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingTransfersTable> {
  $$PendingTransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PendingTransferKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PendingTransferStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get initiatedAt => $composableBuilder(
    column: $table.initiatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get sourceAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceAccountId,
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

  $$AccountsTableAnnotationComposer get categoryId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
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

  $$AccountsTableAnnotationComposer get destinationAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationAccountId,
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

  $$JournalEntriesTableAnnotationComposer get provisionalEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.provisionalEntryId,
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

  $$JournalEntriesTableAnnotationComposer get settlementEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.settlementEntryId,
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

  $$JournalEntriesTableAnnotationComposer get feeEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feeEntryId,
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

class $$PendingTransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingTransfersTable,
          PendingTransferRow,
          $$PendingTransfersTableFilterComposer,
          $$PendingTransfersTableOrderingComposer,
          $$PendingTransfersTableAnnotationComposer,
          $$PendingTransfersTableCreateCompanionBuilder,
          $$PendingTransfersTableUpdateCompanionBuilder,
          (PendingTransferRow, $$PendingTransfersTableReferences),
          PendingTransferRow,
          PrefetchHooks Function({
            bool sourceAccountId,
            bool categoryId,
            bool destinationAccountId,
            bool provisionalEntryId,
            bool settlementEntryId,
            bool feeEntryId,
          })
        > {
  $$PendingTransfersTableTableManager(
    _$AppDatabase db,
    $PendingTransfersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingTransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<PendingTransferKind> kind = const Value.absent(),
                Value<String> sourceAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> provisionalEntryId = const Value.absent(),
                Value<PendingTransferStatus> status = const Value.absent(),
                Value<String?> settlementEntryId = const Value.absent(),
                Value<String?> feeEntryId = const Value.absent(),
                Value<DateTime> initiatedAt = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingTransfersCompanion(
                id: id,
                kind: kind,
                sourceAccountId: sourceAccountId,
                categoryId: categoryId,
                destinationAccountId: destinationAccountId,
                currency: currency,
                provisionalEntryId: provisionalEntryId,
                status: status,
                settlementEntryId: settlementEntryId,
                feeEntryId: feeEntryId,
                initiatedAt: initiatedAt,
                settledAt: settledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required PendingTransferKind kind,
                required String sourceAccountId,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                required String currency,
                required String provisionalEntryId,
                required PendingTransferStatus status,
                Value<String?> settlementEntryId = const Value.absent(),
                Value<String?> feeEntryId = const Value.absent(),
                required DateTime initiatedAt,
                Value<DateTime?> settledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingTransfersCompanion.insert(
                id: id,
                kind: kind,
                sourceAccountId: sourceAccountId,
                categoryId: categoryId,
                destinationAccountId: destinationAccountId,
                currency: currency,
                provisionalEntryId: provisionalEntryId,
                status: status,
                settlementEntryId: settlementEntryId,
                feeEntryId: feeEntryId,
                initiatedAt: initiatedAt,
                settledAt: settledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PendingTransfersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceAccountId = false,
                categoryId = false,
                destinationAccountId = false,
                provisionalEntryId = false,
                settlementEntryId = false,
                feeEntryId = false,
              }) {
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
                        if (sourceAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceAccountId,
                                    referencedTable:
                                        $$PendingTransfersTableReferences
                                            ._sourceAccountIdTable(db),
                                    referencedColumn:
                                        $$PendingTransfersTableReferences
                                            ._sourceAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$PendingTransfersTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$PendingTransfersTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (destinationAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.destinationAccountId,
                                    referencedTable:
                                        $$PendingTransfersTableReferences
                                            ._destinationAccountIdTable(db),
                                    referencedColumn:
                                        $$PendingTransfersTableReferences
                                            ._destinationAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (provisionalEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.provisionalEntryId,
                                    referencedTable:
                                        $$PendingTransfersTableReferences
                                            ._provisionalEntryIdTable(db),
                                    referencedColumn:
                                        $$PendingTransfersTableReferences
                                            ._provisionalEntryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (settlementEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.settlementEntryId,
                                    referencedTable:
                                        $$PendingTransfersTableReferences
                                            ._settlementEntryIdTable(db),
                                    referencedColumn:
                                        $$PendingTransfersTableReferences
                                            ._settlementEntryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (feeEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.feeEntryId,
                                    referencedTable:
                                        $$PendingTransfersTableReferences
                                            ._feeEntryIdTable(db),
                                    referencedColumn:
                                        $$PendingTransfersTableReferences
                                            ._feeEntryIdTable(db)
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

typedef $$PendingTransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingTransfersTable,
      PendingTransferRow,
      $$PendingTransfersTableFilterComposer,
      $$PendingTransfersTableOrderingComposer,
      $$PendingTransfersTableAnnotationComposer,
      $$PendingTransfersTableCreateCompanionBuilder,
      $$PendingTransfersTableUpdateCompanionBuilder,
      (PendingTransferRow, $$PendingTransfersTableReferences),
      PendingTransferRow,
      PrefetchHooks Function({
        bool sourceAccountId,
        bool categoryId,
        bool destinationAccountId,
        bool provisionalEntryId,
        bool settlementEntryId,
        bool feeEntryId,
      })
    >;
typedef $$OfxImportRecordsTableCreateCompanionBuilder =
    OfxImportRecordsCompanion Function({
      Value<String> id,
      required String financialAccountId,
      Value<String?> fitid,
      Value<String?> fallbackMatchKey,
      required String journalEntryId,
      required DateTime importedAt,
      Value<ImportSource?> source,
      Value<int> rowid,
    });
typedef $$OfxImportRecordsTableUpdateCompanionBuilder =
    OfxImportRecordsCompanion Function({
      Value<String> id,
      Value<String> financialAccountId,
      Value<String?> fitid,
      Value<String?> fallbackMatchKey,
      Value<String> journalEntryId,
      Value<DateTime> importedAt,
      Value<ImportSource?> source,
      Value<int> rowid,
    });

final class $$OfxImportRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OfxImportRecordsTable,
          OfxImportRecordRow
        > {
  $$OfxImportRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _financialAccountIdTable(_$AppDatabase db) => db
      .accounts
      .createAlias('ofx_import_records__financial_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get financialAccountId {
    final $_column = $_itemColumn<String>('financial_account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_financialAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JournalEntriesTable _journalEntryIdTable(_$AppDatabase db) => db
      .journalEntries
      .createAlias('ofx_import_records__journal_entry_id__journal_entries__id');

  $$JournalEntriesTableProcessedTableManager get journalEntryId {
    final $_column = $_itemColumn<String>('journal_entry_id')!;

    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_journalEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OfxImportRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $OfxImportRecordsTable> {
  $$OfxImportRecordsTableFilterComposer({
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

  ColumnFilters<String> get fitid => $composableBuilder(
    column: $table.fitid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fallbackMatchKey => $composableBuilder(
    column: $table.fallbackMatchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ImportSource?, ImportSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$AccountsTableFilterComposer get financialAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.financialAccountId,
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

  $$JournalEntriesTableFilterComposer get journalEntryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalEntryId,
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

class $$OfxImportRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $OfxImportRecordsTable> {
  $$OfxImportRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get fitid => $composableBuilder(
    column: $table.fitid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fallbackMatchKey => $composableBuilder(
    column: $table.fallbackMatchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get financialAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.financialAccountId,
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

  $$JournalEntriesTableOrderingComposer get journalEntryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalEntryId,
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

class $$OfxImportRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfxImportRecordsTable> {
  $$OfxImportRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fitid =>
      $composableBuilder(column: $table.fitid, builder: (column) => column);

  GeneratedColumn<String> get fallbackMatchKey => $composableBuilder(
    column: $table.fallbackMatchKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ImportSource?, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$AccountsTableAnnotationComposer get financialAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.financialAccountId,
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

  $$JournalEntriesTableAnnotationComposer get journalEntryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalEntryId,
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

class $$OfxImportRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfxImportRecordsTable,
          OfxImportRecordRow,
          $$OfxImportRecordsTableFilterComposer,
          $$OfxImportRecordsTableOrderingComposer,
          $$OfxImportRecordsTableAnnotationComposer,
          $$OfxImportRecordsTableCreateCompanionBuilder,
          $$OfxImportRecordsTableUpdateCompanionBuilder,
          (OfxImportRecordRow, $$OfxImportRecordsTableReferences),
          OfxImportRecordRow,
          PrefetchHooks Function({bool financialAccountId, bool journalEntryId})
        > {
  $$OfxImportRecordsTableTableManager(
    _$AppDatabase db,
    $OfxImportRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfxImportRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfxImportRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfxImportRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> financialAccountId = const Value.absent(),
                Value<String?> fitid = const Value.absent(),
                Value<String?> fallbackMatchKey = const Value.absent(),
                Value<String> journalEntryId = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<ImportSource?> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfxImportRecordsCompanion(
                id: id,
                financialAccountId: financialAccountId,
                fitid: fitid,
                fallbackMatchKey: fallbackMatchKey,
                journalEntryId: journalEntryId,
                importedAt: importedAt,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String financialAccountId,
                Value<String?> fitid = const Value.absent(),
                Value<String?> fallbackMatchKey = const Value.absent(),
                required String journalEntryId,
                required DateTime importedAt,
                Value<ImportSource?> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfxImportRecordsCompanion.insert(
                id: id,
                financialAccountId: financialAccountId,
                fitid: fitid,
                fallbackMatchKey: fallbackMatchKey,
                journalEntryId: journalEntryId,
                importedAt: importedAt,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OfxImportRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({financialAccountId = false, journalEntryId = false}) {
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
                        if (financialAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.financialAccountId,
                                    referencedTable:
                                        $$OfxImportRecordsTableReferences
                                            ._financialAccountIdTable(db),
                                    referencedColumn:
                                        $$OfxImportRecordsTableReferences
                                            ._financialAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (journalEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.journalEntryId,
                                    referencedTable:
                                        $$OfxImportRecordsTableReferences
                                            ._journalEntryIdTable(db),
                                    referencedColumn:
                                        $$OfxImportRecordsTableReferences
                                            ._journalEntryIdTable(db)
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

typedef $$OfxImportRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfxImportRecordsTable,
      OfxImportRecordRow,
      $$OfxImportRecordsTableFilterComposer,
      $$OfxImportRecordsTableOrderingComposer,
      $$OfxImportRecordsTableAnnotationComposer,
      $$OfxImportRecordsTableCreateCompanionBuilder,
      $$OfxImportRecordsTableUpdateCompanionBuilder,
      (OfxImportRecordRow, $$OfxImportRecordsTableReferences),
      OfxImportRecordRow,
      PrefetchHooks Function({bool financialAccountId, bool journalEntryId})
    >;
typedef $$CsvImportProfilesTableCreateCompanionBuilder =
    CsvImportProfilesCompanion Function({
      Value<String> id,
      required String name,
      required String headerFingerprint,
      required String columnMapping,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CsvImportProfilesTableUpdateCompanionBuilder =
    CsvImportProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> headerFingerprint,
      Value<String> columnMapping,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CsvImportProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CsvImportProfilesTable> {
  $$CsvImportProfilesTableFilterComposer({
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

  ColumnFilters<String> get headerFingerprint => $composableBuilder(
    column: $table.headerFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get columnMapping => $composableBuilder(
    column: $table.columnMapping,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CsvImportProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CsvImportProfilesTable> {
  $$CsvImportProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get headerFingerprint => $composableBuilder(
    column: $table.headerFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get columnMapping => $composableBuilder(
    column: $table.columnMapping,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CsvImportProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CsvImportProfilesTable> {
  $$CsvImportProfilesTableAnnotationComposer({
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

  GeneratedColumn<String> get headerFingerprint => $composableBuilder(
    column: $table.headerFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get columnMapping => $composableBuilder(
    column: $table.columnMapping,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CsvImportProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CsvImportProfilesTable,
          CsvImportProfileRow,
          $$CsvImportProfilesTableFilterComposer,
          $$CsvImportProfilesTableOrderingComposer,
          $$CsvImportProfilesTableAnnotationComposer,
          $$CsvImportProfilesTableCreateCompanionBuilder,
          $$CsvImportProfilesTableUpdateCompanionBuilder,
          (
            CsvImportProfileRow,
            BaseReferences<
              _$AppDatabase,
              $CsvImportProfilesTable,
              CsvImportProfileRow
            >,
          ),
          CsvImportProfileRow,
          PrefetchHooks Function()
        > {
  $$CsvImportProfilesTableTableManager(
    _$AppDatabase db,
    $CsvImportProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CsvImportProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CsvImportProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CsvImportProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> headerFingerprint = const Value.absent(),
                Value<String> columnMapping = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CsvImportProfilesCompanion(
                id: id,
                name: name,
                headerFingerprint: headerFingerprint,
                columnMapping: columnMapping,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String headerFingerprint,
                required String columnMapping,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CsvImportProfilesCompanion.insert(
                id: id,
                name: name,
                headerFingerprint: headerFingerprint,
                columnMapping: columnMapping,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CsvImportProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CsvImportProfilesTable,
      CsvImportProfileRow,
      $$CsvImportProfilesTableFilterComposer,
      $$CsvImportProfilesTableOrderingComposer,
      $$CsvImportProfilesTableAnnotationComposer,
      $$CsvImportProfilesTableCreateCompanionBuilder,
      $$CsvImportProfilesTableUpdateCompanionBuilder,
      (
        CsvImportProfileRow,
        BaseReferences<
          _$AppDatabase,
          $CsvImportProfilesTable,
          CsvImportProfileRow
        >,
      ),
      CsvImportProfileRow,
      PrefetchHooks Function()
    >;
typedef $$CategoryRulesTableCreateCompanionBuilder =
    CategoryRulesCompanion Function({
      Value<String> id,
      required String keyword,
      required String categoryId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CategoryRulesTableUpdateCompanionBuilder =
    CategoryRulesCompanion Function({
      Value<String> id,
      Value<String> keyword,
      Value<String> categoryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CategoryRulesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableFilterComposer({
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

  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableOrderingComposer({
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

  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoryRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRulesTable,
          CategoryRuleRow,
          $$CategoryRulesTableFilterComposer,
          $$CategoryRulesTableOrderingComposer,
          $$CategoryRulesTableAnnotationComposer,
          $$CategoryRulesTableCreateCompanionBuilder,
          $$CategoryRulesTableUpdateCompanionBuilder,
          (
            CategoryRuleRow,
            BaseReferences<_$AppDatabase, $CategoryRulesTable, CategoryRuleRow>,
          ),
          CategoryRuleRow,
          PrefetchHooks Function()
        > {
  $$CategoryRulesTableTableManager(_$AppDatabase db, $CategoryRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> keyword = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRulesCompanion(
                id: id,
                keyword: keyword,
                categoryId: categoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String keyword,
                required String categoryId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoryRulesCompanion.insert(
                id: id,
                keyword: keyword,
                categoryId: categoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRulesTable,
      CategoryRuleRow,
      $$CategoryRulesTableFilterComposer,
      $$CategoryRulesTableOrderingComposer,
      $$CategoryRulesTableAnnotationComposer,
      $$CategoryRulesTableCreateCompanionBuilder,
      $$CategoryRulesTableUpdateCompanionBuilder,
      (
        CategoryRuleRow,
        BaseReferences<_$AppDatabase, $CategoryRulesTable, CategoryRuleRow>,
      ),
      CategoryRuleRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountGroupsTableTableManager get accountGroups =>
      $$AccountGroupsTableTableManager(_db, _db.accountGroups);
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
  $$InstrumentsTableTableManager get instruments =>
      $$InstrumentsTableTableManager(_db, _db.instruments);
  $$InvestmentLotsTableTableManager get investmentLots =>
      $$InvestmentLotsTableTableManager(_db, _db.investmentLots);
  $$InvestmentSellsTableTableManager get investmentSells =>
      $$InvestmentSellsTableTableManager(_db, _db.investmentSells);
  $$InstrumentQuotesTableTableManager get instrumentQuotes =>
      $$InstrumentQuotesTableTableManager(_db, _db.instrumentQuotes);
  $$PendingTransfersTableTableManager get pendingTransfers =>
      $$PendingTransfersTableTableManager(_db, _db.pendingTransfers);
  $$OfxImportRecordsTableTableManager get ofxImportRecords =>
      $$OfxImportRecordsTableTableManager(_db, _db.ofxImportRecords);
  $$CsvImportProfilesTableTableManager get csvImportProfiles =>
      $$CsvImportProfilesTableTableManager(_db, _db.csvImportProfiles);
  $$CategoryRulesTableTableManager get categoryRules =>
      $$CategoryRulesTableTableManager(_db, _db.categoryRules);
}
