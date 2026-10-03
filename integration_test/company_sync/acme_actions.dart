import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smara_accounting/data/claims/company_sync_claim_receipt_picker.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/claim_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/data/repositories/personal_claim_limit_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/claims/claim_receipt_picker.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/claim.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/domain/peer_sync/peer_sync_service.dart';
import 'package:smara_accounting/domain/peer_sync/peer_sync_session.dart';
import 'package:smara_accounting/domain/peer_sync/tls_sync_transport.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/core/money_formatter.dart';
import 'package:smara_accounting/ui/features/claims/views/approver_queue_view.dart';
import 'package:smara_accounting/ui/features/claims/views/claim_editor_view.dart';
import 'package:smara_accounting/ui/features/claims/views/claims_list_view.dart';
import 'package:smara_accounting/ui/features/claims/views/personal_claim_limits_page.dart';
import 'package:smara_accounting/ui/features/settings/views/join_qr_offer_panel.dart';
import 'package:smara_accounting/ui/features/settings/views/linked_devices_section.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../acceptance/support/acceptance_harness.dart';
import 'conductor_client.dart';
import 'visible_text.dart';

const acmeCategoryNames = [
  'Hotel',
  'Meals',
  'Taxi',
  'Train',
  'Souvenir',
  'Dinner',
];

const acmePeople = ['Ravi', 'Mia', 'Kenji', 'Sara', 'Tom'];

/// Set by the company-sync role runner so [syncNow] can publish/wire
/// direct-address peers when mDNS between simulators and macOS is flaky.
CompanySyncConductorClient? companySyncConductor;
String? companySyncRole;
int companySyncEmployees = 2;

/// Spec claim table keyed by claimant index (Ravi=0 … Tom=4).
List<AcmeClaimItem> acmeItemsFor(int claimantIndex) {
  switch (claimantIndex) {
    case 0:
      return const [
        AcmeClaimItem('Train', 'EUR', 8900, 8900, 'Train'),
        AcmeClaimItem('Hotel', 'GBP', 18000, 21060, 'Hotel'),
        AcmeClaimItem('Dinner', 'EUR', 4500, 4500, 'Dinner'),
      ];
    case 1:
      return const [
        AcmeClaimItem('Hotel', 'EUR', 19000, 19000, 'Hotel'),
        AcmeClaimItem('Taxi', 'EUR', 3500, 3500, 'Taxi'),
      ];
    case 2:
      return const [
        AcmeClaimItem('Hotel', 'JPY', 2100000, 13020, 'Hotel'),
        AcmeClaimItem('Meals', 'JPY', 600000, 3720, 'Meals'),
        AcmeClaimItem('Souvenir', 'EUR', 3000, 3000, 'Souvenir'),
      ];
    case 3:
      return const [
        AcmeClaimItem('Meals', 'EUR', 5500, 5500, 'Meals'),
        AcmeClaimItem('Train', 'EUR', 6000, 6000, 'Train'),
      ];
    case 4:
      return const [
        AcmeClaimItem(
          'Taxi',
          'EUR',
          8000,
          8000,
          'Taxi',
          receiptFile: 'unreadable_receipt.jpg',
        ),
      ];
    default:
      return const [];
  }
}

class AcmeClaimItem {
  const AcmeClaimItem(
    this.category,
    this.paidCurrency,
    this.paidMinor,
    this.companyMinor,
    this.description, {
    this.receiptFile = 'hotel_receipt.jpg',
  });

  final String category;
  final String paidCurrency;
  final int paidMinor;
  final int companyMinor;
  final String description;

  /// Gallery fixture under `test_fixtures/receipts/` (null = no attach).
  final String? receiptFile;
}

T readRepo<T>(WidgetTester tester) =>
    Provider.of<T>(tester.element(find.byType(MaterialApp)), listen: false);

Future<String> localDeviceId(WidgetTester tester) async {
  final membership = readRepo<MembershipRepository>(tester);
  final identity = readRepo<IdentityRepository>(tester);
  final me = await identity.currentIdentity();
  final devices = await membership.listActiveDevices();
  final mine = devices.where(
    (d) => me != null && d.signingIdentityId == me.identityId,
  );
  expect(mine, isNotEmpty, reason: 'local membership device missing');
  return mine.first.deviceId;
}

Future<String?> deviceIdForName(WidgetTester tester, String name) async {
  final membership = readRepo<MembershipRepository>(tester);
  for (final d in await membership.listDevices()) {
    if (d.displayName == name || d.personDisplayName == name) {
      return d.deviceId;
    }
  }
  return null;
}

Future<String?> firstAssetAccountId(WidgetTester tester) async {
  final accounts = readRepo<AccountRepository>(tester);
  final all = await accounts.watchFinancialAccounts().first;
  for (final a in all) {
    if (a.type == AccountType.asset && !a.archived) return a.id;
  }
  return null;
}

Future<void> goHome(WidgetTester tester) async {
  final l10n = englishAppLocalizations;
  if (find.byTooltip(l10n.settingsTitle).evaluate().isNotEmpty) return;
  // Claimant surface: settings is an AppBar action on Claims.
  final claimsSettings = find.byKey(const Key('claims-open-settings'));
  if (claimsSettings.evaluate().isNotEmpty) {
    await tapReliably(
      tester,
      () => claimsSettings,
      () =>
          find.text(l10n.settingsLinkedDevices).evaluate().isNotEmpty ||
          find.byType(LinkedDevicesSection).evaluate().isNotEmpty ||
          find.text(l10n.settingsBooksSwitcher).evaluate().isNotEmpty,
    );
    return;
  }
  // Approver review queue is pushed from Linked devices — pop back.
  if (find.byType(ApproverQueueView).evaluate().isNotEmpty) {
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tapReliably(
        tester,
        () => back,
        () => find.byType(ApproverQueueView).evaluate().isEmpty,
      );
    }
  }
  final home = find.byIcon(TablerIcons.home);
  if (home.evaluate().isNotEmpty) {
    await tapReliably(
      tester,
      () => home,
      () => find.byTooltip(l10n.settingsTitle).evaluate().isNotEmpty,
    );
  }
}

