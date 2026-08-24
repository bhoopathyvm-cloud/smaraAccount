import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/csv/csv_column_mapping.dart';
import '../../../../domain/csv/csv_import_profile.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/statement_import/category_rule.dart';
import '../../../../domain/statement_import/parsed_statement_transaction.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_text_field.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../core/entity_picker_field.dart';
import '../../../core/money_formatter.dart';
import '../../../core/status_banner.dart';
import '../view_models/statement_import_view_model.dart';

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
                    _CategoryRuleManagementView(viewModel: viewModel),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return switch (viewModel.step) {
            StatementImportStep.chooseSource => _ChooseSourceStep(
              viewModel: viewModel,
            ),
            StatementImportStep.pickFile => _PickFileStep(
              viewModel: viewModel,
              onPickFile: () => _pickFile(context),
            ),
            StatementImportStep.selectAccount when viewModel.isLoading =>
              const Center(child: CircularProgressIndicator()),
            StatementImportStep.selectAccount => _SelectAccountStep(
              viewModel: viewModel,
            ),
            StatementImportStep.mapColumns when viewModel.isLoading =>
              const Center(child: CircularProgressIndicator()),
            StatementImportStep.mapColumns => _MapColumnsStep(
              viewModel: viewModel,
            ),
            StatementImportStep.preview => _PreviewStep(viewModel: viewModel),
            StatementImportStep.summary => _SummaryStep(
              viewModel: viewModel,
              onFinished: onFinished,
            ),
          };
        },
      ),
    );
  }
}

class _ChooseSourceStep extends StatelessWidget {
  const _ChooseSourceStep({required this.viewModel});

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

class _PickFileStep extends StatelessWidget {
  const _PickFileStep({required this.viewModel, required this.onPickFile});

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

class _SelectAccountStep extends StatelessWidget {
  const _SelectAccountStep({required this.viewModel});

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
          _SkippedRowsSection(skippedRows: viewModel.skippedRows),
        ],
      ),
    );
  }
}

class _MapColumnsStep extends StatefulWidget {
  const _MapColumnsStep({required this.viewModel});

  final StatementImportViewModel viewModel;

  @override
  State<_MapColumnsStep> createState() => _MapColumnsStepState();
}

class _MapColumnsStepState extends State<_MapColumnsStep> {
  late final _datePatternController = TextEditingController(
    text: widget.viewModel.csvDatePattern,
  );
  late final _decimalSeparatorController = TextEditingController(
    text: widget.viewModel.csvDecimalSeparator,
  );
  late final _currencyController = TextEditingController(
    text: widget.viewModel.csvCurrency ?? '',
  );
  final _profileNameController = TextEditingController();

  @override
  void dispose() {
    _datePatternController.dispose();
    _decimalSeparatorController.dispose();
    _currencyController.dispose();
    _profileNameController.dispose();
    super.dispose();
  }

