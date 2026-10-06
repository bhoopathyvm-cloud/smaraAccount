import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/claims/views/claims_list_view.dart';
import 'package:smara_accounting/ui/features/settings/views/join_code_entry_panel.dart';
import 'package:smara_accounting/ui/features/settings/views/join_qr_offer_panel.dart';
import 'package:smara_accounting/ui/features/setup_choice/views/setup_choice_view.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../acceptance/support/acceptance_harness.dart';
import 'acme_actions.dart';
import 'artifacts.dart';
import 'conductor_client.dart';
import 'household_actions.dart';
import 'visible_text.dart';

/// Role runner for the company sync acceptance suite (task 7.2 / 8.x).
///
/// Launch with:
/// ```
/// flutter test integration_test/company_sync/company_sync_test.dart \
///   -d <device> \
///   --dart-define=COMPANY_SYNC_ROLE=owner \
///   --dart-define=COMPANY_SYNC_CONDUCTOR=http://127.0.0.1:PORT \
///   --dart-define=COMPANY_SYNC_TEST=true \
///   --dart-define=COMPANY_SYNC_ARTIFACTS=build/company_sync/<ts>
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const role = String.fromEnvironment('COMPANY_SYNC_ROLE', defaultValue: '');
  const conductorUrl = String.fromEnvironment(
    'COMPANY_SYNC_CONDUCTOR',
    defaultValue: '',
  );
  const artifactsPath = String.fromEnvironment(
    'COMPANY_SYNC_ARTIFACTS',
    defaultValue: '',
  );
  const dryRun = bool.fromEnvironment('COMPANY_SYNC_DRY_RUN');
  const employees = int.fromEnvironment(
    'COMPANY_SYNC_EMPLOYEES',
    defaultValue: 2,
  );

  testWidgets('company_sync role runner ($role)', (tester) async {
    expect(role, isNotEmpty, reason: 'COMPANY_SYNC_ROLE is required');
    expect(
      conductorUrl,
      isNotEmpty,
      reason: 'COMPANY_SYNC_CONDUCTOR is required',
    );

    final client = CompanySyncConductorClient(baseUrl: conductorUrl);
    final artifactRoot = await CompanySyncArtifacts.resolveWritableRoot(
      artifactsPath,
    );
    final artifacts = CompanySyncArtifacts(
      role: role,
      root: artifactRoot,
      binding: binding,
    );
    await artifacts.ensureReady();
    await client.reportReady(role: role, device: Platform.localHostname);

    try {
      await artifacts.writeLog('startup', 'resetToFreshDevice start');
      await resetToFreshDevice(tester);
      await artifacts.writeLog('startup', 'resetToFreshDevice done');
      // Named up front so Linked devices doesn't stop to ask, and so peers
      // list each role by name.
      await SettingsRepository().setLocalDeviceDisplayName('Smara $role');
      await _runRole(
        tester: tester,
        client: client,
        artifacts: artifacts,
        role: role,
        dryRun: dryRun,
        employees: employees,
      );
    } catch (e, st) {
      final text = dumpVisibleText(tester);
      await artifacts.writeVisibleText('fatal', text);
      await artifacts.writeLog('fatal', '$e\n$st');
      await artifacts.takeScreenshot('fatal');
      try {
        await client.reportFailed('fatal', error: e, visibleText: text);
      } catch (_) {}
      rethrow;
    } finally {
      client.close();
    }
  }, timeout: Timeout(Duration(minutes: dryRun ? 15 : 45)));
}

