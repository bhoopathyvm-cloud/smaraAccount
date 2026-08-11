import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/account.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/money_formatter.dart';
import '../view_models/ofx_import_view_model.dart';

/// Views are lean. No business logic, no Repository calls. Listen to the
/// ViewModel; render what it exposes (smara-tech-guidelines.md).
class OfxImportView extends StatelessWidget {
  const OfxImportView({super.key, required this.viewModel, this.onFinished});

  final OfxImportViewModel viewModel;
  final VoidCallback? onFinished;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['ofx', 'qfx'],
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    await viewModel.loadFile(name: file.name, bytes: bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import OFX', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return switch (viewModel.step) {
            OfxImportStep.pickFile => _PickFileStep(
              viewModel: viewModel,
              onPickFile: _pickFile,
            ),
            OfxImportStep.selectAccount when viewModel.isLoading =>
              const Center(child: CircularProgressIndicator()),
            OfxImportStep.selectAccount => _SelectAccountStep(
              viewModel: viewModel,
            ),
            OfxImportStep.preview => _PreviewStep(viewModel: viewModel),
            OfxImportStep.summary => _SummaryStep(
              viewModel: viewModel,
              onFinished: onFinished,
            ),
          };
        },
      ),
    );
  }
}

class _PickFileStep extends StatelessWidget {
  const _PickFileStep({required this.viewModel, required this.onPickFile});

  final OfxImportViewModel viewModel;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(TablerIcons.fileImport, size: 48),
            const SizedBox(height: AppSpacing.large),
            Text(
              'Select a .ofx or .qfx statement file to import',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            if (viewModel.parseError != null) ...[
              const SizedBox(height: AppSpacing.large),
              Text(
                viewModel.parseError!,
                style: AppTypography.body.copyWith(color: AppColors.signal),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(
              onPressed: onPickFile,
              child: const Text('Choose file'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectAccountStep extends StatelessWidget {
  const _SelectAccountStep({required this.viewModel});

  final OfxImportViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${viewModel.parsedTransactionCount} transactions parsed'
            '${viewModel.skippedRowCount > 0 ? ' (${viewModel.skippedRowCount} skipped)' : ''}',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.large),
          DropdownButtonFormField<String>(
            initialValue: viewModel.selectedAccountId,
            decoration: const InputDecoration(labelText: 'Import into account'),
            items: [
              for (final account in viewModel.accounts)
                DropdownMenuItem(value: account.id, child: Text(account.name)),
            ],
            onChanged: (accountId) {
              if (accountId != null) viewModel.selectAccount(accountId);
            },
          ),
        ],
      ),
    );
  }
}

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({required this.viewModel});

  final OfxImportViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final expenseCategories = viewModel.categories
        .where(
          (c) => c.type == AccountType.expense || c.type == AccountType.income,
        )
        .toList();

    return Column(
      children: [
        if (viewModel.currencyMismatch)
          MaterialBanner(
            content: Text(
              "This file's currency (${viewModel.statementCurrency}) "
              "doesn't match the selected account's currency.",
              style: AppTypography.body.copyWith(color: AppColors.signal),
            ),
            actions: const [SizedBox.shrink()],
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: viewModel.rows.length,
            itemBuilder: (context, index) {
              final row = viewModel.rows[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Row(
                    children: [
                      Checkbox(
                        value: row.selected,
                        onChanged: (_) => viewModel.toggleRowSelected(index),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    row.transaction.description,
                                    style: AppTypography.cardTitle,
                                  ),
                                ),
                                Text(
                                  formatAmountMinor(
                                    row.transaction.amountMinor,
                                  ),
                                  style: AppTypography.cardTitle,
                                ),
                              ],
                            ),
                            Text(
                              '${row.transaction.transactionDate.year}-'
                              '${row.transaction.transactionDate.month.toString().padLeft(2, '0')}-'
                              '${row.transaction.transactionDate.day.toString().padLeft(2, '0')}'
                              '${row.isDuplicate ? ' - possible duplicate' : ''}',
                              style: AppTypography.metadata.copyWith(
                                color: row.isDuplicate
                                    ? AppColors.signal
                                    : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.small),
                            DropdownButtonFormField<String>(
                              initialValue: row.categoryId,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                isDense: true,
                              ),
                              items: [
                                for (final category in expenseCategories)
                                  DropdownMenuItem(
                                    value: category.id,
                                    child: Text(category.name),
                                  ),
                              ],
                              onChanged: (categoryId) =>
                                  viewModel.setRowCategory(index, categoryId),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ElevatedButton(
            onPressed: viewModel.isSubmitting
                ? null
                : () => viewModel.confirmImport(),
            child: Text(
              viewModel.isSubmitting ? 'Importing...' : 'Confirm import',
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.viewModel, this.onFinished});

  final OfxImportViewModel viewModel;
  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context) {
    final result = viewModel.batchResult;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${result?.postedCount ?? 0} posted', style: AppTypography.body),
          if (viewModel.skippedOrExcludedRowCount > 0)
            Text(
              '${viewModel.skippedOrExcludedRowCount} skipped or excluded',
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
          if ((result?.failedCount ?? 0) > 0)
            Text(
              '${result!.failedCount} failed',
              style: AppTypography.body.copyWith(color: AppColors.signal),
            ),
          const SizedBox(height: AppSpacing.large),
          Expanded(
            child: ListView(
              children: [
                for (final row in result?.results ?? const [])
                  if (!row.succeeded)
                    ListTile(
                      leading: const Icon(
                        TablerIcons.alertCircle,
                        color: AppColors.signal,
                      ),
                      title: Text(row.transaction.description),
                      subtitle: Text(row.error ?? ''),
                    ),
              ],
            ),
          ),
          ElevatedButton(onPressed: onFinished, child: const Text('Done')),
        ],
      ),
    );
  }
}
