import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/books_set/books_set_paths.dart';
import '../../../../data/repositories/claim_person_service.dart';
import '../../../../data/repositories/claim_repository.dart';
import '../../../../data/repositories/membership_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/app_error.dart';
import '../../../../domain/linked_devices/local_network_permission.dart';
import '../../../../domain/models/join_qr_payload.dart';
import '../../../../domain/models/join_request.dart';
import '../../../../domain/models/linked_device.dart';
import '../../../../domain/models/linked_device_role.dart';
import '../../../../l10n/l10n.dart';

/// Settings "Linked devices" section state (tasks 4.2–4.4), plus Add /
/// Remove a person (shared-accounts tasks 2.3–2.4).
class LinkedDevicesViewModel extends ChangeNotifier with LocalizedErrorMixin {
  LinkedDevicesViewModel({
    required MembershipRepository membershipRepository,
    required SettingsRepository settingsRepository,
    required BooksSetStore booksSetStore,
    ClaimPersonService? claimPersonService,
    ClaimRepository? claimRepository,
    LocalNetworkPermission? localNetworkPermission,
    Uuid? uuid,
    this.booksGeneration = 0,
    this.syncNowAction,
  }) : _membership = membershipRepository,
       _settings = settingsRepository,
       _booksSetStore = booksSetStore,
       _people = claimPersonService,
       _claims = claimRepository,
       _permission = localNetworkPermission ?? FakeLocalNetworkPermission(),
       _uuid = uuid ?? const Uuid() {
    _load();
  }

  final MembershipRepository _membership;
  final SettingsRepository _settings;
  final BooksSetStore _booksSetStore;
  final ClaimPersonService? _people;
  final ClaimRepository? _claims;
  final LocalNetworkPermission _permission;
  final Uuid _uuid;
  final int booksGeneration;

  /// Optional Sync now hook (PeerSyncSession). Null means the button is a
  /// no-op success until the session is wired in DI.
  final Future<void> Function()? syncNowAction;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  /// True while the first-open permission sentence is on screen, before the
  /// OS prompt hook runs.
  bool _showingPermissionExplanation = false;
  bool get showingPermissionExplanation => _showingPermissionExplanation;

  /// Set when [continueAfterPermissionExplanation] has invoked the OS prompt.
  bool _permissionPromptRequested = false;
  bool get permissionPromptRequested => _permissionPromptRequested;

  List<LinkedDevice> _devices = const [];
  List<LinkedDevice> get devices => _devices;

  List<JoinRequest> _pendingJoins = const [];
  List<JoinRequest> get pendingJoins => _pendingJoins;

  bool _canAdd = false;
  bool get canAdd => _canAdd;

  bool _canManageMembership = false;
  bool get canManageMembership => _canManageMembership;

  bool _suggestSecondOwner = false;
  bool get suggestSecondOwner => _suggestSecondOwner;

  String? _localDeviceId;
  String? get localDeviceId => _localDeviceId;

  JoinQrPayload? _activeJoinQr;
  JoinQrPayload? get activeJoinQr => _activeJoinQr;

  bool _disposed = false;

