import '../../domain/crypto/signing_key_service.dart';
import '../../domain/linked_devices/device_certificate_store.dart';
import '../../domain/models/join_qr_payload.dart';
import '../database/app_database.dart';
import '../repositories/account_repository.dart';
import '../repositories/identity_repository.dart';
import '../repositories/ledger_repository.dart';
import '../repositories/membership_repository.dart';

/// Seeds a freshly opened joined books set on the joiner device after QR /
/// join-by-code confirm (linked-devices books transfer; shared-account-access
/// Claimant surface).
///
/// Uses this device's Signing Identity already reserved for the set (created
/// before the join hello under that set's namespaced key), pins the host
/// identity, and writes host Owner + local Claimant/Member membership so
/// peer sync can advertise/browse.
abstract final class JoinedBooksSeeder {
  /// Idempotent: skips work when the local device is already a member.
  ///
  /// Expects [ActiveBooksSession.reserveJoinIdentity] (or equivalent) to have
  /// already created this set's Signing Identity. Falls back to generating
  /// one only when reserve was skipped (e.g. widget fakes).
  static Future<void> seed({
    required AppDatabase database,
    required SigningKeyService signingKeyService,
    required JoinQrPayload payload,
    required String localDeviceId,
    required String localDisplayName,
    DeviceCertificateStore? certificateStore,
    String currency = 'USD',
  }) async {
    final ledger = LedgerRepository(
      database: database,
      signingKeyService: signingKeyService,
    );
    final accounts = AccountRepository(
      database: database,
      ledgerRepository: ledger,
    );
    final identity = IdentityRepository(
      database: database,
      accountRepository: accounts,
      signingKeyService: signingKeyService,
    );
    final membership = MembershipRepository(
      database: database,
      identityRepository: identity,
      certificateStore: certificateStore,
    );

    final existingLocal = await membership.findByDeviceId(localDeviceId);
    if (existingLocal != null && existingLocal.isActive) {
      return;
    }

    var localIdentity = await identity.currentIdentity();
    if (localIdentity == null) {
      final generated = await identity.generateFirstIdentity();
      localIdentity = await identity.confirmFirstIdentity(
        generated,
        currency: currency,
        seedStarterCategories: false,
      );
    }

    await membership.prepareJoinerFromScannedQr(payload);

    final certs = certificateStore ?? FakeDeviceCertificateStore();
    final localCert = await certs.localCertificate(deviceId: localDeviceId);
    final roles = payload.personRoles.isNotEmpty
        ? payload.personRoles
        : {payload.roleOffer};

    await membership.seedJoinerMembership(
      payload: payload,
      localDeviceId: localDeviceId,
      localDisplayName: localDisplayName,
      localSigningIdentityId: localIdentity.identityId,
      localDeviceCertFingerprint: localCert.fingerprint,
      localRoles: roles,
    );
  }
}