Future<void> _runRole({
  required WidgetTester tester,
  required CompanySyncConductorClient client,
  required CompanySyncArtifacts artifacts,
  required String role,
  required bool dryRun,
  required int employees,
}) async {
  companySyncConductor = client;
  companySyncRole = role;
  companySyncEmployees = employees;
  installSyncDebugLogger(role);
  final steps = _stepsForRole(role, dryRun: dryRun, employees: employees);
  for (final stepId in steps) {
    await artifacts.writeLog(stepId, 'awaiting permission');
    await client.awaitPermission(stepId);
    await artifacts.writeLog(stepId, 'start');
    try {
      await _executeStep(
        tester: tester,
        client: client,
        stepId: stepId,
        role: role,
        dryRun: dryRun,
        employees: employees,
      );
      final text = dumpVisibleText(tester);
      await artifacts.writeVisibleText(stepId, text);
      await artifacts.takeScreenshot(stepId);
      await client.reportDone(stepId, visibleText: text);
      await artifacts.writeLog(stepId, 'done');
    } catch (e, st) {
      final text = dumpVisibleText(tester);
      await artifacts.writeVisibleText(stepId, text);
      await artifacts.writeLog(stepId, 'failed: $e\n$st');
      await artifacts.takeScreenshot(stepId);
      await client.reportFailed(stepId, error: e, visibleText: text);
      rethrow;
    }
  }
}

List<String> _stepsForRole(
  String role, {
  required bool dryRun,
  required int employees,
}) {
  if (const bool.fromEnvironment('COMPANY_SYNC_PAIR')) {
    // One phone hosts (owner), the other joins (claimant_0); see
    // pairScenario in tool/company_sync/scenario.dart.
    return switch (role) {
      'owner' => [
        'owner.ready',
        'owner.hh_create_books',
        'owner.hh_offer_0',
        'owner.hh_confirm_0',
        'owner.hh_record',
        'owner.hh_verify_entries',
        'owner.hh_compare_balances',
        'owner.hh_rename',
        'owner.hh_verify_rename',
        'owner.pair_remove',
        'owner.hh_verify_erase',
      ],
      'claimant_0' => [
        'claimant_0.ready',
        'claimant_0.join',
        'claimant_0.hh_record',
        'claimant_0.hh_verify_entries',
        'claimant_0.hh_rename',
        'claimant_0.hh_verify_rename',
        'claimant_0.pair_await_erase',
      ],
      _ => fail('pair run supports owner and claimant_0: $role'),
    };
  }
  if (const bool.fromEnvironment('COMPANY_SYNC_HOUSEHOLD')) {
    return switch (role) {
      'owner' => [
        'owner.ready',
        'owner.hh_create_books',
        'owner.hh_offer_0',
        'owner.hh_confirm_0',
        'owner.hh_offer_1',
        'owner.hh_confirm_1',
        'owner.hh_record',
        'owner.hh_verify_entries',
        'owner.hh_compare_balances',
        'owner.hh_rename',
        'owner.hh_verify_rename',
        'owner.hh_remove_1',
        'owner.hh_verify_erase',
        'owner.hh_final',
      ],
      'claimant_0' => [
        'claimant_0.ready',
        'claimant_0.join',
        'claimant_0.hh_record',
        'claimant_0.hh_verify_entries',
        'claimant_0.hh_rename',
        'claimant_0.hh_verify_rename',
        'claimant_0.hh_after_removal',
      ],
      'claimant_1' => [
        'claimant_1.ready',
        'claimant_1.join',
        'claimant_1.hh_record',
        'claimant_1.hh_verify_entries',
        'claimant_1.hh_verify_rename',
        'claimant_1.hh_await_erase',
      ],
      _ => fail('household run supports owner, claimant_0, claimant_1: $role'),
    };
  }
  if (dryRun) {
    return switch (role) {
      'owner' => [
        'owner.ready',
        'owner.create_company',
        'owner.publish_join',
        'owner.confirm_claimant_0',
        'owner.verify_sync',
      ],
      'claimant_0' => [
        'claimant_0.ready',
        'claimant_0.join',
        'claimant_0.submit',
      ],
      _ => fail('dry run only supports owner and claimant_0, got $role'),
    };
  }

  if (role == 'owner') {
    return [
      'owner.ready',
      'owner.create_company',
      'owner.configure_limits',
      'owner.confirm_approver',
      for (var i = 0; i < employees; i++) 'owner.confirm_claimant_$i',
      'owner.set_personal_limits',
      'owner.settle',
      if (employees >= 3) 'owner.remove_kenji',
      if (employees >= 3) 'owner.verify_erase',
      'owner.competing_rename',
      'all.verify_rename',
      'owner.pass_criteria',
    ];
  }
  if (role == 'approver') {
    return [
      'approver.ready',
      'approver.join',
      'approver.decide',
      'approver.competing_rename',
      'approver.pass_criteria',
    ];
  }
  final match = RegExp(r'^claimant_(\d+)$').firstMatch(role);
  if (match != null) {
    final i = int.parse(match.group(1)!);
    return [
      'claimant_$i.ready',
      'claimant_$i.join',
      'claimant_$i.submit',
      if (i == 4 && employees >= 5) 'claimant_4.reopen',
      if (i == 2 && employees >= 3) 'claimant_2.post_removal_entry',
      'claimant_$i.privacy_check',
    ];
  }
  fail('unknown COMPANY_SYNC_ROLE: $role');
}

