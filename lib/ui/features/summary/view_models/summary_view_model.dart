import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/summary.dart';

/// Date range selection for the Income vs. Expense Summary requirement.
/// Defaults to the current calendar month.
class SummaryViewModel extends ChangeNotifier {
  SummaryViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository,
      _start = _startOfMonth(DateTime.now()),
      _end = DateTime.now() {
    _accountsSubscription = _ledgerRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _financialAccounts = accounts;
      if (_financialAccountId != null &&
          !accounts.any((account) => account.id == _financialAccountId)) {
        _financialAccountId = null;
        _subscribe();
      }
      notifyListeners();
    });
    _subscribe();
  }

  final LedgerRepository _ledgerRepository;
  StreamSubscription<LedgerSummary>? _subscription;
  late final StreamSubscription<List<Account>> _accountsSubscription;

  List<Account> _financialAccounts = const [];
  List<Account> get financialAccounts => _financialAccounts;

  String? _financialAccountId;
  String? get financialAccountId => _financialAccountId;

  DateTime _start;
  DateTime get start => _start;

  DateTime _end;
  DateTime get end => _end;

  LedgerSummary _summary = const LedgerSummary(
    totalIncomeMinor: 0,
    totalExpenseMinor: 0,
  );
  LedgerSummary get summary => _summary;

  void setDateRange({required DateTime start, required DateTime end}) {
    _start = start;
    _end = end;
    _subscribe();
    notifyListeners();
  }

  void setFinancialAccountId(String? accountId) {
    if (_financialAccountId == accountId) return;
    _financialAccountId = accountId;
    _subscribe();
    notifyListeners();
  }

  void _subscribe() {
    _subscription?.cancel();
    final stream = _financialAccountId == null
        ? _ledgerRepository.watchSummary(start: _start, end: _end)
        : _ledgerRepository.watchSummary(
            start: _start,
            end: _end,
            financialAccountId: _financialAccountId,
          );
    _subscription = stream.listen((summary) {
      _summary = summary;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _accountsSubscription.cancel();
    super.dispose();
  }
}

DateTime _startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);
