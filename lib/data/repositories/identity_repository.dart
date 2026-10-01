import 'package:drift/drift.dart';

import '../../domain/crypto/signing_key_service.dart';
import '../../domain/models/signing_identity.dart';
import '../database/app_database.dart';
import 'account_repository.dart';
import 'identity_continuation_engine.dart';
import 'ledger_chain_store.dart';
import 'ledger_chain_verifier.dart';
import 'repository_date_utils.dart';

/// Device signing-identity lifecycle and Continuation. Split out of
/// `LedgerRepository` (architecture-deepening design.md D1). Depends on
/// optional [AccountRepository] only to seed starter books in
/// [confirmFirstIdentity]; omitted for [BooksCopyRepository]'s throwaway
/// temp-file instance (design.md D2).
///
/// Chain tip, verification-cache, and current-identity reads go through
/// [LedgerChainStore] so posting can share them without importing this
/// class (Identity → Account → Ledger stays acyclic). Chain verification
/// lives on [LedgerChainVerifier]. Continuation is a leaf engine
/// ([IdentityContinuationEngine], ADR 0002).
class IdentityRepository {
  IdentityRepository({
    required AppDatabase database,
    AccountRepository? accountRepository,
    SigningKeyService? signingKeyService,
    LedgerChainStore? chain,
    LedgerChainVerifier? chainVerifier,
  }) : _db = database,
       _accountRepository = accountRepository,
       _signingKeyService = signingKeyService ?? SigningKeyService(),
       _chain = chain ?? LedgerChainStore(database),
       _chainVerifier =
           chainVerifier ??
           LedgerChainVerifier(
             database: database,
             signingKeyService: signingKeyService ?? SigningKeyService(),
             chain: chain ?? LedgerChainStore(database),
           );

  final AppDatabase _db;
  final AccountRepository? _accountRepository;
  final SigningKeyService _signingKeyService;
  final LedgerChainStore _chain;
  final LedgerChainVerifier _chainVerifier;

  late final IdentityContinuationEngine _continuation =
      IdentityContinuationEngine(
        database: _db,
        chain: _chain,
        chainVerifier: _chainVerifier,
        signingKeyService: _signingKeyService,
      );

  AccountRepository _requireAccountRepository() {
    final accounts = _accountRepository;
    if (accounts == null) {
      throw StateError(
        'IdentityRepository.confirmFirstIdentity requires AccountRepository.',
      );
    }
    return accounts;
  }

  /// The active (non-superseded, non-continued) signing identity that
  /// matches this device's stored private key, or the newest active
  /// identity when no key is stored yet. Peer linked identities stay
  /// active but are not returned here.
  Future<SigningIdentity?> currentIdentity() async {
    final stored = await _signingKeyService.loadStoredKeyMaterial();
    return _chain.currentSigningIdentity(matchingPublicKey: stored?.publicKey);
  }

  /// Whether this device's secure storage currently holds the private key
  /// matching [identity]. False means either no key is stored at all, or
  /// a different key is stored - both are the "books without matching key"
  /// scenario that routes to Continuation.
  Future<bool> hasMatchingStoredKey(SigningIdentity identity) async {
    final stored = await _signingKeyService.loadStoredKeyMaterial();
    if (stored == null) return false;
    return bytesEqual(stored.publicKey, identity.publicKey);
  }

  /// Generates a new this-device-only key pair. Does *not* write a
  /// `signing_identities` row - call [confirmFirstIdentity] to commit it.
  Future<GeneratedIdentity> generateFirstIdentity() {
    return _signingKeyService.generateNewIdentity();
  }

  /// Persists [generated] as this device's signing identity, seeds the
  /// chain state, and seeds the starter financial account/categories.
  ///
  /// [currency] (ISO 4217, e.g. 'USD') is chosen during onboarding and
  /// applied to all starter groups.
  ///
  /// Pass [seedStarterCategories]: false when linking into existing books
  /// (QR / approved join) so New-setup starters are not inserted
  /// (shared-categories task 7.4).
  Future<SigningIdentity> confirmFirstIdentity(
    GeneratedIdentity generated, {
    required String currency,
    bool seedStarterCategories = true,
  }) async {
    late IdentityRow row;
    await _db.transaction(() async {
      row = await _db
          .into(_db.signingIdentities)
          .insertReturning(
            SigningIdentitiesCompanion.insert(
              publicKey: Uint8List.fromList(generated.keyMaterial.publicKey),
              acknowledgedAt: Value(DateTime.now()),
            ),
          );
      await _chain.loadState();
      await _chain.ensureIdentityTip(row.identityId);
      await _requireAccountRepository().seedOnboardingBooks(
        currency: currency,
        seedStarterCategories: seedStarterCategories,
      );
    });
    return _toDomainIdentity(row);
  }

  /// Registers a peer device's Signing Identity as an active linked signer
  /// without marking anyone `continuedAt` and without touching this device's
  /// private key (linked-devices design Decision 3 — linking ≠ Continuation).
  ///
  /// Pass [identityId] when the peer's id is already known from join (QR /
  /// join-request) so both devices share the same id for that public key —
  /// sync verification looks up entries by `signedByIdentityId`.
  Future<SigningIdentity> addLinkedPeerIdentity({
    required List<int> publicKey,
    String? identityId,
    DateTime? at,
  }) async {
    final when = at ?? DateTime.now();
    if (identityId != null) {
      final existing = await (_db.select(
        _db.signingIdentities,
      )..where((t) => t.identityId.equals(identityId))).getSingleOrNull();
      if (existing != null) {
        return _toDomainIdentity(existing);
      }
    }
    late IdentityRow row;
    await _db.transaction(() async {
      row = await _db
          .into(_db.signingIdentities)
          .insertReturning(
            SigningIdentitiesCompanion.insert(
              identityId: identityId != null
                  ? Value(identityId)
                  : const Value.absent(),
              publicKey: Uint8List.fromList(publicKey),
              acknowledgedAt: Value(when),
            ),
          );
      await _chain.ensureIdentityTip(row.identityId);
    });
    return _toDomainIdentity(row);
  }

  /// Continues books under a new this-device-only identity (or no-ops when
  /// the stored key already matches). See [IdentityContinuationEngine].
  Future<SigningIdentity> continueBooks({DateTime? copySavedAt}) {
    return _continuation.continueBooks(copySavedAt: copySavedAt);
  }

  /// Deletes any orphaned private key after a Books Copy restore.
  Future<void> deleteStoredKey() => _signingKeyService.deleteStoredKey();

  /// One-time this-device-only Keychain re-save (design Decision 7).
  Future<bool> migrateKeyAccessibilityIfNeeded({
    required bool alreadyMigrated,
    required Future<void> Function() markMigrated,
  }) {
    return _signingKeyService.migrateKeyAccessibilityIfNeeded(
      alreadyMigrated: alreadyMigrated,
      markMigrated: markMigrated,
    );
  }

  SigningIdentity _toDomainIdentity(IdentityRow row) {
    return SigningIdentity(
      identityId: row.identityId,
      publicKey: row.publicKey,
      createdAt: row.createdAt,
      supersedesIdentityId: row.supersedesIdentityId,
      supersededAt: row.supersededAt,
      continuesIdentityId: row.continuesIdentityId,
      continuedAt: row.continuedAt,
      acknowledgedAt: row.acknowledgedAt,
    );
  }
}
