import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/payee.dart';

/// Minimal add/rename/delete for payees (payees-and-spending-memory tasks.md
/// 1.2: "CRUD (minimal, inline or in Settings) for payees").
class PayeeManagementViewModel extends ChangeNotifier {
  PayeeManagementViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _subscription = _ledgerRepository.watchPayees().listen((payees) {
      _payees = payees;
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Payee>> _subscription;

  List<Payee> _payees = const [];
  List<Payee> get payees => _payees;

  Future<void> addPayee(String name) =>
      _ledgerRepository.createPayee(name: name);

  Future<void> renamePayee({required String id, required String newName}) =>
      _ledgerRepository.renamePayee(id: id, newName: newName);

  Future<void> deletePayee(String id) => _ledgerRepository.deletePayee(id);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
