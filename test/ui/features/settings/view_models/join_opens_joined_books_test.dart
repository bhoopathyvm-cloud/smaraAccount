import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/books_set/active_books_session.dart';
import 'package:smara_accounting/data/books_set/books_set_paths.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/books_set_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/linked_devices/join_code_lookup.dart';
import 'package:smara_accounting/domain/linked_devices/join_completion.dart';
import 'package:smara_accounting/domain/linked_devices/join_offer_discovery.dart';
import 'package:smara_accounting/domain/linked_devices/local_network_permission.dart';
import 'package:smara_accounting/domain/linked_devices/reserved_join_identity.dart';
import 'package:smara_accounting/domain/models/join_qr_payload.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/ui/features/settings/view_models/linked_devices_view_model.dart';

import '../../../../domain/crypto/in_memory_secure_key_storage.dart';

/// Fake lookup that reserves the joined set's identity (as welcome+hello
/// would) before returning success — mirrors AppJoinCodeLookup.
class _ReservingJoinCodeLookup implements JoinCodeLookup {
  _ReservingJoinCodeLookup({
    required this.session,
    required this.payload,
    required this.currency,
  });

  final ActiveBooksSession session;
  final JoinQrPayload payload;
  final String currency;
  ReservedJoinIdentity? helloIdentity;

  @override
  Future<JoinCodeLookupResult> lookup(String typedCode) async {
    helloIdentity = await session.reserveJoinIdentity(
      booksSetId: payload.booksSetId,
      currency: currency,
    );
    final checkCode = payload.checkCode;
    return JoinCodeLookupResult.success(
      JoinCodeLookupSuccess(
        checkCode: checkCode,
        offer: DiscoveredJoinOffer(
          offerId: 'offer-1',
          host: '127.0.0.1',
          port: 9,
          booksSetId: payload.booksSetId,
        ),
        normalizedCode: 'K7QF3M9P',
        completeJoin: () async => JoinCompletion(payload: payload),
      ),
    );
  }
}

