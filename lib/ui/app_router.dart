import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/account_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/identity_repository.dart';
import '../data/repositories/investment_repository.dart';
import '../data/repositories/ledger_backup_repository.dart';
import '../data/repositories/ledger_repository.dart';
import '../data/repositories/payee_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/statement_import_repository.dart';
import '../l10n/l10n.dart';
import '../domain/lock/app_lock_service.dart';
import '../domain/lock/biometric_authenticator.dart';
import '../domain/models/transaction_direction.dart';
import '../domain/navigation/app_navigation_policy.dart';
import 'core/app_lock_controller.dart';
import 'core/app_shell.dart';
import 'features/account_management/view_models/account_management_view_model.dart';
import 'features/account_management/views/account_management_view.dart';
import 'features/category_management/view_models/category_management_view_model.dart';
import 'features/category_management/views/category_management_view.dart';
import 'features/correction_wizard/view_models/correction_view_model.dart';
import 'features/correction_wizard/views/correction_view.dart';
import 'features/first_week_setup/view_models/first_week_setup_view_model.dart';
import 'features/first_week_setup/views/first_week_setup_view.dart';
import 'features/home/view_models/home_view_model.dart';
import 'features/home/views/home_view.dart';
import 'features/holdings/view_models/holdings_view_model.dart';
import 'features/holdings/views/holdings_view.dart';
import 'features/lock/view_models/lock_view_model.dart';
import 'features/lock/views/lock_view.dart';
import 'features/migration/view_models/key_loss_migration_view_model.dart';
import 'features/migration/views/key_loss_migration_view.dart';
import 'features/onboarding/view_models/currency_backfill_view_model.dart';
import 'features/onboarding/view_models/first_account_name_view_model.dart';
import 'features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'features/onboarding/views/currency_backfill_view.dart';
import 'features/onboarding/views/currency_selection_view.dart';
import 'features/onboarding/views/first_account_name_view.dart';
import 'features/onboarding/views/keystore_export_view.dart';
import 'features/onboarding/views/recovery_phrase_confirm_view.dart';
import 'features/onboarding/views/recovery_phrase_view.dart';
import 'features/payee_management/view_models/payee_management_view_model.dart';
import 'features/payee_management/views/payee_management_view.dart';
import 'features/record_transaction/view_models/record_transaction_view_model.dart';
import 'features/recurring_template_management/view_models/recurring_template_management_view_model.dart';
import 'features/recurring_template_management/views/recurring_template_management_view.dart';
import 'features/record_transaction/views/record_transaction_view.dart';
import 'features/register/view_models/register_row.dart';
import 'features/register/view_models/register_view_model.dart';
import 'features/register/views/register_view.dart';
import 'features/restore/view_models/restore_identity_view_model.dart';
import 'features/restore/views/restore_identity_view.dart';
import 'features/settings/view_models/settings_view_model.dart';
import 'features/settings/views/settings_view.dart';
import 'features/settle_pending_transfer/views/settle_pending_transfer_route.dart';
import 'features/statement_import/view_models/statement_import_view_model.dart';
import 'features/statement_import/views/statement_import_view.dart';
import 'features/summary/view_models/summary_view_model.dart';
import 'features/summary/views/summary_view.dart';
import 'features/transfer/view_models/transfer_view_model.dart';
import 'features/transfer/views/transfer_view.dart';

