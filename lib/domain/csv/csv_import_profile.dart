import 'dart:convert';

import 'csv_column_mapping.dart';

/// A saved, reusable column mapping (csv-transaction-import design.md
/// Decision 6): offered again automatically when a later file's header
/// row exactly matches [headerFingerprint].
class CsvImportProfile {
  const CsvImportProfile({
    required this.id,
    required this.name,
    required this.headerFingerprint,
    required this.mapping,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// The source file's header row, normalized via [normalizeHeaderRow] -
  /// the exact-match fingerprint a later file's header row is compared
  /// against.
  final List<String> headerFingerprint;

  final CsvColumnMapping mapping;
  final DateTime createdAt;
}

/// Trims and lowercases each header cell so a profile still matches a
/// file whose header row differs only in whitespace or casing, while
/// still requiring every other difference to be an exact mismatch
/// (design.md Decision 6: exact match only, no fuzzy scoring).
List<String> normalizeHeaderRow(List<String> headerRow) =>
    headerRow.map((cell) => cell.trim().toLowerCase()).toList();

extension CsvColumnMappingJson on CsvColumnMapping {
  Map<String, dynamic> toJson() => {
    'hasHeaderRow': hasHeaderRow,
    'dateColumnIndex': dateColumnIndex,
    'datePattern': datePattern,
    'descriptionColumnIndexes': descriptionColumnIndexes,
    'amountConvention': amountConvention.name,
    'signedAmountColumnIndex': signedAmountColumnIndex,
    'debitColumnIndex': debitColumnIndex,
    'creditColumnIndex': creditColumnIndex,
    'referenceIdColumnIndex': referenceIdColumnIndex,
    'decimalSeparator': decimalSeparator,
    'currency': currency,
  };

  String toJsonString() => jsonEncode(toJson());
}

CsvColumnMapping csvColumnMappingFromJson(Map<String, dynamic> json) {
  return CsvColumnMapping(
    hasHeaderRow: json['hasHeaderRow'] as bool,
    dateColumnIndex: json['dateColumnIndex'] as int,
    datePattern: json['datePattern'] as String,
    descriptionColumnIndexes: (json['descriptionColumnIndexes'] as List)
        .cast<int>(),
    amountConvention: CsvAmountConvention.values.byName(
      json['amountConvention'] as String,
    ),
    signedAmountColumnIndex: json['signedAmountColumnIndex'] as int?,
    debitColumnIndex: json['debitColumnIndex'] as int?,
    creditColumnIndex: json['creditColumnIndex'] as int?,
    referenceIdColumnIndex: json['referenceIdColumnIndex'] as int?,
    decimalSeparator: json['decimalSeparator'] as String,
    currency: json['currency'] as String,
  );
}

CsvColumnMapping csvColumnMappingFromJsonString(String source) =>
    csvColumnMappingFromJson(jsonDecode(source) as Map<String, dynamic>);