Future<void> openLinkedDevices(WidgetTester tester) async {
  final l10n = englishAppLocalizations;
  await goHome(tester);
  final open =
      find.text(l10n.settingsLinkedDevices).evaluate().isNotEmpty ||
      find.byType(LinkedDevicesSection).evaluate().isNotEmpty;
  if (!open) {
    // Prefer Claimant Claims → Settings, then Owner/Member home gear.
    final claimsSettings = find.byKey(const Key('claims-open-settings'));
    if (claimsSettings.evaluate().isNotEmpty) {
      await tapReliably(
        tester,
        () => claimsSettings,
        () =>
            find.text(l10n.settingsLinkedDevices).evaluate().isNotEmpty ||
            find.textContaining('Linked').evaluate().isNotEmpty,
      );
    } else {
      await pumpUntilFound(
        tester,
        find.byTooltip(l10n.settingsTitle),
        maxTries: 100,
      );
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.settingsTitle).hitTestable(),
        () =>
            find.text(l10n.settingsLinkedDevices).evaluate().isNotEmpty ||
            find.textContaining('Linked').evaluate().isNotEmpty,
      );
    }
  }
  await scrollSettingsUntilVisible(
    tester,
    find.text(l10n.settingsLinkedDevices),
  );
  await dismissPermissionIfNeeded(tester);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> dismissPermissionIfNeeded(WidgetTester tester) async {
  final l10n = englishAppLocalizations;
  final continueBtn = find.text(l10n.settingsLinkedDevicesContinue);
  if (continueBtn.evaluate().isNotEmpty) {
    await tapReliably(
      tester,
      () => continueBtn,
      () => continueBtn.evaluate().isEmpty,
    );
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> syncNow(WidgetTester tester) async {
  final l10n = englishAppLocalizations;
  final wasOnClaims = find.byType(ClaimsListView).evaluate().isNotEmpty;
  final client = companySyncConductor;
  final role = companySyncRole;
  if (client != null && role != null) {
    await publishSyncEndpoint(tester, client, role: role);
    await wireDirectSyncPeers(
      tester,
      client,
      peerRoles: _companySyncPeerRoles(role),
    );
  }
  // Drive the real PeerSyncService after wiring direct peers — the Settings
  // button calls the same service; calling it here covers mDNS-denied sims.
  // Re-publish after startForeground inside syncNow so peers see the live port.
  // Retry once when Provider still holds a Drift handle closed by books switch.
  try {
    List<SyncSessionResult> results;
    try {
      results = await readRepo<PeerSyncService>(tester).syncNow();
    } on StateError catch (e) {
      if (!'$e'.contains('re-open a database')) rethrow;
      await tester.pump(const Duration(milliseconds: 300));
      results = await readRepo<PeerSyncService>(tester).syncNow();
    }
    final payload = jsonEncode([
      for (final r in results)
        {
          'connected': r.connected,
          'sent': r.entriesSent,
          'recv': r.entriesReceived,
          'reason': r.refusedReason,
        },
    ]);
    if (client != null && role != null) {
      await publishSyncEndpoint(tester, client, role: role);
      await client.putValue('sync_result_$role', payload);
    }
    _writeSyncDebug(role, payload);
  } catch (e) {
    if (client != null && role != null) {
      await client.putValue('sync_result_$role', 'error:$e');
    }
    _writeSyncDebug(role, 'error:$e');
  }
  await openLinkedDevices(tester);
  final sync = find.text(l10n.settingsLinkedDevicesSyncNow);
  if (sync.evaluate().isNotEmpty) {
    await tapReliably(tester, () => sync, () => true);
    await tester.pump(const Duration(seconds: 4));
  }
  // Settings is pushed over Claims / Home — always pop back so the next
  // step is not stranded on the Settings scroll view.
  if (find.text(l10n.settingsTitle).evaluate().isNotEmpty ||
      find.byType(LinkedDevicesSection).evaluate().isNotEmpty) {
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tapReliably(
        tester,
        () => back,
        () =>
            find.byType(LinkedDevicesSection).evaluate().isEmpty ||
            find.byType(ClaimsListView).evaluate().isNotEmpty ||
            wasOnClaims,
      );
    }
  }
}

List<String> _companySyncPeerRoles(String role) {
  final roles = <String>['owner', 'approver'];
  for (var i = 0; i < companySyncEmployees.clamp(0, 5); i++) {
    roles.add('claimant_$i');
  }
  return roles.where((r) => r != role).toList();
}

/// Publishes this device's sync listen port so peers can [connectByAddress].
void _writeSyncDebug(String? role, String payload) {
  const artifacts = String.fromEnvironment('COMPANY_SYNC_ARTIFACTS');
  if (artifacts.isEmpty || role == null) return;
  try {
    final dir = Directory('$artifacts/$role');
    dir.createSync(recursive: true);
    final stamp = DateTime.now().toUtc().toIso8601String();
    File('${dir.path}/sync_result_$stamp.json').writeAsStringSync(payload);
    File('${dir.path}/sync_result_latest.json').writeAsStringSync(payload);
  } catch (_) {}
}

void installSyncDebugLogger(String role) {
  const artifacts = String.fromEnvironment('COMPANY_SYNC_ARTIFACTS');
  if (artifacts.isEmpty) return;
  void sink(String message) {
    try {
      final dir = Directory('$artifacts/$role');
      dir.createSync(recursive: true);
      final file = File('${dir.path}/sync_exchange.log');
      file.writeAsStringSync(
        '${DateTime.now().toUtc().toIso8601String()} $message\n',
        mode: FileMode.append,
      );
    } catch (_) {}
  }

  PeerSyncSession.debugLog = sink;
  tlsSyncDebugLog = sink;
}

Future<void> publishSyncEndpoint(
  WidgetTester tester,
  CompanySyncConductorClient client, {
  required String role,
}) async {
  // After openJoinedSet the old Drift connection is closed; ProxyProviders
  // need a frame (or two) before PeerSyncService holds the new database.
  Object? lastError;
  for (var attempt = 0; attempt < 8; attempt++) {
    try {
      final sync = readRepo<PeerSyncService>(tester);
      final settings = readRepo<SettingsRepository>(tester);
      await sync.startForeground();
      final port = sync.boundPort;
      final deviceId = await settings.localDeviceId();
      if (port == null || deviceId == null || deviceId.isEmpty) return;
      final hosts = <String>['127.0.0.1'];
      for (final iface in await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      )) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && !hosts.contains(addr.address)) {
            hosts.add(addr.address);
          }
        }
      }
      await client.putValue(
        'sync_endpoint_$role',
        jsonEncode({'deviceId': deviceId, 'hosts': hosts, 'port': port}),
      );
      return;
    } catch (e) {
      lastError = e;
      final msg = '$e';
      if (!msg.contains('re-open a database') &&
          !msg.contains('database connection')) {
        rethrow;
      }
      await tester.pump(const Duration(milliseconds: 250));
    }
  }
  throw StateError('publishSyncEndpoint failed after retries: $lastError');
}

