import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/csv/csv_column_mapping.dart';
import '../../../../domain/csv/csv_import_profile.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/statement_import/category_rule.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
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

  Future<void> _pickFile() async {
    try {
      // Not FileType.custom + allowedExtensions here: .ofx/.qfx aren't
      // registered macOS UTTypes, so the native allowedContentTypes
      // filter file_picker builds from them ends up greying those files
      // out in the dialog instead of narrowing it to them. Allow any
      // file and validate the extension ourselves once one is picked.
      final result = await FilePicker.platform.pickFiles(withData: true);
      final file = result?.files.single;
      final bytes = file?.bytes;
      if (file == null || bytes == null) return;

      final extension = file.name.split('.').last.toLowerCase();
      final allowed = viewModel.source == StatementSource.csv
          ? ['csv']
          : ['ofx', 'qfx'];
      if (!allowed.contains(extension)) {
        viewModel.reportPickFileError(
          'Please select a .${allowed.join(" or .")} file '
          '(got "${file.name}").',
        );
        return;
      }

      await viewModel.loadFile(name: file.name, bytes: bytes);
    } catch (error) {
      viewModel.reportPickFileError('Could not open the file picker: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Statement', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            tooltip: 'Manage category rules',
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
              onPickFile: _pickFile,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What kind of statement file do you have?',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(
              onPressed: () => viewModel.chooseSource(StatementSource.ofx),
              child: const Text('Import OFX / QFX file'),
            ),
            const SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: () => viewModel.chooseSource(StatementSource.csv),
              child: const Text('Import CSV file'),
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
              'Select a $extensions statement file to import',
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

  final StatementImportViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.source != StatementSource.csv)
            Text(
              '${viewModel.parsedTransactionCount} transactions parsed'
              '${viewModel.skippedRowCount > 0 ? ' (${viewModel.skippedRowCount} skipped)' : ''}',
              style: AppTypography.body,
            )
          else
            Text(
              'Choose which account this file belongs to.',
              style: AppTypography.body,
            ),
          const SizedBox(height: AppSpacing.large),
          EntityPickerField<Account>(
            labelText: 'Import into account',
            items: viewModel.accounts,
            idOf: (account) => account.id,
            labelOf: (account) => account.name,
            value: viewModel.selectedAccountId,
            onChanged: (accountId) {
              if (accountId != null) viewModel.selectAccount(accountId);
            },
          ),
          if (viewModel.skippedRows.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.large),
            Text('Skipped rows', style: AppTypography.cardTitle),
            const SizedBox(height: AppSpacing.small),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: viewModel.skippedRows.length,
                itemBuilder: (context, index) {
                  final skipped = viewModel.skippedRows[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.small,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(skipped.reason, style: AppTypography.body),
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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename profile'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await widget.viewModel.renameProfile(profile.id, name);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProfile(
    BuildContext context,
    CsvImportProfile profile,
  ) async {
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: 'Delete profile?',
      message:
          'The saved column mapping "${profile.name}" will be deleted. '
          'Statements already imported with it are unaffected.',
      confirmLabel: 'Delete',
    );
    if (confirmed) await widget.viewModel.deleteProfile(profile.id);
  }

  String _columnLabel(int index) {
    final headerRow = widget.viewModel.csvHeaderRow;
    final header = (headerRow != null && index < headerRow.length)
        ? headerRow[index]
        : null;
    return header == null || header.isEmpty ? 'Column $index' : header;
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const InputDecoration(
                labelText: 'Use a saved profile',
              ),
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
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _ProfileAction.rename,
                      child: Text('Rename'),
                    ),
                    PopupMenuItem(
                      value: _ProfileAction.delete,
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.large),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('File has a header row'),
            value: viewModel.csvHasHeaderRow,
            onChanged: (value) =>
                viewModel.updateCsvMapping(hasHeaderRow: value),
          ),
          const SizedBox(height: AppSpacing.medium),
          DropdownButtonFormField<int>(
            initialValue: viewModel.csvDateColumnIndex,
            decoration: const InputDecoration(labelText: 'Date column'),
            items: [
              for (final i in columnIndexes)
                DropdownMenuItem(value: i, child: Text(_columnLabel(i))),
            ],
            onChanged: (value) =>
                viewModel.updateCsvMapping(dateColumnIndex: value),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _datePatternController,
            decoration: const InputDecoration(
              labelText: 'Date format (e.g. dd/MM/yyyy)',
            ),
            onChanged: (value) =>
                viewModel.updateCsvMapping(datePattern: value),
          ),
          const SizedBox(height: AppSpacing.large),
          Text('Description column(s)', style: AppTypography.body),
          for (final i in columnIndexes)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(_columnLabel(i)),
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
            decoration: const InputDecoration(labelText: 'Amount convention'),
            items: const [
              DropdownMenuItem(
                value: CsvAmountConvention.signedColumn,
                child: Text('Signed amount column'),
              ),
              DropdownMenuItem(
                value: CsvAmountConvention.debitCreditColumns,
                child: Text('Separate debit / credit columns'),
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
              decoration: const InputDecoration(labelText: 'Amount column'),
              items: [
                for (final i in columnIndexes)
                  DropdownMenuItem(value: i, child: Text(_columnLabel(i))),
              ],
              onChanged: (value) =>
                  viewModel.updateCsvMapping(signedAmountColumnIndex: value),
            )
          else ...[
            DropdownButtonFormField<int>(
              initialValue: viewModel.csvDebitColumnIndex,
              decoration: const InputDecoration(labelText: 'Debit column'),
              items: [
                for (final i in columnIndexes)
                  DropdownMenuItem(value: i, child: Text(_columnLabel(i))),
              ],
              onChanged: (value) =>
                  viewModel.updateCsvMapping(debitColumnIndex: value),
            ),
            const SizedBox(height: AppSpacing.medium),
            DropdownButtonFormField<int>(
              initialValue: viewModel.csvCreditColumnIndex,
              decoration: const InputDecoration(labelText: 'Credit column'),
              items: [
                for (final i in columnIndexes)
                  DropdownMenuItem(value: i, child: Text(_columnLabel(i))),
              ],
              onChanged: (value) =>
                  viewModel.updateCsvMapping(creditColumnIndex: value),
            ),
          ],
          const SizedBox(height: AppSpacing.large),
          DropdownButtonFormField<int?>(
            initialValue: viewModel.csvReferenceIdColumnIndex,
            decoration: const InputDecoration(
              labelText: 'Reference id column (optional)',
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('None')),
              for (final i in columnIndexes)
                DropdownMenuItem(value: i, child: Text(_columnLabel(i))),
            ],
            onChanged: (value) =>
                viewModel.updateCsvMapping(referenceIdColumnIndex: value),
          ),
          const SizedBox(height: AppSpacing.large),
          TextField(
            controller: _decimalSeparatorController,
            decoration: const InputDecoration(
              labelText: 'Decimal separator (. or ,)',
            ),
            onChanged: (value) =>
                viewModel.updateCsvMapping(decimalSeparator: value),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _currencyController,
            decoration: const InputDecoration(labelText: 'Currency'),
            onChanged: (value) => viewModel.updateCsvMapping(currency: value),
          ),
          const SizedBox(height: AppSpacing.large),
          Text('Preview', style: AppTypography.sectionLabel),
          for (final row in viewModel.csvMappingPreviewRows)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(row.description),
              subtitle: Text(
                '${row.transactionDate.year}-'
                '${row.transactionDate.month.toString().padLeft(2, '0')}-'
                '${row.transactionDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: Text(formatAmountMinor(row.amountMinor)),
            ),
          const SizedBox(height: AppSpacing.large),
          TextField(
            controller: _profileNameController,
            decoration: const InputDecoration(
              labelText: 'Save this mapping as a profile (optional)',
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: viewModel.canConfirmCsvMapping
                ? () => viewModel.confirmCsvMapping(
                    saveAsProfileName: _profileNameController.text.trim(),
                  )
                : null,
            child: const Text('Continue'),
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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save as a rule?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Future imports whose description contains this keyword will '
              'be categorized the same way automatically.',
              style: AppTypography.metadata,
            ),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              controller: keywordController,
              autofocus: group.isSingleRow,
              decoration: const InputDecoration(labelText: 'Keyword'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              final keyword = keywordController.text.trim();
              if (keyword.isEmpty) return;
              await viewModel.saveCategoryRule(
                keyword: keyword,
                categoryId: categoryId,
              );
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            child: const Text('Save rule'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = viewModel.categories
        .where(
          (c) => c.type == AccountType.expense || c.type == AccountType.income,
        )
        .toList();
    final groups = viewModel.rowGroups;

    return Column(
      children: [
        if (viewModel.currencyMismatch)
          StatusBanner(
            message:
                "This file's currency (${viewModel.statementCurrency}) "
                "doesn't match the selected account's currency.",
            isError: true,
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
                          '${group.rowIndexes.length} rows',
                          style: AppTypography.sectionLabel,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        EntityPickerField<Account>(
                          labelText: 'Category for all',
                          items: expenseCategories,
                          idOf: (category) => category.id,
                          labelOf: (category) => category.name,
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
              viewModel.isSubmitting ? 'Importing...' : 'Confirm import',
            ),
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
                      row.transaction.description,
                      style: AppTypography.cardTitle,
                    ),
                  ),
                  Text(
                    formatAmountMinor(row.transaction.amountMinor),
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
              EntityPickerField<Account>(
                labelText: 'Category',
                items: categories,
                idOf: (category) => category.id,
                labelOf: (category) => category.name,
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

enum _ProfileAction { rename, delete }

/// Lists every saved category rule with edit/delete actions (spec:
/// "Manage Saved Category Rules"). Reachable from the import flow's app
/// bar - the same place a user is already thinking about categorization -
/// rather than a separate settings screen, since rules are created from,
/// and most relevant during, an import in progress.
class _CategoryRuleManagementView extends StatelessWidget {
  const _CategoryRuleManagementView({required this.viewModel});

  final StatementImportViewModel viewModel;

  String _categoryName(String categoryId) {
    final category = viewModel.categories
        .where((c) => c.id == categoryId)
        .cast<Account?>()
        .firstWhere((c) => c != null, orElse: () => null);
    return category?.name ?? 'Unknown category';
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
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit rule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keywordController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Keyword'),
              ),
              const SizedBox(height: AppSpacing.medium),
              EntityPickerField<Account>(
                labelText: 'Category',
                items: expenseCategories,
                idOf: (category) => category.id,
                labelOf: (category) => category.name,
                value: categoryId,
                onChanged: (value) =>
                    setDialogState(() => categoryId = value ?? categoryId),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
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
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoryRule rule) async {
    final confirmed = await confirmDestructiveAction(
      context: context,
      title: 'Delete rule?',
      message:
          'Imports will no longer be auto-categorized by "${rule.keyword}". '
          'Transactions already categorized using this rule are unaffected.',
      confirmLabel: 'Delete',
    );
    if (confirmed) await viewModel.deleteCategoryRule(rule.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category rules', style: AppTypography.headerTitle),
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
                  'No saved rules yet. Assign a category to a group of rows '
                  'during an import and choose "Save rule" to create one.',
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
                subtitle: Text(_categoryName(rule.categoryId)),
                trailing: PopupMenuButton<_CategoryRuleAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _CategoryRuleAction.edit:
                        _showEditDialog(context, rule);
                      case _CategoryRuleAction.delete:
                        _confirmDelete(context, rule);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _CategoryRuleAction.edit,
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: _CategoryRuleAction.delete,
                      child: Text('Delete'),
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
