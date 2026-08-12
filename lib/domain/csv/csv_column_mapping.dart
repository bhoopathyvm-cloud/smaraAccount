/// How a CSV row's amount and direction are represented (design.md
/// Decision 3): a single signed column, or separate debit/credit columns -
/// both are common in real bank exports (e.g. ICICI uses separate
/// withdrawal/deposit columns).
enum CsvAmountConvention { signedColumn, debitCreditColumns }

/// A user-supplied mapping from a CSV file's columns to the fields a
/// [ParsedStatementTransaction] needs, plus the file's currency (never
/// embedded in a CSV) - the whole point of this type is that nothing here
/// is guessed from header text (csv-transaction-import design.md,
/// "Non-Goals": no auto-detection).
///
/// Columns are always referenced by zero-based index, whether or not the
/// file has a header row - `hasHeaderRow` only controls whether row 0 of
/// the file is skipped as a header rather than parsed as data.
class CsvColumnMapping {
  const CsvColumnMapping({
    required this.hasHeaderRow,
    required this.dateColumnIndex,
    required this.datePattern,
    required this.descriptionColumnIndexes,
    required this.amountConvention,
    required this.currency,
    this.signedAmountColumnIndex,
    this.debitColumnIndex,
    this.creditColumnIndex,
    this.referenceIdColumnIndex,
    this.decimalSeparator = '.',
  }) : assert(
         amountConvention != CsvAmountConvention.signedColumn ||
             signedAmountColumnIndex != null,
         'signedAmountColumnIndex is required for CsvAmountConvention.signedColumn',
       ),
       assert(
         amountConvention != CsvAmountConvention.debitCreditColumns ||
             (debitColumnIndex != null && creditColumnIndex != null),
         'debitColumnIndex and creditColumnIndex are both required for '
         'CsvAmountConvention.debitCreditColumns',
       );

  final bool hasHeaderRow;

  final int dateColumnIndex;

  /// A small pattern language of `d`/`M`/`y` tokens separated by any
  /// non-letter character, e.g. `dd/MM/yyyy`, `MM-dd-yy`, `yyyy.MM.dd`.
  /// Never inferred from the data - always the user's explicit choice
  /// (design.md Risk: date-format ambiguity).
  final String datePattern;

  /// One or more columns concatenated (in order) to form the transaction
  /// description, e.g. a "Payee" column plus a "Reference" column.
  final List<int> descriptionColumnIndexes;

  final CsvAmountConvention amountConvention;

  /// Set only when [amountConvention] is [CsvAmountConvention.signedColumn].
  final int? signedAmountColumnIndex;

  /// Set only when [amountConvention] is
  /// [CsvAmountConvention.debitCreditColumns].
  final int? debitColumnIndex;

  /// Set only when [amountConvention] is
  /// [CsvAmountConvention.debitCreditColumns].
  final int? creditColumnIndex;

  /// Optional column supplying a stable per-row id, reusing the same
  /// authoritative de-duplication path OFX's `FITID` uses. Most bank CSV
  /// exports don't have one; absent by default.
  final int? referenceIdColumnIndex;

  /// `.` or `,` - whichever the file uses as its decimal point (design.md
  /// Risk: decimal-separator ambiguity, e.g. UBS's European-convention
  /// exports).
  final String decimalSeparator;

  /// The file's currency - CSV never embeds one, so the user supplies it
  /// during mapping (design.md Decision 3), typically defaulted to the
  /// target account's currency.
  final String currency;
}
