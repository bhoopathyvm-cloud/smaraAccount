import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/ledger_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/statement_import_repository.dart';
import '../domain/lock/app_lock_service.dart';
import '../domain/lock/biometric_authenticator.dart';
import '../domain/models/home_overview.dart';
import '../domain/models/transaction_direction.dart';
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
import 'features/settle_pending_transfer/view_models/settle_pending_transfer_view_model.dart';
import 'features/settle_pending_transfer/views/settle_pending_transfer_view.dart';
import 'features/statement_import/view_models/statement_import_view_model.dart';
import 'features/statement_import/views/statement_import_view.dart';
import 'features/summary/view_models/summary_view_model.dart';
import 'features/summary/views/summary_view.dart';
import 'features/transfer/view_models/transfer_view_model.dart';
import 'features/transfer/views/transfer_view.dart';

// deferred-onboarding-first-entry: onboarding now runs currency selection
// first (which commits the signing identity and seeds starter accounts),
// then names the first account, then a guided first entry, and only then
// the mandatory recovery-phrase acknowledgment screens - see the redirect
// logic below.
const _currencyPath = '/onboarding/currency';
const _firstAccountPath = '/onboarding/first-account';
const _firstEntryPath = '/onboarding/first-entry';
const _acknowledgmentPaths = {
  '/onboarding/recovery-phrase',
  '/onboarding/keystore-export',
  '/onboarding/confirm',
};
const _onboardingPaths = {
  _currencyPath,
  _firstAccountPath,
  _firstEntryPath,
  ..._acknowledgmentPaths,
};
const _restorePath = '/restore';
const _migrationPath = '/restore/migrate';
const _restoreRelatedPaths = {_restorePath, _migrationPath};
const _currencyBackfillPath = '/currency-backfill';
// first-week-setup-wizard: shown exactly once, gated on
// SettingsRepository.isFirstWeekSetupCompleted() - see the redirect logic
// below, checked right after the currency-backfill gate (same reasoning:
// no financial content exists to lock or show before this).
const _setupWizardPath = '/onboarding/first-week-setup';

/// Gates every navigation on the device signing identity's state (spec:
/// "Device Signing Identity", "Mandatory Recovery Phrase Acknowledgment",
/// "Recoverable Reinstall or Device Migration", "Startup Integrity
/// Verification", and deferred-onboarding-first-entry's "Guided First
/// Entry Before Acknowledgment"):
///
///  - no identity yet -> pick a currency (commits the identity + starter
///    accounts automatically, before the phrase is ever shown)
///  - identity committed but not yet acknowledged, no entry recorded yet
///    -> name the first account, then guided first entry
///  - identity committed but not yet acknowledged, first entry recorded
///    -> the mandatory recovery-phrase acknowledgment screens
///  - identity exists but this device's secure storage has no matching
///    key -> restore (recovery phrase / keystore file)
///  - identity exists and matches -> run verifyChain() once per app
///    session, then the app shell is reachable
const _lockPath = '/lock';