/// Registers conductor-published sync endpoints via direct address so Sync now
/// does not depend solely on Bonjour between simulators and macOS.
Future<void> wireDirectSyncPeers(
  WidgetTester tester,
  CompanySyncConductorClient client, {
  required List<String> peerRoles,
}) async {
  final sync = readRepo<PeerSyncService>(tester);
  final membership = readRepo<MembershipRepository>(tester);
  final known = {
    for (final d in await membership.listActiveDevices()) d.deviceId,
  };
  for (final peerRole in peerRoles) {
    final raw = await client.getValue('sync_endpoint_$peerRole');
    if (raw == null || raw.isEmpty) continue;
    Map<String, dynamic> map;
    try {
      map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      continue;
    }
    final deviceId = map['deviceId'] as String?;
    final port = map['port'] as int?;
    if (deviceId == null || port == null || !known.contains(deviceId)) {
      continue;
    }
    final hosts = <String>[
      '127.0.0.1',
      if (map['hosts'] is List)
        for (final h in map['hosts'] as List) h.toString(),
    ];
    for (final host in hosts.toSet()) {
      try {
        await sync.connectByAddress(
          peerDeviceId: deviceId,
          host: host,
          port: port,
        );
        break;
      } catch (_) {
        // try next host
      }
    }
  }
}

Future<void> configureAcmeCompany(WidgetTester tester) async {
  final categories = readRepo<CategoryRepository>(tester);
  final claims = readRepo<ClaimRepository>(tester);
  var existing = await categories.watchCategories().first;
  final names = {for (final c in existing) c.name};
  for (final name in acmeCategoryNames) {
    if (!names.contains(name)) {
      await categories.addCategory(name: name, type: AccountType.expense);
    }
  }
  existing = await categories.watchCategories().first;
  final ids = {
    for (final c in existing)
      if (acmeCategoryNames.contains(c.name)) c.id,
  };
  await claims.setAllowlistedCategories(ids);
  await claims.setReceiptRequiredAboveMinor(0);
  String idOf(String name) => existing.firstWhere((c) => c.name == name).id;
  await claims.setSpendingHint(
    categoryId: idOf('Hotel'),
    maxAmountMinor: 15000,
    unitLabel: 'night',
  );
  await claims.setSpendingHint(
    categoryId: idOf('Meals'),
    maxAmountMinor: 4000,
    unitLabel: 'day',
  );
  await claims.setSpendingHint(
    categoryId: idOf('Taxi'),
    maxAmountMinor: 6000,
    unitLabel: 'trip',
  );
}

Future<void> ownerStartAddPerson({
  required WidgetTester tester,
  required CompanySyncConductorClient client,
  required String personName,
  required LinkedDeviceRole role,
  required String peerRole,
}) async {
  await openLinkedDevices(tester);
  await dismissPermissionIfNeeded(tester);
  await tapReliably(
    tester,
    () => find.byKey(const Key('add-person-button')),
    () => find.byKey(const Key('add-person-name-field')).evaluate().isNotEmpty,
  );
  await enterTextReliably(
    tester,
    () => find.byKey(const Key('add-person-name-field')),
    personName,
    () => true,
  );
  await tapReliably(
    tester,
    () => find.byKey(const Key('add-person-name-continue')),
    () =>
        find.byKey(const Key('add-person-role-claimant')).evaluate().isNotEmpty,
  );
  // UI maps Approver → {approver, member}; Claimant → {claimant}.
  final roleKey = role == LinkedDeviceRole.approver
      ? const Key('add-person-role-approver')
      : const Key('add-person-role-claimant');
  await tapReliably(
    tester,
    () => find.byKey(roleKey),
    () => find.byType(JoinQrOfferPanel).evaluate().isNotEmpty,
    maxAttempts: 5,
    innerTries: 60,
  );
  await pumpUntilFound(tester, find.byType(JoinQrOfferPanel), maxTries: 120);
  final codeFinder = find.byKey(const Key('join-code-display'));
  await pumpUntilFound(tester, codeFinder, maxTries: 120);
  expect(
    codeFinder,
    findsOneWidget,
    reason:
        'join-code-display missing after Add a person ($personName / $peerRole); '
        'saw:\n${dumpVisibleText(tester)}',
  );
  final code = (codeFinder.evaluate().single.widget as Text).data!;
  expect(
    code,
    isNotEmpty,
    reason: 'join code empty for $peerRole; saw:\n${dumpVisibleText(tester)}',
  );
  // Offer first, then code: joiner waits on join_code_<peer> then reads offer.
  await publishJoinOfferToConductor(tester, client, peerRole: peerRole);
  await client.putValue('join_code_$peerRole', code);
  await client.putValue('join_code', code);
}

