import 'package:flutter/material.dart';

import '../../../../domain/csv/csv_column_mapping.dart';
import '../../../../domain/csv/csv_import_profile.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_text_field.dart';
import '../../../core/app_typography.dart';
import '../../../core/destructive_confirmation.dart';
import '../../../core/money_formatter.dart';
import '../../../core/show_managed_dialog.dart';
import '../view_models/statement_import_view_model.dart';

class MapColumnsStep extends StatefulWidget {
  const MapColumnsStep({super.key, required this.viewModel});

  final StatementImportViewModel viewModel;

  @override
  State<MapColumnsStep> createState() => _MapColumnsStepState();
}

class _MapColumnsStepState extends State<MapColumnsStep> {
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
    final l10n = l10nOf(context);
    await showManagedDialog<void>(
      context: context,
      controllerCount: 1,
      initialTexts: [profile.name],
      builder: (dialogContext, controllers) {
        final controller = controllers[0];
        return AlertDialog(
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
        );
      },
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
                trailing: PopupMenuButton<ProfileAction>(
                  onSelected: (action) {
                    switch (action) {
                      case ProfileAction.rename:
                        _showRenameProfileDialog(context, profile);
                      case ProfileAction.delete:
                        _confirmDeleteProfile(context, profile);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: ProfileAction.rename,
                      child: Text(l10n.actionRename),
                    ),
                    PopupMenuItem(
                      value: ProfileAction.delete,
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

enum ProfileAction { rename, delete }