GoRouter buildAppRouter(
  LedgerRepository ledgerRepository,
  StatementImportRepository statementImportRepository,
  SettingsRepository settingsRepository,
  AppLockController appLockController,
) {
  var hasVerifiedThisSession = false;

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: appLockController,
    redirect: (context, state) async {
      final isOnboardingRoute = _onboardingPaths.contains(
        state.matchedLocation,
      );
      final isRestoreRoute = _restoreRelatedPaths.contains(
        state.matchedLocation,
      );
      final isLockRoute = state.matchedLocation == _lockPath;

      final identity = await ledgerRepository.currentIdentity();
      if (identity == null) {
        return state.matchedLocation == _currencyPath ? null : _currencyPath;
      }

      if (identity.acknowledgedAt == null) {
        // Committed but not yet acknowledged: deferred-onboarding-first-entry's
        // window between currency selection and the mandatory recovery-phrase
        // acknowledgment screens. Exactly one guided entry is allowed through
        // before acknowledgment is forced - re-checked on every navigation
        // (including app resume after backgrounding/kill), so it's never
        // bypassable.
        final hasRecordedFirstEntry = await ledgerRepository
            .hasAnyJournalEntries();
        if (!hasRecordedFirstEntry) {
          return state.matchedLocation == _firstAccountPath ||
                  state.matchedLocation == _firstEntryPath
              ? null
              : _firstAccountPath;
        }
        return _acknowledgmentPaths.contains(state.matchedLocation)
            ? null
            : '/onboarding/recovery-phrase';
      }

      final hasMatchingKey = await ledgerRepository.hasMatchingStoredKey(
        identity,
      );
      if (!hasMatchingKey) {
        return isRestoreRoute ? null : _restorePath;
      }

      if (!hasVerifiedThisSession) {
        await ledgerRepository.verifyChain();
        hasVerifiedThisSession = true;
      }

      final isCurrencyBackfillRoute =
          state.matchedLocation == _currencyBackfillPath;
      if (await ledgerRepository.needsCurrencyBackfill()) {
        return isCurrencyBackfillRoute ? null : _currencyBackfillPath;
      }

      final isSetupWizardRoute = state.matchedLocation == _setupWizardPath;
      if (!await settingsRepository.isFirstWeekSetupCompleted()) {
        return isSetupWizardRoute ? null : _setupWizardPath;
      }

      // app-lock: checked only once the ledger itself is reachable -
      // onboarding/restore/currency-backfill screens show no financial
      // content yet, so there's nothing to lock behind them. Re-evaluated
      // on every navigation via refreshListenable, so a background-then-
      // resume relock (AppLockController.didChangeAppLifecycleState)
      // takes effect immediately, not just on the next explicit navigation.
      if (await settingsRepository.isAppLockEnabled() &&
          !appLockController.isUnlocked) {
        return isLockRoute ? null : _lockPath;
      }

      if (isOnboardingRoute ||
          isRestoreRoute ||
          isCurrencyBackfillRoute ||
          isSetupWizardRoute ||
          isLockRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: _currencyPath,
        builder: (context, state) => CurrencySelectionView(
          viewModel: context.read<RecoveryPhraseSetupViewModel>(),
          onFinished: () => context.go(_firstAccountPath),
        ),
      ),
      GoRoute(
        path: _firstAccountPath,
        builder: (context, state) => FirstAccountNameView(
          viewModel: FirstAccountNameViewModel(
            ledgerRepository: ledgerRepository,
          ),
          onFinished: () => context.go(_firstEntryPath),
        ),
      ),
      GoRoute(
        path: _firstEntryPath,
        builder: (context, state) => RecordTransactionView(
          viewModel: RecordTransactionViewModel(
            ledgerRepository: ledgerRepository,
          ),
          onSaved: () => context.go('/onboarding/recovery-phrase'),
        ),
      ),
      GoRoute(
        path: '/onboarding/recovery-phrase',
        builder: (context, state) => RecoveryPhraseView(
          viewModel: context.read<RecoveryPhraseSetupViewModel>(),
          onContinue: () => context.go('/onboarding/keystore-export'),
        ),
      ),
      GoRoute(
        path: '/onboarding/keystore-export',
        builder: (context, state) => KeystoreExportView(
          viewModel: context.read<RecoveryPhraseSetupViewModel>(),
          onContinue: () => context.go('/onboarding/confirm'),
        ),
      ),
      GoRoute(
        path: '/onboarding/confirm',
        builder: (context, state) => RecoveryPhraseConfirmView(
          viewModel: context.read<RecoveryPhraseSetupViewModel>(),
          onConfirmed: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: _setupWizardPath,
        builder: (context, state) => FirstWeekSetupView(
          viewModel: FirstWeekSetupViewModel(
            ledgerRepository: ledgerRepository,
            settingsRepository: settingsRepository,
          ),
          onFinished: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: _currencyBackfillPath,
        builder: (context, state) => CurrencyBackfillView(
          viewModel: CurrencyBackfillViewModel(
            ledgerRepository: ledgerRepository,
          ),
          onFinished: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: _restorePath,
        builder: (context, state) => RestoreIdentityView(
          viewModel: context.read<RestoreIdentityViewModel>(),
          onRestored: () => context.go('/home'),
          onNoRecoveryMaterial: () => context.push(_migrationPath),
        ),
      ),
      GoRoute(
        path: _migrationPath,
        builder: (context, state) => KeyLossMigrationView(
          viewModel: KeyLossMigrationViewModel(
            ledgerRepository: ledgerRepository,
          ),
          onMigrated: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: '/record-transaction',
        builder: (context, state) => RecordTransactionView(
          viewModel: RecordTransactionViewModel(
            ledgerRepository: ledgerRepository,
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
            ledgerRepository: ledgerRepository,
            initialFinancialAccountId: state.uri.queryParameters['accountId'],
          ),
          onFinished: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/settle-pending-transfer/:pendingTransferId',
        builder: (context, state) =>
            _buildSettlePendingTransfer(context, state, ledgerRepository),
      ),
      GoRoute(
        path: _lockPath,
        builder: (context, state) => LockView(
          viewModel: LockViewModel(
            appLockService: AppLockService(),
            biometricAuthenticator: LocalAuthBiometricAuthenticator(),
            settingsRepository: settingsRepository,
            lockController: appLockController,
          ),
        ),
      ),
      GoRoute(
        path: '/fix',
        builder: (context, state) =>
            _buildFixEntry(context, state, ledgerRepository),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsView(
          viewModel: SettingsViewModel(
            settingsRepository: settingsRepository,
            ledgerRepository: ledgerRepository,
            appLockService: AppLockService(),
            biometricAuthenticator: LocalAuthBiometricAuthenticator(),
            appLockController: appLockController,
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
                path: '/home',
                builder: (context, state) => HomeView(
                  viewModel: context.read<HomeViewModel>(),
                  onAccountTap: (accountId) => context.go(
                    '/register?accountId=${Uri.encodeQueryComponent(accountId)}',
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
  final extra = state.extra! as ({RegisterRow row, String financialAccountId});
  return CorrectionView(
    viewModel: CorrectionViewModel(
      ledgerRepository: ledgerRepository,
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

/// Looks up the tapped pending transfer's [PendingTransferSummary] from the
/// already-loaded Home overview (the only place that summary - names,
/// currency, amount - is computed) rather than re-deriving it here.
Widget _buildSettlePendingTransfer(
  BuildContext context,
  GoRouterState state,
  LedgerRepository ledgerRepository,
) {
  final pendingTransferId = state.pathParameters['pendingTransferId'];
  final pendingTransfers =
      context.read<HomeViewModel>().overview?.pendingTransfers ?? const [];
  PendingTransferSummary? summary;
  for (final candidate in pendingTransfers) {
    if (candidate.pendingTransfer.id == pendingTransferId) {
      summary = candidate;
      break;
    }
  }
  if (summary == null) {
    return const Center(child: Text('Already settled.'));
  }
  return SettlePendingTransferView(
    viewModel: SettlePendingTransferViewModel(
      ledgerRepository: ledgerRepository,
      summary: summary,
    ),
    onSaved: () => context.pop(),
  );
}
