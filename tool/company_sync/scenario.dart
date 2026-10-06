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

/// Household scenario: one person, the macOS app (`owner`) and two phones
/// (`claimant_0`, `claimant_1`) linked with "Add a device", no claims or
/// roles. Proves that every device sees every entry with the same balance,
/// that the later rename wins everywhere, and that removing a device erases
/// its copy while the remaining two keep syncing.
List<CompanySyncStep> householdScenario() {
  const devices = ['claimant_0', 'claimant_1'];
  const all = ['owner', ...devices];
  return [
    const CompanySyncStep(id: 'owner.ready', role: 'owner'),
    const CompanySyncStep(
      id: 'owner.hh_create_books',
      role: 'owner',
      dependsOn: ['owner.ready'],
      timeout: Duration(minutes: 5),
    ),
    for (var i = 0; i < devices.length; i++) ...[
      CompanySyncStep(
        id: 'owner.hh_offer_$i',
        role: 'owner',
        dependsOn: [
          i == 0 ? 'owner.hh_create_books' : 'owner.hh_confirm_${i - 1}',
        ],
        timeout: const Duration(minutes: 5),
      ),
      CompanySyncStep(
        id: 'claimant_$i.ready',
        role: 'claimant_$i',
        dependsOn: ['owner.hh_offer_$i'],
        timeout: const Duration(minutes: 10),
      ),
      CompanySyncStep(
        id: 'claimant_$i.join',
        role: 'claimant_$i',
        dependsOn: ['claimant_$i.ready'],
        timeout: const Duration(minutes: 8),
      ),
      CompanySyncStep(
        id: 'owner.hh_confirm_$i',
        role: 'owner',
        dependsOn: ['owner.hh_offer_$i'],
        timeout: const Duration(minutes: 8),
      ),
    ],
    for (final role in all)
      CompanySyncStep(
        id: '$role.hh_record',
        role: role,
        dependsOn: const [
          'owner.hh_confirm_1',
          'claimant_0.join',
          'claimant_1.join',
        ],
        timeout: const Duration(minutes: 5),
      ),
    for (final role in all)
      CompanySyncStep(
        id: '$role.hh_verify_entries',
        role: role,
        dependsOn: [for (final r in all) '$r.hh_record'],
        timeout: const Duration(minutes: 8),
      ),
    CompanySyncStep(
      id: 'owner.hh_compare_balances',
      role: 'owner',
      dependsOn: [for (final r in all) '$r.hh_verify_entries'],
      timeout: const Duration(minutes: 3),
    ),
    const CompanySyncStep(
      id: 'owner.hh_rename',
      role: 'owner',
      dependsOn: ['owner.hh_compare_balances'],
      timeout: Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'claimant_0.hh_rename',
      role: 'claimant_0',
      // Strictly after the Mac's rename, so the phone's rename is the later
      // one and must win on every device.
      dependsOn: ['owner.hh_rename'],
      timeout: Duration(minutes: 5),
    ),
    for (final role in all)
      CompanySyncStep(
        id: '$role.hh_verify_rename',
        role: role,
        dependsOn: const ['claimant_0.hh_rename'],
        timeout: const Duration(minutes: 8),
      ),
    CompanySyncStep(
      id: 'owner.hh_remove_1',
      role: 'owner',
      dependsOn: [for (final r in all) '$r.hh_verify_rename'],
      timeout: const Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'claimant_1.hh_await_erase',
      role: 'claimant_1',
      dependsOn: ['owner.hh_remove_1'],
      timeout: Duration(minutes: 10),
    ),
    const CompanySyncStep(
      id: 'owner.hh_verify_erase',
      role: 'owner',
      dependsOn: ['owner.hh_remove_1'],
      timeout: Duration(minutes: 10),
    ),
    const CompanySyncStep(
      id: 'claimant_0.hh_after_removal',
      role: 'claimant_0',
      dependsOn: ['owner.hh_verify_erase'],
      timeout: Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'owner.hh_final',
      role: 'owner',
      dependsOn: ['claimant_0.hh_after_removal'],
      timeout: Duration(minutes: 8),
    ),
  ];
}

/// Direct pair (os-provided-encryption 6.3/6.5): one phone hosts the books
/// (owner) and the other joins (claimant_0) - an iPhone and an Android
/// device with no Mac in between, run once with each as host. Both record,
/// both see both entries with the same balance, the later rename wins on
/// both, and removing the joiner erases its copy on next contact.
List<CompanySyncStep> pairScenario() {
  const all = ['owner', 'claimant_0'];
  return [
    const CompanySyncStep(id: 'owner.ready', role: 'owner'),
    const CompanySyncStep(
      id: 'owner.hh_create_books',
      role: 'owner',
      dependsOn: ['owner.ready'],
      timeout: Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'owner.hh_offer_0',
      role: 'owner',
      dependsOn: ['owner.hh_create_books'],
      timeout: Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'claimant_0.ready',
      role: 'claimant_0',
      dependsOn: ['owner.hh_offer_0'],
      timeout: Duration(minutes: 10),
    ),
    const CompanySyncStep(
      id: 'claimant_0.join',
      role: 'claimant_0',
      dependsOn: ['claimant_0.ready'],
      timeout: Duration(minutes: 8),
    ),
    const CompanySyncStep(
      id: 'owner.hh_confirm_0',
      role: 'owner',
      dependsOn: ['owner.hh_offer_0'],
      timeout: Duration(minutes: 8),
    ),
    for (final role in all)
      CompanySyncStep(
        id: '$role.hh_record',
        role: role,
        dependsOn: const ['owner.hh_confirm_0', 'claimant_0.join'],
        timeout: const Duration(minutes: 5),
      ),
    for (final role in all)
      CompanySyncStep(
        id: '$role.hh_verify_entries',
        role: role,
        dependsOn: [for (final r in all) '$r.hh_record'],
        timeout: const Duration(minutes: 8),
      ),
    CompanySyncStep(
      id: 'owner.hh_compare_balances',
      role: 'owner',
      dependsOn: [for (final r in all) '$r.hh_verify_entries'],
      timeout: const Duration(minutes: 3),
    ),
    const CompanySyncStep(
      id: 'owner.hh_rename',
      role: 'owner',
      dependsOn: ['owner.hh_compare_balances'],
      timeout: Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'claimant_0.hh_rename',
      role: 'claimant_0',
      dependsOn: ['owner.hh_rename'],
      timeout: Duration(minutes: 5),
    ),
    for (final role in all)
      CompanySyncStep(
        id: '$role.hh_verify_rename',
        role: role,
        dependsOn: const ['claimant_0.hh_rename'],
        timeout: const Duration(minutes: 8),
      ),
    CompanySyncStep(
      id: 'owner.pair_remove',
      role: 'owner',
      dependsOn: [for (final r in all) '$r.hh_verify_rename'],
      timeout: const Duration(minutes: 5),
    ),
    const CompanySyncStep(
      id: 'claimant_0.pair_await_erase',
      role: 'claimant_0',
      dependsOn: ['owner.pair_remove'],
      timeout: Duration(minutes: 10),
    ),
    const CompanySyncStep(
      id: 'owner.hh_verify_erase',
      role: 'owner',
      dependsOn: ['owner.pair_remove'],
      timeout: Duration(minutes: 10),
    ),
  ];
}