  Future<void> _showRenameProfileDialog(
    BuildContext context,
    CsvImportProfile profile,
  ) async {
    // Not disposed synchronously after showDialog returns: Navigator.pop()
    // resolves the awaited Future immediately, but the dialog route's exit
    // transition keeps rebuilding this TextField for a few more frames -
    // disposing the controller right away races that animation.
    final controller = TextEditingController(text: profile.name);
    final l10n = l10nOf(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameProfile),
        content: AppTextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await widget.viewModel.renameProfile(profile.id, name);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProfile(
    BuildContext context,
    CsvImportProfile profile,
  ) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.deleteProfileTitle,
      message: l10n.deleteProfileBody(profile.name),
      confirmLabel: l10n.actionDelete,
    );
    if (confirmed) await widget.viewModel.deleteProfile(profile.id);
  }

  String _columnLabel(AppLocalizations l10n, int index) {
    final headerRow = widget.viewModel.csvHeaderRow;
    final header = (headerRow != null && index < headerRow.length)
        ? headerRow[index]
        : null;
    return header == null || header.isEmpty ? l10n.columnN('$index') : header;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final viewModel = widget.viewModel;
    final columnCount = viewModel.csvColumnCount;
    final columnIndexes = List.generate(columnCount, (i) => i);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.profiles.isNotEmpty) ...[
            DropdownButtonFormField<CsvImportProfile>(
              initialValue: null,
              decoration: InputDecoration(labelText: l10n.useSavedProfile),
              items: [
                for (final profile in viewModel.profiles)
                  DropdownMenuItem(value: profile, child: Text(profile.name)),
              ],
              onChanged: (profile) {
                if (profile == null) return;
                viewModel.applyProfile(profile);
                _datePatternController.text = viewModel.csvDatePattern;
                _decimalSeparatorController.text =
                    viewModel.csvDecimalSeparator;
                _currencyController.text = viewModel.csvCurrency ?? '';
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            for (final profile in viewModel.profiles)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(profile.name),
                trailing: PopupMenuButton<_ProfileAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _ProfileAction.rename:
                        _showRenameProfileDialog(context, profile);
                      case _ProfileAction.delete:
                        _confirmDeleteProfile(context, profile);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ProfileAction.rename,
                      child: Text(l10n.actionRename),
                    ),
                    PopupMenuItem(
                      value: _ProfileAction.delete,
                      child: Text(l10n.actionDelete),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.large),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fileHasHeader),
            value: viewModel.csvHasHeaderRow,
            onChanged: (value) =>
                viewModel.updateCsvMapping(hasHeaderRow: value),
          ),
          const SizedBox(height: AppSpacing.medium),
          DropdownButtonFormField<int>(
            initialValue: viewModel.csvDateColumnIndex,
            decoration: InputDecoration(labelText: l10n.dateColumn),
            items: [
              for (final i in columnIndexes)
                DropdownMenuItem(value: i, child: Text(_columnLabel(l10n, i))),
            ],
            onChanged: (value) =>
                viewModel.updateCsvMapping(dateColumnIndex: value),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _datePatternController,
            decoration: InputDecoration(labelText: l10n.dateFormatHint),
            onChanged: (value) =>
                viewModel.updateCsvMapping(datePattern: value),
          ),
          const SizedBox(height: AppSpacing.large),
          Text(l10n.descriptionColumns, style: AppTypography.body),
          for (final i in columnIndexes)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(_columnLabel(l10n, i)),
              value: viewModel.csvDescriptionColumnIndexes.contains(i),
              onChanged: (checked) {
                final updated = List<int>.of(
                  viewModel.csvDescriptionColumnIndexes,
                );
                if (checked == true) {
                  updated.add(i);
                } else {
                  updated.remove(i);
                }
                updated.sort();
                viewModel.updateCsvMapping(descriptionColumnIndexes: updated);
              },
            ),
          const SizedBox(height: AppSpacing.large),
          // A DropdownButtonFormField, not a SegmentedButton: the segment
          // labels are long enough ("Debit / credit columns") to overflow
          // a SegmentedButton's fixed-width row on a narrower window,
          // and a dropdown matches every other field on this screen.
          DropdownButtonFormField<CsvAmountConvention>(
            initialValue: viewModel.csvAmountConvention,
            decoration: InputDecoration(labelText: l10n.amountConvention),
            items: [
              DropdownMenuItem(
                value: CsvAmountConvention.signedColumn,
                child: Text(l10n.signedAmountColumn),
              ),
              DropdownMenuItem(
                value: CsvAmountConvention.debitCreditColumns,
                child: Text(l10n.separateDebitCredit),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                viewModel.updateCsvMapping(amountConvention: value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          if (viewModel.csvAmountConvention == CsvAmountConvention.signedColumn)
            DropdownButtonFormField<int>(
              initialValue: viewModel.csvSignedAmountColumnIndex,
              decoration: InputDecoration(labelText: l10n.amountColumn),
              items: [
                for (final i in columnIndexes)
                  DropdownMenuItem(
                    value: i,
                    child: Text(_columnLabel(l10n, i)),
                  ),
              ],
              onChanged: (value) =>
                  viewModel.updateCsvMapping(signedAmountColumnIndex: value),
            )
          else ...[
            DropdownButtonFormField<int>(
              initialValue: viewModel.csvDebitColumnIndex,
              decoration: InputDecoration(labelText: l10n.debitColumn),
              items: [
                for (final i in columnIndexes)
                  DropdownMenuItem(
                    value: i,
                    child: Text(_columnLabel(l10n, i)),
                  ),
              ],
              onChanged: (value) =>
                  viewModel.updateCsvMapping(debitColumnIndex: value),
            ),
            const SizedBox(height: AppSpacing.medium),
            DropdownButtonFormField<int>(
              initialValue: viewModel.csvCreditColumnIndex,
              decoration: InputDecoration(labelText: l10n.creditColumn),
              items: [
                for (final i in columnIndexes)
                  DropdownMenuItem(
                    value: i,
                    child: Text(_columnLabel(l10n, i)),
                  ),
              ],
              onChanged: (value) =>
                  viewModel.updateCsvMapping(creditColumnIndex: value),
            ),
          ],
          const SizedBox(height: AppSpacing.large),
          DropdownButtonFormField<int?>(
            initialValue: viewModel.csvReferenceIdColumnIndex,
            decoration: InputDecoration(labelText: l10n.referenceIdColumn),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.none)),
              for (final i in columnIndexes)
                DropdownMenuItem(value: i, child: Text(_columnLabel(l10n, i))),
            ],
            onChanged: (value) =>
                viewModel.updateCsvMapping(referenceIdColumnIndex: value),
          ),
          const SizedBox(height: AppSpacing.large),
          TextField(
            controller: _decimalSeparatorController,
            decoration: InputDecoration(labelText: l10n.decimalSeparator),
            onChanged: (value) =>
                viewModel.updateCsvMapping(decimalSeparator: value),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _currencyController,
            decoration: InputDecoration(labelText: l10n.currency),
            onChanged: (value) => viewModel.updateCsvMapping(currency: value),
          ),
          const SizedBox(height: AppSpacing.large),
          Text(l10n.actionPreview, style: AppTypography.sectionLabel),
          for (final row in viewModel.csvMappingPreviewRows)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(localizeStoredName(l10n, row.description)),
              subtitle: Text(
                '${row.transactionDate.year}-'
                '${row.transactionDate.month.toString().padLeft(2, '0')}-'
                '${row.transactionDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: Text(
                formatAmountMinor(
                  row.amountMinor,
                  viewModel.csvCurrency ?? 'USD',
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.large),
          AppTextField(
            controller: _profileNameController,
            labelText: l10n.saveMappingProfile,
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: viewModel.canConfirmCsvMapping
                ? () => viewModel.confirmCsvMapping(
                    saveAsProfileName: _profileNameController.text.trim(),
                  )
                : null,
            child: Text(l10n.actionContinue),
          ),
        ],
      ),
    );
  }
}

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({required this.viewModel});

  final StatementImportViewModel viewModel;

  /// The group's shared category, or null when its rows currently carry
  /// different categories (e.g. right after per-row overrides) - shown as
  /// the group picker's blank/unset state rather than guessing one.
  String? _groupCategoryId(StatementImportRowGroup group) {
    String? shared;
    var isFirst = true;
    for (final index in group.rowIndexes) {
      final categoryId = viewModel.rows[index].categoryId;
      if (isFirst) {
        shared = categoryId;
        isFirst = false;
      } else if (categoryId != shared) {
        return null;
      }
    }
    return shared;
  }

  Future<void> _assignGroupCategory(
    BuildContext context,
    StatementImportRowGroup group,
    String? categoryId,
  ) async {
    viewModel.setCategoryForGroup(group.key, categoryId);
    if (categoryId == null) return;
    await _promptSaveAsRule(context, group, categoryId);
  }

  /// Offers to save the just-made group assignment as a reusable rule
  /// (spec: "Save a Category Rule From a Group Assignment"). Declining -
  /// including simply dismissing the dialog - leaves the assignment
  /// applied to this import only; no rule is created.
  Future<void> _promptSaveAsRule(
    BuildContext context,
    StatementImportRowGroup group,
    String categoryId,
  ) async {
    // Not disposed synchronously after showDialog returns: Navigator.pop()
    // resolves the awaited Future immediately, but the dialog route's exit
    // transition keeps rebuilding this TextField for a few more frames -
    // disposing the controller right away races that animation.
    final keywordController = TextEditingController(
      text: group.isSingleRow ? '' : group.key,
    );
    var linkPayee = true;
    final l10n = l10nOf(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.saveAsRule),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.saveAsRuleBlurb, style: AppTypography.metadata),
              const SizedBox(height: AppSpacing.medium),
              AppTextField(
                controller: keywordController,
                autofocus: group.isSingleRow,
                labelText: l10n.keyword,
              ),
              // payees-and-spending-memory: "Saving a rule offers to link a
              // payee too" - opt-in, pre-checked; declining still saves the
              // rule exactly as it would without this option.
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l10n.alsoRememberPayee),
                value: linkPayee,
                onChanged: (value) =>
                    setDialogState(() => linkPayee = value ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionSkip),
            ),
            ElevatedButton(
              onPressed: () async {
                final keyword = keywordController.text.trim();
                if (keyword.isEmpty) return;
                await viewModel.saveCategoryRule(
                  keyword: keyword,
                  categoryId: categoryId,
                );
                if (linkPayee) {
                  await viewModel.linkPayeeToRule(
                    keyword: keyword,
                    categoryId: categoryId,
                  );
                }
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.actionSaveRule),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final expenseCategories = viewModel.categories
        .where(
          (c) => c.type == AccountType.expense || c.type == AccountType.income,
        )
        .toList();
    final groups = viewModel.rowGroups;

    // Preview is the first step that always has skip reasons for both
    // OFX (including register-launched auto-select) and CSV (parsed after
    // mapping). Listing them here satisfies "before posting" without
    // blocking Continue / Confirm import.
    final skippedRows = viewModel.skippedRows;

    return Column(
      children: [
        if (viewModel.currencyMismatch)
          StatusBanner(
            message: l10n.statementCurrencyMismatch(
              viewModel.statementCurrency ?? '',
            ),
            isError: true,
          ),
        if (skippedRows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.medium,
              AppSpacing.medium,
              0,
            ),
            child: _SkippedRowsSection(skippedRows: skippedRows),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: groups.length,
            itemBuilder: (context, groupIndex) {
              final group = groups[groupIndex];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!group.isSingleRow) ...[
                        Text(
                          l10n.rowsGrouped('${group.rowIndexes.length}'),
                          style: AppTypography.sectionLabel,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        EntityPickerField<Account>(
                          labelText: l10n.categoryForAll,
                          items: expenseCategories,
                          idOf: (category) => category.id,
                          labelOf: (category) =>
                              localizeStoredName(l10n, category.name),
                          value: _groupCategoryId(group),
                          onChanged: (categoryId) =>
                              _assignGroupCategory(context, group, categoryId),
                        ),
                        const Divider(height: AppSpacing.xLarge),
                      ],
                      for (final index in group.rowIndexes)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index == group.rowIndexes.last
                                ? 0
                                : AppSpacing.medium,
                          ),
                          child: _PreviewRow(
                            row: viewModel.rows[index],
                            categories: expenseCategories,
                            selected: viewModel.rows[index].selected,
                            onToggleSelected: () =>
                                viewModel.toggleRowSelected(index),
                            onCategoryChanged: (categoryId) => group.isSingleRow
                                ? _assignGroupCategory(
                                    context,
                                    group,
                                    categoryId,
                                  )
                                : viewModel.setRowCategory(index, categoryId),
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
              viewModel.isSubmitting ? l10n.importingLabel : l10n.confirmImport,
            ),
          ),
        ),
      ],
    );
  }
}