void main() {
  late Directory tempDir;
  late ActiveBooksSession session;
  late SettingsRepository settings;
  late MembershipRepository personalMembership;
  late String personalId;
  late InMemorySecureKeyStorage secure;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tempDir = Directory.systemTemp.createTempSync('smara-join-open-');
    final store = BooksSetStore();
    secure = InMemorySecureKeyStorage();
    final booksSets = BooksSetRepository(
      supportDirectory: tempDir,
      store: store,
      secureStorage: secure,
    );
    session = ActiveBooksSession(
      booksSets: booksSets,
      store: store,
      signingKeyService: SigningKeyService(
        secureStorage: secure,
        resolveBooksSetId: store.activeBooksSetId,
      ),
    );
    final personal = await session.createSet(
      displayName: 'My household',
      id: 'personal-set',
    );
    personalId = personal.id;

    final keys = session.signingKeyService;
    final ledger = LedgerRepository(
      database: session.database,
      signingKeyService: keys,
    );
    final accounts = AccountRepository(
      database: session.database,
      ledgerRepository: ledger,
    );
    final identity = IdentityRepository(
      database: session.database,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    personalMembership = MembershipRepository(
      database: session.database,
      identityRepository: identity,
    );
    settings = SettingsRepository();
    await settings.setLocalDeviceId('joiner-device');
    await settings.setLocalDeviceDisplayName('Ravi phone');

    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'EUR');
    await personalMembership.ensureLocalOwner(
      localDeviceId: 'joiner-device',
      displayName: 'Ravi phone',
    );
  });

  tearDown(() async {
    session.dispose();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<JoinQrPayload> companyClaimantPayload() async {
    final checkCode = await JoinQrPayload.deriveCheckCode('join-open-nonce');
    return JoinQrPayload(
      booksSetId: 'company-acme',
      hostDeviceId: 'owner-device',
      hostDisplayName: 'Acme Owner',
      hostIdentityId: 'host-identity',
      signingPublicKey: List<int>.generate(32, (i) => i + 1),
      deviceCertDer: List<int>.filled(16, 7),
      deviceCertFingerprint: 'host-fp',
      roleOffer: LinkedDeviceRole.claimant,
      joinNonce: 'join-open-nonce',
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 2)),
      checkCode: checkCode,
      personRoles: const {LinkedDeviceRole.claimant},
      personDisplayName: 'Ravi',
      isPersonJoin: true,
    );
  }

  test(
    'confirmJoinCodeMatch opens company books as Claimant; personal stays listed',
    () async {
      final payload = await companyClaimantPayload();
      final lookup = _ReservingJoinCodeLookup(
        session: session,
        payload: payload,
        currency: 'EUR',
      );

      final viewModel = LinkedDevicesViewModel(
        membershipRepository: personalMembership,
        settingsRepository: settings,
        booksSetStore: session.store,
        booksSession: session,
        localNetworkPermission: FakeLocalNetworkPermission(granted: true),
        joinCodeLookup: lookup,
      );
      addTearDown(viewModel.dispose);
      while (viewModel.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(await session.activeBooksSetId(), personalId);

      final personalIdentity = IdentityRepository(
        database: session.database,
        signingKeyService: session.signingKeyService,
      );
      final householdIdentity = await personalIdentity.currentIdentity();
      expect(householdIdentity, isNotNull);
      final householdKey = await session.signingKeyService
          .loadStoredKeyMaterial();
      expect(householdKey, isNotNull);

      final lookupResult = await viewModel.lookupJoinCode('K7QF3M9P');
      expect(lookupResult.isSuccess, isTrue);
      expect(lookup.helloIdentity, isNotNull);
      expect(
        lookup.helloIdentity!.identityId,
        isNot(householdIdentity!.identityId),
        reason: 'Hello must present the joined set identity, not household',
      );

      final ok = await viewModel.confirmJoinCodeMatch();
      expect(ok, isTrue);

      expect(await session.activeBooksSetId(), 'company-acme');
      final sets = await session.listSets();
      expect(sets.map((s) => s.id), containsAll([personalId, 'company-acme']));
      expect(sets.where((s) => s.id == 'company-acme').single.isActive, isTrue);
      expect(sets.where((s) => s.id == personalId).single.isActive, isFalse);

      final joinedIdentity = IdentityRepository(
        database: session.database,
        accountRepository: AccountRepository(
          database: session.database,
          ledgerRepository: LedgerRepository(
            database: session.database,
            signingKeyService: session.signingKeyService,
          ),
        ),
        signingKeyService: session.signingKeyService,
      );
      final joinedCurrent = await joinedIdentity.currentIdentity();
      expect(joinedCurrent, isNotNull);
      expect(
        joinedCurrent!.identityId,
        lookup.helloIdentity!.identityId,
        reason:
            'Joined books must use the Signing Identity presented in hello '
            'so the host can verify EntryBatch signatures',
      );
      expect(
        joinedCurrent.identityId,
        isNot(householdIdentity.identityId),
        reason: 'Company and household Signing Identities must differ',
      );

      final joinedScopedKeys = SigningKeyService(
        secureStorage: secure,
        booksSetId: 'company-acme',
      );
      final joinedKey = await joinedScopedKeys.loadStoredKeyMaterial();
      expect(joinedKey, isNotNull);
      expect(joinedKey!.publicKey, joinedCurrent.publicKey);
      expect(
        joinedKey.privateKeySeed,
        isNot(householdKey!.privateKeySeed),
        reason: 'Household private key must not be readable under joined set',
      );
      expect(
        await secure.read(SigningKeyService.storageKeyFor(personalId)),
        isNotNull,
      );
      expect(
        await secure.read(SigningKeyService.storageKeyFor('company-acme')),
        isNotNull,
      );
      expect(
        await secure.read(SigningKeyService.storageKeyFor(personalId)),
        isNot(
          await secure.read(SigningKeyService.storageKeyFor('company-acme')),
        ),
      );

      final joinedMembership = MembershipRepository(
        database: session.database,
        identityRepository: joinedIdentity,
      );
      final devices = await joinedMembership.listActiveDevices();
      expect(
        devices.map((d) => d.deviceId),
        containsAll(['owner-device', 'joiner-device']),
      );
      final local = devices.firstWhere((d) => d.deviceId == 'joiner-device');
      expect(local.isClaimantOnly, isTrue);
      expect(local.signingIdentityId, lookup.helloIdentity!.identityId);
      final host = devices.firstWhere((d) => d.deviceId == 'owner-device');
      expect(host.hasRole(LinkedDeviceRole.owner), isTrue);
    },
  );

  test(
    'registerHostFromScannedJoin opens joined set for Add-a-device Member',
    () async {
      final checkCode = await JoinQrPayload.deriveCheckCode(
        'device-join-nonce',
      );
      final payload = JoinQrPayload(
        booksSetId: 'shared-books',
        hostDeviceId: 'host-a',
        hostDisplayName: 'Phone A',
        hostIdentityId: 'host-id-a',
        signingPublicKey: List<int>.generate(32, (i) => 40 + i),
        deviceCertDer: List<int>.filled(8, 3),
        deviceCertFingerprint: 'fp-a',
        roleOffer: LinkedDeviceRole.member,
        joinNonce: 'device-join-nonce',
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 2)),
        checkCode: checkCode,
      );

      final viewModel = LinkedDevicesViewModel(
        membershipRepository: personalMembership,
        settingsRepository: settings,
        booksSetStore: session.store,
        booksSession: session,
        localNetworkPermission: FakeLocalNetworkPermission(granted: true),
      );
      addTearDown(viewModel.dispose);
      while (viewModel.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }

      final householdIdentity = await IdentityRepository(
        database: session.database,
        signingKeyService: session.signingKeyService,
      ).currentIdentity();

      final ok = await viewModel.registerHostFromScannedJoin(payload);
      expect(ok, isTrue);
      expect(await session.activeBooksSetId(), 'shared-books');
      final sets = await session.listSets();
      expect(sets.map((s) => s.id), containsAll([personalId, 'shared-books']));

      final membership = MembershipRepository(
        database: session.database,
        identityRepository: IdentityRepository(
          database: session.database,
          signingKeyService: session.signingKeyService,
        ),
      );
      final local = (await membership.listActiveDevices()).firstWhere(
        (d) => d.deviceId == 'joiner-device',
      );
      expect(local.hasRole(LinkedDeviceRole.member), isTrue);
      expect(local.isClaimantOnly, isFalse);
      expect(local.signingIdentityId, isNot(householdIdentity!.identityId));
    },
  );
}