/// Gates every navigation on the device signing identity's state (spec:
/// "Device Signing Identity", "Mandatory Recovery Phrase Acknowledgment",
/// "Recoverable Reinstall or Device Migration", "Startup Integrity
/// Verification", and deferred-onboarding-first-entry's "Guided First
/// Entry Before Acknowledgment"). Redirect decisions live in
/// [AppNavigationPolicy]; this function registers routes and forwards.
GoRouter buildAppRouter(
  LedgerRepository ledgerRepository,
  AccountRepository accountRepository,
  CategoryRepository categoryRepository,
  PayeeRepository payeeRepository,
  IdentityRepository identityRepository,
  InvestmentRepository investmentRepository,
  LedgerBackupRepository ledgerBackupRepository,
  StatementImportRepository statementImportRepository,
  SettingsRepository settingsRepository,
  AppLockController appLockController,
) {
  final navigationPolicy = AppNavigationPolicy(
    currentIdentity: identityRepository.currentIdentity,
    hasAnyJournalEntries: ledgerRepository.hasAnyJournalEntries,
    hasMatchingStoredKey: identityRepository.hasMatchingStoredKey,
    verifyChain: () async {
      await identityRepository.verifyChain();
    },
    needsCurrencyBackfill: accountRepository.needsCurrencyBackfill,
    isFirstWeekSetupCompleted: settingsRepository.isFirstWeekSetupCompleted,
    lockScreenRequired: () async {
      await appLockController.policy.ensureLoaded();
      return appLockController.policy.requiresLockScreen;
    },
  );

  return GoRouter(
    initialLocation: AppNavPaths.home,
    refreshListenable: appLockController,
    redirect: (context, state) =>
        navigationPolicy.resolve(state.matchedLocation),
    routes: [
      GoRoute(
        path: AppNavPaths.currency,
        builder: (context, state) => CurrencySelectionView(
          viewModel: context.read<RecoveryPhraseSetupViewModel>(),
          onFinished: () => context.go(AppNavPaths.firstAccount),
        ),
      ),
      GoRoute(
        path: AppNavPaths.firstAccount,
        builder: (context, state) => FirstAccountNameView(
          viewModel: FirstAccountNameViewModel(
            accountRepository: accountRepository,
          ),
          onFinished: () => context.go(AppNavPaths.firstEntry),
        ),
      ),
      GoRoute(
        path: AppNavPaths.firstEntry,
        builder: (context, state) => RecordTransactionView(
          viewModel: RecordTransactionViewModel(
            ledgerRepository: ledgerRepository,
            accountRepository: accountRepository,
            categoryRepository: categoryRepository,
            payeeRepository: payeeRepository,
          ),
          onSaved: () => context.go(AppNavPaths.recoveryPhrase),
        ),
      ),
      GoRoute(
        path: AppNavPaths.recoveryPhrase,
        builder: (context, state) => RecoveryPhraseView(
          viewModel: context.read<RecoveryPhraseSetupViewModel>(),
          onContinue: () => context.go(AppNavPaths.keystoreExport),
        ),
      ),
      GoRoute(
        path: AppNavPaths.keystoreExport,
        builder: (context, state) => KeystoreExportView(
          viewModel: context.read<RecoveryPhraseSetupViewModel>(),
          onContinue: () => context.go(AppNavPaths.confirm),
        ),
      ),
      GoRoute(
        path: AppNavPaths.confirm,
        builder: (context, state) => RecoveryPhraseConfirmView(
          viewModel: context.read<RecoveryPhraseSetupViewModel>(),
          onConfirmed: () => context.go(AppNavPaths.home),
        ),
      ),
      GoRoute(
        path: AppNavPaths.setupWizard,
        builder: (context, state) => FirstWeekSetupView(
          viewModel: FirstWeekSetupViewModel(
            accountRepository: accountRepository,
            settingsRepository: settingsRepository,
          ),
          onFinished: () => context.go(AppNavPaths.home),
        ),
      ),
      GoRoute(
        path: AppNavPaths.currencyBackfill,
        builder: (context, state) => CurrencyBackfillView(
          viewModel: CurrencyBackfillViewModel(
            accountRepository: accountRepository,
          ),
          onFinished: () => context.go(AppNavPaths.home),
        ),
      ),
      GoRoute(
        path: AppNavPaths.restore,
        builder: (context, state) => RestoreIdentityView(
          viewModel: context.read<RestoreIdentityViewModel>(),
          onRestored: () => context.go(AppNavPaths.home),
          onNoRecoveryMaterial: () => context.push(AppNavPaths.migrate),
        ),
      ),
      GoRoute(
        path: AppNavPaths.migrate,
        builder: (context, state) => KeyLossMigrationView(
          viewModel: KeyLossMigrationViewModel(
            ledgerRepository: ledgerRepository,
            identityRepository: identityRepository,
          ),
          onMigrated: () => context.go(AppNavPaths.home),
        ),
      ),
      GoRoute(
        path: '/record-transaction',
        builder: (context, state) => RecordTransactionView(
          viewModel: RecordTransactionViewModel(
            ledgerRepository: ledgerRepository,
            accountRepository: accountRepository,
            categoryRepository: categoryRepository,
            payeeRepository: payeeRepository,
            initialFinancialAccountId: state.uri.queryParameters['accountId'],
            initialDirection: _directionFromQueryParam(
              state.uri.queryParameters['direction'],
            ),
          ),
          onSaved: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/transfer',
        builder: (context, state) => TransferView(
          viewModel: TransferViewModel(
            ledgerRepository: ledgerRepository,
            accountRepository: accountRepository,
            categoryRepository: categoryRepository,
            initialFromAccountId: state.uri.queryParameters['fromAccountId'],
            // credit-card-household-flow: "Pay card" pre-fills the
            // destination via this query param; the ordinary transfer
            // route and mechanism are otherwise unchanged.
            initialToAccountId: state.uri.queryParameters['toAccountId'],
          ),
          onSaved: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/import-statement',
        builder: (context, state) => StatementImportView(
          viewModel: StatementImportViewModel(
            importRepository: statementImportRepository,
            accountRepository: accountRepository,
            categoryRepository: categoryRepository,
            payeeRepository: payeeRepository,
            initialFinancialAccountId: state.uri.queryParameters['accountId'],
          ),
          onFinished: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/settle-pending-transfer/:pendingTransferId',
        builder: (context, state) => SettlePendingTransferRoute(
          pendingTransferId: state.pathParameters['pendingTransferId']!,
          ledgerRepository: ledgerRepository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
          onSaved: () => context.pop(),
        ),
      ),
      GoRoute(
        path: AppNavPaths.lock,
        builder: (context, state) => LockView(
          viewModel: LockViewModel(
            appLockService: context.read<AppLockService>(),
            biometricAuthenticator: context.read<BiometricAuthenticator>(),
            settingsRepository: settingsRepository,
            lockController: appLockController,
            localeController: context.read<LocaleController>(),
          ),
        ),
      ),
      GoRoute(
        path: '/fix',
        builder: (context, state) =>
            _buildFixEntry(context, state, ledgerRepository),
      ),
      GoRoute(
        path: '/holdings/:accountId',
        builder: (context, state) {
          final accountId = state.pathParameters['accountId']!;
          return HoldingsView(
            viewModel: HoldingsViewModel(
              ledgerRepository: ledgerRepository,
              accountRepository: accountRepository,
              categoryRepository: categoryRepository,
              investmentRepository: investmentRepository,
              settingsRepository: settingsRepository,
              accountId: accountId,
            ),
            onOpenRegister: () => context.go(
              '/register?accountId=${Uri.encodeQueryComponent(accountId)}',
            ),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsView(
          viewModel: SettingsViewModel(
            settingsRepository: settingsRepository,
            ledgerBackupRepository: ledgerBackupRepository,
            appLockService: context.read<AppLockService>(),
            biometricAuthenticator: context.read<BiometricAuthenticator>(),
            appLockController: appLockController,
            localeController: context.read<LocaleController>(),
          ),
          onOpenPayees: () => context.push('/payees'),
          onOpenRecurringTemplates: () => context.push('/recurring-templates'),
        ),
      ),
      GoRoute(
        path: '/payees',
        builder: (context, state) => PayeeManagementView(
          viewModel: context.read<PayeeManagementViewModel>(),
        ),
      ),
      GoRoute(
        path: '/recurring-templates',
        builder: (context, state) => RecurringTemplateManagementView(
          viewModel: context.read<RecurringTemplateManagementViewModel>(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppNavPaths.home,
                builder: (context, state) => HomeView(
                  viewModel: context.read<HomeViewModel>(),
                  onAccountTap: (accountId) => context.go(
                    '/register?accountId=${Uri.encodeQueryComponent(accountId)}',
                  ),
                  onInvestmentAccountTap: (accountId) => context.push(
                    '/holdings/${Uri.encodeComponent(accountId)}',
                  ),
                  onSettlePendingTransfer: (pendingTransferId) => context.push(
                    '/settle-pending-transfer/'
                    '${Uri.encodeQueryComponent(pendingTransferId)}',
                  ),
                  onOpenSettings: () => context.push('/settings'),
                  onSpent: () =>
                      context.push('/record-transaction?direction=spent'),
                  onReceived: () =>
                      context.push('/record-transaction?direction=received'),
                  onTransfer: () => context.push('/transfer'),
                  onImport: () => context.push('/import-statement'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/register', builder: _buildRegister),
              GoRoute(path: '/register/:accountId', builder: _buildRegister),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/summary',
                builder: (context, state) =>
                    SummaryView(viewModel: context.read<SummaryViewModel>()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/accounts',
                builder: (context, state) => AccountManagementView(
                  viewModel: context.read<AccountManagementViewModel>(),
                  onTransfer: () => context.push('/transfer'),
                  onImport: () => context.push('/import-statement'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => CategoryManagementView(
                  viewModel: context.read<CategoryManagementViewModel>(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// home-hub-capture: Home's and Register's Add sheets pass "spent" or
/// "received" through this query param so `/record-transaction` opens
/// with the right direction pre-selected. Anything else (including
/// absent, for every other pre-existing caller of this route) keeps the
/// form's own default.
TransactionDirection _directionFromQueryParam(String? value) {
  return switch (value) {
    'spent' => TransactionDirection.moneyOut,
    'received' => TransactionDirection.moneyIn,
    _ => TransactionDirection.moneyIn,
  };
}

RegisterView _buildRegister(BuildContext context, GoRouterState state) {
  final viewModel = context.read<RegisterViewModel>();
  final accountId =
      state.pathParameters['accountId'] ??
      state.uri.queryParameters['accountId'];
  // selectAccount() calls notifyListeners(), which can hit "setState()
  // called during build" if RegisterView's ListenableBuilder is already
  // mounted (e.g. tapping a different account on Home while the Register
  // tab is already showing another one) - this builder runs as part of
  // go_router's own build, so the mutation must be deferred to just after
  // the current frame instead of applied synchronously here.
  if (accountId != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.selectAccount(accountId);
    });
  }
  String recordTransactionLocation(String direction) {
    final selectedAccountId = viewModel.selectedAccountId;
    final directionParam = 'direction=$direction';
    return selectedAccountId == null
        ? '/record-transaction?$directionParam'
        : '/record-transaction?accountId=${Uri.encodeQueryComponent(selectedAccountId)}&$directionParam';
  }

  return RegisterView(
    viewModel: viewModel,
    onSpent: () => context.push(recordTransactionLocation('spent')),
    onReceived: () => context.push(recordTransactionLocation('received')),
    onTransfer: () {
      final selectedAccountId = viewModel.selectedAccountId;
      final location = selectedAccountId == null
          ? '/transfer'
          : '/transfer?fromAccountId=${Uri.encodeQueryComponent(selectedAccountId)}';
      context.push(location);
    },
    onImport: () {
      final selectedAccountId = viewModel.selectedAccountId;
      final location = selectedAccountId == null
          ? '/import-statement'
          : '/import-statement?accountId=${Uri.encodeQueryComponent(selectedAccountId)}';
      context.push(location);
    },
    onFixEntry: (row) {
      final selectedAccountId = viewModel.selectedAccountId;
      if (selectedAccountId == null) return;
      context.push(
        '/fix',
        extra: (row: row, financialAccountId: selectedAccountId),
      );
    },
    onPayCard: () {
      final selectedAccountId = viewModel.selectedAccountId;
      if (selectedAccountId == null) return;
      context.push(
        '/transfer?toAccountId=${Uri.encodeQueryComponent(selectedAccountId)}',
      );
    },
  );
}

/// Reads the [RegisterRow] and its account, both already loaded by the
/// Register screen, rather than re-fetching the entry (mirrors
/// [_buildSettlePendingTransfer] below).
CorrectionView _buildFixEntry(
  BuildContext context,
  GoRouterState state,
  LedgerRepository ledgerRepository,
) {
  final accountRepository = context.read<AccountRepository>();
  final categoryRepository = context.read<CategoryRepository>();
  final extra = state.extra! as ({RegisterRow row, String financialAccountId});
  return CorrectionView(
    viewModel: CorrectionViewModel(
      ledgerRepository: ledgerRepository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      entryId: extra.row.entryId,
      initialAmountMinor: extra.row.amountMinor,
      initialDirection: extra.row.direction,
      // Only reachable when RegisterViewModel.isRowFixable(row) is true,
      // which requires exactly one counterpart (split-transactions).
      initialCategoryId: extra.row.counterpartAccountIds.single,
      initialFinancialAccountId: extra.financialAccountId,
      initialTransactionDate: extra.row.transactionDate,
      initialDescription: extra.row.description,
    ),
    onFixed: () => context.pop(),
  );
}
