import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/settings/views/join_qr_offer_panel.dart';

import '../acceptance/support/acceptance_harness.dart';
import 'acme_actions.dart';
import 'conductor_client.dart';

/// Household scenario (one person, the Mac and two phones; see
/// `householdScenario` in tool/company_sync/scenario.dart).

/// The entry each device records: amount in minor units and description.
const householdEntries = {
  'owner': (amountMinor: 4200, description: 'HH Mac groceries'),
  'claimant_0': (amountMinor: 450, description: 'HH phone A coffee'),
  'claimant_1': (amountMinor: 6000, description: 'HH phone B fuel'),
};
const householdAfterRemovalEntry = (
  amountMinor: 1250,
  description: 'HH phone A after removal',
);

/// The Groceries category is renamed twice; the later rename must win.
const householdRenameFirst = 'Food (Mac)';
const householdRenameLater = 'Supermarket (phone A)';

Future<void> householdCreateBooks(
  WidgetTester tester,
  CompanySyncConductorClient client,
) async {
  await completeOnboardingWithGuidedEntry(
    tester,
    amountText: '10.00',
    categoryName: englishAppLocalizations.systemCategorySalary,
    currencyCode: 'USD',
  );
  await publishSyncEndpoint(tester, client, role: 'owner');
}

/// Mac: Settings → Linked devices → Add a device, and relay the code for
/// [peerRole] to the conductor.
Future<void> householdOfferDevice(
  WidgetTester tester,
  CompanySyncConductorClient client, {
  required String peerRole,
}) async {
  final l10n = englishAppLocalizations;
  await openLinkedDevices(tester);
  await dismissPermissionIfNeeded(tester);
  await tapReliably(
    tester,
    () => find.text(l10n.settingsLinkedDevicesAddDevice),
    () => find.byType(JoinQrOfferPanel).evaluate().isNotEmpty,
  );
  final codeFinder = find.byKey(const Key('join-code-display'));
  await pumpUntilFound(tester, codeFinder, maxTries: 50);
  final code = (codeFinder.evaluate().single.widget as Text).data!;
  await publishJoinOfferToConductor(tester, client, peerRole: peerRole);
  await client.putValue('join_code_$peerRole', code);
}

/// The household's Groceries category. A phone that has just joined gets
/// the Mac's categories with its first syncs, so this syncs until the
/// category has arrived rather than failing on the joiner's empty copy.
Future<String> _groceriesCategoryId(WidgetTester tester) async {
  final names = {
    englishAppLocalizations.systemCategoryGroceries,
    householdRenameFirst,
    householdRenameLater,
  };
  var seen = <String>[];
  for (var i = 0; i < 30; i++) {
    final categories = await readRepo<CategoryRepository>(
      tester,
    ).watchCategories().first;
    for (final c in categories) {
      if (names.contains(c.name)) return c.id;
    }
    seen = [for (final c in categories) c.name];
    await syncNow(tester);
    await tester.pump(const Duration(seconds: 2));
  }
  fail('Groceries never arrived from the Mac; categories here: $seen');
}

Future<String> _cashAccountId(WidgetTester tester) async {
  final accounts = await readRepo<AccountRepository>(
    tester,
  ).watchFinancialAccounts().first;
  expect(accounts, isNotEmpty, reason: 'household books need Cash & Bank');
  return accounts.first.id;
}

Future<void> _record(
  WidgetTester tester, {
  required int amountMinor,
  required String description,
}) async {
  await readRepo<LedgerRepository>(tester).recordTransaction(
    amountMinor: amountMinor,
    direction: TransactionDirection.moneyOut,
    categoryId: await _groceriesCategoryId(tester),
    financialAccountId: await _cashAccountId(tester),
    transactionDate: DateTime.now(),
    description: description,
  );
}

/// Each device records its own entry, then syncs.
Future<void> householdRecord(
  WidgetTester tester, {
  required String role,
}) async {
  final entry = householdEntries[role]!;
  await _record(
    tester,
    amountMinor: entry.amountMinor,
    description: entry.description,
  );
  await syncNow(tester);
}

Future<Set<String>> _descriptions(WidgetTester tester) async {
  final entries = await readRepo<LedgerRepository>(tester).watchEntries().first;
  return {for (final e in entries) ?e.description};
}

/// Cash & Bank balance in minor units, from this device's own copy.
Future<int> _cashBalance(WidgetTester tester) async {
  final cashId = await _cashAccountId(tester);
  final entries = await readRepo<LedgerRepository>(tester).watchEntries().first;
  var total = 0;
  for (final e in entries) {
    for (final p in e.postings) {
      if (p.accountId == cashId) total += p.amountMinor;
    }
  }
  return total;
}

