import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/money_formatter.dart';
import '../view_models/summary_view_model.dart';

/// Date range picker + income/expense totals.
class SummaryView extends StatelessWidget {
  const SummaryView({super.key, required this.viewModel});

  final SummaryViewModel viewModel;

  Future<void> _pickRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: viewModel.start,
        end: viewModel.end,
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      viewModel.setDateRange(start: picked.start, end: picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: viewModel.financialAccountId ?? '',
                  decoration: const InputDecoration(labelText: 'Account'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All accounts'),
                    ),
                    for (final account in viewModel.financialAccounts)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                  ],
                  onChanged: (accountId) => viewModel.setFinancialAccountId(
                    accountId == null || accountId.isEmpty ? null : accountId,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                OutlinedButton(
                  onPressed: () => _pickRange(context),
                  child: Text(
                    '${_formatDate(viewModel.start)} to ${_formatDate(viewModel.end)}',
                  ),
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _SummaryCard(
                  label: 'Total income',
                  amountMinor: viewModel.summary.totalIncomeMinor,
                ),
                const SizedBox(height: AppSpacing.medium),
                _SummaryCard(
                  label: 'Total expense',
                  amountMinor: viewModel.summary.totalExpenseMinor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.amountMinor});

  final String label;
  final int amountMinor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.sectionLabel),
            const SizedBox(height: AppSpacing.base),
            Text(formatAmountMinor(amountMinor), style: AppTypography.balance),
          ],
        ),
      ),
    );
  }
}
