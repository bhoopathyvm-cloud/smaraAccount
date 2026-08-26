import '../models/signing_identity.dart';

/// Startup and resume path constants shared by [AppNavigationPolicy] and
/// the GoRouter adapter.
abstract final class AppNavPaths {
  static const currency = '/onboarding/currency';
  static const firstAccount = '/onboarding/first-account';
  static const firstEntry = '/onboarding/first-entry';
  static const recoveryPhrase = '/onboarding/recovery-phrase';
  static const keystoreExport = '/onboarding/keystore-export';
  static const confirm = '/onboarding/confirm';
  static const restore = '/restore';
  static const migrate = '/restore/migrate';
  static const currencyBackfill = '/currency-backfill';
  static const setupWizard = '/onboarding/first-week-setup';
  static const lock = '/lock';
  static const home = '/home';

  static const acknowledgment = {recoveryPhrase, keystoreExport, confirm};

  static const onboarding = {
    currency,
    firstAccount,
    firstEntry,
    ...acknowledgment,
  };

  static const restoreRelated = {restore, migrate};
}

/// Deep redirect policy: identity, first-entry, key match, session chain
/// verify, currency backfill, first-week setup, and app lock. [GoRouter]
/// forwards [matchedLocation] and returns the path (or none).
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
  }) : _currentIdentity = currentIdentity,
       _hasAnyJournalEntries = hasAnyJournalEntries,
       _hasMatchingStoredKey = hasMatchingStoredKey,
       _verifyChain = verifyChain,
       _needsCurrencyBackfill = needsCurrencyBackfill,
       _isFirstWeekSetupCompleted = isFirstWeekSetupCompleted,
       _lockScreenRequired = lockScreenRequired;

  final Future<SigningIdentity?> Function() _currentIdentity;
  final Future<bool> Function() _hasAnyJournalEntries;
  final Future<bool> Function(SigningIdentity identity) _hasMatchingStoredKey;
  final Future<void> Function() _verifyChain;
  final Future<bool> Function() _needsCurrencyBackfill;
  final Future<bool> Function() _isFirstWeekSetupCompleted;
  final Future<bool> Function() _lockScreenRequired;

  var _hasVerifiedThisSession = false;

  /// Redirect path for [matchedLocation], or null to stay.
  Future<String?> resolve(String matchedLocation) async {
    final isOnboardingRoute = AppNavPaths.onboarding.contains(matchedLocation);
    final isRestoreRoute = AppNavPaths.restoreRelated.contains(matchedLocation);
    final isLockRoute = matchedLocation == AppNavPaths.lock;

    final identity = await _currentIdentity();
    if (identity == null) {
      return matchedLocation == AppNavPaths.currency
          ? null
          : AppNavPaths.currency;
    }

    if (identity.acknowledgedAt == null) {
      final hasRecordedFirstEntry = await _hasAnyJournalEntries();
      if (!hasRecordedFirstEntry) {
        return matchedLocation == AppNavPaths.firstAccount ||
                matchedLocation == AppNavPaths.firstEntry
            ? null
            : AppNavPaths.firstAccount;
      }
      return AppNavPaths.acknowledgment.contains(matchedLocation)
          ? null
          : AppNavPaths.recoveryPhrase;
    }

    final hasMatchingKey = await _hasMatchingStoredKey(identity);
    if (!hasMatchingKey) {
      return isRestoreRoute ? null : AppNavPaths.restore;
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
        isRestoreRoute ||
        isCurrencyBackfillRoute ||
        isSetupWizardRoute ||
        isLockRoute) {
      return AppNavPaths.home;
    }
    return null;
  }
}