/// Syncs until [descriptions] are all present, retrying up to [tries].
Future<void> _syncUntilEntries(
  WidgetTester tester,
  Set<String> descriptions, {
  int tries = 30,
}) async {
  var seen = <String>{};
  for (var i = 0; i < tries; i++) {
    seen = await _descriptions(tester);
    if (seen.containsAll(descriptions)) return;
    await syncNow(tester);
    await tester.pump(const Duration(seconds: 2));
  }
  fail('entries never arrived: missing ${descriptions.difference(seen)}');
}

/// Every device must end up with all three entries; it then publishes its
/// balance and entry count so the Mac can compare them.
Future<void> householdVerifyEntries(
  WidgetTester tester,
  CompanySyncConductorClient client, {
  required String role,
}) async {
  await _syncUntilEntries(tester, {
    for (final e in householdEntries.values) e.description,
  });
  final entries = await readRepo<LedgerRepository>(tester).watchEntries().first;
  await client.putValue(
    'hh_state_$role',
    jsonEncode({
      'balance': await _cashBalance(tester),
      'entries': entries.length,
    }),
  );
}

Future<void> householdCompareBalances(CompanySyncConductorClient client) async {
  final states = <String, Map<String, dynamic>>{};
  for (final role in householdEntries.keys) {
    final raw = await client.waitValue('hh_state_$role');
    states[role] = Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
  final balances = {for (final s in states.values) s['balance']};
  final counts = {for (final s in states.values) s['entries']};
  expect(
    balances.length,
    1,
    reason: 'every device must show the same Cash & Bank balance: $states',
  );
  expect(counts.length, 1, reason: 'every device must hold the same entries');
}

Future<void> householdRename(
  WidgetTester tester, {
  required String newName,
}) async {
  await readRepo<CategoryRepository>(
    tester,
  ).renameCategory(id: await _groceriesCategoryId(tester), newName: newName);
  await syncNow(tester);
}

/// The later rename (phone A's) must win on every device.
Future<void> householdVerifyRename(WidgetTester tester) async {
  final id = await _groceriesCategoryId(tester);
  var name = '';
  for (var i = 0; i < 30; i++) {
    final categories = await readRepo<CategoryRepository>(
      tester,
    ).watchCategories().first;
    name = categories.firstWhere((c) => c.id == id).name;
    if (name == householdRenameLater) return;
    await syncNow(tester);
    await tester.pump(const Duration(seconds: 2));
  }
  fail('later rename did not win: saw "$name", want "$householdRenameLater"');
}

/// Mac removes phone B (claimant_1) and marks its copy for erase.
Future<void> householdRemovePhoneB(
  WidgetTester tester,
  CompanySyncConductorClient client,
) async {
  final raw = await client.waitValue('sync_endpoint_claimant_1');
  final target =
      (jsonDecode(raw) as Map<String, dynamic>)['deviceId'] as String;
  final membership = readRepo<MembershipRepository>(tester);
  final owner = await localDeviceId(tester);
  await membership.removeDevice(actorDeviceId: owner, targetDeviceId: target);
  await membership.markErasePending(
    actorDeviceId: owner,
    targetDeviceId: target,
  );
  await syncNow(tester);
}

/// Phone B keeps syncing until the Mac reports its copy erased, so erase on
/// next contact can happen.
Future<void> householdAwaitErase(
  WidgetTester tester,
  CompanySyncConductorClient client,
) async {
  for (var i = 0; i < 60; i++) {
    if (await client.getValue('hh_erased') == 'true') return;
    try {
      await syncNow(tester);
    } catch (_) {
      // After the wipe this device has no linked books left to sync.
    }
    await tester.pump(const Duration(seconds: 3));
  }
  fail('the Mac never reported phone B erased');
}

Future<void> householdVerifyErase(
  WidgetTester tester,
  CompanySyncConductorClient client,
) async {
  await ownerVerifyErase(tester);
  await client.putValue('hh_erased', 'true');
}

/// After phone B is gone, the Mac and phone A must still sync.
Future<void> householdAfterRemoval(WidgetTester tester) async {
  await _record(
    tester,
    amountMinor: householdAfterRemovalEntry.amountMinor,
    description: householdAfterRemovalEntry.description,
  );
  await syncNow(tester);
}

Future<void> householdFinal(WidgetTester tester) async {
  await _syncUntilEntries(tester, {householdAfterRemovalEntry.description});
}
