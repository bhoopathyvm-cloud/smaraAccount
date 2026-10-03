import '../models/signing_identity.dart';

/// Startup and resume path constants shared by [AppNavigationPolicy] and
/// the GoRouter adapter.
abstract final class AppNavPaths {
  static const setupChoice = '/onboarding/setup-choice';
  static const importBackup = '/onboarding/import-backup';
  static const language = '/onboarding/language';
  static const currency = '/onboarding/currency';
  static const firstAccount = '/onboarding/first-account';
  static const firstEntry = '/onboarding/first-entry';
  static const continuePath = '/continue';
  static const currencyBackfill = '/currency-backfill';
  static const setupWizard = '/onboarding/first-week-setup';
  static const lock = '/lock';
  static const home = '/home';

  /// Claimant-only surface (shared-accounts-and-expense-claims).
  static const claims = '/claims';
  static const claimEditor = '/claims/edit';
  static const claimDetail = '/claims/detail';
  static const claimantBalance = '/claims/balance';
  static const myClaimLimits = '/claims/limits';
  static const approverQueue = '/claims/review';
  static const settings = '/settings';

  /// Routes a Claimant-only membership may open on company books.
  static const claimantAllowed = {
    claims,
    claimEditor,
    claimDetail,
    claimantBalance,
    myClaimLimits,
    home,
    lock,
    settings,
  };

  /// Bookkeeping routes Claimant-only must not open.
  static const bookkeepingBlockedForClaimant = {
    '/register',
    '/accounts',
    '/categories',
    '/summary',
    '/transfer',
    '/record-transaction',
    '/import-statement',
    '/payees',
    '/recurring-templates',
    '/holdings',
    '/fix',
    approverQueue,
  };

  /// Reachable before any signing identity exists (books-copy-and-
  /// continuation: "Startup Setup Choice") - the choice screen itself,
  /// the restore-from-copy flow (which never generates an identity of its
  /// own), and New Setup's first two screens (language/currency), which
  /// run before [IdentityRepository.confirmFirstIdentity] commits an
  /// identity.
  static const preIdentity = {setupChoice, importBackup, language, currency};

  static const onboarding = {
    setupChoice,
    importBackup,
    language,
    currency,
    firstAccount,
    firstEntry,
  };

  static const continueRelated = {continuePath};
}

/// Deep redirect policy: setup choice, identity, first-entry, key match,
/// session chain verify, currency backfill, first-week setup, and app
/// lock. [GoRouter] forwards [matchedLocation] and returns the path (or
/// none).
///
/// Session-once chain verify lives on this instance (same lifetime as the
/// router that owns it). Ports are functions so tests need no Flutter
/// navigation and no repository graph.
class AppNavigationPolicy {
  AppNavigationPolicy({
    required Future<SigningIdentity?> Function() currentIdentity,
    required Future<bool> Function() hasAnyJournalEntries,
    required Future<bool> Function(SigningIdentity identity)
    hasMatchingStoredKey,
    required Future<void> Function() verifyChain,
    required Future<bool> Function() needsCurrencyBackfill,
    required Future<bool> Function() isFirstWeekSetupCompleted,
    required Future<bool> Function() lockScreenRequired,
    Future<bool> Function()? isClaimantOnlyActiveSet,
  }) : _currentIdentity = currentIdentity,
       _hasAnyJournalEntries = hasAnyJournalEntries,
       _hasMatchingStoredKey = hasMatchingStoredKey,
       _verifyChain = verifyChain,
       _needsCurrencyBackfill = needsCurrencyBackfill,
       _isFirstWeekSetupCompleted = isFirstWeekSetupCompleted,
       _lockScreenRequired = lockScreenRequired,
       _isClaimantOnlyActiveSet =
           isClaimantOnlyActiveSet ?? (() async => false);

