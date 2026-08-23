import 'package:flutter/widgets.dart';
import 'package:smara_accounting/domain/statement_import/parsed_statement_transaction.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:test/test.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations ta;

  setUpAll(() {
    en = lookupAppLocalizations(const Locale('en'));
    ta = lookupAppLocalizations(const Locale('ta'));
  });

  test('maps a plain code to the English ARB string', () {
    expect(
      localizeSkipReason(en, StatementSkipCode.missingDate),
      equals('Missing date.'),
    );
  });

  test('maps a plain code to the Tamil ARB string, not English', () {
    final message = localizeSkipReason(ta, StatementSkipCode.missingDate);
    expect(message, isNot(equals('Missing date.')));
    expect(message, equals(ta.skipMissingDate));
  });

  test('fills the raw-value and pattern placeholders in English', () {
    expect(
      localizeSkipReason(en, StatementSkipCode.unparseableDate, {
        'raw': '31-02-2026',
        'pattern': 'dd/MM/yyyy',
      }),
      equals('Could not parse date "31-02-2026" with pattern "dd/MM/yyyy".'),
    );
  });

  test('fills the same placeholders in Tamil', () {
    final message = localizeSkipReason(ta, StatementSkipCode.unparseableDate, {
      'raw': '31-02-2026',
      'pattern': 'dd/MM/yyyy',
    });
    expect(message, contains('31-02-2026'));
    expect(message, contains('dd/MM/yyyy'));
    expect(message, isNot(contains('Could not parse date')));
  });

  test(
    'every StatementSkipCode resolves to a non-empty message in both locales',
    () {
      for (final code in StatementSkipCode.values) {
        expect(localizeSkipReason(en, code), isNotEmpty, reason: code.name);
        expect(localizeSkipReason(ta, code), isNotEmpty, reason: code.name);
      }
    },
  );
}
