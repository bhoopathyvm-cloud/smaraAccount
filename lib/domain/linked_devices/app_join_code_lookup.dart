import 'dart:convert';
import 'dart:io';

import '../../data/books_set/active_books_session.dart';
import '../../data/repositories/settings_repository.dart';
import 'device_certificate_store.dart';
import 'join_code_lookup.dart';
import 'join_code_session.dart';
import 'join_offer_discovery.dart';
import 'reserved_join_identity.dart';

/// Production [JoinCodeLookup] that reserves a Signing Identity for the
/// offered books set (from the host welcome frame) before hello, then runs
/// [SecureJoinCodeLookup] over Bonjour offers.
///
/// Under `COMPANY_SYNC_TEST`, prefers a conductor-relayed join offer (HTTP),
/// then a host-written `join_offer.json`, so iOS Simulator ↔ macOS dry runs
/// work when Bonjour does not cross the process boundary and the simulator
/// cannot read the Mac artifacts directory.
class AppJoinCodeLookup implements JoinCodeLookup {
  AppJoinCodeLookup({
    required JoinOfferDiscovery discovery,
    required DeviceCertificateStore certificates,
    required SettingsRepository settings,
    required ActiveBooksSession booksSession,
    this.browseTimeout = const Duration(seconds: 8),
    HttpClient? httpClient,
  }) : _discovery = discovery,
       _certificates = certificates,
       _settings = settings,
       _booksSession = booksSession,
       _http = httpClient;

  final JoinOfferDiscovery _discovery;
  final DeviceCertificateStore _certificates;
  final SettingsRepository _settings;
  final ActiveBooksSession _booksSession;
  final Duration browseTimeout;
  final HttpClient? _http;

  static const _companySyncTest = bool.fromEnvironment('COMPANY_SYNC_TEST');
  static const _artifactsRoot = String.fromEnvironment(
    'COMPANY_SYNC_ARTIFACTS',
  );
  static const _conductorUrl = String.fromEnvironment('COMPANY_SYNC_CONDUCTOR');

  @override
  Future<JoinCodeLookupResult> lookup(String typedCode) async {
    final deviceId = await _settings.localDeviceId();
    if (deviceId == null || deviceId.isEmpty) {
      return const JoinCodeLookupResult.failure(JoinCodeLookupError.notFound);
    }
    final cert = await _certificates.localCertificate(deviceId: deviceId);
    final displayName =
        await _settings.localDeviceDisplayName() ?? 'This device';

    final discovery = await _discoveryForLookup();
    await _debugPut(
      'join_lookup_source',
      discovery is _FixedJoinOfferDiscovery ? 'fixed' : 'bonjour',
    );
    final secure = SecureJoinCodeLookup(
      discovery: discovery,
      localCertificate: cert,
      resolveJoinerIdentity: _reserveForJoin,
      joinerDeviceId: deviceId,
      joinerDisplayName: displayName,
      joinerCertFingerprint: cert.fingerprint,
      // Fixed conductor offers complete immediately; keep Bonjour at 8s.
      browseTimeout: discovery is _FixedJoinOfferDiscovery
          ? const Duration(seconds: 2)
          : browseTimeout,
    );
    try {
      final result = await secure.lookup(typedCode);
      final summary = result.isSuccess
          ? 'ok'
          : 'err_${result.error?.name ?? 'x'}';
      await _debugPut('join_lookup_result', summary);
      if (!result.isSuccess &&
          SecureJoinCodeLookup.lastOfferErrors.isNotEmpty) {
        await _debugPut(
          'join_lookup_errors',
          SecureJoinCodeLookup.lastOfferErrors.length > 500
              ? SecureJoinCodeLookup.lastOfferErrors.substring(0, 500)
              : SecureJoinCodeLookup.lastOfferErrors,
        );
      }
      return result;
    } catch (e) {
      await _debugPut('join_lookup_result', 'throw_$e');
      rethrow;
    }
  }

