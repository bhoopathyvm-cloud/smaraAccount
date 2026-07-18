import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/ledger_repository.dart';
import 'core/app_shell.dart';
import 'features/category_management/view_models/category_management_view_model.dart';
import 'features/category_management/views/category_management_view.dart';
import 'features/record_transaction/view_models/record_transaction_view_model.dart';
import 'features/record_transaction/views/record_transaction_view.dart';
import 'features/register/view_models/register_view_model.dart';
import 'features/register/views/register_view.dart';
import 'features/summary/view_models/summary_view_model.dart';
import 'features/summary/views/summary_view.dart';

GoRouter buildAppRouter(LedgerRepository ledgerRepository) {
  return GoRouter(
    initialLocation: '/register',
    routes: [
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
