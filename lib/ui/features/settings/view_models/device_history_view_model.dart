import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/membership_repository.dart';
import '../../../../domain/models/integrity_event.dart';
import '../../../../domain/models/membership_notice.dart';

/// One row in Device history: Continuation or a membership notice.
enum DeviceHistoryKind { continuation, membershipNotice }

class DeviceHistoryItem {
  DeviceHistoryItem.continuation({
    required DateTime continuedAt,
    this.copySavedAt,
  }) : kind = DeviceHistoryKind.continuation,
       notice = null,
       continuedAt = continuedAt,
       occurredAt = continuedAt;

  DeviceHistoryItem.membership({required MembershipNotice notice})
    : kind = DeviceHistoryKind.membershipNotice,
      continuedAt = null,
      copySavedAt = null,
      notice = notice,
      occurredAt = notice.createdAt;

  final DeviceHistoryKind kind;
  final DateTime occurredAt;
  final DateTime? continuedAt;
  final DateTime? copySavedAt;
  final MembershipNotice? notice;
}

class DeviceHistoryViewModel extends ChangeNotifier {
  DeviceHistoryViewModel({
    required LedgerRepository ledgerRepository,
    MembershipRepository? membershipRepository,
  }) : _ledgerRepository = ledgerRepository,
       _membershipRepository = membershipRepository {
    _subscription = _ledgerRepository.watchIntegrityEvents().listen((events) {
      _continuationItems = events
          .where((e) => e.eventType == IntegrityEventType.identityContinued)
          .map(_toContinuationItem)
          .toList();
      unawaited(_reloadNotices());
    });
    unawaited(_reloadNotices());
  }

  final LedgerRepository _ledgerRepository;
  final MembershipRepository? _membershipRepository;
  late final StreamSubscription<List<IntegrityEvent>> _subscription;

  List<DeviceHistoryItem> _continuationItems = const [];
  List<DeviceHistoryItem> _noticeItems = const [];

  List<DeviceHistoryItem> get items {
    final combined = [..._continuationItems, ..._noticeItems]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return combined;
  }

  Future<void> _reloadNotices() async {
    final membership = _membershipRepository;
    if (membership == null) {
      _noticeItems = const [];
      notifyListeners();
      return;
    }
    final notices = await membership.listNotices();
    _noticeItems = notices
        .map((n) => DeviceHistoryItem.membership(notice: n))
        .toList();
    notifyListeners();
  }

  Future<void> refresh() => _reloadNotices();

  DeviceHistoryItem _toContinuationItem(IntegrityEvent event) {
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
    return DeviceHistoryItem.continuation(
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