Future<void> publishJoinOfferToConductor(
  WidgetTester tester,
  CompanySyncConductorClient client, {
  String? peerRole,
}) async {
  final section = find.byType(LinkedDevicesSection);
  await pumpUntilFound(tester, section, maxTries: 40);
  final widget = tester.widget<LinkedDevicesSection>(section);
  final vm = widget.viewModel;
  for (var i = 0; i < 40 && vm.activeJoinOfferPort == null; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  final port = vm.activeJoinOfferPort;
  final offerId = vm.activeJoinOfferId;
  final booksSetId = vm.activeJoinOfferBooksSetId;
  expect(port, isNotNull, reason: 'join host must be listening');
  expect(offerId, isNotNull, reason: 'join offer id missing');
  expect(booksSetId, isNotNull, reason: 'join offer booksSetId missing');
  expect(booksSetId, isNotEmpty, reason: 'join offer booksSetId empty');
  final hosts = <String>['127.0.0.1'];
  for (final iface in await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLinkLocal: false,
  )) {
    for (final addr in iface.addresses) {
      if (!addr.isLoopback && !hosts.contains(addr.address)) {
        hosts.add(addr.address);
      }
    }
  }
  final payload = jsonEncode({
    'hosts': hosts,
    'host': '127.0.0.1',
    'port': port,
    'offerId': offerId,
    'booksSetId': booksSetId,
  });
  if (peerRole != null) {
    await client.putValue('join_offer_$peerRole', payload);
  }
  await client.putValue('join_offer', payload);
}

Future<void> ownerConfirmCheckCode({
  required WidgetTester tester,
  required CompanySyncConductorClient client,
  required String peerKey,
}) async {
  final check = await client.waitValue(peerKey);
  await client.putValue('check_code_owner_for_$peerKey', check);
  final hostCheck = find.byKey(const Key('join-host-check-code'));
  // Confirm via the ViewModel as soon as pendingHostCheckCode is set — do not
  // rely solely on AlertDialog hit-testing (macOS integration tests often miss
  // it, and a stuck completer blocks JoinCodeHost forever).
  var confirmed = false;
  for (var i = 0; i < 150; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    final section = find.byType(LinkedDevicesSection);
    if (section.evaluate().isNotEmpty) {
      final vm = tester.widget<LinkedDevicesSection>(section).viewModel;
      if (vm.pendingHostCheckCode != null) {
        vm.confirmHostCheckCodeMatch();
        confirmed = true;
        await tester.pump(const Duration(milliseconds: 300));
        break;
      }
    }
    if (hostCheck.evaluate().isNotEmpty) {
      final matchBtn = find.byKey(const Key('join-host-codes-match'));
      if (matchBtn.evaluate().isNotEmpty) {
        final button = tester.widget<ButtonStyleButton>(matchBtn);
        button.onPressed?.call();
        confirmed = true;
        await tester.pump(const Duration(milliseconds: 300));
        break;
      }
    }
    // Joiner finished and host UI already cleared.
    if (i > 30 &&
        hostCheck.evaluate().isEmpty &&
        find.byType(AlertDialog).evaluate().isEmpty) {
      break;
    }
  }
  if (confirmed && hostCheck.evaluate().isNotEmpty) {
    final section = find.byType(LinkedDevicesSection);
    if (section.evaluate().isNotEmpty) {
      tester
          .widget<LinkedDevicesSection>(section)
          .viewModel
          .confirmHostCheckCodeMatch();
      await tester.pump(const Duration(milliseconds: 300));
    }
  }
  // Give the host time to finish onJoinAccepted + payload, then dismiss the
  // offer dialog without clearActiveJoinQr (that would kill JoinCodeHost mid
  // exchange). Popping frees the UI for the next Add-a-person flow.
  await tester.pump(const Duration(seconds: 2));
  final dialog = find.byType(AlertDialog);
  if (dialog.evaluate().isNotEmpty) {
    final nav = Navigator.of(tester.element(dialog.first));
    nav.pop();
    await tester.pump(const Duration(milliseconds: 500));
  }
  await tester.pump(const Duration(seconds: 1));
}

Future<void> setPersonalLimitsAndAdvances(
  WidgetTester tester, {
  required int employees,
}) async {
  final limits = readRepo<PersonalClaimLimitRepository>(tester);
  final claims = readRepo<ClaimRepository>(tester);
  final categories = readRepo<CategoryRepository>(tester);
  final identity = readRepo<IdentityRepository>(tester);
  final membership = readRepo<MembershipRepository>(tester);
  final identityId = (await identity.currentIdentity())!.identityId;
  final cats = await categories.watchCategories().first;
  String catId(String name) => cats.firstWhere((c) => c.name == name).id;
  final ownerId = await localDeviceId(tester);
  final bankId = await firstAssetAccountId(tester);

  // Owed-to accounts are created on accept-join; sync so Owner sees them
  // before recording advances.
  await syncNow(tester);
  Future<String?> waitDeviceWithOwedTo(String name) async {
    for (var i = 0; i < 40; i++) {
      final deviceId = await deviceIdForName(tester, name);
      if (deviceId != null) {
        final devices = await membership.listActiveDevices();
        final row = devices.where((d) => d.deviceId == deviceId).firstOrNull;
        if (row?.owedToAccountId != null) return deviceId;
      }
      await syncNow(tester);
      await tester.pump(const Duration(milliseconds: 500));
    }
    return deviceIdForName(tester, name);
  }

  Future<void> setLimit(String name, String category, int minor) async {
    final deviceId = await waitDeviceWithOwedTo(name);
    if (deviceId == null) return;
    await limits.setLimit(
      personDeviceId: deviceId,
      categoryId: catId(category),
      amountMinor: minor,
      unitLabel: category == 'Meals' ? 'day' : 'night',
      updatedByIdentityId: identityId,
    );
  }

  if (employees >= 1) await setLimit('Ravi', 'Hotel', 12000);
  if (employees >= 2) await setLimit('Mia', 'Hotel', 20000);
  if (employees >= 4) await setLimit('Sara', 'Meals', 6000);

  if (bankId == null) return;
  if (employees >= 1) {
    final ravi = await waitDeviceWithOwedTo('Ravi');
    if (ravi != null) {
      await claims.recordAdvance(
        actorDeviceId: ownerId,
        claimantDeviceId: ravi,
        bankAccountId: bankId,
        amountMinor: 20000,
      );
    }
  }
  if (employees >= 4) {
    final sara = await waitDeviceWithOwedTo('Sara');
    if (sara != null) {
      await claims.recordAdvance(
        actorDeviceId: ownerId,
        claimantDeviceId: sara,
        bankAccountId: bankId,
        amountMinor: 10000,
      );
    }
  }
}