/// Scrollable list of parser skip reasons. Shown on account-select (OFX)
/// and preview (OFX + CSV) so every import path surfaces them before
/// posting without blocking the good rows.
class _SkippedRowsSection extends StatelessWidget {
  const _SkippedRowsSection({required this.skippedRows});

  final List<StatementSkippedRow> skippedRows;

  @override
  Widget build(BuildContext context) {
    if (skippedRows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.large),
        Text(l10nOf(context).skippedRows, style: AppTypography.cardTitle),
        const SizedBox(height: AppSpacing.small),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 160),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: skippedRows.length,
            itemBuilder: (context, index) {
              final skipped = skippedRows[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeSkipReason(
                        l10nOf(context),
                        skipped.code,
                        skipped.params,
                      ),
                      style: AppTypography.body,
                    ),
                    Text(
                      skipped.rawFragment,
                      style: AppTypography.metadata,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.row,
    required this.categories,
    required this.selected,
    required this.onToggleSelected,
    required this.onCategoryChanged,
  });

  final StatementImportPreviewRow row;
  final List<Account> categories;
  final bool selected;
  final VoidCallback onToggleSelected;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Row(
      children: [
        Checkbox(value: selected, onChanged: (_) => onToggleSelected()),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      localizeStoredName(l10n, row.transaction.description),
                      style: AppTypography.cardTitle,
                    ),
                  ),
                  Text(
                    formatAmountMinor(
                      row.transaction.amountMinor,
                      row.transaction.currency,
                    ),
                    style: AppTypography.cardTitle,
                  ),
                ],
              ),
              Text(
                '${row.transaction.transactionDate.year}-'
                '${row.transaction.transactionDate.month.toString().padLeft(2, '0')}-'
                '${row.transaction.transactionDate.day.toString().padLeft(2, '0')}'
                '${row.isDuplicate ? ' - ${l10n.possibleDuplicate}' : ''}',
                style: AppTypography.metadata.copyWith(
                  color: row.isDuplicate
                      ? AppColors.signal
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              EntityPickerField<Account>(
                labelText: l10n.category,
                items: categories,
                idOf: (category) => category.id,
                labelOf: (category) => localizeStoredName(l10n, category.name),
                value: row.categoryId,
                onChanged: onCategoryChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.viewModel, this.onFinished});

  final StatementImportViewModel viewModel;
  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final result = viewModel.batchResult;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.postedFailedCount(
              '${result?.postedCount ?? 0}',
              '${result?.failedCount ?? 0}',
            ),
            style: AppTypography.body,
          ),
          if (viewModel.skippedOrExcludedRowCount > 0)
            Text(
              l10n.skippedOrExcludedCount(
                '${viewModel.skippedOrExcludedRowCount}',
              ),
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
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
                      title: Text(
                        localizeStoredName(l10n, row.transaction.description),
                      ),
                      subtitle: Text(row.error ?? ''),
                    ),
              ],
            ),
          ),
          ElevatedButton(onPressed: onFinished, child: Text(l10n.actionDone)),
        ],
      ),
    );
  }
}

