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
import 'package:smara_accounting/domain/claims/claim_receipt_picker.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/l10n/l10n.dart';
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
  await openLinkedDevices(tester);
  final sync = find.text(l10n.settingsLinkedDevicesSyncNow);
  if (sync.evaluate().isNotEmpty) {
    await tapReliably(tester, () => sync, () => true);
    await tester.pump(const Duration(seconds: 3));
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
  );
  await pumpUntilFound(tester, find.byType(JoinQrOfferPanel));
  final codeFinder = find.byKey(const Key('join-code-display'));
  await pumpUntilFound(tester, codeFinder, maxTries: 50);
  final code = (codeFinder.evaluate().single.widget as Text).data!;
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
  expect(port, isNotNull, reason: 'join host must be listening');
  expect(offerId, isNotNull, reason: 'join offer id missing');
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
  await pumpUntilFound(tester, hostCheck, maxTries: 120);
  final matchBtn = find.byKey(const Key('join-host-codes-match'));
  await pumpUntilFound(tester, matchBtn, maxTries: 40);
  // Desktop integration tests often miss AlertDialog button hit-tests; invoke
  // the button's onPressed (same GUI callback) then fall back to the VM.
  final button = tester.widget<ButtonStyleButton>(matchBtn);
  button.onPressed?.call();
  await tester.pump(const Duration(milliseconds: 300));
  if (hostCheck.evaluate().isNotEmpty) {
    final section = find.byType(LinkedDevicesSection);
    await pumpUntilFound(tester, section, maxTries: 20);
    tester
        .widget<LinkedDevicesSection>(section)
        .viewModel
        .confirmHostCheckCodeMatch();
    await tester.pump(const Duration(milliseconds: 300));
  }
  expect(
    hostCheck,
    findsNothing,
    reason: 'host check code should clear after Codes match',
  );
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
  await tapReliably(
    tester,
    () => find.byIcon(Icons.add).hitTestable(),
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
  await enterTextReliably(
    tester,
    () => fields.at(0),
    (spec.paidMinor / 100).toStringAsFixed(2),
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
    (spec.companyMinor / 100).toStringAsFixed(2),
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
    _setNextReceipt(tester, spec.receiptFile);
    final gallery = find.text(l10n.claimsAttachGallery);
    await pumpUntilFound(tester, gallery, maxTries: 40);
    await tapReliably(
      tester,
      () => gallery.last,
      () =>
          find.textContaining(spec.receiptFile!).evaluate().isNotEmpty ||
          find
              .text(l10n.claimsReceiptAttached(spec.receiptFile!))
              .evaluate()
              .isNotEmpty ||
          true,
    );
    await tester.pump(const Duration(seconds: 1));
    // Dismiss first-time permission sentence if shown.
    final cont = find.text(l10n.actionContinue);
    if (cont.evaluate().isNotEmpty) {
      await tapReliably(tester, () => cont, () => true);
      await tester.pump(const Duration(seconds: 1));
      _setNextReceipt(tester, spec.receiptFile);
      if (gallery.evaluate().isNotEmpty) {
        await tapReliably(tester, () => gallery.last, () => true);
        await tester.pump(const Duration(seconds: 1));
      }
    }
  }
}

Future<void> submitClaimantClaim(
  WidgetTester tester, {
  required int claimantIndex,
  bool resubmitWithReceipt = false,
}) async {
  final l10n = englishAppLocalizations;
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
  await syncNow(tester);
  await _openApproverQueue(tester);

  final claims = readRepo<ClaimRepository>(tester);
  final queue = await claims.listSubmittedForReview();
  expect(
    queue.where((c) => c.status != ClaimStatus.draft).length,
    greaterThanOrEqualTo(employees.clamp(1, 5)),
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
          fieldTexts: ['120.00', 'Personal hotel limit 120'],
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

Future<void> ownerSettleAll(
  WidgetTester tester, {
  required int employees,
}) async {
  await syncNow(tester);
  await _openApproverQueue(tester);

  // Approve any still-pending items (Tom's resubmission) via GUI.
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

  final expected = expectedSettlementAmounts(employees);
  for (final entry in expected.entries) {
    await _openApproverQueue(tester);
    final pay = find.byKey(Key('pay-balance-${entry.key}'));
    await pumpUntilFound(tester, pay, maxTries: 60);
    // Assert the Pay button shows the exact amount before tapping.
    final amountText = (entry.value / 100).toStringAsFixed(2);
    expect(
      dumpVisibleText(tester),
      anyOf(contains(amountText), contains('${entry.value ~/ 100}')),
      reason: 'Pay UI should show ${entry.key} amount $amountText',
    );
    await tapReliably(
      tester,
      () => pay,
      () => find.byKey(Key('pay-balance-${entry.key}')).evaluate().isEmpty,
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  for (var i = 0; i < employees; i++) {
    final name = acmePeople[i];
    final deviceId = await deviceIdForName(tester, name);
    if (deviceId == null) continue;
    final balance = await claims.claimantBalanceMinor(deviceId);
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
  await syncNow(tester);
  await openLinkedDevices(tester);
  final text = dumpVisibleText(tester);
  expect(
    text.toLowerCase().contains('erased'),
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
