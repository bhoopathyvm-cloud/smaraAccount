import '../domain/statement_import/parsed_statement_transaction.dart';
import 'generated/app_localizations.dart';

/// Maps a [StatementSkippedRow]'s stable [StatementSkipCode] (+ params) to
/// localized copy for the import screen's skipped-rows list. Parsers never
/// produce user-facing English sentences directly
/// (i18n-full-ui-and-input-language design.md Decision 3).
String localizeSkipReason(
  AppLocalizations l10n,
  StatementSkipCode code, [
  Map<String, String> params = const {},
]) {
  String p(String key) => params[key] ?? '';
  return switch (code) {
    StatementSkipCode.missingDate => l10n.skipMissingDate,
    StatementSkipCode.unparseableDate => l10n.skipUnparseableDate(
      p('raw'),
      p('pattern'),
    ),
    StatementSkipCode.ofxMissingOrInvalidDate =>
      l10n.skipOfxMissingOrInvalidDate,
    StatementSkipCode.ofxUnparseableDate => l10n.skipOfxUnparseableDate(
      p('raw'),
    ),
    StatementSkipCode.missingAmount => l10n.skipMissingAmount,
    StatementSkipCode.unparseableAmount => l10n.skipUnparseableAmount(p('raw')),
    StatementSkipCode.zeroAmount => l10n.skipZeroAmount,
    StatementSkipCode.unparseableDebitCreditAmount =>
      l10n.skipUnparseableDebitCreditAmount,
    StatementSkipCode.bothDebitAndCreditNonZero =>
      l10n.skipBothDebitAndCreditNonZero,
    StatementSkipCode.bothDebitAndCreditZero => l10n.skipBothDebitAndCreditZero,
  };
}