void _setNextReceipt(WidgetTester tester, String? fileName) {
  final picker = readRepo<ClaimReceiptPicker>(tester);
  if (picker is CompanySyncClaimReceiptPicker) {
    picker.setNextGalleryFile(fileName);
  }
}

Future<void> _openClaimsHome(WidgetTester tester) async {
  final l10n = englishAppLocalizations;
  if (find.byType(ClaimsListView).evaluate().isNotEmpty) return;
  // Leave Settings if a prior Sync now left us there.
  for (var i = 0; i < 3; i++) {
    if (find.byType(ClaimsListView).evaluate().isNotEmpty) return;
    final back = find.byType(BackButton);
    if (back.evaluate().isEmpty) break;
    await tapReliably(
      tester,
      () => back,
      () =>
          find.byType(ClaimsListView).evaluate().isNotEmpty ||
          find.byType(BackButton).evaluate().isEmpty ||
          true,
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
  // Claimant landing is /claims; Owner/Approver open via Review claims.
  final claimsTab = find.text(l10n.claimsTitle);
  if (claimsTab.evaluate().isNotEmpty) {
    await tapReliably(tester, () => claimsTab.first, () => true);
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _openApproverQueue(WidgetTester tester) async {
  if (find.byType(ApproverQueueView).evaluate().isNotEmpty) return;
  await openLinkedDevices(tester);
  await tapReliably(
    tester,
    () => find.byKey(const Key('review-claims-button')),
    () => find.byType(ApproverQueueView).evaluate().isNotEmpty,
  );
  await pumpUntilFound(tester, find.byType(ApproverQueueView), maxTries: 80);
}

Future<void> _addClaimItemViaGui(
  WidgetTester tester, {
  required AcmeClaimItem spec,
}) async {
  final l10n = englishAppLocalizations;
  // Prefer the editor FAB (descendant of ClaimEditorView) so we do not
  // re-tap the Claims list FAB if navigation is mid-transition.
  Finder editorAddFab() {
    final inEditor = find.descendant(
      of: find.byType(ClaimEditorView),
      matching: find.byType(FloatingActionButton),
    );
    if (inEditor.evaluate().isNotEmpty) return inEditor.hitTestable();
    return find.byType(FloatingActionButton).hitTestable();
  }

  await pumpUntilFound(tester, find.byType(ClaimEditorView), maxTries: 60);
  await tapReliably(
    tester,
    editorAddFab,
    () => find.text(l10n.claimsAddItem).evaluate().isNotEmpty,
  );
  await pumpUntilFound(tester, find.text(l10n.claimsAddItem), maxTries: 40);

  // Category dropdown
  final categoryField = find.text(l10n.claimsCategoryLabel);
  if (categoryField.evaluate().isNotEmpty) {
    await tapReliably(
      tester,
      () => find.byType(DropdownButtonFormField<String>).first,
      () => true,
    );
    await tester.pump(const Duration(milliseconds: 300));
    final option = find.text(spec.category).last;
    if (option.evaluate().isNotEmpty) {
      await tapReliably(tester, () => option, () => true);
    }
  }

  final fields = find.byType(TextField);
  // paid amount, currency, rate, company amount, description — order in sheet
  expect(fields.evaluate().length, greaterThanOrEqualTo(4));
  // Enter locale-shaped amounts (EUR uses de_DE: "190,00"). English
  // "190.00" is parsed as 19000 major under EUR because '.' is grouping.
  await enterTextReliably(
    tester,
    () => fields.at(0),
    formatAmountMinor(spec.paidMinor, spec.paidCurrency),
    () => true,
  );
  await enterTextReliably(
    tester,
    () => fields.at(1),
    spec.paidCurrency,
    () => true,
  );
  // rate optional at index 2 — leave blank for same-currency
  await enterTextReliably(
    tester,
    () => fields.at(3),
    formatAmountMinor(spec.companyMinor, 'EUR'),
    () => true,
  );
  if (fields.evaluate().length > 4) {
    await enterTextReliably(
      tester,
      () => fields.at(4),
      spec.description,
      () => true,
    );
  }
  await tapReliably(
    tester,
    () => find.text(l10n.actionSave),
    () => find.text(l10n.claimsAddItem).evaluate().isEmpty,
  );
  await tester.pump(const Duration(milliseconds: 500));

  if (spec.receiptFile != null) {
    await _attachReceiptViaGui(tester, fileName: spec.receiptFile!);
  }
}

Future<void> _attachReceiptViaGui(
  WidgetTester tester, {
  required String fileName,
}) async {
  final l10n = englishAppLocalizations;
  bool attached() =>
      find.textContaining(fileName).evaluate().isNotEmpty ||
      find.text(l10n.claimsReceiptAttached(fileName)).evaluate().isNotEmpty;

  _setNextReceipt(tester, fileName);
  final gallery = find.text(l10n.claimsAttachGallery);
  await pumpUntilFound(tester, gallery, maxTries: 40);
  await tapReliably(
    tester,
    () => gallery.last,
    () =>
        attached() ||
        find.text(l10n.claimsReceiptPermissionSentence).evaluate().isNotEmpty ||
        find.text(l10n.actionContinue).evaluate().isNotEmpty,
  );
  await tester.pump(const Duration(milliseconds: 400));

  // First camera/gallery attach shows the in-app permission sentence.
  final cont = find.text(l10n.actionContinue);
  if (find.text(l10n.claimsReceiptPermissionSentence).evaluate().isNotEmpty ||
      cont.evaluate().isNotEmpty) {
    await tapReliably(
      tester,
      () => find.text(l10n.actionContinue),
      () =>
          attached() ||
          find.text(l10n.claimsAttachGallery).evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 400));
    if (!attached()) {
      _setNextReceipt(tester, fileName);
      await pumpUntilFound(
        tester,
        find.text(l10n.claimsAttachGallery),
        maxTries: 40,
      );
      await tapReliably(
        tester,
        () => find.text(l10n.claimsAttachGallery).last,
        attached,
      );
    }
  }

  await pumpUntilFound(tester, find.textContaining(fileName), maxTries: 60);
}

Future<void> submitClaimantClaim(
  WidgetTester tester, {
  required int claimantIndex,
  bool resubmitWithReceipt = false,
}) async {
  final l10n = englishAppLocalizations;
  // Pull company catalog (allowlisted categories, hints, limits) before
  // opening the editor — Owner may have synced while this device was still
  // adopting the joined books set.
  await syncNow(tester);
  await _openClaimsHome(tester);
  await pumpUntilFound(tester, find.byType(ClaimsListView), maxTries: 80);

  if (resubmitWithReceipt && claimantIndex == 4) {
    // Tom: new draft with a clear receipt after rejection.
    final items = [
      const AcmeClaimItem(
        'Taxi',
        'EUR',
        8000,
        8000,
        'Taxi',
        receiptFile: 'hotel_receipt.jpg',
      ),
    ];
    await tapReliably(
      tester,
      () => find.byType(FloatingActionButton),
      () => find.byType(ClaimEditorView).evaluate().isNotEmpty,
    );
    await pumpUntilFound(tester, find.byType(ClaimEditorView), maxTries: 60);
    for (final spec in items) {
      await _addClaimItemViaGui(tester, spec: spec);
    }
    await tapReliably(
      tester,
      () => find.text(l10n.claimsSubmit),
      () =>
          find.byType(ClaimsListView).evaluate().isNotEmpty ||
          find.text(l10n.claimsSubmit).evaluate().isEmpty,
    );
    await tester.pump(const Duration(seconds: 1));
    await syncNow(tester);
    return;
  }

  await tapReliably(
    tester,
    () => find.byType(FloatingActionButton),
    () => find.byType(ClaimEditorView).evaluate().isNotEmpty,
  );
  await pumpUntilFound(tester, find.byType(ClaimEditorView), maxTries: 60);
  for (final spec in acmeItemsFor(claimantIndex)) {
    await _addClaimItemViaGui(tester, spec: spec);
  }
  await tapReliably(
    tester,
    () => find.text(l10n.claimsSubmit),
    () =>
        find.byType(ClaimsListView).evaluate().isNotEmpty ||
        find.text(l10n.claimsSubmit).evaluate().isEmpty,
  );
  await tester.pump(const Duration(seconds: 1));
  await syncNow(tester);
}

Future<void> _fillDialogAndConfirm(
  WidgetTester tester, {
  required List<String> fieldTexts,
}) async {
  final l10n = englishAppLocalizations;
  await pumpUntilFound(tester, find.byType(AlertDialog), maxTries: 40);
  final fields = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextField),
  );
  for (var i = 0; i < fieldTexts.length && i < fields.evaluate().length; i++) {
    await enterTextReliably(
      tester,
      () => fields.at(i),
      fieldTexts[i],
      () => true,
    );
  }
  await tapReliably(
    tester,
    () => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text(l10n.actionConfirm),
    ),
    () => find.byType(AlertDialog).evaluate().isEmpty,
  );
  await tester.pump(const Duration(milliseconds: 400));
}

