import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// The device's signing key history - public half only. The matching
/// private key is never written here; it lives exclusively in OS secure
/// storage (spec: "Device Signing Identity"). A row is inserted at
/// first-install key generation, again for a Continuation
/// ([continuesIdentityId] pointing at the previous identity), and may
/// still exist for identities created by the retired key-loss Migration
/// ([supersedesIdentityId] pointing at the old one).
///
/// Named IdentityRow (not the Drift default "SigningIdentity") to stay
/// distinct from domain/models/signing_identity.dart's SigningIdentity.
@DataClassName('IdentityRow')
class SigningIdentities extends Table {
  TextColumn get identityId => text().clientDefault(() => const Uuid().v4())();

  BlobColumn get publicKey => blob()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get supersedesIdentityId =>
      text().nullable().references(SigningIdentities, #identityId)();

  DateTimeColumn get supersededAt => dateTime().nullable()();

  /// When set, this identity was continued by a later identity (see
  /// [continuesIdentityId] on the successor). Unlike [supersededAt], a
  /// continued identity's entries stay in balances and remain verified.
  DateTimeColumn get continuedAt => dateTime().nullable()();

  /// The previous active identity this row continues, when this identity
  /// was created by Continuation rather than first setup or Migration.
  TextColumn get continuesIdentityId =>
      text().nullable().references(SigningIdentities, #identityId)();

  /// When the user completed the mandatory recovery-phrase acknowledgment
  /// for this identity (historical; phrase acknowledgment is removed by
  /// books-copy-and-continuation). Null for identities that never went
  /// through that flow.
  DateTimeColumn get acknowledgedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {identityId};
}
