import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/ofx/ofx_sgml_normalizer.dart';
import 'package:xml/xml.dart';

void main() {
  group('normalizeOfxSgml', () {
    test('strips the flat header block before the first tag', () {
      const input = '''
OFXHEADER:100
DATA:OFXSGML
VERSION:102

<OFX>
<STATUS>OK
</OFX>
''';
      final normalized = normalizeOfxSgml(input);
      expect(normalized, isNot(contains('OFXHEADER')));
      expect(normalized, contains('<STATUS>OK</STATUS>'));
    });

    test(
      'auto-closes leaf tags but leaves aggregate tags for their own closing tag',
      () {
        const input = '''
<OFX>
<BANKTRANLIST>
<STMTTRN>
<TRNAMT>-12.34
</STMTTRN>
</BANKTRANLIST>
</OFX>
''';
        final normalized = normalizeOfxSgml(input);
        final document = XmlDocument.parse(normalized);
        final trnamt = document.findAllElements('TRNAMT').single;
        expect(trnamt.innerText, '-12.34');
      },
    );

    test(
      'escapes a bare ampersand in leaf content so the result is valid XML',
      () {
        const input = '<OFX>\n<NAME>A&P Grocery\n</OFX>\n';
        final normalized = normalizeOfxSgml(input);
        expect(() => XmlDocument.parse(normalized), returnsNormally);
        final document = XmlDocument.parse(normalized);
        expect(
          document.findAllElements('NAME').single.innerText,
          'A&P Grocery',
        );
      },
    );

    test('leaves an already-escaped entity untouched', () {
      const input = '<OFX>\n<NAME>Bob &amp; Sons\n</OFX>\n';
      final normalized = normalizeOfxSgml(input);
      final document = XmlDocument.parse(normalized);
      expect(document.findAllElements('NAME').single.innerText, 'Bob & Sons');
    });
  });
}
