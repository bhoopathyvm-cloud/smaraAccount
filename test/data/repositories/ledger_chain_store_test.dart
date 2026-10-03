import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/ledger_chain_state_table.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_store.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late LedgerChainStore store;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = LedgerChainStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('loadState inserts the singleton when missing', () async {
    final state = await store.loadState();
    expect(state.id, ledgerChainStateSingletonId);
    expect(state.nextDeviceChainSequence, 0);
    expect(state.trustedTipEntryId, isNull);
  });

  test('a second store on the same database sees updateState', () async {
    await store.loadState();
    final hash = Uint8List.fromList(List<int>.filled(32, 7));
    await store.updateState(
      trustedTipEntryId: null,
      trustedTipHash: hash,
      nextDeviceChainSequence: 4,
    );

    final other = LedgerChainStore(db);
    final state = await other.loadState();
    expect(state.nextDeviceChainSequence, 4);
    expect(state.trustedTipHash, hash);
  });

  test('currentSigningIdentity is null until a row exists', () async {
    expect(await store.currentSigningIdentity(), isNull);

    await db
        .into(db.signingIdentities)
        .insert(
          SigningIdentitiesCompanion.insert(
            publicKey: Uint8List.fromList(List<int>.filled(32, 1)),
          ),
        );

    final identity = await store.currentSigningIdentity();
    expect(identity, isNotNull);
    expect(identity!.publicKey, List<int>.filled(32, 1));
  });

  test('without a matching key, currentSigningIdentity prefers the local '
      'write-tip identity over a newer peer', () async {
    final localId = 'local-identity';
    final peerId = 'peer-identity';
    final tipHash = Uint8List.fromList(List<int>.filled(32, 9));
    final sameSecond = DateTime.utc(2026, 4, 1, 12);

    await db
        .into(db.signingIdentities)
        .insert(
          SigningIdentitiesCompanion.insert(
            identityId: Value(localId),
            publicKey: Uint8List.fromList(List<int>.filled(32, 1)),
            createdAt: Value(sameSecond),
          ),
        );
    await db
        .into(db.signingIdentities)
        .insert(
          SigningIdentitiesCompanion.insert(
            identityId: Value(peerId),
            publicKey: Uint8List.fromList(List<int>.filled(32, 2)),
            // Peer linked later (or same second — either used to flake).
            createdAt: Value(sameSecond.add(const Duration(seconds: 5))),
          ),
        );
    await store.ensureIdentityTip(localId);
    await store.ensureIdentityTip(peerId);
    await store.updateIdentityTip(
      identityId: localId,
      trustedTipEntryId: 'local-tip-entry',
      trustedTipHash: tipHash,
      nextDeviceChainSequence: 1,
    );
    await store.updateState(
      trustedTipEntryId: 'local-tip-entry',
      trustedTipHash: tipHash,
      nextDeviceChainSequence: 1,
    );

    final current = await store.currentSigningIdentity();
    expect(current, isNotNull);
    expect(current!.identityId, localId);

    final active = await store.activeSigningIdentities();
    expect(active.map((i) => i.identityId).toList(), [peerId, localId]);
  });

  test('without a tip yet, currentSigningIdentity picks the first-inserted '
      'active identity when createdAt ties at second precision', () async {
    final sameSecond = DateTime.utc(2026, 4, 1, 12);
    // Peer id sorts before local lexicographically; insertion order must
    // win so a same-second peer link does not become "current".
    await db
        .into(db.signingIdentities)
        .insert(
          SigningIdentitiesCompanion.insert(
            identityId: const Value('zzzz-local'),
            publicKey: Uint8List.fromList(List<int>.filled(32, 1)),
            createdAt: Value(sameSecond),
          ),
        );
    await db
        .into(db.signingIdentities)
        .insert(
          SigningIdentitiesCompanion.insert(
            identityId: const Value('aaaa-peer'),
            publicKey: Uint8List.fromList(List<int>.filled(32, 2)),
            createdAt: Value(sameSecond),
          ),
        );

    final current = await store.currentSigningIdentity();
    expect(current!.identityId, 'zzzz-local');
  });
}
