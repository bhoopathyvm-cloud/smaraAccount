import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/home_overview.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _subscription = _ledgerRepository.watchHomeOverview().listen((overview) {
      _overview = overview;
      _isLoading = false;
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<HomeOverview> _subscription;

  HomeOverview? _overview;
  HomeOverview? get overview => _overview;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
