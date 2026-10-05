import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/books_set/active_books_session.dart';
import 'data/database/app_database.dart';
import 'data/repositories/account_chart_reader.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/books_copy_repository.dart';
import 'data/repositories/books_set_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/identity_id_source.dart';
import 'data/repositories/identity_repository.dart';
import 'data/repositories/investment_repository.dart';
import 'data/repositories/ledger_chain_store.dart';
import 'data/repositories/ledger_chain_verifier.dart';
import 'data/repositories/ledger_repository.dart';
import 'data/repositories/membership_repository.dart';
import 'data/repositories/metadata_outbox.dart';
import 'data/repositories/personal_claim_limit_repository.dart';
import 'data/repositories/claim_person_service.dart';
import 'data/repositories/claim_receipt_store.dart';
import 'data/repositories/claim_repository.dart';
import 'data/claims/company_sync_claim_receipt_picker.dart';
import 'data/claims/platform_claim_receipt_picker.dart';
import 'domain/claims/claim_receipt_picker.dart';
import 'data/repositories/payee_repository.dart';
import 'data/repositories/recurring_template_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/statement_import_repository.dart';
import 'data/repositories/sync_merge_repository.dart';
import 'data/books_set/books_set_paths.dart';
import 'domain/crypto/crypto_backend.dart';
import 'domain/crypto/secure_key_storage.dart';
import 'domain/crypto/signing_key_service.dart';
import 'domain/linked_devices/device_certificate_store.dart';
import 'domain/linked_devices/join_offer_discovery.dart';
import 'domain/linked_devices/local_network_permission.dart';
import 'domain/linked_devices/local_network_reachability.dart';
import 'domain/linked_devices/platform_device_certificate_store.dart';
import 'domain/peer_sync/bonsoir_peer_discovery.dart';
import 'domain/peer_sync/direct_address_peer_discovery.dart';
import 'domain/peer_sync/peer_discovery.dart';
import 'domain/peer_sync/peer_sync_service.dart';
import 'domain/peer_sync/sync_transport.dart';
import 'data/peer_sync/socket_sync_transport.dart';
import 'l10n/l10n.dart';
import 'domain/lock/app_lock_service.dart';
import 'domain/lock/biometric_authenticator.dart';
import 'ui/app_router.dart';
import 'ui/core/app_lock_controller.dart';
import 'ui/core/app_theme.dart';
import 'ui/core/snapshot_hiding_overlay.dart';
import 'ui/features/account_management/view_models/account_management_view_model.dart';
import 'ui/features/category_management/view_models/category_management_view_model.dart';
import 'ui/features/continuation/view_models/continuation_view_model.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/features/onboarding/view_models/first_identity_setup_view_model.dart';
import 'ui/features/payee_management/view_models/payee_management_view_model.dart';
import 'ui/features/recurring_template_management/view_models/recurring_template_management_view_model.dart';
import 'ui/features/register/view_models/register_view_model.dart';
import 'ui/features/setup_choice/view_models/bundle_import_view_model.dart';
import 'ui/features/summary/view_models/summary_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Chosen once from the platform: Apple frameworks on iOS and macOS, the
  // Dart implementation elsewhere (os-provided-encryption design D1). The
  // debug check fails loudly if an Apple build would reach Dart crypto.
  CryptoBackend.use(selectCryptoBackend());
  debugCheckCryptoBackendMatchesPlatform();
  final session = await ActiveBooksSession.open();
  runApp(SmaraAccountingApp(session: session));
}

class SmaraAccountingApp extends StatelessWidget {
  const SmaraAccountingApp({super.key, required this.session});

