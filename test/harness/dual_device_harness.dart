import 'dart:async';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_chart_reader.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_store.dart';
import 'package:smara_accounting/data/repositories/ledger_posting.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/data/repositories/sync_merge_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/linked_devices/device_certificate_store.dart';
import 'package:smara_accounting/domain/linked_devices/local_network_reachability.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/peer_sync/peer_sync_session.dart';
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';

import '../domain/crypto/in_memory_secure_key_storage.dart';

/// One in-memory "device" stack for CI dual-device harness (design Decision 5).
class HarnessDevice {
  HarnessDevice._({
    required this.deviceId,
    required this.displayName,
    required this.booksSetId,
    required this.db,
    required this.keys,
    required this.certs,
    required this.identity,
    required this.accounts,
    required this.categories,
    required this.ledger,
    required this.membership,
    required this.merge,
    required this.transport,
    required this.reachability,
    required this.certificate,
  });

  final String deviceId;
  final String displayName;
  final String booksSetId;
  final AppDatabase db;
  final SigningKeyService keys;
  final FakeDeviceCertificateStore certs;
  final IdentityRepository identity;
  final AccountRepository accounts;
  final CategoryRepository categories;
  final LedgerRepository ledger;
  final MembershipRepository membership;
  final SyncMergeRepository merge;
  final InProcessSyncTransport transport;
  final FakeLocalNetworkReachability reachability;
  final DeviceCertificate certificate;

  Future<String> currentIdentityId() async =>
      (await identity.currentIdentity())!.identityId;

  Future<String> financialAccountId() async =>
      (await accounts.watchFinancialAccounts().first).first.id;

  Future<String> expenseCategoryId() async =>
      (await categories.watchCategories().first)
          .firstWhere((a) => a.type == AccountType.expense)
          .id;

  Future<String> recordSpend({
    required int amountMinor,
    String description = 'spend',
    DateTime? date,
  }) async {
    final accountId = await financialAccountId();
    final categoryId = await expenseCategoryId();
    return ledger.recordTransaction(
      amountMinor: amountMinor,
      direction: TransactionDirection.moneyOut,
      categoryId: categoryId,
      financialAccountId: accountId,
      transactionDate: date ?? DateTime(2026, 4, 1),
      description: description,
    );
  }

  Future<void> close() async {
    await transport.stopListening();
    await db.close();
  }
}

/// Two isolated in-memory devices that share only a test-controlled
/// in-process transport (linked-devices-and-sync task 9.1).
class DualDeviceHarness {
  DualDeviceHarness({
    this.booksSetId = 'books-harness',
    this.networkId = 'lan',
    FakeLocalNetworkReachability? reachability,
    DateTime Function()? clock,
  }) : reachability =
           reachability ?? FakeLocalNetworkReachability(onLocalNetwork: true),
       _clock = clock ?? DateTime.now;

  final String booksSetId;
  final String networkId;
  final FakeLocalNetworkReachability reachability;
  final DateTime Function() _clock;

  late HarnessDevice a;
  late HarnessDevice b;
  bool _linked = false;

  bool get isLinked => _linked;

  Set<String> get pinnedFingerprints => {
    a.certificate.fingerprint,
    b.certificate.fingerprint,
  };

  /// Creates devices A (Owner) and B (joiner, no starter categories yet).
  Future<void> setUp() async {
    // Two isolated NativeDatabase.memory() executors — Drift's warning is
    // for sharing one executor across two AppDatabase instances.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    InProcessSyncTransport.resetAll();
    a = await _createDevice(
      deviceId: 'device-a',
      displayName: 'Phone A',
      seedStarterCategories: true,
    );
    b = await _createDevice(
      deviceId: 'device-b',
      displayName: 'Phone B',
      seedStarterCategories: false,
    );
  }

  Future<void> tearDown() async {
    await a.close();
    await b.close();
    InProcessSyncTransport.resetAll();
  }

