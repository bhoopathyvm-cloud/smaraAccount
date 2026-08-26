import 'package:flutter/material.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/home_overview.dart';
import '../../../../l10n/l10n.dart';
import '../view_models/settle_pending_transfer_view_model.dart';
import 'settle_pending_transfer_view.dart';

/// Settle route: loads [PendingTransferSummary] by id without Home state.
class SettlePendingTransferRoute extends StatefulWidget {
  const SettlePendingTransferRoute({
    super.key,
    required this.pendingTransferId,
    required this.ledgerRepository,
    required this.accountRepository,
    required this.categoryRepository,
    this.onSaved,
  });

  final String pendingTransferId;
  final LedgerRepository ledgerRepository;
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;
  final VoidCallback? onSaved;

  @override
  State<SettlePendingTransferRoute> createState() =>
      _SettlePendingTransferRouteState();
}

class _SettlePendingTransferRouteState
    extends State<SettlePendingTransferRoute> {
  late final Future<PendingTransferSummary?> _load;
  SettlePendingTransferViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _load = widget.ledgerRepository.pendingTransferSummary(
      widget.pendingTransferId,
    );
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final summary = snapshot.data;
        if (summary == null) {
          return Center(child: Text(l10nOf(context).alreadySettled));
        }
        _viewModel ??= SettlePendingTransferViewModel(
          ledgerRepository: widget.ledgerRepository,
          accountRepository: widget.accountRepository,
          categoryRepository: widget.categoryRepository,
          summary: summary,
        );
        return SettlePendingTransferView(
          viewModel: _viewModel!,
          onSaved: widget.onSaved,
        );
      },
    );
  }
}
