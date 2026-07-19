import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/ledger_repository.dart';
import 'core/app_shell.dart';
import 'features/category_management/view_models/category_management_view_model.dart';
import 'features/category_management/views/category_management_view.dart';
import 'features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'features/onboarding/views/keystore_export_view.dart';
import 'features/onboarding/views/recovery_phrase_confirm_view.dart';
import 'features/onboarding/views/recovery_phrase_view.dart';
import 'features/record_transaction/view_models/record_transaction_view_model.dart';
import 'features/record_transaction/views/record_transaction_view.dart';
import 'features/register/view_models/register_view_model.dart';
import 'features/register/views/register_view.dart';
import 'features/restore/view_models/restore_identity_view_model.dart';
import 'features/restore/views/restore_identity_view.dart';
import 'features/summary/view_models/summary_view_model.dart';
import 'features/summary/views/summary_view.dart';

const _onboardingPaths = {
  '/onboarding/recovery-phrase',
  '/onboarding/keystore-export',
  '/onboarding/confirm',
};
const _restorePath = '/restore';

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
    initialLocation: '/register',
    redirect: (context, state) async {
      final isOnboardingRoute = _onboardingPaths.contains(
        state.matchedLocation,
      );
      final isRestoreRoute = state.matchedLocation == _restorePath;

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

      if (isOnboardingRoute || isRestoreRoute) {
        return '/register';
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
          onConfirmed: () => context.go('/register'),
        ),
      ),
      GoRoute(
        path: _restorePath,
        builder: (context, state) => RestoreIdentityView(
          viewModel: context.read<RestoreIdentityViewModel>(),
          onRestored: () => context.go('/register'),
        ),
      ),
      GoRoute(
        path: '/record-transaction',
        builder: (context, state) => RecordTransactionView(
          viewModel: RecordTransactionViewModel(
            ledgerRepository: ledgerRepository,
          ),
          ledgerRepository: ledgerRepository,
          onSaved: () => context.pop(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/register',
                builder: (context, state) => RegisterView(
                  viewModel: context.read<RegisterViewModel>(),
                  onAddTransaction: () => context.push('/record-transaction'),
                ),
              ),
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
