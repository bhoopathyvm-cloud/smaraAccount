import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/integrity_event.dart';

/// One Continuation row for the Device history list, in plain words.
class DeviceHistoryItem {
  const DeviceHistoryItem({
    required this.continuedAt,
    this.copySavedAt,
  });

  final DateTime continuedAt;
  final DateTime? copySavedAt;
}

class DeviceHistoryViewModel extends ChangeNotifier {
  DeviceHistoryViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _subscription = _ledgerRepository.watchIntegrityEvents().listen((events) {
      _items = events
          .where((e) => e.eventType == IntegrityEventType.identityContinued)
          .map(_toItem)
          .toList();
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<IntegrityEvent>> _subscription;

  List<DeviceHistoryItem> _items = const [];
  List<DeviceHistoryItem> get items => _items;

  DeviceHistoryItem _toItem(IntegrityEvent event) {
    DateTime? copySavedAt;
    final detail = event.detail;
    if (detail != null && detail.isNotEmpty) {
      try {
        final json = jsonDecode(detail) as Map<String, dynamic>;
        final raw = json['copySavedAt'];
        if (raw is String) {
          copySavedAt = DateTime.tryParse(raw);
        }
      } catch (_) {
        // Plain-text legacy detail — ignore.
      }
    }
    return DeviceHistoryItem(
      continuedAt: event.occurredAt,
      copySavedAt: copySavedAt,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
