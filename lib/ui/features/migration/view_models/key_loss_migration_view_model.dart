import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/journal_entry.dart';
import '../../../../l10n/l10n.dart';

/// Disaster-recovery flow for true key loss - no recovery phrase or
/// keystore file available (spec: "True Key-Loss Migration"). Loads the
/// current ledger for the user to review, requires an explicit
/// confirmation before doing anything irreversible, then migrates.
class KeyLossMigrationViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  KeyLossMigrationViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _entriesSubscription = _ledgerRepository.watchEntries().listen(_onEntries);
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<JournalEntry>> _entriesSubscription;

  List<JournalEntry> _entries = const [];
  List<JournalEntry> get entries => _entries;

  bool _hasConfirmed = false;
  bool get hasConfirmed => _hasConfirmed;
  void setConfirmed(bool value) {
    _hasConfirmed = value;
    notifyListeners();
  }

  bool _isMigrating = false;
  bool get isMigrating => _isMigrating;

  void _onEntries(List<JournalEntry> entries) {
    _entries = entries;
    notifyListeners();
  }

  /// Only proceeds if [hasConfirmed] is true - the explicit
  /// "I confirm the current books are valid" acknowledgment is a
  /// precondition this ViewModel itself enforces, not just the View.
  Future<bool> confirmAndMigrate() async {
    if (!_hasConfirmed) return false;

    _isMigrating = true;
    clearFailure();
    notifyListeners();

    try {
      await _ledgerRepository.migrateToNewIdentityAfterKeyLoss();
      _isMigrating = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isMigrating = false;
      setFailure(const AppFailure(AppErrorCode.validationMigrationFailed));
      return false;
    }
  }

  @override
  void dispose() {
    _entriesSubscription.cancel();
    super.dispose();
  }
}
