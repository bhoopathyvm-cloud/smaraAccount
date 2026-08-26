import 'dart:typed_data';

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
}