  final ActiveBooksSession session;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CryptoBackend>.value(value: CryptoBackend.instance),
        ChangeNotifierProvider<ActiveBooksSession>.value(value: session),
        ProxyProvider<ActiveBooksSession, AppDatabase>(
          update: (_, session, _) => session.database,
        ),
        ProxyProvider<ActiveBooksSession, BooksSetRepository>(
          update: (_, session, _) => session.booksSets,
        ),
        ProxyProvider<ActiveBooksSession, SigningKeyService>(
          update: (_, session, _) => session.signingKeyService,
        ),
        ProxyProvider<AppDatabase, AccountChartReader>(
          update: (_, db, _) => AccountChartReader(db),
        ),
        ProxyProvider<AppDatabase, LedgerChainStore>(
          update: (_, db, _) => LedgerChainStore(db),
        ),
        Provider<IdentityIdSource>(create: (_) => IdentityIdSource()),
        ProxyProvider<AppDatabase, MetadataOutbox>(
          update: (_, db, _) => MetadataOutbox(database: db),
        ),
        ProxyProvider4<
          AppDatabase,
          AccountChartReader,
          LedgerChainStore,
          SigningKeyService,
          LedgerRepository
        >(
          update: (_, db, chart, chain, keys, _) => LedgerRepository(
            database: db,
            chart: chart,
            chain: chain,
            signingKeyService: keys,
          ),
        ),
        ProxyProvider5<
          AppDatabase,
          LedgerRepository,
          AccountChartReader,
          MetadataOutbox,
          IdentityIdSource,
          AccountRepository
        >(
          update: (_, db, ledgerRepository, chart, outbox, identitySource, _) =>
              AccountRepository(
                database: db,
                ledgerRepository: ledgerRepository,
                chart: chart,
                metadataOutbox: outbox,
                currentIdentityId: identitySource.current,
              ),
        ),
        ProxyProvider3<
          AppDatabase,
          MetadataOutbox,
          IdentityIdSource,
          PayeeRepository
        >(
          update: (_, db, outbox, identitySource, _) => PayeeRepository(
            database: db,
            metadataOutbox: outbox,
            currentIdentityId: identitySource.current,
          ),
        ),
        ProxyProvider4<
          AppDatabase,
          AccountRepository,
          LedgerChainStore,
          SigningKeyService,
          IdentityRepository
        >(
          update: (context, db, accountRepository, chain, keys, _) {
            final identity = IdentityRepository(
              database: db,
              accountRepository: accountRepository,
              chain: chain,
              signingKeyService: keys,
            );
            context.read<IdentityIdSource>().bind(
              () async => (await identity.currentIdentity())?.identityId,
            );
            return identity;
          },
        ),
        ProxyProvider4<
          AppDatabase,
          AccountChartReader,
          MetadataOutbox,
          IdentityIdSource,
          CategoryRepository
        >(
          update: (_, db, chart, outbox, identitySource, _) =>
              CategoryRepository(
                database: db,
                chart: chart,
                metadataOutbox: outbox,
                currentIdentityId: identitySource.current,
              ),
        ),
        ProxyProvider2<
          AppDatabase,
          MetadataOutbox,
          PersonalClaimLimitRepository
        >(
          update: (_, db, outbox, _) => PersonalClaimLimitRepository(
            database: db,
            metadataOutbox: outbox,
          ),
        ),
        ProxyProvider3<
          AppDatabase,
          LedgerChainStore,
          SigningKeyService,
          LedgerChainVerifier
        >(
          update: (_, db, chain, keys, _) => LedgerChainVerifier(
            database: db,
            chain: chain,
            signingKeyService: keys,
          ),
        ),
        Provider<LocalNetworkReachability>(
          create: (_) => FakeLocalNetworkReachability(onLocalNetwork: true),
        ),
        Provider<DeviceCertificateStore>(
          create: (_) => createPlatformDeviceCertificateStore(
            secureStorage: FlutterSecureKeyStorage(),
          ),
        ),
        Provider<LocalNetworkPermission>(
          create: (_) => FakeLocalNetworkPermission(granted: true),
        ),
        Provider<JoinOfferDiscovery>(
          create: (_) => BonsoirJoinOfferDiscovery(),
        ),
        Provider<SyncTransport>(
          create: (_) => createPlatformSyncTransport(),
          dispose: (_, transport) => transport.stopListening(),
        ),
        ProxyProvider<LocalNetworkPermission, PeerDiscovery>(
          update: (_, permission, previous) {
            if (previous != null) return previous;
            return PermissionGatedPeerDiscovery(
              inner: CompositePeerDiscovery(
                primary: BonsoirPeerDiscovery(),
                direct: DirectAddressPeerDiscovery(),
              ),
              permission: permission,
            );
          },
        ),
        ProxyProvider3<
          AppDatabase,
          IdentityRepository,
          DeviceCertificateStore,
          MembershipRepository
        >(
          update: (context, db, identity, certs, _) => MembershipRepository(
            database: db,
            identityRepository: identity,
            certificateStore: certs,
            reachability: context.read<LocalNetworkReachability>(),
          ),
        ),
        ProxyProvider4<
          AppDatabase,
          SigningKeyService,
          MetadataOutbox,
          DeviceCertificateStore,
          SyncMergeRepository
        >(
          update: (_, db, keys, outbox, certs, _) => SyncMergeRepository(
            database: db,
            signingKeyService: keys,
            metadataOutbox: outbox,
            certificates: certs,
          ),
        ),
        ProxyProvider2<AppDatabase, ActiveBooksSession, ClaimReceiptStore>(
          update: (_, db, session, _) {
            final booksSetId = session.booksSets.activeBooksSetId;
            if (booksSetId == null) {
              throw StateError(
                'ActiveBooksSession has no active books set id.',
              );
            }
            return ClaimReceiptStore(
              database: db,
              booksSetId: booksSetId,
              supportDirectory: session.booksSets.supportDirectory,
            );
          },
        ),
        ProxyProvider4<
          AppDatabase,
          MembershipRepository,
          LedgerRepository,
          ClaimReceiptStore,
          ClaimRepository
        >(
          update: (_, db, membership, ledger, receipts, _) => ClaimRepository(
            database: db,
            membership: membership,
            ledger: ledger,
            receipts: receipts,
          ),
        ),
        Provider<ClaimReceiptPicker>(
          create: (_) {
            const companySyncTest = bool.fromEnvironment('COMPANY_SYNC_TEST');
            if (companySyncTest) {
              return CompanySyncClaimReceiptPicker();
            }
            return PlatformClaimReceiptPicker();
          },
        ),
        ProxyProvider5<
          MembershipRepository,
          AccountRepository,
          AppDatabase,
          MetadataOutbox,
          IdentityIdSource,
          ClaimPersonService
        >(
          update: (_, membership, accounts, db, outbox, identitySource, _) =>
              ClaimPersonService(
                membership: membership,
                accounts: accounts,
                database: db,
                outbox: outbox,
                currentIdentityId: identitySource.current,
              ),
        ),
        ProxyProvider<ActiveBooksSession, BooksSetStore>(
          update: (_, session, _) => session.store,
        ),
        ProxyProvider3<
          BooksSetStore,
          MetadataOutbox,
          IdentityIdSource,
          SettingsRepository
        >(
          update: (_, store, outbox, identitySource, _) => SettingsRepository(
            booksSetStore: store,
            metadataOutbox: outbox,
            currentIdentityId: identitySource.current,
          ),
        ),
        ProxyProvider6<
          SyncTransport,
          PeerDiscovery,
          MembershipRepository,
          SyncMergeRepository,
          DeviceCertificateStore,
          SettingsRepository,
          PeerSyncService
        >(
          update:
              (
                context,
                transport,
                discovery,
                membership,
                merge,
                certs,
                settings,
                previous,
              ) {
                unawaited(previous?.stop());
                final session = context.read<ActiveBooksSession>();
                final reachability = context.read<LocalNetworkReachability>();
                return PeerSyncService(
                  transport: transport,
                  discovery: discovery,
                  membership: membership,
                  merge: merge,
                  certificates: certs,
                  settings: settings,
                  reachability: reachability,
                  activeBooksSetId: session.activeBooksSetId,
                  wipeActiveBooksCopy: merge.wipeLocalLedgerForErase,
                );
              },
          dispose: (_, service) => service.stop(),
        ),
        ProxyProvider4<
          AppDatabase,
          IdentityRepository,
          SettingsRepository,
          SigningKeyService,
          BooksCopyRepository
        >(
          update: (_, db, identityRepository, settingsRepository, keys, _) =>
              BooksCopyRepository(
                database: db,
                identityRepository: identityRepository,
                settingsRepository: settingsRepository,
                signingKeyService: keys,
              ),
        ),
        ProxyProvider3<
          AppDatabase,
          LedgerRepository,
          AccountChartReader,
          InvestmentRepository
        >(
          update: (_, db, ledgerRepository, chart, _) => InvestmentRepository(
            database: db,
            ledgerRepository: ledgerRepository,
            chart: chart,
          ),
        ),
        ProxyProvider4<
          AppDatabase,
          LedgerRepository,
          MetadataOutbox,
          IdentityIdSource,
          RecurringTemplateRepository
        >(
          update: (_, db, ledgerRepository, outbox, identitySource, _) =>
              RecurringTemplateRepository(
                database: db,
                ledgerRepository: ledgerRepository,
                metadataOutbox: outbox,
                currentIdentityId: identitySource.current,
              ),
        ),
        Provider<AppLockService>(
          create: (context) =>
              AppLockService(backend: context.read<CryptoBackend>()),
        ),
        Provider<BiometricAuthenticator>(
          create: (_) => LocalAuthBiometricAuthenticator(),
        ),
        ChangeNotifierProvider<LocaleController>(
          create: (context) {
            final controller = LocaleController(
              settingsRepository: context.read<SettingsRepository>(),
            );
            controller.load();
            return controller;
          },
        ),
        ChangeNotifierProvider<AppLockController>(
          create: (context) => AppLockController(
            settingsRepository: context.read<SettingsRepository>(),
          ),
        ),
        ProxyProvider6<
          AppDatabase,
          LedgerRepository,
          AccountRepository,
          CategoryRepository,
          MetadataOutbox,
          IdentityIdSource,
          StatementImportRepository
        >(
          update:
              (
                _,
                db,
                ledgerRepository,
                accountRepository,
                categoryRepository,
                outbox,
                identitySource,
                _,
              ) => StatementImportRepository(
                database: db,
                ledgerRepository: ledgerRepository,
                accountRepository: accountRepository,
                categoryRepository: categoryRepository,
                metadataOutbox: outbox,
                currentIdentityId: identitySource.current,
              ),
        ),
        ChangeNotifierProxyProvider4<
          ActiveBooksSession,
          LedgerRepository,
          AccountRepository,
          CategoryRepository,
          RegisterViewModel
        >(
          create: (context) => RegisterViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
            accountRepository: context.read<AccountRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
            booksGeneration: context.read<ActiveBooksSession>().generation,
          ),
          update:
              (
                _,
                session,
                repository,
                accountRepository,
                categoryRepository,
                previous,
              ) {
                if (previous != null &&
                    previous.booksGeneration == session.generation) {
                  return previous;
                }
                // Do not dispose [previous] here — ChangeNotifierProxyProvider
                // disposes the prior notifier when update returns a new one.
                return RegisterViewModel(
                  ledgerRepository: repository,
                  accountRepository: accountRepository,
                  categoryRepository: categoryRepository,
                  booksGeneration: session.generation,
                );
              },
        ),
        ChangeNotifierProxyProvider3<
          ActiveBooksSession,
          LedgerRepository,
          AccountRepository,
          SummaryViewModel
        >(
          create: (context) => SummaryViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
            accountRepository: context.read<AccountRepository>(),
            booksGeneration: context.read<ActiveBooksSession>().generation,
          ),
          update: (_, session, repository, accountRepository, previous) {
            if (previous != null &&
                previous.booksGeneration == session.generation) {
              return previous;
            }
            return SummaryViewModel(
              ledgerRepository: repository,
              accountRepository: accountRepository,
              booksGeneration: session.generation,
            );
          },
        ),
        ChangeNotifierProxyProvider2<
          ActiveBooksSession,
          CategoryRepository,
          CategoryManagementViewModel
        >(
          create: (context) => CategoryManagementViewModel(
            categoryRepository: context.read<CategoryRepository>(),
            booksGeneration: context.read<ActiveBooksSession>().generation,
          ),
          update: (_, session, repository, previous) {
            if (previous != null &&
                previous.booksGeneration == session.generation) {
              return previous;
            }
            return CategoryManagementViewModel(
              categoryRepository: repository,
              booksGeneration: session.generation,
            );
          },
        ),
        ChangeNotifierProxyProvider2<
          IdentityRepository,
          LedgerChainVerifier,
          FirstIdentitySetupViewModel
        >(
          create: (context) => FirstIdentitySetupViewModel(
            identityRepository: context.read<IdentityRepository>(),
            chainVerifier: context.read<LedgerChainVerifier>(),
          ),
          update: (_, repository, chainVerifier, previous) =>
              previous ??
              FirstIdentitySetupViewModel(
                identityRepository: repository,
                chainVerifier: chainVerifier,
              ),
        ),
        ChangeNotifierProxyProvider3<
          IdentityRepository,
          LedgerChainVerifier,
          BooksCopyRepository,
          ContinuationViewModel
        >(
          create: (context) => ContinuationViewModel(
            identityRepository: context.read<IdentityRepository>(),
            chainVerifier: context.read<LedgerChainVerifier>(),
            booksCopyRepository: context.read<BooksCopyRepository>(),
          ),
          update: (_, repository, chainVerifier, booksCopy, previous) =>
              previous ??
              ContinuationViewModel(
                identityRepository: repository,
                chainVerifier: chainVerifier,
                booksCopyRepository: booksCopy,
              ),
        ),
        ChangeNotifierProxyProvider<BooksCopyRepository, BundleImportViewModel>(
          create: (context) => BundleImportViewModel(
            booksCopyRepository: context.read<BooksCopyRepository>(),
          ),
          update: (_, booksCopyRepository, previous) =>
              previous ??
              BundleImportViewModel(booksCopyRepository: booksCopyRepository),
        ),
        ChangeNotifierProxyProvider5<
          ActiveBooksSession,
          LedgerRepository,
          SettingsRepository,
          CategoryRepository,
          RecurringTemplateRepository,
          HomeViewModel
        >(
          create: (context) => HomeViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
            settingsRepository: context.read<SettingsRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
            recurringTemplateRepository: context
                .read<RecurringTemplateRepository>(),
            investmentRepository: context.read<InvestmentRepository>(),
            membershipRepository: context.read<MembershipRepository>(),
            booksGeneration: context.read<ActiveBooksSession>().generation,
          ),
          update:
              (
                context,
                session,
                repository,
                settings,
                categoryRepository,
                recurringTemplateRepository,
                previous,
              ) {
                if (previous != null &&
                    previous.booksGeneration == session.generation) {
                  return previous;
                }
                // Do not dispose [previous] here — ChangeNotifierProxyProvider
                // disposes the prior notifier when update returns a new one.
                return HomeViewModel(
                  ledgerRepository: repository,
                  settingsRepository: settings,
                  categoryRepository: categoryRepository,
                  recurringTemplateRepository: recurringTemplateRepository,
                  investmentRepository: context.read<InvestmentRepository>(),
                  membershipRepository: context.read<MembershipRepository>(),
                  booksGeneration: session.generation,
                );
              },
        ),
        ChangeNotifierProxyProvider2<
          ActiveBooksSession,
          AccountRepository,
          AccountManagementViewModel
        >(
          create: (context) => AccountManagementViewModel(
            accountRepository: context.read<AccountRepository>(),
            booksGeneration: context.read<ActiveBooksSession>().generation,
          ),
          update: (_, session, accountRepository, previous) {
            if (previous != null &&
                previous.booksGeneration == session.generation) {
              return previous;
            }
            return AccountManagementViewModel(
              accountRepository: accountRepository,
              booksGeneration: session.generation,
            );
          },
        ),
        ChangeNotifierProxyProvider2<
          ActiveBooksSession,
          PayeeRepository,
          PayeeManagementViewModel
        >(
          create: (context) => PayeeManagementViewModel(
            payeeRepository: context.read<PayeeRepository>(),
            booksGeneration: context.read<ActiveBooksSession>().generation,
          ),
          update: (_, session, repository, previous) {
            if (previous != null &&
                previous.booksGeneration == session.generation) {
              return previous;
            }
            return PayeeManagementViewModel(
              payeeRepository: repository,
              booksGeneration: session.generation,
            );
          },
        ),
        ChangeNotifierProxyProvider3<
          RecurringTemplateRepository,
          AccountRepository,
          CategoryRepository,
          RecurringTemplateManagementViewModel
        >(
          create: (context) => RecurringTemplateManagementViewModel(
            recurringTemplateRepository: context
                .read<RecurringTemplateRepository>(),
            accountRepository: context.read<AccountRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
          ),
          update:
              (
                _,
                repository,
                accountRepository,
                categoryRepository,
                previous,
              ) =>
                  previous ??
                  RecurringTemplateManagementViewModel(
                    recurringTemplateRepository: repository,
                    accountRepository: accountRepository,
                    categoryRepository: categoryRepository,
                  ),
        ),
      ],
      child: const _AppRouterHost(),
    );
  }
}

