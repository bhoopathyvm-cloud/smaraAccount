import 'package:drift/drift.dart';

import '../../domain/crypto/signing_key_service.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/signing_identity.dart';
import '../database/app_database.dart';
import 'account_repository.dart';
import 'key_loss_migration_engine.dart';
import 'ledger_chain_store.dart';
import 'repository_date_utils.dart';

/// Device signing-identity lifecycle and keystore export. Split out of
/// `LedgerRepository` (architecture-deepening design.md D1). Depends on
/// optional [AccountRepository] only to seed starter books in
/// [confirmFirstIdentity]; omitted for [LedgerBackupRepository]'s
/// throwaway temp-file instance (design.md D2).
///
/// Chain tip, verification-cache, and current-identity reads go through
/// [LedgerChainStore] so posting can share them without importing this
/// class (Identity → Account → Ledger stays acyclic). Chain verification
/// lives on [LedgerChainVerifier].
class IdentityRepository {
  IdentityRepository({
    required AppDatabase database,
    AccountRepository? accountRepository,
    SigningKeyService? signingKeyService,
    LedgerChainStore? chain,
  }) : _db = database,
       _accountRepository = accountRepository,
       _signingKeyService = signingKeyService ?? SigningKeyService(),
       _chain = chain ?? LedgerChainStore(database);

  final AppDatabase _db;
  final AccountRepository? _accountRepository;
  final SigningKeyService _signingKeyService;
  final LedgerChainStore _chain;

