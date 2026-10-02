import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../domain/models/claim_item.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_spacing.dart';
import '../../../core/money_formatter.dart';
import '../view_models/approver_queue_view_model.dart';
import '../view_models/claims_list_view_model.dart';

/// Approver review queue with per-item approve / reject / different-amount.
class ApproverQueueView extends StatelessWidget {
  const ApproverQueueView({
    super.key,
    required this.viewModel,
    this.companyCurrency = 'USD',
    this.categoryNames = const {},
    this.receiptThumbnails = const {},
  });

  final ApproverQueueViewModel viewModel;
  final String companyCurrency;
  final Map<String, String> categoryNames;

  /// Optional JPEG/PNG bytes keyed by claim item id for receipt thumbnails.
  final Map<String, Uint8List> receiptThumbnails;

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
                  final status = ClaimsListViewModel.statusLabel(
                    claim.status,
                    l10n,
                  );
                  return [
                    Text(
                      l10n.claimsReviewClaimHeading(status),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    ...claim.items.map((item) {
                      final pending = item.isPendingDecision;
                      final thumb = receiptThumbnails[item.id];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: thumb != null
                                    ? Image.memory(
                                        thumb,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const Icon(Icons.receipt_long),
                                      )
                                    : (item.receipt != null
                                          ? const Icon(Icons.receipt_long)
                                          : null),
                                title: Text(_amountLine(item)),
                                subtitle: Text(_subtitle(item, l10n)),
                              ),
                              if (pending)
                                Wrap(
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
                                        final result =
                                            await _askDifferentAmount(context);
                                        if (result == null) return;
                                        await viewModel.approve(
                                          claimItemId: item.id,
                                          differentAmountMinor: result.amount,
                                          reason: result.reason,
                                        );
                                      },
                                      child: Text(l10n.claimsApproveDifferent),
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
                              else
                                Text(item.decision!.kind.name),
                            ],
                          ),
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

  String _amountLine(ClaimItem item) {
    final paid = formatAmountMinor(item.paidAmountMinor, item.paidCurrency);
    final company = formatAmountMinor(
      item.companyCurrencyAmountMinor,
      companyCurrency,
    );
    return '$paid ${item.paidCurrency} → $company $companyCurrency';
  }

  String _subtitle(ClaimItem item, AppLocalizations l10n) {
    final name = categoryNames[item.categoryId] ?? item.categoryId;
    final desc = item.description;
    if (desc == null || desc.isEmpty) return name;
    return '$name · $desc';
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

  Future<({int amount, String reason})?> _askDifferentAmount(
    BuildContext context,
  ) async {
    final l10n = l10nOf(context);
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.claimsApproveDifferentReasonTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.claimsCompanyAmountLabel(companyCurrency),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(labelText: l10n.claimsReasonRequired),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
    if (result != true) return null;
    final amount = parseAmountToMinor(amountController.text, companyCurrency);
    final reason = reasonController.text.trim();
    if (amount == null || amount <= 0 || reason.isEmpty) return null;
    return (amount: amount, reason: reason);
  }
}