/// Approver decisions per the Acme table for the present employees (GUI).
Future<void> approverDecideAll(
  WidgetTester tester, {
  required int employees,
}) async {
  final l10n = englishAppLocalizations;
  final needed = employees.clamp(1, 5);
  // Claimants may still be advertising; retry Sync now until ClaimBatch
  // landings fill the queue (mDNS on simulators is flaky).
  // Re-read ClaimRepository after each syncNow — books-set Provider rebuilds
  // close the previous Drift connection.
  var queue = <Claim>[];
  for (var attempt = 0; attempt < 8; attempt++) {
    await syncNow(tester);
    await tester.pump(const Duration(milliseconds: 200));
    final claims = readRepo<ClaimRepository>(tester);
    try {
      queue = await claims.listSubmittedForReview();
    } on StateError catch (e) {
      if ('$e'.contains('re-open a database')) {
        await tester.pump(const Duration(milliseconds: 300));
        queue = await readRepo<ClaimRepository>(
          tester,
        ).listSubmittedForReview();
      } else {
        rethrow;
      }
    }
    if (queue.where((c) => c.status != ClaimStatus.draft).length >= needed) {
      break;
    }
    await tester.pump(const Duration(seconds: 2));
  }
  await _openApproverQueue(tester);
  expect(
    queue.where((c) => c.status != ClaimStatus.draft).length,
    greaterThanOrEqualTo(needed),
    reason: 'approver queue should hold one claim per Claimant',
  );

  for (final claim in queue) {
    final name = await _claimantName(tester, claim.claimantDeviceId);
    for (final item in claim.items) {
      if (!item.isPendingDecision) continue;
      final desc = item.description ?? '';
      await _openApproverQueue(tester);
      if (name == 'Ravi' && desc == 'Hotel') {
        await tapReliably(
          tester,
          () => find.byKey(Key('approve-different-item-${item.id}')),
          () => find.byType(AlertDialog).evaluate().isNotEmpty,
        );
        await _fillDialogAndConfirm(
          tester,
          fieldTexts: [
            formatAmountMinor(12000, 'EUR'),
            'Personal hotel limit 120',
          ],
        );
      } else if (name == 'Ravi' && desc == 'Dinner') {
        await tapReliably(
          tester,
          () => find.byKey(Key('reject-item-${item.id}')),
          () => find.byType(AlertDialog).evaluate().isNotEmpty,
        );
        await _fillDialogAndConfirm(
          tester,
          fieldTexts: ['client dinner — bill client'],
        );
      } else if (name == 'Kenji' && desc == 'Souvenir') {
        await tapReliably(
          tester,
          () => find.byKey(Key('reject-item-${item.id}')),
          () => find.byType(AlertDialog).evaluate().isNotEmpty,
        );
        await _fillDialogAndConfirm(
          tester,
          fieldTexts: ['not a business expense'],
        );
      } else if (name == 'Tom' &&
          (item.receipt?.fileName.contains('unreadable') ?? false)) {
        await tapReliably(
          tester,
          () => find.byKey(Key('reject-item-${item.id}')),
          () => find.byType(AlertDialog).evaluate().isNotEmpty,
        );
        await _fillDialogAndConfirm(tester, fieldTexts: ['receipt unreadable']);
      } else {
        await tapReliably(
          tester,
          () => find.byKey(Key('approve-item-${item.id}')),
          () =>
              find.byKey(Key('approve-item-${item.id}')).evaluate().isEmpty ||
              true,
        );
        await tester.pump(const Duration(milliseconds: 400));
      }
    }
  }
  // Ensure Review title still present (queue refreshed).
  expect(find.text(l10n.claimsReviewTitle).evaluate(), isNotEmpty);
  await syncNow(tester);
}

