import 'package:smara_accounting/domain/models/signing_identity.dart';
import 'package:smara_accounting/domain/navigation/app_navigation_policy.dart';
import 'package:test/test.dart';

SigningIdentity _identity() {
  return SigningIdentity(
    identityId: 'id-1',
    publicKey: const [1, 2, 3],
    createdAt: DateTime(2026, 1, 1),
    supersedesIdentityId: null,
    supersededAt: null,
    continuesIdentityId: null,
    continuedAt: null,
    acknowledgedAt: null,
  );
}

AppNavigationPolicy _policy({
  SigningIdentity? identity,
  bool hasEntries = true,
  bool matchingKey = true,
  bool needsBackfill = false,
  bool setupCompleted = true,
  bool lockRequired = false,
  bool joinedLinked = false,
  bool claimantOnly = false,
  void Function()? onVerify,
}) {
  return AppNavigationPolicy(
    currentIdentity: () async => identity,
    hasAnyJournalEntries: () async => hasEntries,
    hasMatchingStoredKey: (_) async => matchingKey,
    verifyChain: () async {
      onVerify?.call();
    },
    needsCurrencyBackfill: () async => needsBackfill,
    isFirstWeekSetupCompleted: () async => setupCompleted,
    lockScreenRequired: () async => lockRequired,
    isJoinedLinkedSet: () async => joinedLinked,
    isClaimantOnlyActiveSet: () async => claimantOnly,
  );
}

void main() {
  final ready = _identity();

  test('no identity redirects to the setup choice screen', () async {
    final policy = _policy(identity: null);
    expect(await policy.resolve(AppNavPaths.home), AppNavPaths.setupChoice);
    expect(await policy.resolve(AppNavPaths.setupChoice), isNull);
  });

  test('no identity stays on every pre-identity screen '
      '(setup choice, import, language, currency)', () async {
    final policy = _policy(identity: null);
    expect(await policy.resolve(AppNavPaths.setupChoice), isNull);
    expect(await policy.resolve(AppNavPaths.importBackup), isNull);
    expect(await policy.resolve(AppNavPaths.language), isNull);
    expect(await policy.resolve(AppNavPaths.currency), isNull);
  });

  test(
    'identity with no entry stays on first-account or first-entry',
    () async {
      final policy = _policy(identity: _identity(), hasEntries: false);
      expect(await policy.resolve(AppNavPaths.home), AppNavPaths.firstAccount);
      expect(await policy.resolve(AppNavPaths.firstAccount), isNull);
      expect(await policy.resolve(AppNavPaths.firstEntry), isNull);
    },
  );

  test(
    'joined linked set with no local entries skips first-account onboarding',
    () async {
      final policy = _policy(
        identity: _identity(),
        hasEntries: false,
        joinedLinked: true,
      );
      expect(await policy.resolve(AppNavPaths.home), isNull);
      expect(await policy.resolve(AppNavPaths.firstAccount), AppNavPaths.home);
    },
  );

  test(
    'joined Claimant-only with no entries lands on Claims, not first-account',
    () async {
      final policy = _policy(
        identity: _identity(),
        hasEntries: false,
        joinedLinked: true,
        claimantOnly: true,
      );
      expect(await policy.resolve(AppNavPaths.home), AppNavPaths.claims);
      expect(await policy.resolve(AppNavPaths.claims), isNull);
    },
  );

  test('identity with a recorded entry proceeds straight through - no '
      'acknowledgment screen follows', () async {
    final policy = _policy(identity: _identity(), hasEntries: true);
    expect(await policy.resolve(AppNavPaths.home), isNull);
  });

  test('missing stored key redirects to continue', () async {
    final policy = _policy(identity: ready, matchingKey: false);
    expect(await policy.resolve(AppNavPaths.home), AppNavPaths.continuePath);
    expect(await policy.resolve(AppNavPaths.continuePath), isNull);
  });

  test('verifyChain runs once per policy instance', () async {
    var calls = 0;
    final policy = _policy(identity: ready, onVerify: () => calls += 1);
    await policy.resolve(AppNavPaths.home);
    await policy.resolve(AppNavPaths.home);
    expect(calls, 1);
  });

  test('currency backfill runs after key match', () async {
    final policy = _policy(identity: ready, needsBackfill: true);
    expect(
      await policy.resolve(AppNavPaths.home),
      AppNavPaths.currencyBackfill,
    );
    expect(await policy.resolve(AppNavPaths.currencyBackfill), isNull);
  });

  test('first-week setup runs after backfill is clear', () async {
    final policy = _policy(identity: ready, setupCompleted: false);
    expect(await policy.resolve(AppNavPaths.home), AppNavPaths.setupWizard);
    expect(await policy.resolve(AppNavPaths.setupWizard), isNull);
  });

  test('lock is required only after setup is complete', () async {
    var lockCalls = 0;
    final locked = AppNavigationPolicy(
      currentIdentity: () async => ready,
      hasAnyJournalEntries: () async => true,
      hasMatchingStoredKey: (_) async => true,
      verifyChain: () async {},
      needsCurrencyBackfill: () async => false,
      isFirstWeekSetupCompleted: () async => false,
      lockScreenRequired: () async {
        lockCalls += 1;
        return true;
      },
    );
    expect(await locked.resolve(AppNavPaths.home), AppNavPaths.setupWizard);
    expect(lockCalls, 0);

    final policy = _policy(identity: ready, lockRequired: true);
    expect(await policy.resolve(AppNavPaths.home), AppNavPaths.lock);
    expect(await policy.resolve(AppNavPaths.lock), isNull);
  });

  test('finished gated routes redirect home; shell stays', () async {
    final policy = _policy(identity: ready);
    expect(await policy.resolve(AppNavPaths.setupChoice), AppNavPaths.home);
    expect(await policy.resolve(AppNavPaths.language), AppNavPaths.home);
    expect(await policy.resolve(AppNavPaths.currency), AppNavPaths.home);
    expect(await policy.resolve(AppNavPaths.lock), AppNavPaths.home);
    expect(await policy.resolve(AppNavPaths.home), isNull);
    expect(await policy.resolve('/settings'), isNull);
  });

  test('verifyChain is skipped when there is no identity', () async {
    var calls = 0;
    final policy = _policy(identity: null, onVerify: () => calls += 1);
    await policy.resolve(AppNavPaths.home);
    expect(calls, 0);
  });
}
