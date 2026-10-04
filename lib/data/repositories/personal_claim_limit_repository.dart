import 'package:drift/drift.dart';

import '../../domain/claims/claim_limit_hint.dart';
import '../database/app_database.dart';
import 'metadata_outbox.dart';

/// Owner-managed personal claim limits (real-sync tasks 6.1–6.2).
class PersonalClaimLimitRepository {
  PersonalClaimLimitRepository({
    required AppDatabase database,
    MetadataOutbox? metadataOutbox,
  }) : _db = database,
       _outbox = metadataOutbox;

  final AppDatabase _db;
  final MetadataOutbox? _outbox;

  /// Composite entity id for metadata ops (`personDeviceId\\x1fcategoryId`).
  static String entityIdFor({
    required String personDeviceId,
    required String categoryId,
  }) => '$personDeviceId\x1f$categoryId';

  static (String personDeviceId, String categoryId)? parseEntityId(String id) {
    final parts = id.split('\x1f');
    if (parts.length != 2) return null;
    return (parts[0], parts[1]);
  }

  Future<void> setLimit({
    required String personDeviceId,
    required String categoryId,
    required int? amountMinor,
    String? unitLabel,
    required String updatedByIdentityId,
    DateTime? updatedAt,
  }) async {
    final at = (updatedAt ?? DateTime.now()).toUtc();
    await _db.transaction(() async {
      await _db
          .into(_db.personalClaimLimits)
          .insertOnConflictUpdate(
            PersonalClaimLimitsCompanion.insert(
              personDeviceId: personDeviceId,
              categoryId: categoryId,
              amountMinor: Value(amountMinor),
              unitLabel: Value(unitLabel),
              updatedAt: at,
              updatedByIdentityId: updatedByIdentityId,
            ),
          );
      final outbox = _outbox;
      if (outbox != null) {
        final entityId = entityIdFor(
          personDeviceId: personDeviceId,
          categoryId: categoryId,
        );
        await outbox.emit(
          entityType: 'personal_claim_limit',
          entityId: entityId,
          field: 'amountMinor',
          value: amountMinor,
          updatedByIdentityId: updatedByIdentityId,
        );
        await outbox.emit(
          entityType: 'personal_claim_limit',
          entityId: entityId,
          field: 'unitLabel',
          value: unitLabel,
          updatedByIdentityId: updatedByIdentityId,
        );
      }
    });
  }

  Future<void> clearLimit({
    required String personDeviceId,
    required String categoryId,
    required String updatedByIdentityId,
  }) {
    return setLimit(
      personDeviceId: personDeviceId,
      categoryId: categoryId,
      amountMinor: null,
      unitLabel: null,
      updatedByIdentityId: updatedByIdentityId,
    );
  }

  Future<List<PersonalClaimLimitRow>> listForPerson(String personDeviceId) {
    return (_db.select(
      _db.personalClaimLimits,
    )..where((t) => t.personDeviceId.equals(personDeviceId))).get();
  }

  /// Claimants only receive their own rows; Owners/Approvers may list any.
  Future<List<PersonalClaimLimitRow>> listVisibleTo({
    required String viewerDeviceId,
    required bool canViewAll,
    String? personDeviceId,
  }) async {
    if (!canViewAll) {
      return listForPerson(viewerDeviceId);
    }
    if (personDeviceId != null) return listForPerson(personDeviceId);
    return _db.select(_db.personalClaimLimits).get();
  }

  Future<ClaimLimitHint?> hintFor({
    required String personDeviceId,
    required String categoryId,
    required int? companyAmountMinor,
    required String? companyUnitLabel,
  }) async {
    final row =
        await (_db.select(_db.personalClaimLimits)..where(
              (t) =>
                  t.personDeviceId.equals(personDeviceId) &
                  t.categoryId.equals(categoryId),
            ))
            .getSingleOrNull();
    return resolveClaimLimitHint(
      personalAmountMinor: row?.amountMinor,
      personalUnitLabel: row?.unitLabel,
      companyAmountMinor: companyAmountMinor,
      companyUnitLabel: companyUnitLabel,
    );
  }
}
