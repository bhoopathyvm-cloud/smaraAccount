import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ensures every non-English ARB keeps the same ICU placeholder *names*
/// (and counts) as `app_en.arb` for every translated message.
///
/// Order of appearance may differ for natural word order; names must match
/// as a multiset. Metadata (`@key`) is ignored — only message values matter.
void main() {
  final l10nDir = Directory('lib/l10n');
  final enFile = File('${l10nDir.path}/app_en.arb');

  test('every locale ARB matches English placeholder names per key', () {
    expect(enFile.existsSync(), isTrue, reason: 'app_en.arb missing');
    final en = _parseArb(enFile);
    final enPlaceholders = <String, List<String>>{
      for (final entry in en.entries)
        if (!entry.key.startsWith('@') && entry.key != '@@locale')
          entry.key: _placeholders(entry.value as String),
    };

    final localeFiles =
        l10nDir
            .listSync()
            .whereType<File>()
            .where(
              (f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'),
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    expect(localeFiles, isNotEmpty);

    final failures = <String>[];
    for (final file in localeFiles) {
      final data = _parseArb(file);
      final locale = data['@@locale'] ?? file.uri.pathSegments.last;
      for (final key in enPlaceholders.keys) {
        final value = data[key];
        if (value is! String) {
          failures.add('$locale: missing key $key');
          continue;
        }
        final got = _placeholders(value)..sort();
        final want = List<String>.from(enPlaceholders[key]!)..sort();
        if (!_listEq(got, want)) {
          failures.add(
            '$locale.$key: placeholders $got != $want (value: $value)',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: failures.take(20).join('\n'));
  });
}

Map<String, dynamic> _parseArb(File file) {
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

final _placeholderPattern = RegExp(r'\{(\w+)\}');

List<String> _placeholders(String value) {
  return [
    for (final match in _placeholderPattern.allMatches(value)) match.group(1)!,
  ];
}

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