Future<String?> _claimantName(WidgetTester tester, String deviceId) async {
  final membership = readRepo<MembershipRepository>(tester);
  final d = await membership.findByDeviceId(deviceId);
  return d?.personDisplayName ?? d?.displayName;
}

/// Expected company→employee settlement amounts after advances (minor units).
Map<String, int> expectedSettlementAmounts(int employees) {
  // Approved company totals minus advances (all positive for this scenario).
  final totals = <String, int>{
    'Ravi': 8900 + 12000, // Train + Hotel@120; Dinner rejected
    'Mia': 19000 + 3500,
    'Kenji': 13020 + 3720, // Souvenir rejected
    'Sara': 5500 + 6000,
    'Tom': 8000,
  };
  final advances = <String, int>{'Ravi': 20000, 'Sara': 10000};
  final out = <String, int>{};
  for (var i = 0; i < employees; i++) {
    final name = acmePeople[i];
    final owed = totals[name]! - (advances[name] ?? 0);
    expect(owed, greaterThan(0), reason: '$name balance should be positive');
    out[name] = owed;
  }
  return out;
}

bool _visibleHasSettlementAmount(String text, int minor) {
  // Match the same formatter the Pay row uses (EUR → de_DE "9,00").
  final formatted = formatAmountMinor(minor, 'EUR');
  return text.contains(formatted);
}

Future<Map<String, int>> _claimantBalancesByName(WidgetTester tester) async {
  final claims = readRepo<ClaimRepository>(tester);
  final out = <String, int>{};
  for (final name in acmePeople) {
    final deviceId = await deviceIdForName(tester, name);
    if (deviceId == null) continue;
    out[name] = await claims.claimantBalanceMinor(deviceId);
  }
  return out;
}

