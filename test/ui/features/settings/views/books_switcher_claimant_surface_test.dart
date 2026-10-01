import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/books_set/active_books_session.dart';
import 'package:smara_accounting/data/books_set/books_set_paths.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/books_set_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/domain/models/signing_identity.dart';
import 'package:smara_accounting/domain/navigation/app_navigation_policy.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/claims/view_models/claims_list_view_model.dart';
import 'package:smara_accounting/ui/features/claims/views/claims_list_view.dart';
import 'package:smara_accounting/ui/features/settings/view_models/books_switcher_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/books_switcher_section.dart';
import 'package:smara_accounting/data/repositories/claim_repository.dart';

import '../../../../domain/crypto/in_memory_secure_key_storage.dart';

class _NoopClaims extends Fake implements ClaimRepository {}

/// Minimal surface that mirrors app_router Claimant-only gating after a
/// books-set switch (task 7.4).
class _ActiveSurface extends StatelessWidget {
  const _ActiveSurface({required this.session, required this.claimantOnly});

  final ActiveBooksSession session;
  final bool claimantOnly;

  @override
  Widget build(BuildContext context) {
    if (claimantOnly) {
      final vm = ClaimsListViewModel(
        claims: _NoopClaims(),
        localDeviceId: 'local',
        companyDisplayName: 'Acme Co',
      );
      vm.loading = false;
      vm.balanceMinor = 0;
      return ClaimsListView(viewModel: vm);
    }
    return const Scaffold(body: Center(child: Text('Household home')));
  }
}

void main() {
  late Directory tempDir;
  late BooksSetStore store;
  late InMemorySecureKeyStorage secureStorage;
  late ActiveBooksSession session;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('smara-switcher-claimant-');
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    store = BooksSetStore();
    secureStorage = InMemorySecureKeyStorage();
    final booksSets = BooksSetRepository(
      supportDirectory: tempDir,
      store: store,
      secureStorage: secureStorage,
    );
    session = ActiveBooksSession(
      booksSets: booksSets,
      store: store,
      signingKeyService: SigningKeyService(
        secureStorage: secureStorage,
        resolveBooksSetId: store.activeBooksSetId,
      ),
    );
  });

  tearDown(() async {
    session.dispose();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<void> seedIdentityAndMembership({
    required AppDatabase db,
    required SigningKeyService keys,
    required Set<LinkedDeviceRole> roles,
    required String deviceId,
  }) async {
    final ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    final identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    final membership = MembershipRepository(
      database: db,
      identityRepository: identity,
    );
    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
    await membership.ensureLocalOwner(
      localDeviceId: deviceId,
      displayName: 'This device',
    );
    await (db.update(
      db.linkedDevices,
    )..where((t) => t.deviceId.equals(deviceId))).write(
      LinkedDevicesCompanion(
        rolesCsv: Value(MembershipRoleGates.encodeRoles(roles)),
        role: Value(MembershipRoleGates.primaryRole(roles)),
      ),
    );
  }

  Future<bool> activeIsClaimantOnly() async {
    final db = session.database;
    final keys = session.signingKeyService;
    final ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    final identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    final membership = MembershipRepository(
      database: db,
      identityRepository: identity,
    );
    final devices = await membership.listActiveDevices();
    if (devices.isEmpty) return false;
    return devices.first.isClaimantOnly;
  }

  testWidgets(
    'switch to company Claimant-only shows Claimant surface; household unchanged',
    (tester) async {
      late BooksSwitcherViewModel switcher;
      late String householdId;
      late String companyId;

      await tester.runAsync(() async {
        final household = await session.createSet(
          displayName: 'My household',
          id: 'household',
        );
        householdId = household.id;
        await seedIdentityAndMembership(
          db: session.database,
          keys: session.booksSets.signingKeyServiceFor(householdId),
          roles: {LinkedDeviceRole.owner},
          deviceId: 'device-home',
        );

        final company = await session.createSet(
          displayName: 'Acme Co',
          id: 'company',
        );
        companyId = company.id;
        await seedIdentityAndMembership(
          db: session.database,
          keys: session.booksSets.signingKeyServiceFor(companyId),
          roles: {LinkedDeviceRole.claimant},
          deviceId: 'device-claimant',
        );

        switcher = BooksSwitcherViewModel(session: session);
        await switcher.refresh();
      });
      addTearDown(switcher.dispose);

      var claimantOnly = false;
      await tester.runAsync(() async {
        claimantOnly = await activeIsClaimantOnly();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
          supportedLocales: supportedAppLocales,
          home: Scaffold(
            body: Column(
              children: [
                BooksSwitcherSection(viewModel: switcher),
                Expanded(
                  child: _ActiveSurface(
                    session: session,
                    claimantOnly: claimantOnly,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // Start on company (last created) → Claimant surface.
      expect(claimantOnly, isTrue);
      expect(find.text('Claims'), findsOneWidget);
      expect(find.text('Settled with Acme Co'), findsOneWidget);
      expect(find.text('Household home'), findsNothing);

      // Policy: Claimant-only blocks bank routes.
      final policyCompany = AppNavigationPolicy(
        currentIdentity: () async => SigningIdentity(
          identityId: 'id',
          publicKey: const [1],
          createdAt: DateTime(2026),
          supersedesIdentityId: null,
          supersededAt: null,
          continuesIdentityId: null,
          continuedAt: null,
          acknowledgedAt: null,
        ),
        hasAnyJournalEntries: () async => true,
        hasMatchingStoredKey: (_) async => true,
        verifyChain: () async {},
        needsCurrencyBackfill: () async => false,
        isFirstWeekSetupCompleted: () async => true,
        lockScreenRequired: () async => false,
        isClaimantOnlyActiveSet: () async => true,
      );
      expect(await policyCompany.resolve('/home'), AppNavPaths.claims);
      expect(await policyCompany.resolve('/register'), AppNavPaths.claims);

      // Switch to household.
      await tester.runAsync(() async {
        final ok = await switcher.switchTo(householdId);
        expect(ok, isTrue);
        claimantOnly = await activeIsClaimantOnly();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
          supportedLocales: supportedAppLocales,
          home: Scaffold(
            body: Column(
              children: [
                BooksSwitcherSection(viewModel: switcher),
                Expanded(
                  child: _ActiveSurface(
                    session: session,
                    claimantOnly: claimantOnly,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(claimantOnly, isFalse);
      expect(find.text('Household home'), findsOneWidget);
      expect(find.text('Claims'), findsNothing);

      final policyHousehold = AppNavigationPolicy(
        currentIdentity: () async => SigningIdentity(
          identityId: 'id',
          publicKey: const [1],
          createdAt: DateTime(2026),
          supersedesIdentityId: null,
          supersededAt: null,
          continuesIdentityId: null,
          continuedAt: null,
          acknowledgedAt: null,
        ),
        hasAnyJournalEntries: () async => true,
        hasMatchingStoredKey: (_) async => true,
        verifyChain: () async {},
        needsCurrencyBackfill: () async => false,
        isFirstWeekSetupCompleted: () async => true,
        lockScreenRequired: () async => false,
        isClaimantOnlyActiveSet: () async => false,
      );
      expect(await policyHousehold.resolve('/home'), isNull);
      expect(await policyHousehold.resolve('/register'), isNull);

      // Switch back to company Claimant surface.
      await tester.runAsync(() async {
        final ok = await switcher.switchTo(companyId);
        expect(ok, isTrue);
        claimantOnly = await activeIsClaimantOnly();
      });
      expect(claimantOnly, isTrue);
    },
  );
}
