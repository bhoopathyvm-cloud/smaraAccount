import 'package:flutter/material.dart';

import '../../../../domain/models/account.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/entity_picker_field.dart';
import '../view_models/statement_import_view_model.dart';
import 'preview_step.dart';

class SelectAccountStep extends StatelessWidget {
  const SelectAccountStep({super.key, required this.viewModel});

  final StatementImportViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.source != StatementSource.csv)
            Text(
              l10n.parsedTransactionCount(
                '${viewModel.parsedTransactionCount}',
              ),
              style: AppTypography.body,
            )
          else
            Text(l10n.chooseAccountForFile, style: AppTypography.body),
          if (viewModel.skippedRowCount > 0)
            Text(
              l10n.skippedOrExcludedCount('${viewModel.skippedRowCount}'),
              style: AppTypography.body,
            ),
          const SizedBox(height: AppSpacing.large),
          EntityPickerField<Account>(
            labelText: l10n.importIntoAccount,
            items: viewModel.accounts,
            idOf: (account) => account.id,
            labelOf: (account) => localizeStoredName(l10n, account.name),
            value: viewModel.selectedAccountId,
            onChanged: (accountId) {
              if (accountId != null) viewModel.selectAccount(accountId);
            },
          ),
          // OFX parses before this step, so reasons are available here.
          // CSV parses later (after mapping); its reasons show on preview.
          SkippedRowsSection(skippedRows: viewModel.skippedRows),
        ],
      ),
    );
  }
}
