import 'package:cupertino_http/cupertino_http.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/crypto/crypto_backend.dart';

/// Which HTTP stack a platform's lookups use (os-provided-encryption
/// design D5).
enum PlatformHttpClientKind {
  /// `dart:io`'s HttpClient (BoringSSL TLS): Android, Windows, Linux.
  dartIo,

  /// Apple's URL loading system (`URLSession`) through `cupertino_http`,
  /// so iOS and macOS never use an app-provided TLS for HTTPS lookups.
  appleUrlSession,
}

PlatformHttpClientKind platformHttpClientKindFor(TargetPlatform platform) {
  if (!kIsWeb && isApplePlatform(platform)) {
    return PlatformHttpClientKind.appleUrlSession;
  }
  return PlatformHttpClientKind.dartIo;
}

/// The `http.Client` for the exchange-rate and quote services on
/// [platform] (default: the running platform). Requests, timeouts and
/// offline handling are the services' own and do not change with the stack.
http.Client createPlatformHttpClient({TargetPlatform? platform}) {
  final target = platform ?? defaultTargetPlatform;
  return switch (platformHttpClientKindFor(target)) {
    PlatformHttpClientKind.appleUrlSession =>
      CupertinoClient.defaultSessionConfiguration(),
    PlatformHttpClientKind.dartIo => http.Client(),
  };
}
