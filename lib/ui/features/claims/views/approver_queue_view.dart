import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../view_models/approver_queue_view_model.dart';

/// Approver review queue with per-item approve / reject actions.
class ApproverQueueView extends StatelessWidget {
  const ApproverQueueView({super.key, required this.viewModel});

  final ApproverQueueViewModel viewModel;

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
          appBar: AppBar(title: Text(l10n.claimsReviewTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (viewModel.lastActionError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    viewModel.lastActionError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (viewModel.queue.isEmpty)
                Text(l10n.claimsNoClaimsToReview)
              else
                ...viewModel.queue.expand((claim) {
                  return [
                    Text(
                      'Claim ${claim.id.substring(0, 8)} · ${claim.status.name}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    ...claim.items.map((item) {
                      final pending = item.isPendingDecision;
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${item.paidAmountMinor / 100} ${item.paidCurrency}'
                            ' → ${item.companyCurrencyAmountMinor / 100}',
                          ),
                          subtitle: Text(item.description ?? item.categoryId),
                          trailing: pending
                              ? Wrap(
                                  spacing: 4,
                                  children: [
                                    TextButton(
                                      onPressed: () => viewModel.approve(
                                        claimItemId: item.id,
                                      ),
                                      child: Text(l10n.claimsApprove),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final reason = await _askReason(
                                          context,
                                          l10n.claimsRejectReasonTitle,
                                        );
                                        if (reason == null) return;
                                        await viewModel.reject(
                                          claimItemId: item.id,
                                          reason: reason,
                                        );
                                      },
                                      child: Text(l10n.claimsReject),
                                    ),
                                  ],
                                )
                              : Text(item.decision!.kind.name),
                        ),
                      );
                    }),
                    const Divider(),
                  ];
                }),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _askReason(BuildContext context, String title) async {
    final l10n = l10nOf(context);
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
  }
}