  late final KeyLossMigrationEngine _migration = KeyLossMigrationEngine(
    database: _db,
    chain: _chain,
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

  /// The active (non-superseded) signing identity, or null if none has
  /// been generated/confirmed yet - the true-first-launch state.
  Future<SigningIdentity?> currentIdentity() => _chain.currentSigningIdentity();

  /// Whether this device's secure storage currently holds the private key
  /// matching [identity]. False means either no key is stored at all, or
  /// (very unusually) a different key is stored - both are the
  /// "existing database file, no matching key" reinstall scenario the
  /// caller should route to a restore flow for, never silently regenerate.
  Future<bool> hasMatchingStoredKey(SigningIdentity identity) async {
    final stored = await _signingKeyService.loadStoredKeyMaterial();
    if (stored == null) return false;
    return bytesEqual(stored.publicKey, identity.publicKey);
  }

  /// Generates a new recovery phrase and its key pair, storing the private
  /// key immediately. Does *not* write a `signing_identities` row - call
  /// [confirmFirstIdentity] only after the user has confirmed possession
  /// of the phrase, so the ledger stays unusable (no identity to sign
  /// against) until that mandatory acknowledgment is complete (spec:
  /// "Onboarding blocks until recovery phrase is acknowledged").
  Future<GeneratedIdentity> generateFirstIdentity() {
    return _signingKeyService.generateNewIdentity();
  }

  /// Stashes the just-generated phrase's words so they survive an app kill
  /// before acknowledgment completes (deferred-onboarding-first-entry).
  Future<void> stashPendingPhraseWords(List<String> words) {
    return _signingKeyService.stashPendingPhraseWords(words);
  }

  /// Reconstructs the pending (committed-but-unacknowledged) identity's
  /// [GeneratedIdentity] from words stashed by [stashPendingPhraseWords],
  /// for redisplay after an app kill. Null if there's nothing pending.
  Future<GeneratedIdentity?> resumePendingIdentity() {
    return _signingKeyService.resumePendingIdentity();
  }

  /// Persists [generated] as this device's signing identity, seeds the
  /// chain state, and seeds the starter financial account/categories.
  /// Call only after the user has confirmed the recovery phrase.
  ///
  /// Starter accounts are seeded here rather than at database creation
  /// (core-ledger-single-account's original approach) because spec
  /// ("Device Signing Identity") requires the signing identity to exist
  /// before any starter account or journal entry does.
  ///
  /// [currency] (ISO 4217, e.g. 'USD') is chosen by the user during a
  /// dedicated onboarding step before this runs (multi-currency-support
  /// design.md addendum) and applied to all four starter groups - a fresh
  /// install never has a group with a null currency, unlike a database
  /// migrated from schemaVersion 3 (see
  /// [AccountRepository.needsCurrencyBackfill]).
  Future<SigningIdentity> confirmFirstIdentity(
    GeneratedIdentity generated, {
    required String currency,
  }) async {
    late IdentityRow row;
    await _db.transaction(() async {
      row = await _db
          .into(_db.signingIdentities)
          .insertReturning(
            SigningIdentitiesCompanion.insert(
              publicKey: Uint8List.fromList(generated.keyMaterial.publicKey),
            ),
          );
      await _chain.loadState();
      await _requireAccountRepository().seedOnboardingBooks(currency: currency);
    });
    return _toDomainIdentity(row);
  }

  /// Re-derives this device's private key from a recovery phrase or
  /// keystore file and matches it to a signing identity already in the
  /// database. Never re-signs or alters any entry.
  Future<SigningIdentity> restoreIdentity({
    List<String>? recoveryPhraseWords,
    String? keystoreFileContents,
    String? keystorePassphrase,
  }) async {
    final material = recoveryPhraseWords != null
        ? await _signingKeyService.restoreFromRecoveryPhrase(
            recoveryPhraseWords,
          )
        : await _signingKeyService.restoreFromKeystoreFile(
            fileContents: keystoreFileContents!,
            passphrase: keystorePassphrase!,
          );

    final candidates = await _db.select(_db.signingIdentities).get();
    IdentityRow? match;
    for (final row in candidates) {
      if (bytesEqual(row.publicKey, material.publicKey)) {
        match = row;
        break;
      }
    }
    if (match == null) {
      throw SigningIdentityMismatchException(
        'This recovery phrase or keystore file does not match any signing '
        'identity in this database.',
      );
    }
    return _toDomainIdentity(match);
  }

  /// Disaster-recovery path for true key loss (spec: "True Key-Loss
  /// Migration"). Generates a brand-new identity, re-creates every
  /// currently-active entry as a new, signed entry under it (preserving
  /// content, referencing the legacy entry via [JournalEntry.migratedFromEntryId]),
  /// and records a `KEY_MIGRATION_CONFIRMED` integrity event. The new
  /// chain starts fresh from genesis - it does not, and cannot, inherit
  /// cryptographic trust from the unrecoverable old chain.
  ///
  /// Callers must have already shown the required plain-language
  /// confirmation that this does not retroactively prove pre-migration
  /// entries were untampered (spec) before calling this.
  Future<GeneratedIdentity> migrateToNewIdentityAfterKeyLoss() =>
      _migration.migrate();

  SigningIdentity _toDomainIdentity(IdentityRow row) {
    return SigningIdentity(
      identityId: row.identityId,
      publicKey: row.publicKey,
      createdAt: row.createdAt,
      supersedesIdentityId: row.supersedesIdentityId,
      supersededAt: row.supersededAt,
      acknowledgedAt: row.acknowledgedAt,
    );
  }

  /// Marks the current (latest, non-superseded) identity as having
  /// completed the mandatory recovery-phrase acknowledgment, and clears
  /// the phrase words temporarily held in secure storage for
  /// crash-recovery re-display (deferred-onboarding-first-entry). Throws
  /// [StateError] if there is no current identity.
  Future<void> acknowledgeIdentity() async {
    final identity = await currentIdentity();
    if (identity == null) {
      throw StateError('No signing identity to acknowledge.');
    }
    await (_db.update(
      _db.signingIdentities,
    )..where((t) => t.identityId.equals(identity.identityId))).write(
      SigningIdentitiesCompanion(acknowledgedAt: Value(DateTime.now())),
    );
    await _signingKeyService.clearPendingPhraseWords();
  }

  /// Encrypted keystore file export of the device's current signing key
  /// (spec: "Optional keystore file export"). Passthrough to
  /// [SigningKeyService] - the only place private key bytes are ever
  /// touched.
  Future<String> exportKeystoreFile({required String passphrase}) {
    return _signingKeyService.exportKeystoreFile(passphrase: passphrase);
  }
}