Future<void> _executeStep({
  required WidgetTester tester,
  required CompanySyncConductorClient client,
  required String stepId,
  required String role,
  required bool dryRun,
  required int employees,
}) async {
  switch (stepId) {
    case 'owner.ready':
    case 'approver.ready':
    case final ready when ready.endsWith('.ready'):
      await client.putValue(
        '${role}_defines',
        'COMPANY_SYNC_TEST=${const bool.fromEnvironment('COMPANY_SYNC_TEST')}'
            ';CONDUCTOR=${const String.fromEnvironment('COMPANY_SYNC_CONDUCTOR')}'
            ';ARTIFACTS=${const String.fromEnvironment('COMPANY_SYNC_ARTIFACTS')}',
      );
      return;

    case 'owner.hh_create_books':
      await householdCreateBooks(tester, client);
      return;
    case 'owner.hh_offer_0':
    case 'owner.hh_offer_1':
      await householdOfferDevice(
        tester,
        client,
        peerRole: 'claimant_${stepId.substring(stepId.length - 1)}',
      );
      return;
    case 'owner.hh_confirm_0':
    case 'owner.hh_confirm_1':
      await ownerConfirmCheckCode(
        tester: tester,
        client: client,
        peerKey: 'check_code_claimant_${stepId.substring(stepId.length - 1)}',
      );
      await publishSyncEndpoint(tester, client, role: role);
      return;
    case final s when s.endsWith('.hh_record'):
      await householdRecord(tester, role: role);
      return;
    case final s when s.endsWith('.hh_verify_entries'):
      await householdVerifyEntries(tester, client, role: role);
      return;
    case 'owner.hh_compare_balances':
      await householdCompareBalances(client);
      return;
    case 'owner.hh_rename':
      await householdRename(tester, newName: householdRenameFirst);
      return;
    case 'claimant_0.hh_rename':
      await householdRename(tester, newName: householdRenameLater);
      return;
    case final s when s.endsWith('.hh_verify_rename'):
      await householdVerifyRename(tester);
      return;
    case 'owner.hh_remove_1':
      await householdRemovePhoneB(tester, client);
      return;
    case 'owner.pair_remove':
      await householdRemovePhoneB(tester, client, peerRole: 'claimant_0');
      return;
    case 'claimant_0.pair_await_erase':
      await householdAwaitErase(tester, client);
      return;
    case 'claimant_1.hh_await_erase':
      await householdAwaitErase(tester, client);
      return;
    case 'owner.hh_verify_erase':
      await householdVerifyErase(tester, client);
      return;
    case 'claimant_0.hh_after_removal':
      await householdAfterRemoval(tester);
      return;
    case 'owner.hh_final':
      await householdFinal(tester);
      return;

    case 'owner.create_company':
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '10.00',
        categoryName: englishAppLocalizations.systemCategorySalary,
        currencyCode: dryRun ? 'USD' : 'EUR',
      );
      await publishSyncEndpoint(tester, client, role: role);
      return;

    case 'owner.publish_join':
      // Dry-run: Add a device (not a person).
      await openLinkedDevices(tester);
      await dismissPermissionIfNeeded(tester);
      await tapReliably(
        tester,
        () => find.text(englishAppLocalizations.settingsLinkedDevicesAddDevice),
        () => find.byType(JoinQrOfferPanel).evaluate().isNotEmpty,
      );
      await pumpUntilFound(tester, find.byType(JoinQrOfferPanel));
      final codeFinder = find.byKey(const Key('join-code-display'));
      await pumpUntilFound(tester, codeFinder, maxTries: 50);
      final code = (codeFinder.evaluate().single.widget as Text).data!;
      await _publishJoinOfferToConductor(
        tester,
        client,
        peerRole: 'claimant_0',
      );
      await client.putValue('join_code_claimant_0', code);
      await client.putValue('join_code', code);
      return;

    case 'owner.configure_limits':
      await configureAcmeCompany(tester);
      return;

    case 'owner.confirm_approver':
      await ownerStartAddPerson(
        tester: tester,
        client: client,
        personName: 'Priya',
        role: LinkedDeviceRole.approver,
        peerRole: 'approver',
      );
      await ownerConfirmCheckCode(
        tester: tester,
        client: client,
        peerKey: 'check_code_approver',
      );
      await publishSyncEndpoint(tester, client, role: role);
      return;

    case 'owner.confirm_claimant_0':
    case 'owner.confirm_claimant_1':
    case 'owner.confirm_claimant_2':
    case 'owner.confirm_claimant_3':
    case 'owner.confirm_claimant_4':
      if (dryRun) {
        await ownerConfirmCheckCode(
          tester: tester,
          client: client,
          peerKey: 'check_code_claimant_0',
        );
        return;
      }
      final index = int.parse(
        stepId.replaceFirst('owner.confirm_claimant_', ''),
      );
      await ownerStartAddPerson(
        tester: tester,
        client: client,
        personName: acmePeople[index],
        role: LinkedDeviceRole.claimant,
        peerRole: 'claimant_$index',
      );
      await ownerConfirmCheckCode(
        tester: tester,
        client: client,
        peerKey: 'check_code_claimant_$index',
      );
      await publishSyncEndpoint(tester, client, role: role);
      return;

    case 'owner.verify_sync':
      await client.waitValue('claimant_0.entry_description');
      await syncNow(tester);
      return;

    case 'owner.set_personal_limits':
      await setPersonalLimitsAndAdvances(tester, employees: employees);
      await syncNow(tester);
      return;

    case final join when join.endsWith('.join'):
      await _joinByCode(tester, client, role: role);
      // After adopting company books, advertise a direct sync endpoint so
      // ClaimBatch can flow Claimant ↔ Owner ↔ Approver without mDNS.
      await publishSyncEndpoint(tester, client, role: role);
      return;

    case 'claimant_0.submit':
      if (dryRun) {
        await _recordSimpleExpense(tester, description: 'Taxi dry-run');
        await client.putValue('claimant_0.entry_description', 'Taxi dry-run');
        await syncNow(tester);
        return;
      }
      await submitClaimantClaim(tester, claimantIndex: 0);
      return;

    case final submit when submit.endsWith('.submit'):
      final i = int.parse(role.replaceFirst('claimant_', ''));
      await submitClaimantClaim(tester, claimantIndex: i);
      return;

    case 'approver.decide':
      await approverDecideAll(tester, employees: employees);
      return;

    case 'claimant_4.reopen':
      // Offline during decide: on reopen, sync decisions + resubmit with receipt.
      await syncNow(tester);
      await submitClaimantClaim(
        tester,
        claimantIndex: 4,
        resubmitWithReceipt: true,
      );
      // Approver must approve Tom's resubmission — relay for Owner settle.
      await client.putValue('tom_resubmitted', 'true');
      return;

    case 'owner.settle':
      if (employees >= 5) {
        await client.waitValue('tom_resubmitted');
        // Approver may still need to approve Tom's resubmit; Owner syncs first.
        await syncNow(tester);
      }
      await ownerSettleAll(tester, employees: employees);
      return;

    case 'owner.remove_kenji':
      await ownerRemoveKenji(tester);
      return;

    case 'claimant_2.post_removal_entry':
      await kenjiPostRemovalEntry(tester);
      return;

    case 'owner.verify_erase':
      await ownerVerifyErase(tester);
      return;

    case 'owner.competing_rename':
      await competingRename(tester, newName: 'Hotel A');
      await client.putValue('owner_rename_done', 'Hotel A');
      return;

    case 'approver.competing_rename':
      await client.waitValue('owner_rename_done');
      await tester.pump(const Duration(milliseconds: 500));
      await competingRename(tester, newName: 'Hotel B');
      return;

    case 'all.verify_rename':
      await verifyRenameWinner(tester);
      return;

    case final privacy when privacy.endsWith('.privacy_check'):
      final i = int.parse(role.replaceFirst('claimant_', ''));
      await privacyCheck(tester, myIndex: i);
      return;

    case 'owner.pass_criteria':
    case 'approver.pass_criteria':
      await passCriteriaOwnerOrApprover(tester, employees: employees);
      return;

    default:
      fail('unimplemented step $stepId for role $role');
  }
}

