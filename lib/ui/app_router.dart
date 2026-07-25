import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/ledger_repository.dart';
import '../domain/models/home_overview.dart';
import 'core/app_shell.dart';
import 'features/account_management/view_models/account_management_view_model.dart';
import 'features/account_management/views/account_management_view.dart';
import 'features/category_management/view_models/category_management_view_model.dart';
import 'features/category_management/views/category_management_view.dart';
import 'features/home/view_models/home_view_model.dart';
import 'features/home/views/home_view.dart';
import 'features/migration/view_models/key_loss_migration_view_model.dart';
import 'features/migration/views/key_loss_migration_view.dart';
import 'features/onboarding/view_models/currency_backfill_view_model.dart';
import 'features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'features/onboarding/views/currency_backfill_view.dart';
import 'features/onboarding/views/currency_selection_view.dart';
import 'features/onboarding/views/keystore_export_view.dart';
import 'features/onboarding/views/recovery_phrase_confirm_view.dart';
import 'features/onboarding/views/recovery_phrase_view.dart';
import 'features/record_transaction/view_models/record_transaction_view_model.dart';
import 'features/record_transaction/views/record_transaction_view.dart';
import 'features/register/view_models/register_view_model.dart';
import 'features/register/views/register_view.dart';
import 'features/restore/view_models/restore_identity_view_model.dart';
import 'features/restore/views/restore_identity_view.dart';
import 'features/settle_pending_transfer/view_models/settle_pending_transfer_view_model.dart';
import 'features/settle_pending_transfer/views/settle_pending_transfer_view.dart';
import 'features/summary/view_models/summary_view_model.dart';
import 'features/summary/views/summary_view.dart';
import 'features/transfer/view_models/transfer_view_model.dart';
import 'features/transfer/views/transfer_view.dart';

const _onboardingPaths = {
  '/onboarding/recovery-phrase',
  '/onboarding/keystore-export',
  '/onboarding/confirm',
  '/onboarding/currency',
};
const _restorePath = '/restore';
const _migrationPath = '/restore/migrate';
const _restoreRelatedPaths = {_restorePath, _migrationPath};
const _currencyBackfillPath = '/currency-backfill';

/// Gates every navigation on the device signing identity's state (spec:
/// "Device Signing Identity", "Mandatory Recovery Phrase Acknowledgment",
/// "Recoverable Reinstall or Device Migration", "Startup Integrity
/// Verification"):
///
///  - no identity yet -> onboarding (generate + confirm a recovery phrase)
///  - identity exists but this device's secure storage has no matching
///    key -> restore (recovery phrase / keystore file)
///  - identity exists and matches -> run verifyChain() once per app
///    session, then the app shell is reachable
GoRouter buildAppRouter(LedgerRepository ledgerRepository) {
  var hasVerifiedThisSession = false;

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) async {
      final isOnboardingRoute = _onboardingPaths.contains(
        state.matchedLocation,
      );
      final isRestoreRoute = _restoreRelatedPaths.contains(
        state.matchedLocation,
      );

      final identity = await ledgerRepository.currentIdentity();
      if (identity == null) {
        return isOnboardingRoute ? null : '/onboarding/recovery-phrase';
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

      if (isOnboardingRoute || isRestoreRoute || isCurrencyBackfillRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
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
          onConfirmed: () => context.go('/onboarding/currency'),
        ),
      ),
      GoRoute(
        path: '/onboarding/currency',
        builder: (context, state) => CurrencySelectionView(
          viewModel: context.read<RecoveryPhraseSetupViewModel>(),
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
          ),
          ledgerRepository: ledgerRepository,
          onSaved: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/transfer',
        builder: (context, state) => TransferView(
          viewModel: TransferViewModel(ledgerRepository: ledgerRepository),
          onSaved: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/settle-pending-transfer/:pendingTransferId',
        builder: (context, state) =>
            _buildSettlePendingTransfer(context, state, ledgerRepository),
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
  return RegisterView(
    viewModel: viewModel,
    onAddTransaction: () {
      final selectedAccountId = viewModel.selectedAccountId;
      final location = selectedAccountId == null
          ? '/record-transaction'
          : '/record-transaction?accountId=${Uri.encodeQueryComponent(selectedAccountId)}';
      context.push(location);
    },
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
