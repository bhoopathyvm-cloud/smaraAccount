import 'dart:io';

/// Orders join-offer host addresses for [SecureJoinCodeLookup].
///
/// When the company-sync conductor is on loopback (simulator-only runs),
/// prefer `127.0.0.1` so the iOS Simulator reaches the macOS JoinCodeHost.
/// When the conductor is on a LAN address (`--real-devices`), prefer LAN
/// IPv4 first: a physical phone's `127.0.0.1` is itself, not the Mac, and
/// trying loopback first wastes the connect timeout (or worse, hangs on a
/// local listener) before the real Wi-Fi path is attempted.
List<String> orderJoinOfferHosts(
  Iterable<String> hosts, {
  required bool preferLoopback,
}) {
  final unique = <String>[];
  for (final h in hosts) {
    if (h.isNotEmpty && !unique.contains(h)) unique.add(h);
  }
  final loopback = unique.where((h) => h == '127.0.0.1').toList();
  final lan = unique.where((h) => h != '127.0.0.1').toList();
  if (preferLoopback) {
    return [...loopback, ...lan];
  }
  return [...lan, ...loopback];
}

/// True when [conductorUrl] points at loopback (simulator-only company sync).
bool conductorPrefersLoopbackJoin(String conductorUrl) {
  if (conductorUrl.isEmpty) return true;
  final uri = Uri.tryParse(conductorUrl);
  if (uri == null) return true;
  final host = uri.host;
  return host.isEmpty ||
      host == '127.0.0.1' ||
      host == 'localhost' ||
      host == '::1';
}

/// Interface-name prefixes that are never the shared Wi-Fi/LAN: cellular
/// (`pdp_ip`), VPN tunnels (`utun`, `ipsec`, `ppp`), Apple peer-to-peer
/// (`awdl`, `llw`) and bridges to virtual machines (`bridge`, `anpi`).
/// A physical iPhone listed its cellular address first, so peers on the
/// same Wi-Fi tried to reach it there and timed out.
const _nonLanInterfacePrefixes = [
  'pdp_ip',
  'utun',
  'ipsec',
  'ppp',
  'awdl',
  'llw',
  'bridge',
  'anpi',
];

/// True when [interfaceName] can carry the shared local network.
bool isLanInterfaceName(String interfaceName) =>
    !_nonLanInterfacePrefixes.any(interfaceName.startsWith);

/// Picks this device's reachable IPv4 addresses from `(interface, address)`
/// pairs: loopback first, then LAN interfaces with `en*` (Wi-Fi/Ethernet)
/// ahead of the rest, skipping cellular, VPN and peer-to-peer interfaces.
List<String> lanIPv4Candidates(
  Iterable<({String interfaceName, String address, bool isLoopback})> addrs,
) {
  final primary = <String>[];
  final other = <String>[];
  for (final a in addrs) {
    if (a.isLoopback || !isLanInterfaceName(a.interfaceName)) continue;
    final target = a.interfaceName.startsWith('en') ? primary : other;
    if (!primary.contains(a.address) && !other.contains(a.address)) {
      target.add(a.address);
    }
  }
  return ['127.0.0.1', ...primary, ...other];
}

/// This device's reachable IPv4 addresses (see [lanIPv4Candidates]).
Future<List<String>> localLanIPv4Addresses() async {
  final pairs = [
    for (final iface in await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    ))
      for (final addr in iface.addresses)
        (
          interfaceName: iface.name,
          address: addr.address,
          isLoopback: addr.isLoopback,
        ),
  ];
  return lanIPv4Candidates(pairs);
}