Future<void> _publishJoinOfferToConductor(
  WidgetTester tester,
  CompanySyncConductorClient client, {
  String? peerRole,
}) async {
  await publishJoinOfferToConductor(tester, client, peerRole: peerRole);
}

Future<void> _joinByCode(
  WidgetTester tester,
  CompanySyncConductorClient client, {
  required String role,
}) async {
  final l10n = englishAppLocalizations;
  final onHome = find.byTooltip(l10n.settingsTitle).evaluate().isNotEmpty;
  if (!onHome || find.byType(SetupChoiceView).evaluate().isNotEmpty) {
    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1.00',
      categoryName: l10n.systemCategorySalary,
      currencyCode: 'EUR',
    );
  }
  await openLinkedDevices(tester);
  final enterCode = find.text(l10n.settingsLinkedDevicesEnterCodeInstead);
  // Code entry sits under "More ways to connect".
  final moreWays = find.byKey(const Key('linked-devices-more-ways'));
  await scrollSettingsUntilVisible(tester, moreWays);
  await tapReliably(
    tester,
    () => moreWays,
    () => enterCode.evaluate().isNotEmpty,
  );
  await scrollSettingsUntilVisible(tester, enterCode);
  await tapReliably(
    tester,
    () => enterCode,
    () =>
        find.byType(JoinCodeEntryPanel).evaluate().isNotEmpty ||
        find
            .text(l10n.settingsLinkedDevicesEnterCodeTitle)
            .evaluate()
            .isNotEmpty,
  );
  // Per-role keys avoid racing Priya's offer against Ravi/Mia (global
  // join_code/join_offer were overwritten mid-lookup).
  final code = await client.waitValue(
    'join_code_$role',
    timeout: const Duration(minutes: 3),
  );
  final offerJson = await client.waitValue(
    'join_offer_$role',
    timeout: const Duration(minutes: 3),
  );
  expect(offerJson, isNotEmpty, reason: 'owner must relay join_offer_$role');
  // Also publish onto the generic keys AppJoinCodeLookup reads from the
  // conductor (fixed discovery) so this peer's offer wins before submit.
  await client.putValue('join_offer', offerJson);
  await enterTextReliably(
    tester,
    () => find.byKey(const Key('join-code-entry-field')),
    code.replaceAll('-', ''),
    () {
      final fields = find.byKey(const Key('join-code-entry-field')).evaluate();
      if (fields.isEmpty) return false;
      final field = fields.single.widget as TextField;
      final text = field.controller?.text ?? '';
      return text.replaceAll('-', '').toUpperCase() ==
          code.replaceAll('-', '').toUpperCase();
    },
  );
  final submit = find.byKey(const Key('join-code-entry-submit'));
  // Lookup may try several hosts (connect + frame timeouts); allow ~45s.
  await tapReliably(
    tester,
    () => submit,
    () =>
        find
            .text(l10n.settingsLinkedDevicesConfirmCheckCodeTitle)
            .evaluate()
            .isNotEmpty ||
        find.byKey(const Key('join-code-entry-error')).evaluate().isNotEmpty,
    maxAttempts: 2,
    innerTries: 250,
  );
  final error = find.byKey(const Key('join-code-entry-error'));
  if (error.evaluate().isNotEmpty) {
    final msg = (error.evaluate().single.widget as Text).data ?? 'join failed';
    // Drain a moment so AppJoinCodeLookup can POST diagnostics.
    await tester.pump(const Duration(milliseconds: 500));
    final source = await client.getValue('join_lookup_source');
    final result = await client.getValue('join_lookup_result');
    final errors = await client.getValue('join_lookup_errors');
    final offer = await client.getValue('join_offer');
    fail(
      'join-by-code lookup failed: $msg '
      '(source=$source result=$result errors=$errors offer=$offer)',
    );
  }
  final match = find.text(l10n.settingsLinkedDevicesCodesMatch);
  await pumpUntilFound(tester, match, maxTries: 120);
  expect(
    match.evaluate(),
    isNotEmpty,
    reason: 'expected check-code confirm after successful join lookup',
  );
  final digits = find.byWidgetPredicate((w) {
    if (w is! Text) return false;
    return RegExp(r'^\d{6}$').hasMatch(w.data ?? '');
  });
  await pumpUntilFound(tester, digits, maxTries: 40);
  expect(digits.evaluate(), isNotEmpty, reason: 'expected 6-digit check code');
  final check = (digits.evaluate().first.widget as Text).data!;
  await client.putValue('check_code_$role', check);
  await client.waitValue('check_code_owner_for_check_code_$role');
  await tapReliably(tester, () => match, () => match.evaluate().isEmpty);
  // confirmJoinCodeMatch opens the joined books set after the dialog closes.
  // Pump so ProxyProviders rebuild against the new AppDatabase before Sync.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  if (role.startsWith('claimant')) {
    await pumpUntilFound(tester, find.byType(ClaimsListView), maxTries: 200);
  } else {
    // Approver / Add-a-device: Claims, Home, or Settings with books switcher.
    for (var i = 0; i < 200; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      final onClaims = find.byType(ClaimsListView).evaluate().isNotEmpty;
      final onHome = find.byTooltip(l10n.settingsTitle).evaluate().isNotEmpty;
      final linkedGone = find
          .text(l10n.settingsLinkedDevices)
          .evaluate()
          .isEmpty;
      final switcher = find
          .text(l10n.settingsBooksSwitcher)
          .evaluate()
          .isNotEmpty;
      if (onClaims || (onHome && linkedGone) || switcher) break;
    }
  }
  await tester.pump(const Duration(milliseconds: 200));
  await syncNow(tester);
}

Future<void> _recordSimpleExpense(
  WidgetTester tester, {
  required String description,
}) async {
  final l10n = englishAppLocalizations;
  await goHome(tester);
  final record = find.byIcon(TablerIcons.plus);
  if (record.evaluate().isNotEmpty) {
    await tapReliably(tester, () => record.first, () => true);
    await tester.pump(const Duration(seconds: 1));
  }
  final amount = find.byType(TextField);
  if (amount.evaluate().isNotEmpty) {
    await enterTextReliably(tester, () => amount.first, '25.00', () => true);
  }
  if (amount.evaluate().length > 1) {
    await enterTextReliably(
      tester,
      () => amount.at(1),
      description,
      () => true,
    );
  }
  final save = find.text(l10n.actionSave);
  if (save.evaluate().isNotEmpty) {
    await tapReliably(tester, () => save, () => true);
    await tester.pump(const Duration(seconds: 1));
  }
}
