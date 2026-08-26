import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/payee_repository.dart';
import '../../../../domain/models/payee.dart';

/// Minimal add/rename/delete for payees (payees-and-spending-memory tasks.md
/// 1.2: "CRUD (minimal, inline or in Settings) for payees").
class PayeeManagementViewModel extends ChangeNotifier {
  PayeeManagementViewModel({required PayeeRepository payeeRepository})
    : _payeeRepository = payeeRepository {
    _subscription = _payeeRepository.watchPayees().listen((payees) {
      _payees = payees;
      notifyListeners();
    });
  }

  final PayeeRepository _payeeRepository;
  late final StreamSubscription<List<Payee>> _subscription;

  List<Payee> _payees = const [];
  List<Payee> get payees => _payees;

  Future<void> addPayee(String name) =>
      _payeeRepository.createPayee(name: name);

  Future<void> renamePayee({required String id, required String newName}) =>
      _payeeRepository.renamePayee(id: id, newName: newName);

  Future<void> deletePayee(String id) => _payeeRepository.deletePayee(id);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
