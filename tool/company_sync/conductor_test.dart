import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'conductor.dart';
import 'scenario.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('company_sync_');
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('permission waits for dependency then done writes report', () async {
    final conductor = CompanySyncConductor(
      steps: const [
        CompanySyncStep(id: 'owner.setup', role: 'owner'),
        CompanySyncStep(
          id: 'claimant.join',
          role: 'claimant',
          dependsOn: ['owner.setup'],
          timeout: Duration(seconds: 2),
        ),
      ],
      reportDirectory: dir,
    );
    await conductor.start();
    addTearDown(conductor.stop);

    final client = HttpClient();
    final base = 'http://127.0.0.1:${conductor.port}';

    final permOwner = await client.getUrl(
      Uri.parse('$base/permission?step=owner.setup'),
    );
    final ownerRes = await (await permOwner.close())
        .transform(utf8.decoder)
        .join();
    expect(jsonDecode(ownerRes)['ok'], true);

    final done = await client.postUrl(Uri.parse('$base/done'));
    done.write(jsonEncode({'step': 'owner.setup', 'visibleText': 'ready'}));
    await (await done.close()).drain<void>();

    final permJoin = await client.getUrl(
      Uri.parse('$base/permission?step=claimant.join'),
    );
    final joinRes = await (await permJoin.close())
        .transform(utf8.decoder)
        .join();
    expect(jsonDecode(joinRes)['ok'], true);

    await conductor.stop();
    final report = jsonDecode(
      await File('${dir.path}/report.json').readAsString(),
    );
    expect(report['done'], contains('owner.setup'));
  });

  test('failed step stops the run', () async {
    final conductor = CompanySyncConductor(
      steps: const [CompanySyncStep(id: 'owner.setup', role: 'owner')],
      reportDirectory: dir,
    );
    await conductor.start();
    addTearDown(conductor.stop);

    final client = HttpClient();
    final base = 'http://127.0.0.1:${conductor.port}';
    final fail = await client.postUrl(Uri.parse('$base/failed'));
    fail.write(
      jsonEncode({'step': 'owner.setup', 'error': 'boom', 'visibleText': 'x'}),
    );
    await (await fail.close()).drain<void>();
    final report = jsonDecode(
      await File('${dir.path}/report.json').readAsString(),
    );
    expect(report['failed']['owner.setup'], 'boom');
    expect(report['stopped'], true);
  });

  test(
    'first failure releases pending permission waiters and marks stopped',
    () async {
      final conductor = CompanySyncConductor(
        steps: const [
          CompanySyncStep(id: 'owner.setup', role: 'owner'),
          CompanySyncStep(
            id: 'owner.confirm',
            role: 'owner',
            dependsOn: ['claimant.join'],
            timeout: Duration(minutes: 5),
          ),
          CompanySyncStep(
            id: 'claimant.join',
            role: 'claimant',
            dependsOn: ['owner.setup'],
          ),
        ],
        reportDirectory: dir,
      );
      await conductor.start();
      addTearDown(conductor.stop);

      final client = HttpClient();
      final base = 'http://127.0.0.1:${conductor.port}';

      // Satisfy owner.setup so claimant.join can proceed; owner.confirm waits.
      final done = await client.postUrl(Uri.parse('$base/done'));
      done.write(jsonEncode({'step': 'owner.setup', 'visibleText': ''}));
      await (await done.close()).drain<void>();

      final pendingConfirm = client
          .getUrl(Uri.parse('$base/permission?step=owner.confirm'))
          .then((r) => r.close());

      // Give the waiter a moment to register.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final fail = await client.postUrl(Uri.parse('$base/failed'));
      fail.write(
        jsonEncode({
          'step': 'claimant.join',
          'error': 'join failed',
          'visibleText': 'no offer',
        }),
      );
      await (await fail.close()).drain<void>();

      final confirmRes = await pendingConfirm.timeout(
        const Duration(seconds: 2),
        onTimeout: () =>
            throw StateError('owner.confirm was not released after fail-fast'),
      );
      expect(confirmRes.statusCode, isNot(200));

      final report = jsonDecode(
        await File('${dir.path}/report.json').readAsString(),
      );
      expect(report['failed']['claimant.join'], 'join failed');
      expect(report['stopped'], true);

      final status = await client.getUrl(Uri.parse('$base/status'));
      // Server may already be closed; either status or connection error is fine.
      try {
        final statusRes = await status.close();
        if (statusRes.statusCode == 200) {
          final body = jsonDecode(await utf8.decodeStream(statusRes));
          expect(body['stopped'], true);
        }
      } on SocketException {
        // Expected once conductor closes after fail-fast.
      }
    },
  );

  test('permission times out when dependency never completes', () async {
    final conductor = CompanySyncConductor(
      steps: const [
        CompanySyncStep(id: 'owner.setup', role: 'owner'),
        CompanySyncStep(
          id: 'claimant.join',
          role: 'claimant',
          dependsOn: ['owner.setup'],
          timeout: Duration(milliseconds: 200),
        ),
      ],
      reportDirectory: dir,
    );
    await conductor.start();
    addTearDown(conductor.stop);

    final client = HttpClient();
    final base = 'http://127.0.0.1:${conductor.port}';
    final perm = await client.getUrl(
      Uri.parse('$base/permission?step=claimant.join'),
    );
    final res = await perm.close();
    final body = await res.transform(utf8.decoder).join();
    expect(res.statusCode, isNot(200), reason: body);
  });

  test('value relay stores and returns join/check codes', () async {
    final conductor = CompanySyncConductor(
      steps: const [CompanySyncStep(id: 'owner.setup', role: 'owner')],
      reportDirectory: dir,
    );
    await conductor.start();
    addTearDown(conductor.stop);

    final client = HttpClient();
    final base = 'http://127.0.0.1:${conductor.port}';

    final put = await client.postUrl(Uri.parse('$base/value'));
    put.write(jsonEncode({'key': 'join_code', 'value': 'K7QF-3M9P'}));
    await (await put.close()).drain<void>();

    final get = await client.getUrl(Uri.parse('$base/value?key=join_code'));
    final body = await (await get.close()).transform(utf8.decoder).join();
    expect(jsonDecode(body)['value'], 'K7QF-3M9P');
  });

  test('ready roles appear in status and report.json', () async {
    final conductor = CompanySyncConductor(
      steps: const [CompanySyncStep(id: 'owner.setup', role: 'owner')],
      reportDirectory: dir,
    );
    await conductor.start();
    addTearDown(conductor.stop);

    final client = HttpClient();
    final base = 'http://127.0.0.1:${conductor.port}';
    final ready = await client.postUrl(Uri.parse('$base/ready'));
    ready.write(jsonEncode({'role': 'claimant_0', 'device': 'iphone'}));
    await (await ready.close()).drain<void>();

    final status = await client.getUrl(Uri.parse('$base/status'));
    final statusBody = await (await status.close())
        .transform(utf8.decoder)
        .join();
    expect(jsonDecode(statusBody)['ready'], contains('claimant_0'));

    final report = jsonDecode(
      await File('${dir.path}/report.json').readAsString(),
    );
    expect(report['ready'], contains('claimant_0'));
  });

  test('dryRunScenario graph: deps, roles, and verify_sync after submit', () {
    final steps = dryRunScenario();
    final byId = {for (final s in steps) s.id: s};
    expect(byId['claimant_0.join']!.dependsOn, contains('claimant_0.ready'));
    expect(
      byId['claimant_0.submit']!.dependsOn,
      containsAll(['claimant_0.join', 'owner.confirm_claimant_0']),
    );
    expect(byId['owner.verify_sync']!.dependsOn, contains('claimant_0.submit'));
    expect(
      byId['owner.publish_join']!.timeout.inMinutes,
      greaterThanOrEqualTo(1),
    );
  });

  test('acmeTravelScenario(2) rush-hour submits share one dependency', () {
    final steps = acmeTravelScenario(employees: 2);
    final submits = steps.where((s) => s.id.endsWith('.submit')).toList();
    expect(submits, hasLength(2));
    expect(
      submits.every((s) => s.dependsOn.contains('owner.set_personal_limits')),
      isTrue,
    );
    expect(
      steps.firstWhere((s) => s.id == 'approver.decide').dependsOn,
      containsAll(['claimant_0.submit', 'claimant_1.submit']),
    );
  });
}
