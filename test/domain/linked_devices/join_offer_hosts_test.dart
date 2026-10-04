import 'package:smara_accounting/domain/linked_devices/join_offer_hosts.dart';
import 'package:test/test.dart';

void main() {
  group('orderJoinOfferHosts', () {
    test('simulator cast prefers loopback before LAN', () {
      expect(
        orderJoinOfferHosts([
          '127.0.0.1',
          '192.168.68.114',
        ], preferLoopback: true),
        ['127.0.0.1', '192.168.68.114'],
      );
    });

    test('real-devices cast prefers LAN before loopback', () {
      // A physical phone's 127.0.0.1 is itself — trying it first caused
      // owner.confirm_* / joiner lookup hangs under --real-devices.
      expect(
        orderJoinOfferHosts([
          '127.0.0.1',
          '192.168.68.114',
        ], preferLoopback: false),
        ['192.168.68.114', '127.0.0.1'],
      );
    });

    test('dedupes and drops empties', () {
      expect(
        orderJoinOfferHosts([
          '192.168.68.114',
          '',
          '192.168.68.114',
          '127.0.0.1',
        ], preferLoopback: false),
        ['192.168.68.114', '127.0.0.1'],
      );
    });
  });

  group('conductorPrefersLoopbackJoin', () {
    test('loopback conductor → prefer loopback join hosts', () {
      expect(conductorPrefersLoopbackJoin('http://127.0.0.1:50124'), isTrue);
      expect(conductorPrefersLoopbackJoin('http://localhost:50124'), isTrue);
      expect(conductorPrefersLoopbackJoin(''), isTrue);
    });

    test('LAN conductor → prefer LAN join hosts', () {
      expect(
        conductorPrefersLoopbackJoin('http://192.168.68.114:50124'),
        isFalse,
      );
    });
  });

  group('lanIPv4Candidates', () {
    test('skips cellular, VPN and peer-to-peer; Wi-Fi first', () {
      final hosts = lanIPv4Candidates([
        (interfaceName: 'pdp_ip0', address: '10.81.13.243', isLoopback: false),
        (interfaceName: 'utun3', address: '10.8.0.2', isLoopback: false),
        (interfaceName: 'lo0', address: '127.0.0.1', isLoopback: true),
        (
          interfaceName: 'bridge100',
          address: '192.168.64.1',
          isLoopback: false,
        ),
        (interfaceName: 'en0', address: '192.168.68.104', isLoopback: false),
      ]);
      expect(hosts, ['127.0.0.1', '192.168.68.104']);
    });

    test('keeps non-en LAN interfaces after en*', () {
      final hosts = lanIPv4Candidates([
        (interfaceName: 'wlan0', address: '192.168.68.110', isLoopback: false),
        (interfaceName: 'en1', address: '192.168.1.5', isLoopback: false),
      ]);
      expect(hosts, ['127.0.0.1', '192.168.1.5', '192.168.68.110']);
    });

    test('isLanInterfaceName rejects cellular and tunnels', () {
      expect(isLanInterfaceName('pdp_ip0'), isFalse);
      expect(isLanInterfaceName('utun0'), isFalse);
      expect(isLanInterfaceName('awdl0'), isFalse);
      expect(isLanInterfaceName('en0'), isTrue);
      expect(isLanInterfaceName('wlan0'), isTrue);
    });
  });
}
