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
import 'data/repositories/identity_repository.dart';
import 'data/repositories/investment_repository.dart';
import 'data/repositories/ledger_chain_store.dart';
import 'data/repositories/ledger_chain_verifier.dart';
import 'data/repositories/ledger_repository.dart';
import 'data/repositories/payee_repository.dart';
import 'data/repositories/recurring_template_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/statement_import_repository.dart';
import 'domain/crypto/signing_key_service.dart';
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
        ProxyProvider3<
          AppDatabase,
          LedgerRepository,
          AccountChartReader,
          AccountRepository
        >(
          update: (_, db, ledgerRepository, chart, _) => AccountRepository(
            database: db,
            ledgerRepository: ledgerRepository,
            chart: chart,
          ),
        ),
        ProxyProvider2<AppDatabase, AccountChartReader, CategoryRepository>(
          update: (_, db, chart, _) =>
              CategoryRepository(database: db, chart: chart),
        ),
        ProxyProvider<AppDatabase, PayeeRepository>(
          update: (_, db, _) => PayeeRepository(database: db),
        ),
        ProxyProvider4<
          AppDatabase,
          AccountRepository,
          LedgerChainStore,
          SigningKeyService,
          IdentityRepository
        >(
          update: (_, db, accountRepository, chain, keys, _) =>
              IdentityRepository(
                database: db,
                accountRepository: accountRepository,
                chain: chain,
                signingKeyService: keys,
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
        ProxyProvider<ActiveBooksSession, SettingsRepository>(
          update: (_, session, _) =>
              SettingsRepository(booksSetStore: session.store),
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
        ProxyProvider2<
          AppDatabase,
          LedgerRepository,
          RecurringTemplateRepository
        >(
          update: (_, db, ledgerRepository, _) => RecurringTemplateRepository(
            database: db,
            ledgerRepository: ledgerRepository,
          ),
        ),
        Provider<AppLockService>(create: (_) => AppLockService()),
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
        ProxyProvider4<
          AppDatabase,
          LedgerRepository,
          AccountRepository,
          CategoryRepository,
          StatementImportRepository
        >(
          update:
              (
                _,
                db,
                ledgerRepository,
                accountRepository,
                categoryRepository,
                _,
              ) => StatementImportRepository(
                database: db,
                ledgerRepository: ledgerRepository,
                accountRepository: accountRepository,
                categoryRepository: categoryRepository,
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
                previous?.dispose();
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
            previous?.dispose();
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
            previous?.dispose();
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
                previous?.dispose();
                return HomeViewModel(
                  ledgerRepository: repository,
                  settingsRepository: settings,
                  categoryRepository: categoryRepository,
                  recurringTemplateRepository: recurringTemplateRepository,
                  investmentRepository: context.read<InvestmentRepository>(),
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
            previous?.dispose();
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
            previous?.dispose();
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

class _AppRouterHostState extends State<_AppRouterHost> {
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
    );
  }

  @override
  void initState() {
    super.initState();
    _booksGeneration = context.read<ActiveBooksSession>().generation;
    _router = _buildRouter();
    _migrateKeyAccessibilityIfNeeded();
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
