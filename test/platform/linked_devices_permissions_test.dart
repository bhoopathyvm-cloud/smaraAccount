import 'dart:io';

import 'package:test/test.dart';

/// In-app Linked devices permission sentence (must match Info.plist usage
/// strings — linked-devices-and-sync tasks 8.1 / 4.2).
const linkedDevicesPermissionSentence =
    'To share your books, Smara needs to find your other devices on this '
    'Wi-Fi. Nothing goes to the internet.';

void main() {
  final root = Directory.current.path.endsWith('/test')
      ? Directory.current.parent.path
      : Directory.current.path;

  test(
    '8.1 iOS/macOS Info.plist local-network strings match in-app sentence',
    () {
      for (final relative in [
        'ios/Runner/Info.plist',
        'macos/Runner/Info.plist',
      ]) {
        final text = File('$root/$relative').readAsStringSync();
        expect(text, contains('NSLocalNetworkUsageDescription'));
        expect(text, contains(linkedDevicesPermissionSentence));
        expect(text, contains('_smara._tcp'));
        expect(text, contains('NSBonjourServices'));
      }
    },
  );

  test('8.1 Android manifest declares local-network / nearby permissions', () {
    final text = File(
      '$root/android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(text, contains('ACCESS_WIFI_STATE'));
    expect(text, contains('CHANGE_WIFI_MULTICAST_STATE'));
    expect(text, contains('NEARBY_WIFI_DEVICES'));
  });

  test('8.2 privacy policy mentions Linked devices LAN sync', () {
    final text = File(
      '$root/pages/open-source/smara-account/privacy-policy.md',
    ).readAsStringSync();
    expect(text.toLowerCase(), contains('linked devices'));
    expect(text.toLowerCase(), contains('local'));
    expect(
      text.toLowerCase().contains('wi-fi') ||
          text.toLowerCase().contains('wifi') ||
          text.toLowerCase().contains('lan'),
      isTrue,
    );
    expect(text.toLowerCase(), isNot(contains('cloud sync service')));
    expect(
      text.contains('no Smara server') ||
          text.contains('does not create an online account'),
      isTrue,
    );
  });

  test(
    '8.3 macOS Release entitlements keep sandbox + Bonjour network rights',
    () {
      final text = File(
        '$root/macos/Runner/Release.entitlements',
      ).readAsStringSync();
      expect(text, contains('com.apple.security.app-sandbox'));
      expect(text, contains('com.apple.security.network.client'));
      expect(text, contains('com.apple.security.network.server'));
      expect(
        text,
        contains('com.apple.security.files.user-selected.read-write'),
      );
    },
  );
}
