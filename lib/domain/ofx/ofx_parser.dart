import 'package:xml/xml.dart';

import '../exceptions.dart';
import '../models/transaction_direction.dart';
import 'ofx_sgml_normalizer.dart';
import 'parsed_ofx_transaction.dart';

const _statementTransactionTags = {'stmttrn', 'ccstmttrn'};

/// Parses an OFX 1.x or 2.x document's bank/credit-card statement
/// transactions (`STMTTRN`/`CCSTMTTRN`) into a normalized [OfxParseResult].
/// Investment aggregates (`INVSTMTTRN` and its own transaction types) are
/// never matched by [_statementTransactionTags], so they're silently
/// excluded rather than requiring separate exclusion logic.
///
/// Throws [OfxParseException] when the file as a whole isn't recognizable
/// as OFX. An individual transaction row that's missing a required field
/// is reported as an [OfxSkippedRow] instead, without aborting the rest of
/// the file.
OfxParseResult parseOfxDocument(String content) {
  final trimmed = content.trimLeft();
  final isXmlDeclared = trimmed.startsWith('<?xml');
  final xmlSource = isXmlDeclared ? content : normalizeOfxSgml(content);

  final XmlDocument document;
  try {
    document = XmlDocument.parse(xmlSource);
  } on XmlException catch (error) {
    throw OfxParseException(
      'Could not recognize this file as OFX: ${error.message}',
    );
  }

  final root = document.rootElement;
  if (root.name.local.toLowerCase() != 'ofx') {
    throw OfxParseException(
      'Could not recognize this file as OFX: no <OFX> root element found.',
    );
  }

  final statementCurrency = _findFirstText(root, 'curdef') ?? '';

  final transactions = <ParsedOfxTransaction>[];
  final skippedRows = <OfxSkippedRow>[];

  for (final element in root.descendantElements) {
    final tagName = element.name.local.toLowerCase();
    if (!_statementTransactionTags.contains(tagName)) continue;

    final parsed = _parseTransactionElement(
      element,
      currency: statementCurrency.isEmpty ? '' : statementCurrency,
    );
    final transaction = parsed.transaction;
    final skipReason = parsed.skipReason;
    if (transaction != null) {
      transactions.add(transaction);
    } else if (skipReason != null) {
      skippedRows.add(
        OfxSkippedRow(rawFragment: element.toXmlString(), reason: skipReason),
      );
    }
  }

  return OfxParseResult(
    transactions: transactions,
    skippedRows: skippedRows,
    statementCurrency: statementCurrency.isEmpty ? null : statementCurrency,
  );
}

class _ParsedRow {
  const _ParsedRow.ok(this.transaction) : skipReason = null;
  const _ParsedRow.skip(this.skipReason) : transaction = null;

  final ParsedOfxTransaction? transaction;
  final String? skipReason;
}

_ParsedRow _parseTransactionElement(
  XmlElement element, {
  required String currency,
}) {
  final dtPosted = _childText(element, 'dtposted');
  if (dtPosted == null || dtPosted.length < 8) {
    return const _ParsedRow.skip('Missing or invalid DTPOSTED.');
  }
  final transactionDate = _parseOfxDate(dtPosted);
  if (transactionDate == null) {
    return _ParsedRow.skip('Could not parse DTPOSTED "$dtPosted".');
  }

  final trnAmt = _childText(element, 'trnamt');
  if (trnAmt == null || trnAmt.isEmpty) {
    return const _ParsedRow.skip('Missing TRNAMT.');
  }
  final amountMinor = _parseDecimalToMinorUnits(trnAmt);
  if (amountMinor == null) {
    return _ParsedRow.skip('Could not parse TRNAMT "$trnAmt".');
  }
  if (amountMinor == 0) {
    return const _ParsedRow.skip('TRNAMT is zero.');
  }

  final direction = amountMinor > 0
      ? TransactionDirection.moneyIn
      : TransactionDirection.moneyOut;

  final name = _childText(element, 'name');
  final payee = _childText(element, 'payee');
  final memo = _childText(element, 'memo');
  final description = [
    name ?? payee,
    if (memo != null && memo != (name ?? payee)) memo,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' — ');

  final fitid = _childText(element, 'fitid');

  return _ParsedRow.ok(
    ParsedOfxTransaction(
      transactionDate: transactionDate,
      amountMinor: amountMinor.abs(),
      direction: direction,
      description: description.isEmpty ? 'OFX import' : description,
      currency: currency,
      fitid: (fitid == null || fitid.isEmpty) ? null : fitid,
    ),
  );
}

String? _childText(XmlElement element, String localNameLower) {
  for (final child in element.childElements) {
    if (child.name.local.toLowerCase() == localNameLower) {
      final text = child.innerText.trim();
      return text.isEmpty ? null : text;
    }
  }
  return null;
}

String? _findFirstText(XmlElement root, String localNameLower) {
  for (final element in root.descendantElements) {
    if (element.name.local.toLowerCase() == localNameLower) {
      final text = element.innerText.trim();
      if (text.isNotEmpty) return text;
    }
  }
  return null;
}

/// `YYYYMMDD[HHMMSS[.XXX[gmt offset]]]` - only the date portion is used.
DateTime? _parseOfxDate(String raw) {
  final datePart = raw.substring(0, 8);
  final year = int.tryParse(datePart.substring(0, 4));
  final month = int.tryParse(datePart.substring(4, 6));
  final day = int.tryParse(datePart.substring(6, 8));
  if (year == null || month == null || day == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return DateTime(year, month, day);
}

/// Parses a decimal amount string (e.g. `-12.34`, `100`) into signed minor
/// units without going through `double`, to avoid binary-float rounding on
/// currency amounts.
int? _parseDecimalToMinorUnits(String raw) {
  final trimmed = raw.trim();
  final match = RegExp(r'^([+-]?)(\d+)(?:\.(\d+))?$').firstMatch(trimmed);
  if (match == null) return null;

  final sign = match.group(1) == '-' ? -1 : 1;
  final whole = int.parse(match.group(2)!);
  final fractionRaw = match.group(3) ?? '';
  final paddedFraction = '$fractionRaw${'0' * 2}'.substring(0, 2);
  final fractionMinor = int.parse(paddedFraction);

  return sign * (whole * 100 + fractionMinor);
}
