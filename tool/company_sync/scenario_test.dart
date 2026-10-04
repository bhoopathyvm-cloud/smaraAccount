import 'package:test/test.dart';

import 'scenario.dart';

void main() {
  test('dryRunScenario orders owner before claimant join and sync', () {
    final steps = dryRunScenario();
    expect(steps.first.id, 'owner.ready');
    expect(
      steps.map((s) => s.id),
      containsAll([
        'owner.publish_join',
        'claimant_0.join',
        'owner.verify_sync',
      ]),
    );
    final join = steps.firstWhere((s) => s.id == 'claimant_0.join');
    expect(join.dependsOn, contains('claimant_0.ready'));
  });

  test('acmeTravelScenario with 2 employees includes rush-hour submits', () {
    final steps = acmeTravelScenario(employees: 2);
    final submits = steps.where((s) => s.id.endsWith('.submit')).toList();
    expect(submits, hasLength(2));
    expect(
      submits.every((s) => s.dependsOn.contains('owner.set_personal_limits')),
      isTrue,
    );
    expect(steps.any((s) => s.id == 'approver.decide'), isTrue);
    expect(steps.any((s) => s.id == 'owner.remove_kenji'), isFalse);
    expect(steps.any((s) => s.id == 'claimant_0.privacy_check'), isTrue);
    expect(steps.any((s) => s.id == 'owner.pass_criteria'), isTrue);
  });

  test(
    'acmeTravelScenario with 5 employees includes Kenji erase and Tom reopen',
    () {
      final steps = acmeTravelScenario(employees: 5);
      expect(steps.any((s) => s.id == 'owner.remove_kenji'), isTrue);
      expect(steps.any((s) => s.id == 'claimant_4.reopen'), isTrue);
      expect(steps.any((s) => s.id == 'claimant_2.post_removal_entry'), isTrue);
      expect(steps.where((s) => s.role.startsWith('claimant_')), isNotEmpty);

      final reopen = steps.firstWhere((s) => s.id == 'claimant_4.reopen');
      expect(reopen.dependsOn, contains('approver.decide'));
      final settle = steps.firstWhere((s) => s.id == 'owner.settle');
      expect(settle.dependsOn, contains('claimant_4.reopen'));
    },
  );

  test('every step dependency refers to a known step id', () {
    for (final n in [2, 5]) {
      final steps = acmeTravelScenario(employees: n);
      final ids = steps.map((s) => s.id).toSet();
      for (final step in steps) {
        for (final dep in step.dependsOn) {
          expect(
            ids,
            contains(dep),
            reason: '${step.id} depends on missing $dep',
          );
        }
      }
    }
  });

  test('claimantDisplayName matches table order', () {
    expect(claimantDisplayName(0), 'Ravi');
    expect(claimantDisplayName(4), 'Tom');
  });

  test('householdScenario is a valid graph over three devices', () {
    final steps = householdScenario();
    final ids = steps.map((s) => s.id).toSet();
    expect(ids.length, steps.length, reason: 'step ids must be unique');
    for (final step in steps) {
      expect(
        ids.containsAll(step.dependsOn),
        isTrue,
        reason: '${step.id} depends on a missing step',
      );
      expect(['owner', 'claimant_0', 'claimant_1'], contains(step.role));
    }
    // No cycles: a topological pass must consume every step.
    final done = <String>{};
    var progressed = true;
    while (progressed) {
      progressed = false;
      for (final step in steps) {
        if (!done.contains(step.id) && done.containsAll(step.dependsOn)) {
          done.add(step.id);
          progressed = true;
        }
      }
    }
    expect(done, ids);
  });

  test('householdScenario: the phone renames after the Mac, then erase', () {
    final steps = {for (final s in householdScenario()) s.id: s};
    expect(steps['claimant_0.hh_rename']!.dependsOn, ['owner.hh_rename']);
    expect(steps['owner.hh_verify_erase']!.dependsOn, ['owner.hh_remove_1']);
    expect(steps['owner.hh_final']!.dependsOn, ['claimant_0.hh_after_removal']);
    for (final role in ['owner', 'claimant_0', 'claimant_1']) {
      expect(steps.containsKey('$role.hh_verify_entries'), isTrue);
    }
  });
}
