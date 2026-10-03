import 'conductor.dart';

/// Minimal two-role dry run for task 7.2 (Owner + one Claimant).
List<CompanySyncStep> dryRunScenario() {
  return const [
    CompanySyncStep(id: 'owner.ready', role: 'owner'),
    CompanySyncStep(
      id: 'owner.create_company',
      role: 'owner',
      dependsOn: ['owner.ready'],
      timeout: Duration(minutes: 5),
    ),
    CompanySyncStep(
      id: 'owner.publish_join',
      role: 'owner',
      dependsOn: ['owner.create_company'],
      timeout: Duration(minutes: 3),
    ),
    CompanySyncStep(
      id: 'claimant_0.ready',
      role: 'claimant_0',
      dependsOn: ['owner.publish_join'],
    ),
    CompanySyncStep(
      id: 'claimant_0.join',
      role: 'claimant_0',
      dependsOn: ['claimant_0.ready'],
      timeout: Duration(minutes: 5),
    ),
    CompanySyncStep(
      id: 'owner.confirm_claimant_0',
      role: 'owner',
      // Parallel with join: waits on check_code_* value, not join completion
      // (both sides must confirm before the payload is exchanged).
      dependsOn: ['owner.publish_join'],
      timeout: Duration(minutes: 5),
    ),
    CompanySyncStep(
      id: 'claimant_0.submit',
      role: 'claimant_0',
      dependsOn: ['claimant_0.join', 'owner.confirm_claimant_0'],
      timeout: Duration(minutes: 5),
    ),
    CompanySyncStep(
      id: 'owner.verify_sync',
      role: 'owner',
      dependsOn: ['claimant_0.submit'],
      timeout: Duration(minutes: 5),
    ),
  ];
}