/// Builds the [GoRouter] once per books-set generation ([initState] plus
/// rebuild on [ActiveBooksSession.generation] change) and hosts
/// [MaterialApp.router]. Deliberately a [StatefulWidget], not a [Builder]
/// watching [LocaleController] directly: a plain `Builder` that both calls
/// `buildAppRouter` and watches `LocaleController` would rebuild a brand
/// new router (and a brand new [AppNavigationPolicy], resetting its
/// once-per-session chain-verification flag) on every language change -
/// including a fresh `GoRouter`/`Navigator` for the *current* route,
/// which would reset any transient State in the widget on it (observed
/// via onboarding-language-selection's mandatory-selection flag being
/// silently wiped the instant it was set). The router doesn't need to
/// change when locale changes - only `MaterialApp.locale` and the
/// rendered text do - so this splits "watch locale for display" from
/// "build the router once per books set."
class _AppRouterHost extends StatefulWidget {
  const _AppRouterHost();

  @override
  State<_AppRouterHost> createState() => _AppRouterHostState();
}

class _AppRouterHostState extends State<_AppRouterHost>
    with WidgetsBindingObserver {
  late final AppLockController _appLockController = context
      .read<AppLockController>();
  GoRouter? _router;
  int _booksGeneration = -1;

  GoRouter _buildRouter() {
    return buildAppRouter(
      context.read<LedgerRepository>(),
      context.read<AccountRepository>(),
      context.read<CategoryRepository>(),
      context.read<PayeeRepository>(),
      context.read<IdentityRepository>(),
      context.read<LedgerChainVerifier>(),
      context.read<InvestmentRepository>(),
      context.read<BooksCopyRepository>(),
      context.read<StatementImportRepository>(),
      context.read<SettingsRepository>(),
      _appLockController,
      membershipRepository: context.read<MembershipRepository>(),
      peerSyncService: context.read<PeerSyncService>(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _booksGeneration = context.read<ActiveBooksSession>().generation;
    _router = _buildRouter();
    _migrateKeyAccessibilityIfNeeded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<PeerSyncService>().startForeground());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<PeerSyncService>().onAppResumed());
    }
  }

  Future<void> _migrateKeyAccessibilityIfNeeded() async {
    final settings = context.read<SettingsRepository>();
    final identity = context.read<IdentityRepository>();
    await identity.migrateKeyAccessibilityIfNeeded(
      alreadyMigrated: await settings.isKeyAccessibilityMigrated(),
      markMigrated: () => settings.setKeyAccessibilityMigrated(true),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ActiveBooksSession>();
    if (_booksGeneration != session.generation) {
      _booksGeneration = session.generation;
      _router?.dispose();
      _router = _buildRouter();
      // Restart advertise/browse against the newly active books set (join
      // and books-switcher both bump generation), then pull catch-up so a
      // newly joined Claimant receives categories before Claims opens.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(() async {
          try {
            final sync = context.read<PeerSyncService>();
            await sync.startForeground();
            await sync.syncNow();
          } catch (_) {
            // Post-join catch-up is best-effort; failures must not abort the
            // Flutter test / UI isolate.
          }
        }());
      });
    }
    final localeController = context.watch<LocaleController>();
    return SnapshotHidingOverlay(
      appLockController: _appLockController,
      child: MaterialApp.router(
        // Opt-in only (store-listing-assembly task 2.2): hides the debug
        // ribbon when capturing store screenshots via
        // `--dart-define=HIDE_DEBUG_BANNER=true`. Off by default, so every
        // normal debug run keeps the banner.
        debugShowCheckedModeBanner: !const bool.fromEnvironment(
          'HIDE_DEBUG_BANNER',
        ),
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: buildAppTheme(),
        locale: localeController.overrideLocale,
        localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
        supportedLocales: supportedAppLocales,
        localeListResolutionCallback: (locales, supported) {
          final device = locales?.isNotEmpty == true ? locales!.first : null;
          return localeController.resolve(device);
        },
        routerConfig: _router!,
      ),
    );
  }
}
