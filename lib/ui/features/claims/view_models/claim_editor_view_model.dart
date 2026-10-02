import 'package:flutter/foundation.dart';

import '../../../../data/repositories/claim_receipt_store.dart';
import '../../../../data/repositories/claim_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/app_error.dart';
import '../../../../domain/claims/claim_receipt_picker.dart';
import '../../../../domain/models/claim.dart';
import '../../../../domain/models/claim_item.dart';
import '../../../../domain/models/claim_spending_hint.dart';
import '../../../../domain/models/claim_status.dart';

/// Draft claim editor: add/edit/remove items, attach receipts, submit
/// (shared-accounts tasks 10.1–10.2).
class ClaimEditorViewModel extends ChangeNotifier {
  ClaimEditorViewModel({
    required ClaimRepository claims,
    required ClaimReceiptStore receipts,
    required ClaimReceiptPicker picker,
    required SettingsRepository settings,
    required this.claimId,
    required String actorDeviceId,
    required this.companyCurrency,
  }) : _claims = claims,
       _receipts = receipts,
       _picker = picker,
       _settings = settings,
       _actorDeviceId = actorDeviceId;

  final ClaimRepository _claims;
  final ClaimReceiptStore _receipts;
  final ClaimReceiptPicker _picker;
  final SettingsRepository _settings;
  final String claimId;
  final String _actorDeviceId;
  final String companyCurrency;

  Claim? claim;
  List<({String id, String name})> allowlistedCategories = const [];
  List<ClaimSpendingHint> hints = const [];
  int receiptRequiredAboveMinor = 0;
  bool loading = true;
  bool busy = false;
  String? error;
  bool showingReceiptPermissionExplanation = false;
  ClaimReceiptSource? _pendingReceiptSource;
  String? _pendingReceiptItemId;

  bool get isDraft => claim?.status == ClaimStatus.draft;

  Future<void> load({
    required List<({String id, String name})> categories,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      claim = await _claims.getClaim(claimId);
      allowlistedCategories = categories;
      hints = await _claims.spendingHints();
      receiptRequiredAboveMinor = await _claims.receiptRequiredAboveMinor();
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ClaimSpendingHint? spendingHintFor(String categoryId) {
    for (final hint in hints) {
      if (hint.categoryId == categoryId) return hint;
    }
    return null;
  }

  bool receiptMissingFor(ClaimItem item) =>
      item.companyCurrencyAmountMinor > receiptRequiredAboveMinor &&
      item.receipt == null;

  Future<ClaimItem?> addItem({
    required String categoryId,
    required DateTime expenseDate,
    required String paidCurrency,
    required int paidAmountMinor,
    required int companyCurrencyAmountMinor,
    String? description,
    double? employeeStatedRate,
  }) async {
    if (!isDraft || busy) return null;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final item = await _claims.addItem(
        claimId: claimId,
        actorDeviceId: _actorDeviceId,
        categoryId: categoryId,
        expenseDate: expenseDate,
        paidCurrency: paidCurrency,
        paidAmountMinor: paidAmountMinor,
        companyCurrencyAmountMinor: companyCurrencyAmountMinor,
        description: description,
        employeeStatedRate: employeeStatedRate,
      );
      claim = await _claims.getClaim(claimId);
      return item;
    } on AppFailure catch (e) {
      error = e.debugMessage ?? e.code.name;
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> updateItem({
    required String claimItemId,
    String? categoryId,
    DateTime? expenseDate,
    String? paidCurrency,
    int? paidAmountMinor,
    int? companyCurrencyAmountMinor,
    String? description,
    bool clearDescription = false,
    double? employeeStatedRate,
    bool clearEmployeeStatedRate = false,
  }) async {
    if (!isDraft || busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _claims.updateItem(
        claimItemId: claimItemId,
        actorDeviceId: _actorDeviceId,
        categoryId: categoryId,
        expenseDate: expenseDate,
        paidCurrency: paidCurrency,
        paidAmountMinor: paidAmountMinor,
        companyCurrencyAmountMinor: companyCurrencyAmountMinor,
        description: description,
        clearDescription: clearDescription,
        employeeStatedRate: employeeStatedRate,
        clearEmployeeStatedRate: clearEmployeeStatedRate,
      );
      claim = await _claims.getClaim(claimId);
      return true;
    } on AppFailure catch (e) {
      error = e.debugMessage ?? e.code.name;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> removeItem(String claimItemId) async {
    if (!isDraft || busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _claims.removeItem(
        claimItemId: claimItemId,
        actorDeviceId: _actorDeviceId,
      );
      claim = await _claims.getClaim(claimId);
      return true;
    } on AppFailure catch (e) {
      error = e.debugMessage ?? e.code.name;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Starts attach; shows the in-app permission sentence before the first
  /// camera/gallery OS prompt (linked-devices pattern).
  Future<void> requestAttachReceipt({
    required String claimItemId,
    required ClaimReceiptSource source,
  }) async {
    if (!isDraft || busy) return;
    if (source == ClaimReceiptSource.camera ||
        source == ClaimReceiptSource.gallery) {
      final explained = await _settings.hasClaimsReceiptPermissionExplained();
      if (!explained) {
        _pendingReceiptItemId = claimItemId;
        _pendingReceiptSource = source;
        showingReceiptPermissionExplanation = true;
        notifyListeners();
        return;
      }
    }
    await _attach(claimItemId: claimItemId, source: source);
  }

  Future<void> continueAfterReceiptPermissionExplanation() async {
    final itemId = _pendingReceiptItemId;
    final source = _pendingReceiptSource;
    showingReceiptPermissionExplanation = false;
    _pendingReceiptItemId = null;
    _pendingReceiptSource = null;
    notifyListeners();
    await _settings.setClaimsReceiptPermissionExplained(true);
    if (itemId == null || source == null) return;
    await _attach(claimItemId: itemId, source: source);
  }

  Future<void> cancelReceiptPermissionExplanation() async {
    showingReceiptPermissionExplanation = false;
    _pendingReceiptItemId = null;
    _pendingReceiptSource = null;
    notifyListeners();
  }

  Future<void> _attach({
    required String claimItemId,
    required ClaimReceiptSource source,
  }) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final picked = await _picker.pick(source);
      if (picked == null) return;
      await _receipts.attach(
        claimItemId: claimItemId,
        bytes: picked.bytes,
        contentType: picked.contentType,
        fileName: picked.fileName,
      );
      claim = await _claims.getClaim(claimId);
    } on AppFailure catch (e) {
      error = e.debugMessage ?? e.code.name;
    } catch (e) {
      error = '$e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> submit() async {
    if (!isDraft || busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      claim = await _claims.submit(
        claimId: claimId,
        actorDeviceId: _actorDeviceId,
      );
      return true;
    } on AppFailure catch (e) {
      error = e.debugMessage ?? e.code.name;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