  final Future<SigningIdentity?> Function() _currentIdentity;
  final Future<bool> Function() _hasAnyJournalEntries;
  final Future<bool> Function(SigningIdentity identity) _hasMatchingStoredKey;
  final Future<void> Function() _verifyChain;
  final Future<bool> Function() _needsCurrencyBackfill;
  final Future<bool> Function() _isFirstWeekSetupCompleted;
  final Future<bool> Function() _lockScreenRequired;
  final Future<bool> Function() _isClaimantOnlyActiveSet;

  var _hasVerifiedThisSession = false;

  /// Redirect path for [matchedLocation], or null to stay.
  Future<String?> resolve(String matchedLocation) async {
    final isOnboardingRoute = AppNavPaths.onboarding.contains(matchedLocation);
    final isContinueRoute = AppNavPaths.continueRelated.contains(
      matchedLocation,
    );
    final isLockRoute = matchedLocation == AppNavPaths.lock;

    final identity = await _currentIdentity();
    if (identity == null) {
      return AppNavPaths.preIdentity.contains(matchedLocation)
          ? null
          : AppNavPaths.setupChoice;
    }

    // Once the guided first entry is posted, an identity falls straight
    // through to the ordinary key-match/backfill/setup-wizard/lock checks
    // below, the same whether it came from New Setup or from a restore-
    // from-copy that already has entries of its own.
    final hasRecordedFirstEntry = await _hasAnyJournalEntries();
    if (!hasRecordedFirstEntry) {
      return matchedLocation == AppNavPaths.firstAccount ||
              matchedLocation == AppNavPaths.firstEntry
          ? null
          : AppNavPaths.firstAccount;
    }

    final hasMatchingKey = await _hasMatchingStoredKey(identity);
    if (!hasMatchingKey) {
      return isContinueRoute ? null : AppNavPaths.continuePath;
    }

    if (!_hasVerifiedThisSession) {
      await _verifyChain();
      _hasVerifiedThisSession = true;
    }

    final isCurrencyBackfillRoute =
        matchedLocation == AppNavPaths.currencyBackfill;
    if (await _needsCurrencyBackfill()) {
      return isCurrencyBackfillRoute ? null : AppNavPaths.currencyBackfill;
    }

    final isSetupWizardRoute = matchedLocation == AppNavPaths.setupWizard;
    if (!await _isFirstWeekSetupCompleted()) {
      return isSetupWizardRoute ? null : AppNavPaths.setupWizard;
    }

    if (await _lockScreenRequired()) {
      return isLockRoute ? null : AppNavPaths.lock;
    }

    if (isOnboardingRoute ||
        isContinueRoute ||
        isCurrencyBackfillRoute ||
        isSetupWizardRoute ||
        isLockRoute) {
      // Claimant-only: land on Claims, not full Home bookkeeping.
      if (await _isClaimantOnlyActiveSet()) {
        return AppNavPaths.claims;
      }
      return AppNavPaths.home;
    }

    // Claimant-only gates on the active Books Set (task 3.5).
    if (await _isClaimantOnlyActiveSet()) {
      if (matchedLocation == AppNavPaths.home) {
        return AppNavPaths.claims;
      }
      if (!_claimantMayOpen(matchedLocation)) {
        return AppNavPaths.claims;
      }
      return null;
    }

    return null;
  }

  /// Whether a Claimant-only user may open [location] (unit-testable without
  /// the full resolve gate chain).
  bool claimantMayOpen(String location) => _claimantMayOpen(location);

  bool _claimantMayOpen(String location) {
    if (location == AppNavPaths.approverQueue ||
        location.startsWith('${AppNavPaths.approverQueue}/')) {
      return false;
    }
    if (AppNavPaths.claimantAllowed.contains(location)) return true;
    if (location.startsWith('${AppNavPaths.claims}/')) return true;
    if (location.startsWith('/register')) return false;
    if (location.startsWith('/holdings')) return false;
    for (final blocked in AppNavPaths.bookkeepingBlockedForClaimant) {
      if (location == blocked || location.startsWith('$blocked/')) {
        return false;
      }
    }
    // Unknown routes: deny for Claimant-only (fail closed).
    return false;
  }
}
