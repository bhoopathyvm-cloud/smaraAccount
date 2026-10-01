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
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/linked_devices/local_network_permission.dart';
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

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    final ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    final identity = IdentityRepository(
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
}
