import 'dart:convert';
import 'dart:io';

/// HTTP client for a company-sync role instance (task 7.2).
class CompanySyncConductorClient {
  CompanySyncConductorClient({required this.baseUrl, HttpClient? httpClient})
    : _client = httpClient ?? HttpClient();

  final String baseUrl;
  final HttpClient _client;

  Future<void> reportReady({required String role, String? device}) async {
    await _post('/ready', {'role': role, 'device': device});
  }

  Future<void> awaitPermission(String stepId) async {
    final uri = Uri.parse(
      '$baseUrl/permission?step=${Uri.encodeComponent(stepId)}',
    );
    final req = await _client.getUrl(uri);
    final res = await req.close();
    final body = await utf8.decodeStream(res);
    if (res.statusCode != 200) {
      throw StateError('permission failed for $stepId: $body');
    }
    final decoded = jsonDecode(body) as Map;
    if (decoded['ok'] != true) {
      throw StateError('permission denied for $stepId: $body');
    }
  }

  Future<void> reportDone(String stepId, {required String visibleText}) async {
    await _post('/done', {'step': stepId, 'visibleText': visibleText});
  }

  Future<void> reportFailed(
    String stepId, {
    required Object error,
    required String visibleText,
  }) async {
    try {
      await _post('/failed', {
        'step': stepId,
        'error': '$error',
        'visibleText': visibleText,
      });
    } catch (_) {
      // Conductor may already be closed after the first failure.
    }
  }

  Future<void> putValue(String key, String value) async {
    await _post('/value', {'key': key, 'value': value});
  }

  Future<String?> getValue(String key) async {
    try {
      final uri = Uri.parse('$baseUrl/value?key=${Uri.encodeComponent(key)}');
      final req = await _client.getUrl(uri);
      final res = await req.close();
      final body = await utf8.decodeStream(res);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(body) as Map;
      if (decoded['stopped'] == true) {
        throw StateError(
          'conductor stopped while waiting for $key: ${decoded['failed']}',
        );
      }
      return decoded['value'] as String?;
    } on SocketException catch (e) {
      throw StateError('conductor unreachable while reading $key: $e');
    }
  }

  /// Polls until [key] is present, the conductor stops, or [timeout] elapses.
  Future<String> waitValue(
    String key, {
    Duration timeout = const Duration(minutes: 5),
    Duration interval = const Duration(milliseconds: 250),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final v = await getValue(key);
      if (v != null && v.isNotEmpty) return v;
      await Future<void>.delayed(interval);
    }
    throw TimeoutException('value $key not set within $timeout');
  }

  Future<void> _post(String path, Map<String, Object?> body) async {
    final req = await _client.postUrl(Uri.parse('$baseUrl$path'));
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close();
    final text = await utf8.decodeStream(res);
    if (res.statusCode != 200) {
      throw StateError('POST $path failed (${res.statusCode}): $text');
    }
  }

  void close() => _client.close(force: true);
}

class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;
  @override
  String toString() => message;
}
