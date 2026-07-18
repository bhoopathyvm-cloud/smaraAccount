import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database/app_database.dart';
import 'data/repositories/ledger_repository.dart';
import 'ui/app_router.dart';
import 'ui/core/app_theme.dart';
import 'ui/features/category_management/view_models/category_management_view_model.dart';
import 'ui/features/register/view_models/register_view_model.dart';
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
        ChangeNotifierProxyProvider<LedgerRepository, RegisterViewModel>(
          create: (context) => RegisterViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ?? RegisterViewModel(ledgerRepository: repository),
        ),
        ChangeNotifierProxyProvider<LedgerRepository, SummaryViewModel>(
          create: (context) => SummaryViewModel(
            ledgerRepository: context.read<LedgerRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ?? SummaryViewModel(ledgerRepository: repository),
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
      ],
      child: Builder(
        builder: (context) {
          final router = buildAppRouter(context.read<LedgerRepository>());
          return MaterialApp.router(
            title: 'Smara Accounting',
            theme: buildAppTheme(),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
