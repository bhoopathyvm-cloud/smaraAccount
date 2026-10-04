import 'package:smara_accounting/domain/peer_sync/bonsoir_peer_discovery.dart';
import 'package:test/test.dart';

void main() {
  test('prefers an IPv4 address over an earlier IPv6 link-local one', () {
    expect(
      preferredPeerHost(['fe80::ce:de33:9de6:2c66%en0', '192.168.68.120']),
      '192.168.68.120',
    );
  });

  test('falls back to the first address when there is no IPv4', () {
    expect(preferredPeerHost(['fe80::1%en0', 'fe80::2%en0']), 'fe80::1%en0');
  });

  test('no addresses gives null', () {
    expect(preferredPeerHost([]), isNull);
  });
}
