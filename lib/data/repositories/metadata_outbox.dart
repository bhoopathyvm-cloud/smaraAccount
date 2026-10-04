import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/peer_sync/sync_payloads.dart';
import '../database/app_database.dart';
import 'metadata_clock_store.dart';

/// Appends [MetadataOperation]s stamped with the books-set HLC (tasks 5.1–5.2).
class MetadataOutbox {
  MetadataOutbox({
    required AppDatabase database,
    Future<String> Function()? resolveDeviceId,
    DateTime Function()? wallClock,
  }) : _db = database,
       _clockStore = MetadataClockStore(database: database),
       _resolveDeviceId = resolveDeviceId ?? (() async => 'local'),
       _wallClock = wallClock ?? DateTime.now;

  final AppDatabase _db;
  final MetadataClockStore _clockStore;
  final Future<String> Function() _resolveDeviceId;
  final DateTime Function() _wallClock;

  /// Records one field change. Call inside the same Drift transaction as the
  /// master-data write.
  Future<MetadataOperation> emit({
    required String entityType,
    required String entityId,
    required String field,
    required Object? value,
    required String updatedByIdentityId,
  }) async {
    final deviceId = await _resolveDeviceId();
    final clock = await _clockStore.loadClock(
      deviceId: deviceId,
      wallClock: _wallClock,
    );
    final stamp = clock.tick();
    await _clockStore.saveClock(clock);
    final op = MetadataOperation(
      entityType: entityType,
      entityId: entityId,
      field: field,
      value: value,
      updatedAt: stamp.wall,
      updatedByIdentityId: updatedByIdentityId,
      hlcCounter: stamp.counter,
      hlcDeviceId: stamp.deviceId,
    );
    await _db
        .into(_db.metadataOperations)
        .insert(
          MetadataOperationsCompanion.insert(
            entityType: op.entityType,
            entityId: op.entityId,
            field: op.field,
            valueJson: Value(value == null ? null : jsonEncode(value)),
            updatedAt: op.updatedAt,
            updatedByIdentityId: op.updatedByIdentityId,
            hlcCounter: Value(op.hlcCounter),
            hlcDeviceId: Value(op.hlcDeviceId),
          ),
        );
    await _clockStore.saveWinner(op);
    return op;
  }

  Future<List<MetadataOperation>> listAll() async {
    final rows = await _db.select(_db.metadataOperations).get();
    return rows.map(_toOp).toList();
  }

  MetadataOperation _toOp(MetadataOperationRow row) {
    Object? value;
    final raw = row.valueJson;
    if (raw != null) {
      value = jsonDecode(raw);
    }
    return MetadataOperation(
      entityType: row.entityType,
      entityId: row.entityId,
      field: row.field,
      value: value,
      updatedAt: row.updatedAt,
      updatedByIdentityId: row.updatedByIdentityId,
      hlcCounter: row.hlcCounter,
      hlcDeviceId: row.hlcDeviceId,
    );
  }
}