  /// Links A↔B via QR join semantics: shared identity ids, catalog copy
  /// (books transfer), membership, pinned certs.
  Future<void> link() async {
    if (_linked) return;

    final qr = await a.membership.buildJoinQrPayload(
      hostDeviceId: a.deviceId,
      hostDisplayName: a.displayName,
      booksSetId: booksSetId,
    );

    final bIdentity = await b.identity.currentIdentity();
    if (bIdentity == null) {
      throw StateError('Device B has no signing identity.');
    }

    // Joiner registers host identity under the host's id from the QR.
    await b.identity.addLinkedPeerIdentity(
      publicKey: qr.signingPublicKey,
      identityId: qr.hostIdentityId,
    );

    // Host accepts joiner with joiner's stable identity id.
    await a.membership.acceptJoinFromQr(
      actorDeviceId: a.deviceId,
      payload: qr,
      joinerDeviceId: b.deviceId,
      joinerDisplayName: b.displayName,
      joinerSigningPublicKey: bIdentity.publicKey,
      joinerDeviceCertFingerprint: b.certificate.fingerprint,
      joinerIdentityId: bIdentity.identityId,
    );

    // Mirror membership onto B (received with the books transfer).
    await _ensureMembershipRow(
      device: b,
      deviceId: a.deviceId,
      displayName: a.displayName,
      signingIdentityId: qr.hostIdentityId,
      fingerprint: a.certificate.fingerprint,
      role: LinkedDeviceRole.owner,
      canAdd: true,
    );
    await _ensureMembershipRow(
      device: b,
      deviceId: b.deviceId,
      displayName: b.displayName,
      signingIdentityId: bIdentity.identityId,
      fingerprint: b.certificate.fingerprint,
      role: LinkedDeviceRole.member,
      canAdd: false,
    );

    await _copySharedCatalog(from: a, to: b);
    _linked = true;
  }

  /// Sync now from [from] to [to] (listener on [to]).
  Future<({SyncSessionResult sender, SyncSessionResult receiver})> syncNow({
    required HarnessDevice from,
    required HarnessDevice to,
  }) async {
    final pins = pinnedFingerprints;
    final senderSession = PeerSyncSession(
      transport: from.transport,
      ledger: from.merge,
      reachability: reachability,
      localIdentity: SyncPeerIdentity(
        deviceId: from.deviceId,
        certificate: from.certificate,
      ),
      pinnedFingerprints: pins,
    );
    final receiverSession = PeerSyncSession(
      transport: to.transport,
      ledger: to.merge,
      reachability: reachability,
      localIdentity: SyncPeerIdentity(
        deviceId: to.deviceId,
        certificate: to.certificate,
      ),
      pinnedFingerprints: pins,
    );

    final done = Completer<SyncSessionResult>();
    await receiverSession.startListening(onCompleted: done.complete);
    final senderResult = await senderSession.syncNow(
      remote: SyncPeerIdentity(
        deviceId: to.deviceId,
        certificate: to.certificate,
      ),
    );
    final receiverResult = await done.future.timeout(
      const Duration(seconds: 5),
    );
    await receiverSession.stopListening();
    return (sender: senderResult, receiver: receiverResult);
  }

