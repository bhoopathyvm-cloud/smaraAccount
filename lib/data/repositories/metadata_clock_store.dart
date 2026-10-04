import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/peer_sync/hybrid_logical_clock.dart';
import '../../domain/peer_sync/metadata_lww.dart';
import '../../domain/peer_sync/sync_payloads.dart';
import '../database/app_database.dart';

/// Persists hybrid logical clock + LWW winners (task 5.2).
class MetadataClockStore {
  MetadataClockStore({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  static const localId = 'local';

  Future<HybridLogicalClock> loadClock({
    required String deviceId,
    DateTime Function()? wallClock,
  }) async {
    final row = await (_db.select(
      _db.hlcState,
    )..where((t) => t.id.equals(localId))).getSingleOrNull();
    if (row == null) {
      return HybridLogicalClock(deviceId: deviceId, wallClock: wallClock);
    }
    return HybridLogicalClock(
      deviceId: row.deviceId.isEmpty ? deviceId : row.deviceId,
      wallClock: wallClock,
      initialWall: row.lastWall,
      initialCounter: row.counter,
    );
  }

  Future<void> saveClock(HybridLogicalClock clock) async {
    await _db
        .into(_db.hlcState)
        .insertOnConflictUpdate(
          HlcStateCompanion.insert(
            id: localId,
            lastWall: clock.lastWall,
            counter: clock.counter,
            deviceId: clock.deviceId,
          ),
        );
  }

  Future<Map<String, MetadataOperation>> loadWinners() async {
    final rows = await _db.select(_db.metadataLwwState).get();
    return {
      for (final row in rows)
        row.fieldKey: MetadataOperation(
          entityType: row.entityType,
          entityId: row.entityId,
          field: row.field,
          value: row.valueJson == null ? null : jsonDecode(row.valueJson!),
          updatedAt: row.hlcWall,
          updatedByIdentityId: row.updatedByIdentityId,
          hlcCounter: row.hlcCounter,
          hlcDeviceId: row.hlcDeviceId,
        ),
    };
  }

  Future<void> saveWinner(MetadataOperation op) async {
    final key = MetadataLww.fieldKey(op);
    await _db
        .into(_db.metadataLwwState)
        .insertOnConflictUpdate(
          MetadataLwwStateCompanion.insert(
            fieldKey: key,
            entityType: op.entityType,
            entityId: op.entityId,
            field: op.field,
            valueJson: Value(op.value == null ? null : jsonEncode(op.value)),
            hlcWall: op.updatedAt.toUtc(),
            hlcCounter: op.hlcCounter,
            hlcDeviceId: op.hlcDeviceId.isEmpty
                ? op.updatedByIdentityId
                : op.hlcDeviceId,
            updatedByIdentityId: op.updatedByIdentityId,
          ),
        );
  }
}
