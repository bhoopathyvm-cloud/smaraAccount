import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/books_set/books_set_paths.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/claim_person_service.dart';
import 'package:smara_accounting/data/repositories/claim_receipt_store.dart';
import 'package:smara_accounting/data/repositories/claim_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/linked_devices/local_network_permission.dart';
import 'package:smara_accounting/domain/models/account_type.dart';
import 'package:smara_accounting/domain/models/claim.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/settings/view_models/linked_devices_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/linked_devices_section.dart';

import '../../../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late IdentityRepository identity;
  late MembershipRepository membership;
  late SettingsRepository settings;
  late BooksSetStore booksSetStore;
  late FakeLocalNetworkPermission permission;
  late ClaimPersonService people;
  late ClaimRepository claims;
  late Directory tempDir;
  late String travelCategoryId;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tempDir = await Directory.systemTemp.createTemp('remove-person-ui-');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    final ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    final categories = CategoryRepository(database: db);
    identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    membership = MembershipRepository(
      database: db,
      identityRepository: identity,
    );
    people = ClaimPersonService(
      membership: membership,
      accounts: accounts,
      database: db,
    );
    final receipts = ClaimReceiptStore(
      database: db,
      booksSetId: 'books-test',
      supportDirectory: tempDir,
    );
    claims = ClaimRepository(
      database: db,
      membership: membership,
      ledger: ledger,
      receipts: receipts,
    );
    settings = SettingsRepository();
    booksSetStore = BooksSetStore();
    await booksSetStore.setActiveBooksSetId('books-test');
    permission = FakeLocalNetworkPermission(granted: true);
    await settings.setLinkedDevicesPermissionExplained(true);

    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');

    final cats = await categories.watchCategories().first;
    travelCategoryId = cats.firstWhere((c) => c.type == AccountType.expense).id;
    await claims.setAllowlistedCategories({travelCategoryId});

    await db
        .into(db.booksSetMetadata)
        .insert(
          BooksSetMetadataCompanion.insert(
            id: 'books-test',
            displayName: 'Acme',
          ),
        );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<LinkedDevicesViewModel> buildVm() async {
    final viewModel = LinkedDevicesViewModel(
      membershipRepository: membership,
      settingsRepository: settings,
      booksSetStore: booksSetStore,
      claimPersonService: people,
      claimRepository: claims,
      localNetworkPermission: permission,
    );
    while (viewModel.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    return viewModel;
  }

  testWidgets(
    'remove person warning shows open Claims and balance; confirm removes',
    (tester) async {
      late LinkedDevicesViewModel viewModel;
      late Claim claim;
      await tester.runAsync(() async {
        viewModel = await buildVm();
        final localId = viewModel.localDeviceId!;

        final peer = await identity.addLinkedPeerIdentity(
          publicKey: List<int>.generate(32, (i) => i + 20),
        );
        final owed = await people.ensureOwedToAccount(
          displayName: 'Ravi',
          currency: 'USD',
        );
        await membership.addDevice(
          actorDeviceId: localId,
          deviceId: 'ravi-device',
          displayName: 'Ravi phone',
          signingIdentityId: peer.identityId,
          deviceCertFingerprint: 'fp-ravi',
          roles: {LinkedDeviceRole.claimant},
          owedToAccountId: owed.id,
          personDisplayName: 'Ravi',
        );

        claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
        await claims.addItem(
          claimId: claim.id,
          actorDeviceId: 'ravi-device',
          categoryId: travelCategoryId,
          expenseDate: DateTime(2026, 3, 11),
          paidCurrency: 'USD',
          paidAmountMinor: 4500,
          companyCurrencyAmountMinor: 4500,
        );
        final item = (await claims.getClaim(claim.id))!.items.single;
        await ClaimReceiptStore(
          database: db,
          booksSetId: 'books-test',
          supportDirectory: tempDir,
        ).attach(
          claimItemId: item.id,
          bytes: List<int>.filled(80, 1),
          contentType: 'image/jpeg',
          fileName: 'r.jpg',
        );
        await claims.submit(claimId: claim.id, actorDeviceId: 'ravi-device');
        await (db.update(
          db.linkedDevices,
        )..where((t) => t.deviceId.equals(localId))).write(
          LinkedDevicesCompanion(
            rolesCsv: Value(
              MembershipRoleGates.encodeRoles({
                LinkedDeviceRole.owner,
                LinkedDeviceRole.approver,
              }),
            ),
          ),
        );
        await claims.approveItem(claimItemId: item.id, actorDeviceId: localId);
        await viewModel.refresh();
      });
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
          supportedLocales: supportedAppLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: LinkedDevicesSection(viewModel: viewModel),
            ),
          ),
        ),
      );
      await settle(tester);

      expect(find.text('Add a person'), findsOneWidget);
      expect(find.text('Ravi'), findsOneWidget);

      await tester.ensureVisible(find.text('Remove').first);
      await tester.pump();
      await tester.tap(find.text('Remove').first);
      // The warning reads open Claims and the owed balance from the database
      // before the dialog opens; let that real I/O finish.
      for (
        var i = 0;
        i < 50 && find.text('Remove Ravi?').evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await settle(tester);

      expect(find.text('Remove Ravi?'), findsOneWidget);
      expect(
        find.textContaining('open Claims and a non-zero owed balance'),
        findsOneWidget,
      );
      expect(find.textContaining('History and receipts stay'), findsOneWidget);

      await tester.tap(find.text('Remove').last);
      // The removal runs in the widget test's zone: let real I/O and frames
      // alternate until it finishes.
      for (var i = 0; i < 200 && viewModel.isBusy; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      expect(viewModel.isBusy, isFalse);
      await settle(tester);

      await tester.runAsync(() async {
        final removed = await membership.findByDeviceId('ravi-device');
        expect(removed!.isActive, isFalse);
        expect(await claims.getClaim(claim.id), isNotNull);
      });
    },
  );
}

/// Pumps until no frame is scheduled or [maxTicks] is reached, letting real
/// database I/O run between frames. Unlike pumpAndSettle it cannot hang on
/// an indeterminate progress indicator.
Future<void> settle(WidgetTester tester, {int maxTicks = 100}) async {
  for (var i = 0; i < maxTicks; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (!tester.binding.hasScheduledFrame) return;
  }
}
