import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../view_models/statement_import_view_model.dart';
import 'choose_source_step.dart';
import 'map_columns_step.dart';
import 'pick_file_step.dart';
import 'preview_step.dart';
import 'select_account_step.dart';
import 'summary_step.dart';

/// Views are lean. No business logic, no Repository calls. Listen to the
/// ViewModel; render what it exposes (smara-tech-guidelines.md).
class StatementImportView extends StatelessWidget {
  const StatementImportView({
    super.key,
    required this.viewModel,
    this.onFinished,
  });

  final StatementImportViewModel viewModel;
  final VoidCallback? onFinished;

  Future<void> _pickFile(BuildContext context) async {
    final l10n = l10nOf(context);
    try {
      // Not FileType.custom + allowedExtensions here: .ofx/.qfx aren't
      // registered macOS UTTypes, so the native allowedContentTypes
      // filter file_picker builds from them ends up greying those files
      // out in the dialog instead of narrowing it to them. Allow any
      // file and validate the extension ourselves once one is picked.
      final file = await FilePicker.pickFile();
      if (file == null) return;
      final bytes = await file.readAsBytes();

      final extension = file.name.split('.').last.toLowerCase();
      final allowed = viewModel.source == StatementSource.csv
          ? ['csv']
          : ['ofx', 'qfx'];
      if (!allowed.contains(extension)) {
        viewModel.reportPickFileError(
          l10n.pleaseSelectFile(allowed.join(' or .')),
        );
        return;
      }

      await viewModel.loadFile(name: file.name, bytes: bytes);
    } catch (error) {
      viewModel.reportPickFileError(l10n.couldNotOpenFilePicker('$error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.importStatementTitle,
          style: AppTypography.headerTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            tooltip: l10n.manageSavedCategoryRules,
            icon: const Icon(TablerIcons.adjustments),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) =>
                    CategoryRuleManagementView(viewModel: viewModel),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return switch (viewModel.step) {
            StatementImportStep.chooseSource => ChooseSourceStep(
              viewModel: viewModel,
            ),
            StatementImportStep.pickFile => PickFileStep(
              viewModel: viewModel,
              onPickFile: () => _pickFile(context),
            ),
            StatementImportStep.selectAccount when viewModel.isLoading =>
              const Center(child: CircularProgressIndicator()),
            StatementImportStep.selectAccount => SelectAccountStep(
              viewModel: viewModel,
            ),
            StatementImportStep.mapColumns when viewModel.isLoading =>
              const Center(child: CircularProgressIndicator()),
            StatementImportStep.mapColumns => MapColumnsStep(
              viewModel: viewModel,
            ),
            StatementImportStep.preview => PreviewStep(viewModel: viewModel),
            StatementImportStep.summary => SummaryStep(
              viewModel: viewModel,
              onFinished: onFinished,
            ),
          };
        },
      ),
    );
  }
}