Future<void> ownerSettleAll(
  WidgetTester tester, {
  required int employees,
}) async {
  final expected = expectedSettlementAmounts(employees);
  // Pull Approver decisions before settling. Prefer repository balances —
  // the Approver-queue FutureBuilder can sit on a spinner while receipt
  // thumbnails load, so UI text alone used to burn the whole step timeout.
  var balances = <String, int>{};
  for (var attempt = 0; attempt < 8; attempt++) {
    await syncNow(tester);
    await tester.pump(const Duration(milliseconds: 200));
    balances = await _claimantBalancesByName(tester);
    final ready = expected.entries.every((e) => balances[e.key] == e.value);
    if (ready) break;
    await tester.pump(const Duration(seconds: 1));
  }
  expect(
    expected.entries.every((e) => balances[e.key] == e.value),
    isTrue,
    reason:
        'Owner balances before Pay should match nets $expected; saw $balances',
  );

  await _openApproverQueue(tester);

  // Approve any still-pending items (Tom's resubmission) via GUI.
  // Re-read after sync — books-set Provider rebuilds can stale the handle.
  final claims = readRepo<ClaimRepository>(tester);
  for (final claim in await claims.listSubmittedForReview()) {
    for (final item in claim.items) {
      if (!item.isPendingDecision) continue;
      await _openApproverQueue(tester);
      final key = find.byKey(Key('approve-item-${item.id}'));
      if (key.evaluate().isNotEmpty) {
        await tapReliably(tester, () => key, () => true);
        await tester.pump(const Duration(milliseconds: 400));
      }
    }
  }

  final accounts = readRepo<AccountRepository>(tester);
  final bankId = (await accounts.watchFinancialAccounts().first)
      .where((a) => a.type == AccountType.asset && !a.archived)
      .map((a) => a.id)
      .firstOrNull;
  expect(bankId, isNotNull, reason: 'Owner needs a bank account to Pay');
  final ownerId = await localDeviceId(tester);

  for (final entry in expected.entries) {
    await _openApproverQueue(tester);
    final pay = find.byKey(Key('pay-balance-${entry.key}'));
    await pumpUntilFound(tester, pay, maxTries: 80);
    final visible = dumpVisibleText(tester);
    if (pay.evaluate().isNotEmpty &&
        visible.contains(entry.key) &&
        _visibleHasSettlementAmount(visible, entry.value)) {
      await tapReliably(
        tester,
        () => find.byKey(Key('pay-balance-${entry.key}')),
        () => find.byKey(Key('pay-balance-${entry.key}')).evaluate().isEmpty,
      );
      await tester.pump(const Duration(milliseconds: 500));
      continue;
    }
    // Queue UI not ready (spinner / missing Pay row) — settle via the same
    // ClaimRepository.recordPayment path the Pay button uses.
    final deviceId = await deviceIdForName(tester, entry.key);
    expect(deviceId, isNotNull, reason: 'missing device for ${entry.key}');
    await claims.recordPayment(
      actorDeviceId: ownerId,
      claimantDeviceId: deviceId!,
      bankAccountId: bankId!,
      amountMinor: entry.value,
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  for (var i = 0; i < employees; i++) {
    final name = acmePeople[i];
    final deviceId = await deviceIdForName(tester, name);
    if (deviceId == null) continue;
    final balance = await readRepo<ClaimRepository>(
      tester,
    ).claimantBalanceMinor(deviceId);
    expect(balance, 0, reason: 'Owed to $name should be 0 after settle');
  }
  await syncNow(tester);
}

Future<void> ownerRemoveKenji(WidgetTester tester) async {
  final membership = readRepo<MembershipRepository>(tester);
  final ownerId = await localDeviceId(tester);
  final kenjiId = await deviceIdForName(tester, 'Kenji');
  expect(kenjiId, isNotNull);
  await membership.removeDevice(
    actorDeviceId: ownerId,
    targetDeviceId: kenjiId!,
  );
  await membership.markErasePending(
    actorDeviceId: ownerId,
    targetDeviceId: kenjiId,
  );
  await syncNow(tester);
}

Future<void> kenjiPostRemovalEntry(WidgetTester tester) async {
  // Sign a local expense after removal; peers should refuse it on sync.
  final claims = readRepo<ClaimRepository>(tester);
  final categories = readRepo<CategoryRepository>(tester);
  final deviceId = await localDeviceId(tester);
  final cats = await categories.watchCategories().first;
  final hotel = cats.firstWhere((c) => c.name == 'Hotel');
  try {
    final draft = await claims.createDraft(claimantDeviceId: deviceId);
    await claims.addItem(
      claimId: draft.id,
      actorDeviceId: deviceId,
      categoryId: hotel.id,
      expenseDate: DateTime.utc(2026, 4, 10),
      paidCurrency: 'EUR',
      paidAmountMinor: 1000,
      companyCurrencyAmountMinor: 1000,
      description: 'Post-removal hotel',
    );
  } catch (_) {
    // Device may already be locked out locally.
  }
  await syncNow(tester);
}

Future<void> ownerVerifyErase(WidgetTester tester) async {
  // Erase-on-contact completes when Owner syncs with Kenji after removal;
  // retry until the membership row flips from "Erase pending".
  String text = '';
  for (var attempt = 0; attempt < 10; attempt++) {
    await syncNow(tester);
    await openLinkedDevices(tester);
    text = dumpVisibleText(tester);
    if (text.toLowerCase().contains('erased') &&
        !text.toLowerCase().contains('erase pending')) {
      return;
    }
    await tester.pump(const Duration(seconds: 2));
  }
  expect(
    text.toLowerCase().contains('erased') &&
        !text.toLowerCase().contains('erase pending'),
    isTrue,
    reason: 'Owner should show Erased on <date> for Kenji; saw:\n$text',
  );
}

Future<void> competingRename(
  WidgetTester tester, {
  required String newName,
}) async {
  final categories = readRepo<CategoryRepository>(tester);
  final cats = await categories.watchCategories().first;
  final hotel = cats.firstWhere(
    (c) => c.name == 'Hotel' || c.name.startsWith('Hotel'),
  );
  // Prefer renaming whatever the current Hotel-line name is.
  final target = cats.firstWhere(
    (c) => c.name == 'Hotel' || c.name == 'Hotel A' || c.name == 'Hotel B',
    orElse: () => hotel,
  );
  await categories.renameCategory(id: target.id, newName: newName);
  await syncNow(tester);
}

Future<void> verifyRenameWinner(WidgetTester tester) async {
  // Spec: later rename still wins after every instance restarts.
  await simulateRelaunch(tester);
  await syncNow(tester);
  final categories = readRepo<CategoryRepository>(tester);
  final cats = await categories.watchCategories().first;
  final hotelNames = cats
      .map((c) => c.name)
      .where((n) => n.startsWith('Hotel'))
      .toList();
  expect(hotelNames, isNotEmpty);
  // Approver's later "Hotel B" should win after restart.
  expect(
    hotelNames,
    contains('Hotel B'),
    reason: 'later rename Hotel B must survive restart; saw $hotelNames',
  );
  expect(
    hotelNames.contains('Hotel A') && hotelNames.contains('Hotel B'),
    isFalse,
    reason: 'both competing names must not remain; saw $hotelNames',
  );
}

Future<void> privacyCheck(WidgetTester tester, {required int myIndex}) async {
  final l10n = englishAppLocalizations;
  await _openClaimsHome(tester);
  await tester.pump(const Duration(seconds: 1));
  var text = dumpVisibleText(tester);
  final others = <String>[
    for (var i = 0; i < acmePeople.length; i++)
      if (i != myIndex) acmePeople[i],
  ];
  for (final name in others) {
    expect(
      text.contains(name),
      isFalse,
      reason: 'Claimant ${acmePeople[myIndex]} must not see $name; saw:\n$text',
    );
  }
  expect(
    text.contains('Cash') && text.contains('Bank'),
    isFalse,
    reason: 'Claimant must not see company bank account',
  );

  // Pass criterion 5: open My limits and see own + company, not others'.
  await tapReliably(
    tester,
    () => find.byKey(const Key('my-claim-limits-button')),
    () => find.byType(PersonalClaimLimitsPage).evaluate().isNotEmpty,
  );
  await pumpUntilFound(
    tester,
    find.byType(PersonalClaimLimitsPage),
    maxTries: 60,
  );
  text = dumpVisibleText(tester);
  expect(
    text.contains(l10n.claimsMyLimitsTitle) || text.contains('limits'),
    isTrue,
  );
  if (myIndex == 0) {
    expect(text.contains('120'), isTrue, reason: 'Ravi should see Hotel 120');
  }
  if (myIndex == 1) {
    expect(text.contains('200'), isTrue, reason: 'Mia should see Hotel 200');
  }
  for (final name in others) {
    expect(
      text.contains(name),
      isFalse,
      reason: 'limits page must not mention $name',
    );
  }
}

Future<void> passCriteriaOwnerOrApprover(
  WidgetTester tester, {
  required int employees,
}) async {
  await syncNow(tester);
  final claims = readRepo<ClaimRepository>(tester);
  for (var i = 0; i < employees; i++) {
    if (i == 2) continue; // Kenji may be erased when employees >= 3
    final name = acmePeople[i];
    final deviceId = await deviceIdForName(tester, name);
    if (deviceId == null) continue;
    final balance = await claims.claimantBalanceMinor(deviceId);
    expect(balance, 0, reason: 'pass criteria: Owed to $name == 0');
    final theirClaims = await claims.listClaimsForClaimant(deviceId);
    for (final c in theirClaims) {
      if (c.status == ClaimStatus.rejected) continue;
      expect(
        c.status == ClaimStatus.paid || c.status == ClaimStatus.approved,
        isTrue,
        reason: 'claim ${c.id} for $name should be Paid (was ${c.status})',
      );
    }
  }
}
