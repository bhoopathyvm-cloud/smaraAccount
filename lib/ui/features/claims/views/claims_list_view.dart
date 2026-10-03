import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/navigation/app_navigation_policy.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/money_formatter.dart';
import '../../../core/system_inset_padding.dart';
import '../view_models/claims_list_view_model.dart';

/// Claimant home: own claims, balance copy, advances.
class ClaimsListView extends StatelessWidget {
  const ClaimsListView({
    super.key,
    required this.viewModel,
    this.companyCurrency = 'USD',
    this.onOpenEditor,
  });

  final ClaimsListViewModel viewModel;
  final String companyCurrency;

  /// When set, FAB / draft tap use this instead of go_router (widget tests).
  final void Function(String claimId)? onOpenEditor;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(l10n.claimsTitle)),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final draft = await viewModel.createDraft();
              await viewModel.load();
              if (!context.mounted) return;
              _openEditor(context, draft.id);
            },
            child: const Icon(Icons.add),
          ),
          body: ListView(
            padding: scrollPaddingAvoidingSystemInsets(context, base: 16),
            children: [
              Text(
                viewModel.balanceCopy(l10n),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (viewModel.balanceMinor != 0)
                Text(
                  '${formatAmountMinor(viewModel.balanceMinor.abs(), companyCurrency)}'
                  ' $companyCurrency',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              const SizedBox(height: 16),
              if (viewModel.advances.isNotEmpty) ...[
                Text(
                  l10n.claimsAdvances,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...viewModel.advances.map(
                  (a) => ListTile(
                    title: Text(
                      '${formatAmountMinor(a.amountMinor, companyCurrency)}'
                      ' $companyCurrency',
                    ),
                    subtitle: Text(a.description ?? l10n.claimsAdvanceDefault),
                  ),
                ),
                const Divider(),
              ],
              if (viewModel.items.isEmpty)
                Text(l10n.claimsNoClaimsYet)
              else
                ...viewModel.items.map((c) {
                  final date = c.submittedAt ?? c.createdAt;
                  final dateLabel =
                      '${date.year}-'
                      '${date.month.toString().padLeft(2, '0')}-'
                      '${date.day.toString().padLeft(2, '0')}';
                  return ListTile(
                    title: Text(
                      ClaimsListViewModel.statusLabel(c.status, l10n),
                    ),
                    subtitle: Text(
                      '${l10n.claimsItemCount(c.items.length)} · $dateLabel',
                    ),
                    onTap: () => _openEditor(context, c.id),
                  );
                }),
              if (viewModel.error != null)
                Text(
                  viewModel.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openEditor(BuildContext context, String claimId) {
    if (onOpenEditor != null) {
      onOpenEditor!(claimId);
      return;
    }
    context.push(
      '${AppNavPaths.claimEditor}?claimId=${Uri.encodeQueryComponent(claimId)}',
    );
  }
}