enum _ProfileAction { rename, delete }

/// Lists every saved category rule with edit/delete actions (spec:
/// "Manage Saved Category Rules"). Reachable from the import flow's app
/// bar - the same place a user is already thinking about categorization -
/// rather than a separate settings screen, since rules are created from,
/// and most relevant during, an import in progress.
class _CategoryRuleManagementView extends StatelessWidget {
  const _CategoryRuleManagementView({required this.viewModel});

  final StatementImportViewModel viewModel;

  String _categoryName(AppLocalizations l10n, String categoryId) {
    final category = viewModel.categories
        .where((c) => c.id == categoryId)
        .cast<Account?>()
        .firstWhere((c) => c != null, orElse: () => null);
    return category == null
        ? l10n.unknownCategory
        : localizeStoredName(l10n, category.name);
  }

  Future<void> _showEditDialog(BuildContext context, CategoryRule rule) async {
    final keywordController = TextEditingController(text: rule.keyword);
    var categoryId = rule.categoryId;
    final expenseCategories = viewModel.categories
        .where(
          (c) => c.type == AccountType.expense || c.type == AccountType.income,
        )
        .toList();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = l10nOf(context);
          return AlertDialog(
            title: Text(l10n.editRule),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: keywordController,
                  autofocus: true,
                  labelText: l10n.keyword,
                ),
                const SizedBox(height: AppSpacing.medium),
                EntityPickerField<Account>(
                  labelText: l10n.category,
                  items: expenseCategories,
                  idOf: (category) => category.id,
                  labelOf: (category) =>
                      localizeStoredName(l10n, category.name),
                  value: categoryId,
                  onChanged: (value) =>
                      setDialogState(() => categoryId = value ?? categoryId),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final keyword = keywordController.text.trim();
                  if (keyword.isEmpty) return;
                  await viewModel.updateCategoryRule(
                    id: rule.id,
                    keyword: keyword,
                    categoryId: categoryId,
                  );
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(l10n.actionSave),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoryRule rule) async {
    final l10n = l10nOf(context);
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: l10n.deleteRuleTitle,
      message: l10n.deleteRuleBody(rule.keyword),
      confirmLabel: l10n.actionDelete,
    );
    if (confirmed) await viewModel.deleteCategoryRule(rule.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoryRulesTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final rules = viewModel.categoryRules;
          if (rules.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Text(
                  l10n.noSavedRules,
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              return ListTile(
                title: Text(rule.keyword),
                subtitle: Text(_categoryName(l10n, rule.categoryId)),
                trailing: PopupMenuButton<_CategoryRuleAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _CategoryRuleAction.edit:
                        _showEditDialog(context, rule);
                      case _CategoryRuleAction.delete:
                        _confirmDelete(context, rule);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _CategoryRuleAction.edit,
                      child: Text(l10n.actionEdit),
                    ),
                    PopupMenuItem(
                      value: _CategoryRuleAction.delete,
                      child: Text(l10n.actionDelete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

enum _CategoryRuleAction { edit, delete }