  Future<HarnessDevice> _createDevice({
    required String deviceId,
    required String displayName,
    required bool seedStarterCategories,
  }) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final storage = InMemorySecureKeyStorage();
    final keys = SigningKeyService(
      secureStorage: storage,
      booksSetId: booksSetId,
    );
    final certs = FakeDeviceCertificateStore();
    final chain = LedgerChainStore(db);
    final ledger = LedgerRepository(
      database: db,
      signingKeyService: keys,
      chain: chain,
    );
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    final categories = CategoryRepository(database: db);
    final identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      chain: chain,
      signingKeyService: keys,
    );
    final posting = LedgerPosting(
      database: db,
      chart: AccountChartReader(db),
      chain: chain,
      entriesForAccount: (id) => ledger.watchEntriesForAccount(id).first,
      signingKeyService: keys,
    );
    final membership = MembershipRepository(
      database: db,
      identityRepository: identity,
      certificateStore: certs,
      reachability: reachability,
      clock: _clock,
    );
    final merge = SyncMergeRepository(
      database: db,
      signingKeyService: keys,
      chain: chain,
      posting: posting,
      clock: _clock,
      localDeviceDisplayName: displayName,
    );
    final transport = InProcessSyncTransport(networkId: networkId);
    final certificate = await certs.localCertificate(deviceId: deviceId);

    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(
      generated,
      currency: 'USD',
      seedStarterCategories: seedStarterCategories,
    );
    if (seedStarterCategories) {
      await membership.ensureLocalOwner(
        localDeviceId: deviceId,
        displayName: displayName,
      );
    }

    return HarnessDevice._(
      deviceId: deviceId,
      displayName: displayName,
      booksSetId: booksSetId,
      db: db,
      keys: keys,
      certs: certs,
      identity: identity,
      accounts: accounts,
      categories: categories,
      ledger: ledger,
      membership: membership,
      merge: merge,
      transport: transport,
      reachability: reachability,
      certificate: certificate,
    );
  }

  Future<void> _ensureMembershipRow({
    required HarnessDevice device,
    required String deviceId,
    required String displayName,
    required String signingIdentityId,
    required String fingerprint,
    required LinkedDeviceRole role,
    required bool canAdd,
  }) async {
    final existing = await device.membership.findByDeviceId(deviceId);
    if (existing != null) return;
    await device.db
        .into(device.db.linkedDevices)
        .insert(
          LinkedDevicesCompanion.insert(
            deviceId: deviceId,
            displayName: displayName,
            signingIdentityId: signingIdentityId,
            deviceCertFingerprint: fingerprint,
            role: role,
            canAdd: Value(canAdd),
            createdAt: Value(_clock()),
          ),
        );
  }

  /// Copies account groups + accounts from [from] onto [to] (simulates the
  /// books transfer that accompanies QR join).
  Future<void> _copySharedCatalog({
    required HarnessDevice from,
    required HarnessDevice to,
  }) async {
    final groups = await from.db.select(from.db.accountGroups).get();
    for (final g in groups) {
      final exists = await (to.db.select(
        to.db.accountGroups,
      )..where((t) => t.id.equals(g.id))).getSingleOrNull();
      if (exists != null) continue;
      await to.db
          .into(to.db.accountGroups)
          .insert(
            AccountGroupsCompanion.insert(
              id: Value(g.id),
              name: g.name,
              kind: g.kind,
              sortOrder: g.sortOrder,
              isSystem: g.isSystem,
              currency: Value(g.currency),
              archivedAt: Value(g.archivedAt),
            ),
          );
    }

    final accounts = await from.db.select(from.db.accounts).get();
    final ordered = [
      ...accounts.where((a) => a.investmentOwnerAccountId == null),
      ...accounts.where((a) => a.investmentOwnerAccountId != null),
    ];
    for (final row in ordered) {
      final exists = await (to.db.select(
        to.db.accounts,
      )..where((t) => t.id.equals(row.id))).getSingleOrNull();
      if (exists != null) continue;
      await to.db
          .into(to.db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: Value(row.id),
              name: row.name,
              type: row.type,
              holdsInvestments: Value(row.holdsInvestments),
              investmentOwnerAccountId: Value(row.investmentOwnerAccountId),
              groupId: Value(row.groupId),
              sortOrder: Value(row.sortOrder),
              monthlyLimitMinor: Value(row.monthlyLimitMinor),
              isCreditCard: Value(row.isCreditCard),
              archivedAt: Value(row.archivedAt),
            ),
          );
    }
  }
}
