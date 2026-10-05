import 'dart:io';

import 'package:test/test.dart';

/// os-provided-encryption task 7.3 / design D6: the export-compliance
/// declaration stays consistent with the code and the public policy.
void main() {
  final root = Directory.current.path.endsWith('/test')
      ? Directory.current.parent.path
      : Directory.current.path;

  test('iOS and macOS declare ITSAppUsesNonExemptEncryption = false', () {
    for (final relative in [
      'ios/Runner/Info.plist',
      'macos/Runner/Info.plist',
    ]) {
      final text = File('$root/$relative').readAsStringSync();
      final match = RegExp(
        r'<key>ITSAppUsesNonExemptEncryption</key>\s*<(true|false)/>',
      ).firstMatch(text);
      expect(match, isNotNull, reason: '$relative lacks the key');
      expect(match!.group(1), 'false', reason: relative);
    }
  });

  test('the privacy policy states the operating-system-only basis', () {
    final policy = File(
      '$root/pages/open-source/smara-account/privacy-policy.md',
    ).readAsStringSync();
    final section = policy.split('## Cryptography (export compliance)');
    expect(section, hasLength(2), reason: 'export-compliance section');
    // Markdown wraps lines, so compare on collapsed whitespace.
    final body = _unwrap(section[1].split('\n## ').first);
    expect(body, contains('ITSAppUsesNonExemptEncryption'));
    expect(body, contains("only through Apple's operating system"));
    expect(body.toLowerCase(), contains('cryptokit'));
  });

  test('the store notes carry the same basis', () {
    final notes = _unwrap(
      File(
        '$root/docs/release/store-listing/app-privacy.md',
      ).readAsStringSync(),
    );
    expect(notes, contains("only through Apple's operating system"));
    expect(notes, contains('ITSAppUsesNonExemptEncryption'));
    final runbook = _unwrap(
      File('$root/docs/release/store-release-runbook.md').readAsStringSync(),
    );
    expect(runbook, contains('ITSAppUsesNonExemptEncryption = false'));
    expect(runbook, contains('os-provided-encryption'));
  });
}

String _unwrap(String text) => text.replaceAll(RegExp(r'\s+'), ' ');
