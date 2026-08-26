import '../csv/csv_column_mapping.dart';
import '../csv/csv_import_profile.dart';
import 'category_rule.dart';
import 'parsed_statement_transaction.dart';

/// Which statement source the user is importing - chosen first, since CSV
/// needs a column-mapping step OFX never does.
enum StatementSource { ofx, csv }

enum StatementImportStep {
  chooseSource,
  pickFile,
  selectAccount,
  mapColumns, // CSV only
  preview,
  summary,
}

/// One previewed row's mutable review state.
class StatementImportPreviewRow {
  StatementImportPreviewRow({
    required this.transaction,
    required this.isDuplicate,
    String? categoryId,
  }) : selected = !isDuplicate,
       categoryId = categoryId;

  final ParsedStatementTransaction transaction;
  final bool isDuplicate;
  bool selected;
  String? categoryId;
}

/// Preview rows sharing a normalized description.
class StatementImportRowGroup {
  const StatementImportRowGroup({required this.key, required this.rowIndexes});

  final String key;
  final List<int> rowIndexes;

  bool get isSingleRow => rowIndexes.length == 1;
}

/// In-progress CSV column mapping (validity + [CsvColumnMapping] build).
class CsvMappingDraft {
  bool hasHeaderRow = true;
  int? dateColumnIndex;
  String datePattern = 'dd/MM/yyyy';
  List<int> descriptionColumnIndexes = [];
  CsvAmountConvention amountConvention = CsvAmountConvention.signedColumn;
  int? signedAmountColumnIndex;
  int? debitColumnIndex;
  int? creditColumnIndex;
  int? referenceIdColumnIndex;
  String decimalSeparator = '.';
  String? currency;

  bool get isComplete {
    if (dateColumnIndex == null) return false;
    if (descriptionColumnIndexes.isEmpty) return false;
    if (currency == null || currency!.isEmpty) return false;
    switch (amountConvention) {
      case CsvAmountConvention.signedColumn:
        return signedAmountColumnIndex != null;
      case CsvAmountConvention.debitCreditColumns:
        return debitColumnIndex != null && creditColumnIndex != null;
    }
  }

  void applyProfile(CsvImportProfile profile) {
    final mapping = profile.mapping;
    hasHeaderRow = mapping.hasHeaderRow;
    dateColumnIndex = mapping.dateColumnIndex;
    datePattern = mapping.datePattern;
    descriptionColumnIndexes = List.of(mapping.descriptionColumnIndexes);
    amountConvention = mapping.amountConvention;
    signedAmountColumnIndex = mapping.signedAmountColumnIndex;
    debitColumnIndex = mapping.debitColumnIndex;
    creditColumnIndex = mapping.creditColumnIndex;
    referenceIdColumnIndex = mapping.referenceIdColumnIndex;
    decimalSeparator = mapping.decimalSeparator;
    currency = mapping.currency;
  }

  CsvColumnMapping? toMapping() {
    if (!isComplete) return null;
    final mappedCurrency = currency;
    final dateIndex = dateColumnIndex;
    if (mappedCurrency == null || dateIndex == null) return null;
    return CsvColumnMapping(
      hasHeaderRow: hasHeaderRow,
      dateColumnIndex: dateIndex,
      datePattern: datePattern,
      descriptionColumnIndexes: descriptionColumnIndexes,
      amountConvention: amountConvention,
      signedAmountColumnIndex: signedAmountColumnIndex,
      debitColumnIndex: debitColumnIndex,
      creditColumnIndex: creditColumnIndex,
      referenceIdColumnIndex: referenceIdColumnIndex,
      decimalSeparator: decimalSeparator,
      currency: mappedCurrency,
    );
  }
}

List<StatementImportRowGroup> groupPreviewRows(
  List<StatementImportPreviewRow> rows,
) {
  final order = <String>[];
  final indexesByKey = <String, List<int>>{};
  for (var i = 0; i < rows.length; i++) {
    final key = normalizeDescription(rows[i].transaction.description);
    final indexes = indexesByKey.putIfAbsent(key, () {
      order.add(key);
      return [];
    });
    indexes.add(i);
  }
  return [
    for (final key in order)
      StatementImportRowGroup(key: key, rowIndexes: indexesByKey[key]!),
  ];
}

/// Flutter-free wizard state: step, source, CSV mapping draft, grouping.
class StatementImportSession {
  StatementImportStep step = StatementImportStep.chooseSource;
  StatementSource? source;
  final csvMapping = CsvMappingDraft();

  void chooseSource(StatementSource next) {
    source = next;
    step = StatementImportStep.pickFile;
  }

  bool get canConfirmCsvMapping => csvMapping.isComplete;
}
