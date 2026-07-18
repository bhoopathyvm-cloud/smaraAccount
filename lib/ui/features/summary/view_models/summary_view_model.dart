import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/summary.dart';

/// Date range selection for the Income vs. Expense Summary requirement.
/// Defaults to the current calendar month.
class SummaryViewModel extends ChangeNotifier {
  SummaryViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository,
      _start = _startOfMonth(DateTime.now()),
      _end = DateTime.now() {
    _subscribe();
  }

  final LedgerRepository _ledgerRepository;
  StreamSubscription<LedgerSummary>? _subscription;

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

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _ledgerRepository
        .watchSummary(start: _start, end: _end)
        .listen((summary) {
          _summary = summary;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

DateTime _startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);
