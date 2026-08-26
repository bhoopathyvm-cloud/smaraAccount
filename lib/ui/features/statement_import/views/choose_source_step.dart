import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/statement_import_view_model.dart';

class ChooseSourceStep extends StatelessWidget {
  const ChooseSourceStep({super.key, required this.viewModel});

  final StatementImportViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.whatKindOfStatement,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(
              onPressed: () => viewModel.chooseSource(StatementSource.ofx),
              child: Text(l10n.importOfxQfxFile),
            ),
            const SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: () => viewModel.chooseSource(StatementSource.csv),
              child: Text(l10n.importCsvFile),
            ),
          ],
        ),
      ),
    );
  }
}