  Future<void> _load() async {
    if (_disposed) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _membership.applyDueSoleOwnerClaims();
      _localDeviceId = await _ensureLocalDeviceId();
      final displayName =
          await _settings.localDeviceDisplayName() ?? 'This device';
      await _membership.ensureLocalOwner(
        localDeviceId: _localDeviceId!,
        displayName: displayName,
      );

      final explained = await _settings.hasLinkedDevicesPermissionExplained();
      final granted = await _permission.isGranted();
      if (!explained && !granted) {
        _showingPermissionExplanation = true;
      } else {
        _showingPermissionExplanation = false;
      }

      _devices = await _membership.listDevices();
      _pendingJoins = await _membership.listPendingJoinRequests();
      final local = await _membership.findByDeviceId(_localDeviceId!);
      _canAdd =
          local != null && await _membership.canAddDevices(_localDeviceId!);
      _canManageMembership =
          local != null && MembershipRoleGates.canManageMembership(local.roles);
      _suggestSecondOwner = await _membership.shouldSuggestSecondOwner();
      clearFailure();
    } catch (e) {
      setFailure(e);
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> refresh() => _load();

  /// User read the in-app sentence; mark shown, then request OS permission.
  Future<void> continueAfterPermissionExplanation() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      await _permission.markExplanationShown();
      await _settings.setLinkedDevicesPermissionExplained(true);
      // Spec: in-app sentence appears *before* the system permission prompt.
      _showingPermissionExplanation = false;
      notifyListeners();
      await _permission.requestPermission();
      _permissionPromptRequested = true;
      clearFailure();
    } catch (e) {
      setFailure(e);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<JoinQrPayload?> startAddDevice() async {
    if (_isBusy || _localDeviceId == null) return null;
    _isBusy = true;
    notifyListeners();
    try {
      final booksSetId = await _booksSetStore.activeBooksSetId();
      if (booksSetId == null) {
        setFailure(
          const AppFailure(
            AppErrorCode.generic,
            debugMessage: 'No active books set.',
          ),
        );
        return null;
      }
      final displayName =
          await _settings.localDeviceDisplayName() ?? 'This device';
      _activeJoinQr = await _membership.buildJoinQrPayload(
        hostDeviceId: _localDeviceId!,
        hostDisplayName: displayName,
        booksSetId: booksSetId,
      );
      clearFailure();
      return _activeJoinQr;
    } catch (e) {
      setFailure(e);
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Builds an "Add a person" QR (default Claimant). Requires
  /// [ClaimPersonService].
  Future<JoinQrPayload?> startAddPerson({required String personDisplayName}) async {
    if (_isBusy || _localDeviceId == null || _people == null) return null;
    final name = personDisplayName.trim();
    if (name.isEmpty) return null;
    _isBusy = true;
    notifyListeners();
    try {
      final booksSetId = await _booksSetStore.activeBooksSetId();
      if (booksSetId == null) {
        setFailure(
          const AppFailure(
            AppErrorCode.generic,
            debugMessage: 'No active books set.',
          ),
        );
        return null;
      }
      final displayName =
          await _settings.localDeviceDisplayName() ?? 'This device';
      _activeJoinQr = await _people.buildAddPersonQr(
        hostDeviceId: _localDeviceId!,
        hostDisplayName: displayName,
        booksSetId: booksSetId,
        personDisplayName: name,
      );
      clearFailure();
      return _activeJoinQr;
    } catch (e) {
      setFailure(e);
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void clearActiveJoinQr() {
    _activeJoinQr = null;
    notifyListeners();
  }

  /// Open-claims / owed-balance warning before remove (task 2.4).
  Future<({int openClaims, int balanceMinor})?> removalWarningFor(
    String targetDeviceId,
  ) async {
    if (_claims == null) {
      return (openClaims: 0, balanceMinor: 0);
    }
    try {
      return await _claims.removalWarning(targetDeviceId: targetDeviceId);
    } catch (e) {
      setFailure(e);
      return null;
    }
  }

  /// Removes a person after the Owner confirms the warning. Past claims and
  /// receipts remain in the books.
  Future<bool> removePerson(String targetDeviceId) async {
    if (_isBusy || _localDeviceId == null) return false;
    _isBusy = true;
    notifyListeners();
    try {
      final warning = _claims == null
          ? (openClaims: 0, balanceMinor: 0)
          : await _claims.removalWarning(targetDeviceId: targetDeviceId);
      if (_people != null) {
        await _people.removePerson(
          actorDeviceId: _localDeviceId!,
          targetDeviceId: targetDeviceId,
          balanceMinor: warning.balanceMinor,
        );
      } else {
        await _membership.removeDevice(
          actorDeviceId: _localDeviceId!,
          targetDeviceId: targetDeviceId,
        );
      }
      await _load();
      clearFailure();
      return true;
    } catch (e) {
      setFailure(e);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> approveJoin(String requestId) async {
    if (_isBusy || _localDeviceId == null) return false;
    _isBusy = true;
    notifyListeners();
    try {
      await _membership.approveJoinRequest(
        actorDeviceId: _localDeviceId!,
        requestId: requestId,
      );
      await _load();
      clearFailure();
      return true;
    } catch (e) {
      setFailure(e);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> refuseJoin(String requestId) async {
    if (_isBusy || _localDeviceId == null) return false;
    _isBusy = true;
    notifyListeners();
    try {
      await _membership.refuseJoinRequest(
        actorDeviceId: _localDeviceId!,
        requestId: requestId,
      );
      await _load();
      clearFailure();
      return true;
    } catch (e) {
      setFailure(e);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Sync now — catch up with linked peers on the same Wi-Fi.
  Future<void> syncNow() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      await syncNowAction?.call();
      clearFailure();
    } catch (e) {
      setFailure(e);
    } finally {
      _isBusy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<String> _ensureLocalDeviceId() async {
    final existing = await _settings.localDeviceId();
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _uuid.v4();
    await _settings.setLocalDeviceId(id);
    return id;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
