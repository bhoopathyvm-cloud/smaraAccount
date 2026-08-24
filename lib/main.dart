import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database/app_database.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/ledger_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/statement_import_repository.dart';
import 'l10n/l10n.dart';
import 'ui/app_router.dart';
import 'ui/core/app_lock_controller.dart';
import 'ui/core/app_theme.dart';
import 'ui/core/snapshot_hiding_overlay.dart';
import 'ui/features/account_management/view_models/account_management_view_model.dart';
import 'ui/features/category_management/view_models/category_management_view_model.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'ui/features/payee_management/view_models/payee_management_view_model.dart';
import 'ui/features/recurring_template_management/view_models/recurring_template_management_view_model.dart';
import 'ui/features/register/view_models/register_view_model.dart';
import 'ui/features/restore/view_models/restore_identity_view_model.dart';
import 'ui/features/summary/view_models/summary_view_model.dart';

void main() {
  runApp(const SmaraAccountingApp());
}

class SmaraAccountingApp extends StatelessWidget {
  const SmaraAccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),
        ProxyProvider<AppDatabase, LedgerRepository>(
          update: (_, db, _) => LedgerRepository(database: db),
        ),
        ProxyProvider2<AppDatabase, LedgerRepository, AccountRepository>(
          update: (_, db, ledgerRepository, _) => AccountRepository(
            database: db,
            ledgerRepository: ledgerRepository,
          ),
        ),
        Provider<SettingsRepository>(create: (_) => SettingsRepository()),
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
        ProxyProvider3<
          AppDatabase,
          LedgerRepository,
          AccountRepository,
          StatementImportRepository
        >(
          update: (_, db, ledgerRepository, accountRepository, _) =>
              StatementImportRepository(
                database: db,
                ledgerRepository: ledgerRepository,
                accountRepository: accountRepository,
              ),
        ),
        ChangeNotifierProxyProvider2<
          LedgerRepository,
          AccountRepository,
          RegisterViewModel
        >(
          create: (context) => RegisterViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
            accountRepository: context.read<AccountRepository>(),
          ),
          update: (_, repository, accountRepository, previous) =>
              previous ??
              RegisterViewModel(
                ledgerRepository: repository,
                accountRepository: accountRepository,
              ),
        ),
        ChangeNotifierProxyProvider2<
          LedgerRepository,
          AccountRepository,
          SummaryViewModel
        >(
          create: (context) => SummaryViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
            accountRepository: context.read<AccountRepository>(),
          ),
          update: (_, repository, accountRepository, previous) =>
              previous ??
              SummaryViewModel(
                ledgerRepository: repository,
                accountRepository: accountRepository,
              ),
        ),
        ChangeNotifierProxyProvider<
          LedgerRepository,
          CategoryManagementViewModel
        >(
          create: (context) => CategoryManagementViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ??
              CategoryManagementViewModel(ledgerRepository: repository),
        ),
        ChangeNotifierProxyProvider<
          LedgerRepository,
          RecoveryPhraseSetupViewModel
        >(
          create: (context) => RecoveryPhraseSetupViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ??
              RecoveryPhraseSetupViewModel(ledgerRepository: repository),
        ),
        ChangeNotifierProxyProvider<LedgerRepository, RestoreIdentityViewModel>(
          create: (context) => RestoreIdentityViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ??
              RestoreIdentityViewModel(ledgerRepository: repository),
        ),
        ChangeNotifierProxyProvider2<
          LedgerRepository,
          SettingsRepository,
          HomeViewModel
        >(
          create: (context) => HomeViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
            settingsRepository: context.read<SettingsRepository>(),
          ),
          update: (_, repository, settings, previous) =>
              previous ??
              HomeViewModel(
                ledgerRepository: repository,
                settingsRepository: settings,
              ),
        ),
        ChangeNotifierProxyProvider<
          AccountRepository,
          AccountManagementViewModel
        >(
          create: (context) => AccountManagementViewModel(
            accountRepository: context.read<AccountRepository>(),
          ),
          update: (_, accountRepository, previous) =>
              previous ??
              AccountManagementViewModel(accountRepository: accountRepository),
        ),
        ChangeNotifierProxyProvider<LedgerRepository, PayeeManagementViewModel>(
          create: (context) => PayeeManagementViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ??
              PayeeManagementViewModel(ledgerRepository: repository),
        ),
        ChangeNotifierProxyProvider2<
          LedgerRepository,
          AccountRepository,
          RecurringTemplateManagementViewModel
        >(
          create: (context) => RecurringTemplateManagementViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
            accountRepository: context.read<AccountRepository>(),
          ),
          update: (_, repository, accountRepository, previous) =>
              previous ??
              RecurringTemplateManagementViewModel(
                ledgerRepository: repository,
                accountRepository: accountRepository,
              ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final appLockController = context.read<AppLockController>();
          final localeController = context.watch<LocaleController>();
          final router = buildAppRouter(
            context.read<LedgerRepository>(),
            context.read<AccountRepository>(),
            context.read<StatementImportRepository>(),
            context.read<SettingsRepository>(),
            appLockController,
          );
          return SnapshotHidingOverlay(
            appLockController: appLockController,
            child: MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              theme: buildAppTheme(),
              locale: localeController.overrideLocale,
              localizationsDelegates:
                  appLocalizationsDelegatesWithMaterialFallback,
              supportedLocales: supportedAppLocales,
              localeListResolutionCallback: (locales, supported) {
                final device = locales?.isNotEmpty == true
                    ? locales!.first
                    : null;
                return localeController.resolve(device);
              },
              routerConfig: router,
            ),
          );
        },
      ),
    );
  }
}
