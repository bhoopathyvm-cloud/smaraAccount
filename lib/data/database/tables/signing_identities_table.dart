import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// The device's signing key history - public half only. The matching
/// private key is never written here; it lives exclusively in OS secure
/// storage (spec: "Device Signing Identity"). A row is inserted at
/// first-install key generation, and again whenever the true-key-loss
/// migration flow creates a replacement identity ([supersedesIdentityId]
/// pointing at the old one).
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

  @override
  Set<Column> get primaryKey => {identityId};
}
