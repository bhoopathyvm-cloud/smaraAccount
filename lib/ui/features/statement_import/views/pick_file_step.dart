import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/statement_import_view_model.dart';

class PickFileStep extends StatelessWidget {
  const PickFileStep({
    super.key,
    required this.viewModel,
    required this.onPickFile,
  });

  final StatementImportViewModel viewModel;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final extensions = viewModel.source == StatementSource.csv
        ? '.csv'
        : '.ofx or .qfx';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(TablerIcons.fileImport, size: 48),
            const SizedBox(height: AppSpacing.large),
            Text(
              l10n.selectStatementFile(extensions),
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
              child: Text(l10n.actionChooseFile),
            ),
          ],
        ),
      ),
    );
  }
}
