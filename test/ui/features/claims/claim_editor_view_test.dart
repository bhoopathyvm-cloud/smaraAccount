import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/claim_person_service.dart';
import 'package:smara_accounting/data/repositories/claim_receipt_store.dart';
import 'package:smara_accounting/data/repositories/claim_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/domain/claims/claim_receipt_picker.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/account_type.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/claims/view_models/claim_editor_view_model.dart';
import 'package:smara_accounting/ui/features/claims/views/claim_editor_view.dart';

import '../../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late ClaimRepository claims;
  late ClaimReceiptStore receipts;
  late FakeClaimReceiptPicker picker;
  late SettingsRepository settings;
  late Directory tempDir;
  late String travelCategoryId;
  late String travelCategoryName;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tempDir = await Directory.systemTemp.createTemp('claim-editor-');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    final ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    final categories = CategoryRepository(database: db);
    final identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    final membership = MembershipRepository(
      database: db,
      identityRepository: identity,
    );
    final people = ClaimPersonService(
      membership: membership,
      accounts: accounts,
      database: db,
    );
    receipts = ClaimReceiptStore(
      database: db,
      booksSetId: 'test-books',
      supportDirectory: tempDir,
    );
    claims = ClaimRepository(
      database: db,
      membership: membership,
      ledger: ledger,
      receipts: receipts,
    );
    settings = SettingsRepository();
    picker = FakeClaimReceiptPicker();

    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
    await membership.ensureLocalOwner(
      localDeviceId: 'owner-device',
      displayName: 'Office',
    );
    await (db.update(
      db.linkedDevices,
    )..where((t) => t.deviceId.equals('owner-device'))).write(
      LinkedDevicesCompanion(
        rolesCsv: Value(
          MembershipRoleGates.encodeRoles({
            LinkedDeviceRole.owner,
            LinkedDeviceRole.approver,
          }),
        ),
      ),
    );

    final cats = await categories.watchCategories().first;
    final travel = cats.firstWhere((c) => c.type == AccountType.expense);
    travelCategoryId = travel.id;
    travelCategoryName = travel.name;
    await claims.setAllowlistedCategories({travelCategoryId});
    await db
        .into(db.booksSetMetadata)
        .insert(
          BooksSetMetadataCompanion.insert(
            id: 'test-books',
            displayName: 'Acme',
          ),
        );

    final peer = await identity.addLinkedPeerIdentity(
      publicKey: List<int>.generate(32, (i) => i + 10),
    );
    final owed = await people.ensureOwedToAccount(
      displayName: 'Ravi',
      currency: 'USD',
    );
    await membership.addDevice(
      actorDeviceId: 'owner-device',
      deviceId: 'ravi-device',
      displayName: 'Ravi phone',
      signingIdentityId: peer.identityId,
      deviceCertFingerprint: 'fp-ravi',
      roles: {LinkedDeviceRole.claimant},
      owedToAccountId: owed.id,
      personDisplayName: 'Ravi',
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('draft → add item → attach receipt → submit', (tester) async {
    final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
    picker.setResult(
      ClaimReceiptSource.gallery,
      ClaimReceiptPickResult(
        bytes: List<int>.filled(200, 3),
        contentType: 'image/jpeg',
        fileName: 'taxi.jpg',
      ),
    );
    // Skip permission sentence for this path by marking explained.
    await settings.setClaimsReceiptPermissionExplained(true);

    final vm = ClaimEditorViewModel(
      claims: claims,
      receipts: receipts,
      picker: picker,
      settings: settings,
      claimId: claim.id,
      actorDeviceId: 'ravi-device',
      companyCurrency: 'USD',
    );
    await vm.load(
      categories: [(id: travelCategoryId, name: travelCategoryName)],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
        supportedLocales: supportedAppLocales,
        home: ClaimEditorView(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit claim'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);

    // Add item via VM (sheet UI is covered separately for field wiring).
    await tester.runAsync(() async {
      await vm.addItem(
        categoryId: travelCategoryId,
        expenseDate: DateTime(2026, 3, 11),
        paidCurrency: 'USD',
        paidAmountMinor: 5000,
        companyCurrencyAmountMinor: 5000,
        description: 'Taxi',
      );
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('Taxi'), findsOneWidget);
    expect(find.textContaining(travelCategoryName), findsOneWidget);

    await tester.runAsync(() async {
      await vm.requestAttachReceipt(
        claimItemId: vm.claim!.items.single.id,
        source: ClaimReceiptSource.gallery,
      );
    });
    await tester.pumpAndSettle();
    expect(picker.pickLog, contains(ClaimReceiptSource.gallery));
    expect(find.textContaining('taxi.jpg'), findsOneWidget);

    await tester.runAsync(() async {
      final ok = await vm.submit();
      expect(ok, isTrue);
    });
    await tester.pumpAndSettle();
    expect(vm.claim!.status, ClaimStatus.submitted);
    expect(find.text('Submitted'), findsOneWidget);
  });

  testWidgets('shows receipt permission sentence before first camera pick', (
    tester,
  ) async {
    final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
    final item = await claims.addItem(
      claimId: claim.id,
      actorDeviceId: 'ravi-device',
      categoryId: travelCategoryId,
      expenseDate: DateTime(2026, 3, 11),
      paidCurrency: 'USD',
      paidAmountMinor: 100,
      companyCurrencyAmountMinor: 100,
    );
    picker.setResult(
      ClaimReceiptSource.camera,
      ClaimReceiptPickResult(
        bytes: [1, 2, 3],
        contentType: 'image/jpeg',
        fileName: 'cam.jpg',
      ),
    );

    final vm = ClaimEditorViewModel(
      claims: claims,
      receipts: receipts,
      picker: picker,
      settings: settings,
      claimId: claim.id,
      actorDeviceId: 'ravi-device',
      companyCurrency: 'USD',
    );
    await vm.load(
      categories: [(id: travelCategoryId, name: travelCategoryName)],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
        supportedLocales: supportedAppLocales,
        home: ClaimEditorView(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await vm.requestAttachReceipt(
        claimItemId: item.id,
        source: ClaimReceiptSource.camera,
      );
    });
    await tester.pumpAndSettle();

    expect(find.textContaining('camera or photo library'), findsOneWidget);
    expect(picker.pickLog, isEmpty);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      // continueAfter is async; allow attach to finish
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(picker.pickLog, contains(ClaimReceiptSource.camera));
  });
}