/// Acme Travel Co scenario (tasks 7.1 / 8.x).
///
/// With [employees] less than 5, people are taken in table order
/// (Ravi, Mia, Kenji, Sara, Tom).
List<CompanySyncStep> acmeTravelScenario({int employees = 2}) {
  final n = employees.clamp(1, 5);
  final steps = <CompanySyncStep>[
    const CompanySyncStep(
      id: 'owner.ready',
      role: 'owner',
      timeout: Duration(minutes: 3),
    ),
    const CompanySyncStep(
      id: 'owner.create_company',
      role: 'owner',
      dependsOn: ['owner.ready'],
      timeout: Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'owner.configure_limits',
      role: 'owner',
      dependsOn: ['owner.create_company'],
      timeout: Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'approver.ready',
      role: 'approver',
      // Waits through create_company (cold macOS build can exceed 2 minutes).
      dependsOn: ['owner.configure_limits'],
      timeout: Duration(minutes: 10),
    ),
    const CompanySyncStep(
      id: 'approver.join',
      role: 'approver',
      dependsOn: ['approver.ready'],
      timeout: Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'owner.confirm_approver',
      role: 'owner',
      // Parallel with approver.join (value-relay handshake).
      dependsOn: ['owner.configure_limits'],
      timeout: Duration(minutes: 10),
    ),
  ];

  for (var i = 0; i < n; i++) {
    final role = 'claimant_$i';
    final priorConfirm = i == 0
        ? 'owner.confirm_approver'
        : 'owner.confirm_claimant_${i - 1}';
    steps.addAll([
      CompanySyncStep(
        id: '$role.ready',
        role: role,
        dependsOn: [priorConfirm],
        // Prior confirm can wait on a slow check-code handshake.
        timeout: const Duration(minutes: 10),
      ),
      CompanySyncStep(
        id: '$role.join',
        role: role,
        dependsOn: ['$role.ready'],
        timeout: const Duration(minutes: 8),
      ),
      CompanySyncStep(
        id: 'owner.confirm_$role',
        role: 'owner',
        // Parallel with $role.join.
        dependsOn: [priorConfirm],
        timeout: const Duration(minutes: 8),
      ),
    ]);
  }

  steps.add(
    CompanySyncStep(
      id: 'owner.set_personal_limits',
      role: 'owner',
      dependsOn: [for (var i = 0; i < n; i++) 'owner.confirm_claimant_$i'],
      timeout: const Duration(minutes: 5),
    ),
  );

  for (var i = 0; i < n; i++) {
    final role = 'claimant_$i';
    steps.add(
      CompanySyncStep(
        id: '$role.submit',
        role: role,
        dependsOn: const ['owner.set_personal_limits'],
        timeout: const Duration(minutes: 5),
      ),
    );
  }

  steps.addAll([
    CompanySyncStep(
      id: 'approver.decide',
      role: 'approver',
      dependsOn: [for (var i = 0; i < n; i++) 'claimant_$i.submit'],
      timeout: const Duration(minutes: 10),
    ),
    if (n >= 5)
      const CompanySyncStep(
        id: 'claimant_4.reopen',
        role: 'claimant_4',
        dependsOn: ['approver.decide'],
        timeout: Duration(minutes: 5),
      ),
    CompanySyncStep(
      id: 'owner.settle',
      role: 'owner',
      dependsOn: n >= 5
          ? const ['claimant_4.reopen']
          : const ['approver.decide'],
      timeout: const Duration(minutes: 10),
    ),
    if (n >= 3)
      const CompanySyncStep(
        id: 'owner.remove_kenji',
        role: 'owner',
        dependsOn: ['owner.settle'],
        // Headroom above owner.settle (10m): permission wait includes deps.
        timeout: Duration(minutes: 15),
      ),
    if (n >= 3)
      const CompanySyncStep(
        id: 'claimant_2.post_removal_entry',
        role: 'claimant_2',
        dependsOn: ['owner.remove_kenji'],
        timeout: Duration(minutes: 15),
      ),
    if (n >= 3)
      const CompanySyncStep(
        id: 'owner.verify_erase',
        role: 'owner',
        dependsOn: ['claimant_2.post_removal_entry'],
        timeout: Duration(minutes: 15),
      ),
    CompanySyncStep(
      id: 'owner.competing_rename',
      role: 'owner',
      dependsOn: [if (n >= 3) 'owner.verify_erase' else 'owner.settle'],
      // Claimants/Approver may already be waiting on this chain; keep headroom
      // above owner.settle (10m) so permission waits do not abort early.
      timeout: const Duration(minutes: 15),
    ),
    CompanySyncStep(
      id: 'approver.competing_rename',
      role: 'approver',
      dependsOn: [if (n >= 3) 'owner.verify_erase' else 'owner.settle'],
      timeout: const Duration(minutes: 15),
    ),
    const CompanySyncStep(
      id: 'all.verify_rename',
      role: 'owner',
      dependsOn: ['owner.competing_rename', 'approver.competing_rename'],
      timeout: Duration(minutes: 10),
    ),
    for (var i = 0; i < n; i++)
      CompanySyncStep(
        id: 'claimant_$i.privacy_check',
        role: 'claimant_$i',
        // Requested right after submit; must outlast settle + renames.
        dependsOn: const ['all.verify_rename'],
        timeout: const Duration(minutes: 20),
      ),
    CompanySyncStep(
      id: 'owner.pass_criteria',
      role: 'owner',
      dependsOn: [for (var i = 0; i < n; i++) 'claimant_$i.privacy_check'],
      timeout: const Duration(minutes: 10),
    ),
    CompanySyncStep(
      id: 'approver.pass_criteria',
      role: 'approver',
      dependsOn: [for (var i = 0; i < n; i++) 'claimant_$i.privacy_check'],
      timeout: const Duration(minutes: 10),
    ),
  ]);

  return steps;
}

/// People in table order for the cast.
const acmePeople = [
  ('Ravi', 'claimant_0'),
  ('Mia', 'claimant_1'),
  ('Kenji', 'claimant_2'),
  ('Sara', 'claimant_3'),
  ('Tom', 'claimant_4'),
];

String claimantDisplayName(int index) => acmePeople[index].$1;
