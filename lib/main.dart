import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database/app_database.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/identity_repository.dart';
import 'data/repositories/investment_repository.dart';
import 'data/repositories/ledger_backup_repository.dart';
import 'data/repositories/ledger_repository.dart';
import 'data/repositories/payee_repository.dart';
import 'data/repositories/recurring_template_repository.dart';
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
        ProxyProvider<AppDatabase, CategoryRepository>(
          update: (_, db, _) => CategoryRepository(database: db),
        ),
        ProxyProvider<AppDatabase, PayeeRepository>(
          update: (_, db, _) => PayeeRepository(database: db),
        ),
        ProxyProvider2<AppDatabase, AccountRepository, IdentityRepository>(
          update: (_, db, accountRepository, _) => IdentityRepository(
            database: db,
            accountRepository: accountRepository,
          ),
        ),
        ProxyProvider2<AppDatabase, IdentityRepository, LedgerBackupRepository>(
          update: (_, db, identityRepository, _) => LedgerBackupRepository(
            database: db,
            identityRepository: identityRepository,
          ),
        ),
        ProxyProvider4<
          AppDatabase,
          LedgerRepository,
          AccountRepository,
          CategoryRepository,
          InvestmentRepository
        >(
          update:
              (
                _,
                db,
                ledgerRepository,
                accountRepository,
                categoryRepository,
                _,
              ) => InvestmentRepository(
                database: db,
                ledgerRepository: ledgerRepository,
                accountRepository: accountRepository,
                categoryRepository: categoryRepository,
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
        ChangeNotifierProxyProvider3<
          LedgerRepository,
          AccountRepository,
          CategoryRepository,
          RegisterViewModel
        >(
          create: (context) => RegisterViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
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
                  RegisterViewModel(
                    ledgerRepository: repository,
                    accountRepository: accountRepository,
                    categoryRepository: categoryRepository,
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
          CategoryRepository,
          CategoryManagementViewModel
        >(
          create: (context) => CategoryManagementViewModel(
            categoryRepository: context.read<CategoryRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ??
              CategoryManagementViewModel(categoryRepository: repository),
        ),
        ChangeNotifierProxyProvider<
          IdentityRepository,
          RecoveryPhraseSetupViewModel
        >(
          create: (context) => RecoveryPhraseSetupViewModel(
            identityRepository: context.read<IdentityRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ??
              RecoveryPhraseSetupViewModel(identityRepository: repository),
        ),
        ChangeNotifierProxyProvider<
          IdentityRepository,
          RestoreIdentityViewModel
        >(
          create: (context) => RestoreIdentityViewModel(
            identityRepository: context.read<IdentityRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ??
              RestoreIdentityViewModel(identityRepository: repository),
        ),
        ChangeNotifierProxyProvider5<
          LedgerRepository,
          SettingsRepository,
          CategoryRepository,
          RecurringTemplateRepository,
          InvestmentRepository,
          HomeViewModel
        >(
          create: (context) => HomeViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
            settingsRepository: context.read<SettingsRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
            recurringTemplateRepository: context
                .read<RecurringTemplateRepository>(),
            investmentRepository: context.read<InvestmentRepository>(),
          ),
          update:
              (
                _,
                repository,
                settings,
                categoryRepository,
                recurringTemplateRepository,
                investmentRepository,
                previous,
              ) =>
                  previous ??
                  HomeViewModel(
                    ledgerRepository: repository,
                    settingsRepository: settings,
                    categoryRepository: categoryRepository,
                    recurringTemplateRepository: recurringTemplateRepository,
                    investmentRepository: investmentRepository,
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
        ChangeNotifierProxyProvider<PayeeRepository, PayeeManagementViewModel>(
          create: (context) => PayeeManagementViewModel(
            payeeRepository: context.read<PayeeRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ?? PayeeManagementViewModel(payeeRepository: repository),
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
      child: Builder(
        builder: (context) {
          final appLockController = context.read<AppLockController>();
          final localeController = context.watch<LocaleController>();
          final router = buildAppRouter(
            context.read<LedgerRepository>(),
            context.read<AccountRepository>(),
            context.read<CategoryRepository>(),
            context.read<PayeeRepository>(),
            context.read<IdentityRepository>(),
            context.read<InvestmentRepository>(),
            context.read<LedgerBackupRepository>(),
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
