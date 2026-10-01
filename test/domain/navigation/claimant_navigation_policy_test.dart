import 'package:smara_accounting/domain/navigation/app_navigation_policy.dart';
import 'package:smara_accounting/domain/models/signing_identity.dart';
import 'package:test/test.dart';

SigningIdentity _identity() => SigningIdentity(
  identityId: 'id-1',
  publicKey: const [1, 2, 3],
  createdAt: DateTime(2026, 1, 1),
  supersedesIdentityId: null,
  supersededAt: null,
  continuesIdentityId: null,
  continuedAt: null,
  acknowledgedAt: null,
);

AppNavigationPolicy _readyPolicy({bool claimantOnly = false}) {
  return AppNavigationPolicy(
    currentIdentity: () async => _identity(),
    hasAnyJournalEntries: () async => true,
    hasMatchingStoredKey: (_) async => true,
    verifyChain: () async {},
    needsCurrencyBackfill: () async => false,
    isFirstWeekSetupCompleted: () async => true,
    lockScreenRequired: () async => false,
    isClaimantOnlyActiveSet: () async => claimantOnly,
  );
}

void main() {
  test('Claimant-only blocks bank register and allows Claims routes', () async {
    final policy = _readyPolicy(claimantOnly: true);
    expect(policy.claimantMayOpen(AppNavPaths.claims), isTrue);
    expect(policy.claimantMayOpen(AppNavPaths.claimEditor), isTrue);
    expect(policy.claimantMayOpen(AppNavPaths.claimantBalance), isTrue);
    expect(policy.claimantMayOpen('/register'), isFalse);
    expect(policy.claimantMayOpen('/register/acct-1'), isFalse);
    expect(policy.claimantMayOpen('/accounts'), isFalse);
    expect(policy.claimantMayOpen(AppNavPaths.approverQueue), isFalse);

    expect(await policy.resolve('/register'), AppNavPaths.claims);
    expect(await policy.resolve(AppNavPaths.claims), isNull);
  });

  test('non-Claimant policy leaves bank routes alone', () async {
    final policy = _readyPolicy(claimantOnly: false);
    expect(await policy.resolve('/register'), isNull);
    expect(await policy.resolve(AppNavPaths.home), isNull);
  });
}
