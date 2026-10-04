import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/books_set/books_set_paths.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/data/repositories/metadata_outbox.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/linked_devices/join_code_lookup.dart';
import 'package:smara_accounting/domain/linked_devices/join_offer_discovery.dart';
import 'package:smara_accounting/domain/linked_devices/local_network_permission.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/settings/view_models/linked_devices_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/linked_devices_section.dart';

import '../../../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late MembershipRepository membership;
  late SettingsRepository settings;
  late BooksSetStore booksSetStore;
  late FakeLocalNetworkPermission permission;
  late IdentityRepository identity;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    final ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    membership = MembershipRepository(
      database: db,
      identityRepository: identity,
    );
    settings = SettingsRepository();
    booksSetStore = BooksSetStore();
    await booksSetStore.setActiveBooksSetId('books-test');
    permission = FakeLocalNetworkPermission(granted: false);

    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
    'shows Linked devices labels, catch-up copy, and permission before OS prompt',
    (tester) async {
      final viewModel = LinkedDevicesViewModel(
        membershipRepository: membership,
        settingsRepository: settings,
        booksSetStore: booksSetStore,
        localNetworkPermission: permission,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LinkedDevicesSection(viewModel: viewModel)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Linked devices'), findsOneWidget);
      expect(
        find.text(
          'Your devices catch up when both have Smara open on the same Wi-Fi.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'To share your books, Smara needs to find your other devices on '
          'this Wi-Fi. Nothing goes to the internet.',
        ),
        findsOneWidget,
      );
      expect(permission.requestCallCount, 0);
      expect(viewModel.permissionPromptRequested, isFalse);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(permission.requestCallCount, 1);
      expect(viewModel.permissionPromptRequested, isTrue);
      expect(viewModel.showingPermissionExplanation, isFalse);
      expect(find.text('Add a device'), findsOneWidget);
      expect(find.text('Add a person'), findsOneWidget);
    },
  );

  testWidgets('approve and refuse join request from section', (tester) async {
    permission = FakeLocalNetworkPermission(granted: true);
    await settings.setLinkedDevicesPermissionExplained(true);

    final viewModel = LinkedDevicesViewModel(
      membershipRepository: membership,
      settingsRepository: settings,
      booksSetStore: booksSetStore,
      localNetworkPermission: permission,
    );
    addTearDown(viewModel.dispose);
    await tester.pump();
    while (viewModel.isLoading) {
      await tester.pump();
    }

    final localId = viewModel.localDeviceId!;
    final request = await membership.createJoinRequest(
      requesterDeviceId: 'joiner-1',
      requesterDisplayName: 'Joiner phone',
      signingPublicKey: List<int>.generate(32, (i) => i + 5),
      deviceCertDer: List<int>.filled(8, 1),
      deviceCertFingerprint: 'fp-join',
      booksSetId: 'books-test',
    );
    await viewModel.refresh();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LinkedDevicesSection(viewModel: viewModel)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Joiner phone wants to join'), findsOneWidget);

    await tester.tap(find.text('Refuse'));
    await tester.pumpAndSettle();
    expect(await membership.listActiveDevices(), hasLength(1));
    expect((await membership.listActiveDevices()).single.deviceId, localId);

    final request2 = await membership.createJoinRequest(
      requesterDeviceId: 'joiner-1',
      requesterDisplayName: 'Joiner phone',
      signingPublicKey: List<int>.generate(32, (i) => i + 5),
      deviceCertDer: List<int>.filled(8, 1),
      deviceCertFingerprint: 'fp-join',
      booksSetId: 'books-test',
    );
    expect(request2.requestId, isNot(request.requestId));
    await viewModel.refresh();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(await membership.listActiveDevices(), hasLength(2));
  });

  testWidgets('Enter code instead shows not-found then success + check code', (
    tester,
  ) async {
    permission = FakeLocalNetworkPermission(granted: true);
    await settings.setLinkedDevicesPermissionExplained(true);

    final lookup = FakeJoinCodeLookup();
    final viewModel = LinkedDevicesViewModel(
      membershipRepository: membership,
      settingsRepository: settings,
      booksSetStore: booksSetStore,
      localNetworkPermission: permission,
      joinCodeLookup: lookup,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LinkedDevicesSection(viewModel: viewModel)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('linked-devices-more-ways')),
    );
    await tester.tap(find.byKey(const Key('linked-devices-more-ways')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('enter-code-instead')));
    await tester.tap(find.byKey(const Key('enter-code-instead')));
    await tester.pumpAndSettle();
    // First join asks for this device's name.
    expect(find.text('Name this device'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('device-name-field')),
      'Ravi phone',
    );
    await tester.tap(find.byKey(const Key('device-name-save')));
    await tester.pumpAndSettle();
    expect(await settings.localDeviceDisplayName(), 'Ravi phone');
    expect(find.text('Enter join code'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('join-code-entry-field')),
      'k7qf3m9p',
    );
    await tester.tap(find.byKey(const Key('join-code-entry-submit')));
    await tester.pumpAndSettle();
    expect(find.text('No device with this code on this Wi-Fi'), findsOneWidget);

    lookup.result = JoinCodeLookupResult.success(
      JoinCodeLookupSuccess(
        checkCode: '482913',
        offer: const DiscoveredJoinOffer(
          offerId: 'o1',
          host: '127.0.0.1',
          port: 9,
          booksSetId: 'books-1',
        ),
        normalizedCode: 'K7QF3M9P',
      ),
    );
    await tester.tap(find.byKey(const Key('join-code-entry-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('join-code-check-code')), findsOneWidget);
    expect(find.text('482913'), findsOneWidget);
    expect(find.text("They don't match"), findsOneWidget);
    expect(find.text('Codes match'), findsOneWidget);
  });

  Future<LinkedDevicesViewModel> pumpSection(
    WidgetTester tester, {
    MetadataOutbox? outbox,
  }) async {
    permission = FakeLocalNetworkPermission(granted: true);
    await settings.setLinkedDevicesPermissionExplained(true);
    final viewModel = LinkedDevicesViewModel(
      membershipRepository: membership,
      settingsRepository: settings,
      booksSetStore: booksSetStore,
      localNetworkPermission: permission,
      identityRepository: identity,
      metadataOutbox: outbox,
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LinkedDevicesSection(viewModel: viewModel)),
      ),
    );
    await tester.pumpAndSettle();
    return viewModel;
  }

  testWidgets('groups my devices and people, marks this device, plain roles', (
    tester,
  ) async {
    await settings.setLocalDeviceDisplayName('Office Mac');
    final viewModel = await pumpSection(tester);
    final owner = viewModel.localDeviceId!;
    await membership.addDevice(
      actorDeviceId: owner,
      deviceId: 'own-phone',
      displayName: 'My iPhone',
      signingIdentityId: 'id-phone',
      deviceCertFingerprint: 'fp-phone',
    );
    await membership.addDevice(
      actorDeviceId: owner,
      deviceId: 'ravi-phone',
      displayName: 'Ravi phone',
      signingIdentityId: 'id-ravi',
      deviceCertFingerprint: 'fp-ravi',
      roles: {LinkedDeviceRole.claimant},
      personDisplayName: 'Ravi',
    );
    await viewModel.refresh();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('linked-devices-my-devices')), findsOneWidget);
    expect(find.byKey(const Key('linked-devices-people')), findsOneWidget);
    expect(find.byKey(const Key('linked-devices-join-sync')), findsOneWidget);
    expect(find.text('Office Mac (this device)'), findsOneWidget);
    expect(find.text('Owner – full books'), findsOneWidget);
    expect(find.text('My iPhone'), findsOneWidget);
    expect(find.text('Bookkeeper'), findsOneWidget);
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('Employee – sends expense claims'), findsOneWidget);

    // My devices come before People; Ravi is listed under People.
    final myDevicesY = tester
        .getTopLeft(find.byKey(const Key('linked-devices-my-devices')))
        .dy;
    final peopleY = tester
        .getTopLeft(find.byKey(const Key('linked-devices-people')))
        .dy;
    expect(tester.getTopLeft(find.text('My iPhone')).dy, lessThan(peopleY));
    expect(tester.getTopLeft(find.text('Ravi')).dy, greaterThan(peopleY));
    expect(myDevicesY, lessThan(peopleY));

    // Code entry and address are tucked under "More ways to connect".
    expect(find.text('Enter code instead'), findsNothing);
    await tester.ensureVisible(
      find.byKey(const Key('linked-devices-more-ways')),
    );
    await tester.tap(find.byKey(const Key('linked-devices-more-ways')));
    await tester.pumpAndSettle();
    expect(find.text('Enter code instead'), findsOneWidget);
  });

  testWidgets('first Add a device asks for a name; cancel shows no QR', (
    tester,
  ) async {
    final viewModel = await pumpSection(tester);
    expect(viewModel.needsDeviceName, isTrue);

    await tester.ensureVisible(find.text('Add a device'));
    await tester.tap(find.text('Add a device'));
    await tester.pumpAndSettle();
    expect(find.text('Name this device'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(viewModel.activeJoinQr, isNull);
    expect(await settings.localDeviceDisplayName(), isNull);
  });

  testWidgets('rename this device updates membership and syncs the name', (
    tester,
  ) async {
    await settings.setLocalDeviceDisplayName('My Mac');
    final outbox = MetadataOutbox(database: db);
    final viewModel = await pumpSection(tester, outbox: outbox);

    await tester.ensureVisible(find.byKey(const Key('rename-this-device')));
    await tester.tap(find.byKey(const Key('rename-this-device')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('device-name-field')),
      'Office Mac',
    );
    await tester.tap(find.byKey(const Key('device-name-save')));
    await tester.pumpAndSettle();

    final local = await membership.findByDeviceId(viewModel.localDeviceId!);
    expect(local!.displayName, 'Office Mac');
    expect(await settings.localDeviceDisplayName(), 'Office Mac');
    expect(find.text('Office Mac (this device)'), findsOneWidget);
    final ops = await outbox.listAll();
    expect(
      ops.where(
        (o) =>
            o.entityType == 'linked_device' &&
            o.entityId == viewModel.localDeviceId &&
            o.field == 'displayName' &&
            o.value == 'Office Mac',
      ),
      hasLength(1),
    );
  });
}
