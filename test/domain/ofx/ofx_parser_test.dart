import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/ofx/ofx_parser.dart';

const _ofx2Fixture = '''
<?xml version="1.0" encoding="UTF-8"?>
<?OFX OFXHEADER="200" VERSION="211" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>
<OFX>
  <SIGNONMSGSRSV1>
    <SONRS>
      <STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS>
      <DTSERVER>20260101120000</DTSERVER>
      <LANGUAGE>ENG</LANGUAGE>
    </SONRS>
  </SIGNONMSGSRSV1>
  <BANKMSGSRSV1>
    <STMTTRNRS>
      <TRNUID>1</TRNUID>
      <STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS>
      <STMTRS>
        <CURDEF>USD</CURDEF>
        <BANKACCTFROM><BANKID>123456789</BANKID><ACCTID>987654321</ACCTID><ACCTTYPE>CHECKING</ACCTTYPE></BANKACCTFROM>
        <BANKTRANLIST>
          <DTSTART>20260101</DTSTART>
          <DTEND>20260131</DTEND>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260105</DTPOSTED>
            <TRNAMT>-42.17</TRNAMT>
            <FITID>2026010500001</FITID>
            <NAME>Coffee Shop</NAME>
          </STMTTRN>
          <STMTTRN>
            <TRNTYPE>CREDIT</TRNTYPE>
            <DTPOSTED>20260110</DTPOSTED>
            <TRNAMT>1500.00</TRNAMT>
            <FITID>2026011000002</FITID>
            <NAME>Payroll</NAME>
          </STMTTRN>
        </BANKTRANLIST>
        <LEDGERBAL><BALAMT>1457.83</BALAMT><DTASOF>20260131</DTASOF></LEDGERBAL>
      </STMTRS>
    </STMTTRNRS>
  </BANKMSGSRSV1>
</OFX>
''';

const _ofx1Fixture = '''
OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:NONE

<OFX>
<SIGNONMSGSRSV1>
<SONRS>
<STATUS>
<CODE>0
<SEVERITY>INFO
</STATUS>
<DTSERVER>20260101120000
<LANGUAGE>ENG
</SONRS>
</SIGNONMSGSRSV1>
<BANKMSGSRSV1>
<STMTTRNRS>
<TRNUID>1
<STATUS>
<CODE>0
<SEVERITY>INFO
</STATUS>
<STMTRS>
<CURDEF>USD
<BANKACCTFROM>
<BANKID>123456789
<ACCTID>987654321
<ACCTTYPE>CHECKING
</BANKACCTFROM>
<BANKTRANLIST>
<DTSTART>20260101
<DTEND>20260131
<STMTTRN>
<TRNTYPE>DEBIT
<DTPOSTED>20260105
<TRNAMT>-42.17
<FITID>2026010500001
<NAME>Coffee Shop
</STMTTRN>
<STMTTRN>
<TRNTYPE>CREDIT
<DTPOSTED>20260110
<TRNAMT>1500.00
<FITID>2026011000002
<NAME>Payroll
</STMTTRN>
</BANKTRANLIST>
<LEDGERBAL>
<BALAMT>1457.83
<DTASOF>20260131
</LEDGERBAL>
</STMTRS>
</STMTTRNRS>
</BANKMSGSRSV1>
</OFX>
''';

const _mixedInvestmentAndBankFixture = '''
<?xml version="1.0" encoding="UTF-8"?>
<OFX>
  <BANKMSGSRSV1>
    <STMTTRNRS>
      <STMTRS>
        <CURDEF>USD</CURDEF>
        <BANKTRANLIST>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260105</DTPOSTED>
            <TRNAMT>-9.99</TRNAMT>
            <FITID>BANK0001</FITID>
            <NAME>Streaming Service</NAME>
          </STMTTRN>
        </BANKTRANLIST>
      </STMTRS>
    </STMTTRNRS>
  </BANKMSGSRSV1>
  <INVSTMTMSGSRSV1>
    <INVSTMTTRNRS>
      <INVSTMTRS>
        <INVTRANLIST>
          <BUYSTOCK>
            <INVBUY>
              <INVTRAN>
                <FITID>INV0001</FITID>
                <DTTRADE>20260112</DTTRADE>
              </INVTRAN>
              <UNITS>10</UNITS>
              <UNITPRICE>25.00</UNITPRICE>
            </INVBUY>
          </BUYSTOCK>
        </INVTRANLIST>
      </INVSTMTRS>
    </INVSTMTTRNRS>
  </INVSTMTMSGSRSV1>
</OFX>
''';

