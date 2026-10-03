import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// One step in the company sync scenario (task 7.1).
class CompanySyncStep {
  const CompanySyncStep({
    required this.id,
    required this.role,
    this.dependsOn = const [],
    this.timeout = const Duration(minutes: 2),
  });

  final String id;
  final String role;
  final List<String> dependsOn;
  final Duration timeout;
}

/// Coordinates role instances over HTTP (real-sync design Decision 8).
class CompanySyncConductor {
  CompanySyncConductor({
    required this.steps,
    required this.reportDirectory,
    HttpServer? server,
  }) : _injectedServer = server;

  final List<CompanySyncStep> steps;
  final Directory reportDirectory;
  final HttpServer? _injectedServer;

  HttpServer? _server;
  final _done = <String>{};
  final _failed = <String, String>{};
  final _timeline = <Map<String, Object?>>[];
  final _waiters = <String, Completer<void>>{};
  final _values = <String, String>{};
  bool _stopped = false;
  Completer<void>? _runFailed;

  int get port => _server!.port;

  bool get isStopped => _stopped;

  bool get _allStepsDone =>
      steps.isNotEmpty && steps.every((s) => _done.contains(s.id));

  Future<void> start({InternetAddress? address, int port = 0}) async {
    await reportDirectory.create(recursive: true);
    _server =
        _injectedServer ??
        await HttpServer.bind(address ?? InternetAddress.loopbackIPv4, port);
    _server!.listen(_handle);
    _log('conductor_started', {'port': _server!.port});
  }

  Future<void> stop() async {
    _stopped = true;
    _failAllWaiters(StateError('conductor stopped'));
    await _server?.close(force: true);
    await _writeReport();
  }

  /// Marks the run failed, releases waiters, writes the report, and closes.
  Future<void> failRun({
    required String stepId,
    required String error,
    String? visibleText,
  }) async {
    if (_stopped && _failed.containsKey(stepId)) {
      await _writeReport();
      return;
    }
    _failed[stepId] = error;
    _log('failed', {
      'step': stepId,
      'error': error,
      'visibleText': ?visibleText,
    });
    await _stopForFailure();
  }

  Future<void> _stopForFailure() async {
    _stopped = true;
    _failAllWaiters(StateError('conductor failed'));
    await _writeReport();
    await _server?.close(force: true);
    final signal = _runFailed;
    if (signal != null && !signal.isCompleted) {
      signal.complete();
    }
  }

  void _failAllWaiters(Object error) {
    for (final c in _waiters.values) {
      if (!c.isCompleted) c.completeError(error);
    }
    _waiters.clear();
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (path == '/ready' && request.method == 'POST') {
        final body = jsonDecode(await utf8.decodeStream(request)) as Map;
        _log('ready', {'role': body['role'], 'device': body['device']});
        await _json(request.response, {'ok': true});
        return;
      }
      if (path == '/status' && request.method == 'GET') {
        await _json(request.response, {
          'stopped': _stopped,
          'failed': _failed,
          'done': _done.toList(),
        });
        return;
      }
      if (path == '/permission' && request.method == 'GET') {
        final stepId = request.uri.queryParameters['step']!;
        if (_stopped) {
          request.response.statusCode = 503;
          await _json(request.response, {
            'ok': false,
            'error': 'conductor stopped',
            'failed': _failed,
          });
          return;
        }
        try {
          await _waitUntilReady(stepId);
        } on TimeoutException {
          request.response.statusCode = 504;
          await _json(request.response, {
            'ok': false,
            'error': 'timeout',
            'step': stepId,
          });
          await failRun(
            stepId: stepId,
            error: 'permission timeout waiting for dependencies of $stepId',
          );
          return;
        } catch (e) {
          request.response.statusCode = 503;
          await _json(request.response, {
            'ok': false,
            'error': '$e',
            'step': stepId,
          });
          return;
        }
        if (_stopped) {
          request.response.statusCode = 503;
          await _json(request.response, {
            'ok': false,
            'error': 'conductor stopped',
            'failed': _failed,
          });
          return;
        }
        await _json(request.response, {'ok': true, 'step': stepId});
        return;
      }
      if (path == '/done' && request.method == 'POST') {
        if (_stopped) {
          request.response.statusCode = 503;
          await _json(request.response, {'ok': false, 'error': 'stopped'});
          return;
        }
        final body = jsonDecode(await utf8.decodeStream(request)) as Map;
        final stepId = body['step'] as String;
        _done.add(stepId);
        _log('done', {'step': stepId, 'text': body['visibleText']});
        _releaseDependents();
        await _writeReport();
        if (_allStepsDone) {
          _stopped = true;
          _log('all_done', {});
          await _writeReport();
          await _json(request.response, {'ok': true, 'complete': true});
          await _server?.close(force: true);
          return;
        }
        await _json(request.response, {'ok': true});
        return;
      }
      if (path == '/failed' && request.method == 'POST') {
        final body = jsonDecode(await utf8.decodeStream(request)) as Map;
        final stepId = body['step'] as String;
        final error = '${body['error']}';
        await _json(request.response, {'ok': true});
        await failRun(
          stepId: stepId,
          error: error,
          visibleText: body['visibleText'] as String?,
        );
        return;
      }
      if (path == '/value' && request.method == 'POST') {
        if (_stopped) {
          request.response.statusCode = 503;
          await _json(request.response, {'ok': false, 'error': 'stopped'});
          return;
        }
        final body = jsonDecode(await utf8.decodeStream(request)) as Map;
        _values[body['key'] as String] = body['value'] as String;
        await _json(request.response, {'ok': true});
        return;
      }
      if (path == '/value' && request.method == 'GET') {
        final key = request.uri.queryParameters['key']!;
        await _json(request.response, {
          'value': _values[key],
          'stopped': _stopped,
          'failed': _failed,
        });
        return;
      }
      request.response.statusCode = 404;
      await request.response.close();
    } catch (e) {
      request.response.statusCode = 500;
      request.response.write('$e');
      await request.response.close();
    }
  }

  Future<void> _waitUntilReady(String stepId) async {
    final step = steps.firstWhere((s) => s.id == stepId);
    final pending = step.dependsOn.where((d) => !_done.contains(d)).toList();
    if (pending.isEmpty) return;
    if (_stopped) {
      throw StateError('conductor stopped');
    }
    final c = Completer<void>();
    _waiters[stepId] = c;
    try {
      await c.future.timeout(step.timeout);
    } on TimeoutException {
      _waiters.remove(stepId);
      rethrow;
    }
  }

  void _releaseDependents() {
    for (final entry in _waiters.entries.toList()) {
      final step = steps.firstWhere((s) => s.id == entry.key);
      if (step.dependsOn.every(_done.contains)) {
        _waiters.remove(entry.key);
        if (!entry.value.isCompleted) entry.value.complete();
      }
    }
  }

  void _log(String event, [Map<String, Object?>? data]) {
    _timeline.add({
      'at': DateTime.now().toUtc().toIso8601String(),
      'event': event,
      ...?data,
    });
  }

  Future<void> _writeReport() async {
    final report = {
      'done': _done.toList()..sort(),
      'failed': _failed,
      'timeline': _timeline,
      'stopped': _stopped,
    };
    await File(
      '${reportDirectory.path}/report.json',
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(report));
    final lines = _timeline
        .map((e) => '${e['at']} ${e['event']} ${e['step'] ?? ''}')
        .join('\n');
    await File('${reportDirectory.path}/timeline.txt').writeAsString(lines);
  }

  static Future<void> _json(HttpResponse res, Map<String, Object?> body) async {
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(body));
    await res.close();
  }
}
