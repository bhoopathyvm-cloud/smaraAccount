/// Converts an OFX 1.x SGML document (unclosed leaf tags, a flat
/// `Key:Value` header block, no XML declaration) into well-formed XML that
/// [XmlDocument.parse] can read, so the parser only has one code path for
/// both OFX 1.x and 2.x input (design.md Decision 1).
///
/// OFX 1.x SGML rule this relies on: an "aggregate" (container) tag always
/// appears alone on its own line as `<TAG>`, closed later by a matching
/// `</TAG>` line; a "leaf" (value) tag has its value inline on the same
/// line as `<TAG>` and is implicitly closed by whatever comes next. Every
/// real-world OFX 1.x file follows this convention.
library;

final _tagWithInlineContent = RegExp(r'^<([A-Za-z0-9.]+)>(.*)$');

String normalizeOfxSgml(String content) {
  final body = _stripHeaderBlock(content);
  final lines = body.split(RegExp(r'\r\n|\r|\n'));
  final buffer = StringBuffer();

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('</')) {
      buffer.writeln(line);
      continue;
    }

    final match = _tagWithInlineContent.firstMatch(line);
    if (match == null) {
      buffer.writeln(line);
      continue;
    }

    final tag = match.group(1)!;
    final rest = match.group(2)!;
    if (rest.isEmpty) {
      // Aggregate opening tag; leave for its own closing tag later.
      buffer.writeln('<$tag>');
    } else {
      buffer.writeln('<$tag>${_escapeLeafContent(rest)}</$tag>');
    }
  }

  return buffer.toString();
}

/// OFX 1.x files start with a flat `Key:Value` header block (`OFXHEADER:100`,
/// `DATA:OFXSGML`, ...) before the `<OFX>` body. That block isn't SGML and
/// carries nothing this parser needs, so it's dropped entirely.
String _stripHeaderBlock(String content) {
  final firstTagIndex = content.indexOf('<');
  if (firstTagIndex == -1) return content;
  return content.substring(firstTagIndex);
}

final _bareAmpersand = RegExp(
  r'&(?!amp;|lt;|gt;|quot;|apos;|#\d+;|#x[0-9A-Fa-f]+;)',
);

String _escapeLeafContent(String value) {
  return value
      .replaceAll(_bareAmpersand, '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