const _malformedRowFixture = '''
<?xml version="1.0" encoding="UTF-8"?>
<OFX>
  <BANKMSGSRSV1>
    <STMTTRNRS>
      <STMTRS>
        <CURDEF>USD</CURDEF>
        <BANKTRANLIST>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260105</DTPOSTED>
            <FITID>BAD0001</FITID>
            <NAME>Missing amount</NAME>
          </STMTTRN>
          <STMTTRN>
            <TRNTYPE>CREDIT</TRNTYPE>
            <DTPOSTED>20260110</DTPOSTED>
            <TRNAMT>25.00</TRNAMT>
            <FITID>GOOD0001</FITID>
            <NAME>Valid row</NAME>
          </STMTTRN>
        </BANKTRANLIST>
      </STMTRS>
    </STMTTRNRS>
  </BANKMSGSRSV1>
</OFX>
''';

void main() {
  group('parseOfxDocument', () {
    test('parses an OFX 2.x (XML) file', () {
      final result = parseOfxDocument(_ofx2Fixture);

      expect(result.statementCurrency, 'USD');
      expect(result.skippedRows, isEmpty);
      expect(result.transactions, hasLength(2));

      final debit = result.transactions[0];
      expect(debit.direction, TransactionDirection.moneyOut);
      expect(debit.amountMinor, 4217);
      expect(debit.externalReferenceId, '2026010500001');
      expect(debit.description, 'Coffee Shop');
      expect(debit.transactionDate, DateTime(2026, 1, 5));

      final credit = result.transactions[1];
      expect(credit.direction, TransactionDirection.moneyIn);
      expect(credit.amountMinor, 150000);
      expect(credit.externalReferenceId, '2026011000002');
    });

    test(
      'parses an OFX 1.x (unclosed-tag SGML) file identically to the OFX 2.x equivalent',
      () {
        final result = parseOfxDocument(_ofx1Fixture);

        expect(result.statementCurrency, 'USD');
        expect(result.skippedRows, isEmpty);
        expect(result.transactions, hasLength(2));
        expect(result.transactions[0].amountMinor, 4217);
        expect(result.transactions[0].direction, TransactionDirection.moneyOut);
        expect(result.transactions[1].amountMinor, 150000);
        expect(result.transactions[1].direction, TransactionDirection.moneyIn);
      },
    );

    test(
      'ignores investment transactions but still parses bank transactions in the same file',
      () {
        final result = parseOfxDocument(_mixedInvestmentAndBankFixture);

        expect(result.transactions, hasLength(1));
        expect(result.transactions.single.externalReferenceId, 'BANK0001');
        expect(result.skippedRows, isEmpty);
      },
    );

    test(
      'a malformed row is skipped without aborting the rest of the file',
      () {
        final result = parseOfxDocument(_malformedRowFixture);

        expect(result.transactions, hasLength(1));
        expect(result.transactions.single.externalReferenceId, 'GOOD0001');
        expect(result.skippedRows, hasLength(1));
        expect(result.skippedRows.single.reason, contains('TRNAMT'));
      },
    );

    test('an unrecognizable file throws OfxParseException', () {
      expect(
        () => parseOfxDocument('Hello, this is not OFX at all.'),
        throwsA(isA<OfxParseException>()),
      );
    });

    test('well-formed XML without an <OFX> root throws OfxParseException', () {
      expect(
        () => parseOfxDocument('<?xml version="1.0"?><NOTOFX></NOTOFX>'),
        throwsA(isA<OfxParseException>()),
      );
    });
  });
}