  Future<ReservedJoinIdentity> _reserveForJoin(String booksSetId) async {
    var currency = 'USD';
    try {
      final row = await _booksSession.database
          .customSelect(
            'SELECT currency FROM account_groups '
            'WHERE currency IS NOT NULL AND currency != \'\' LIMIT 1',
          )
          .getSingleOrNull();
      final value = row?.read<String>('currency');
      if (value != null && value.isNotEmpty) currency = value;
    } catch (_) {}
    final reserved = await _booksSession.reserveJoinIdentity(
      booksSetId: booksSetId,
      currency: currency,
    );
    await _debugPut('join_reserved_identity', reserved.identityId);
    await _debugPut('join_reserved_books', booksSetId);
    return reserved;
  }

  Future<void> _debugPut(String key, String value) async {
    if (!_companySyncTest || _conductorUrl.isEmpty) return;
    final client = _http ?? HttpClient();
    try {
      final req = await client.postUrl(Uri.parse('$_conductorUrl/value'));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({'key': key, 'value': value}));
      await (await req.close()).drain<void>();
    } catch (_) {
      // Best-effort diagnostics only.
    } finally {
      if (_http == null) client.close(force: true);
    }
  }

  Future<JoinOfferDiscovery> _discoveryForLookup() async {
    if (!_companySyncTest) return _discovery;
    final fromConductor = await _offersFromConductor();
    if (fromConductor != null) return fromConductor;
    final fromFile = await _offersFromArtifactsFile();
    if (fromFile != null) return fromFile;
    return _discovery;
  }

  Future<JoinOfferDiscovery?> _offersFromConductor() async {
    if (_conductorUrl.isEmpty) return null;
    final client = _http ?? HttpClient();
    try {
      final uri = Uri.parse(
        '$_conductorUrl/value?key=${Uri.encodeComponent('join_offer')}',
      );
      final req = await client.getUrl(uri);
      final res = await req.close().timeout(const Duration(seconds: 2));
      if (res.statusCode != 200) return null;
      final body = await utf8.decodeStream(res);
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final raw = decoded['value'] as String?;
      if (raw == null || raw.isEmpty) return null;
      return _discoveryFromOfferMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    } finally {
      if (_http == null) client.close(force: true);
    }
  }

  Future<JoinOfferDiscovery?> _offersFromArtifactsFile() async {
    if (_artifactsRoot.isEmpty) return null;
    final file = File('$_artifactsRoot/conductor/join_offer.json');
    if (!file.existsSync()) return null;
    try {
      final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return _discoveryFromOfferMap(map);
    } catch (_) {
      return null;
    }
  }

  JoinOfferDiscovery? _discoveryFromOfferMap(Map<String, dynamic> map) {
    final port = map['port'] as int?;
    final offerId = map['offerId'] as String?;
    final booksSetId = map['booksSetId'] as String?;
    if (port == null || offerId == null) return null;
    if (booksSetId == null || booksSetId.isEmpty) return null;
    final hosts = <String>[];
    final listed = map['hosts'];
    if (listed is List) {
      for (final h in listed) {
        if (h is String && h.isNotEmpty) hosts.add(h);
      }
    }
    final single = map['host'] as String?;
    if (single != null && single.isNotEmpty && !hosts.contains(single)) {
      hosts.insert(0, single);
    }
    // Prefer loopback first: iOS Simulator shares the Mac network stack, so
    // 127.0.0.1 reaches the host JoinCodeHost reliably. LAN IPv4 is a fallback
    // for Android emulators / physical devices.
    final lan = hosts.where((h) => h != '127.0.0.1').toList();
    final ordered = <String>[
      if (hosts.contains('127.0.0.1')) '127.0.0.1',
      ...lan,
    ];
    hosts
      ..clear()
      ..addAll(ordered);
    if (hosts.isEmpty) return null;
    return _FixedJoinOfferDiscovery([
      for (final host in hosts)
        DiscoveredJoinOffer(
          offerId: offerId,
          host: host,
          port: port,
          booksSetId: booksSetId,
        ),
    ]);
  }
}

class _FixedJoinOfferDiscovery implements JoinOfferDiscovery {
  _FixedJoinOfferDiscovery(this.offers);

  final List<DiscoveredJoinOffer> offers;

  @override
  Future<void> startAdvertising(JoinOfferAdvertisement advertisement) async {}

  @override
  Future<void> stopAdvertising() async {}

  @override
  Stream<DiscoveredJoinOffer> browse() =>
      Stream<DiscoveredJoinOffer>.fromIterable(offers);
}
