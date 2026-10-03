import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/books_set/active_books_session.dart';
import '../../../../data/books_set/books_set_paths.dart';
import '../../../../data/books_set/joined_books_seeder.dart';
import '../../../../data/repositories/claim_person_service.dart';
import '../../../../data/repositories/claim_repository.dart';
import '../../../../data/repositories/identity_repository.dart';
import '../../../../data/repositories/membership_repository.dart';
import '../../../../data/repositories/metadata_outbox.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/repositories/sync_merge_repository.dart';
import '../../../../domain/app_error.dart';
import '../../../../domain/linked_devices/device_certificate_store.dart';
import '../../../../domain/linked_devices/join_code.dart';
import '../../../../domain/linked_devices/join_code_lookup.dart';
import '../../../../domain/linked_devices/join_code_session.dart';
import '../../../../domain/linked_devices/join_offer_discovery.dart';
import '../../../../domain/linked_devices/local_network_permission.dart';
import '../../../../domain/models/join_qr_payload.dart';
import '../../../../domain/models/join_request.dart';
import '../../../../domain/models/linked_device.dart';
import '../../../../domain/models/linked_device_role.dart';
import '../../../../domain/peer_sync/sync_payloads.dart';
import '../../../../l10n/l10n.dart';

/// Settings "Linked devices" section state (tasks 4.2–4.4), plus Add /
/// Remove a person (shared-accounts tasks 2.3–2.4).
class LinkedDevicesViewModel extends ChangeNotifier with LocalizedErrorMixin {
  LinkedDevicesViewModel({
    required MembershipRepository membershipRepository,
    required SettingsRepository settingsRepository,
    required BooksSetStore booksSetStore,
    ActiveBooksSession? booksSession,
    MetadataOutbox? metadataOutbox,
    ClaimPersonService? claimPersonService,
    ClaimRepository? claimRepository,
    LocalNetworkPermission? localNetworkPermission,
    JoinCodeLookup? joinCodeLookup,
    DeviceCertificateStore? deviceCertificateStore,
    IdentityRepository? identityRepository,
    JoinOfferDiscovery? joinOfferDiscovery,
    Uuid? uuid,
    this.booksGeneration = 0,
    this.syncNowAction,
    this.connectByAddressAction,
  }) : _membership = membershipRepository,
       _settings = settingsRepository,
       _booksSetStore = booksSetStore,
       _booksSession = booksSession,
       _outbox = metadataOutbox,
       _people = claimPersonService,
       _claims = claimRepository,
       _permission = localNetworkPermission ?? FakeLocalNetworkPermission(),
       _joinCodeLookup = joinCodeLookup ?? FakeJoinCodeLookup(),
       _certs = deviceCertificateStore,
       _identity = identityRepository,
       _joinDiscovery = joinOfferDiscovery,
       _uuid = uuid ?? const Uuid() {
    _load();
  }

  final MembershipRepository _membership;
  final SettingsRepository _settings;
  final BooksSetStore _booksSetStore;
  final ActiveBooksSession? _booksSession;
  final MetadataOutbox? _outbox;
  final ClaimPersonService? _people;
  final ClaimRepository? _claims;
  final LocalNetworkPermission _permission;
  final JoinCodeLookup _joinCodeLookup;
  final DeviceCertificateStore? _certs;
  final IdentityRepository? _identity;
  final JoinOfferDiscovery? _joinDiscovery;
  final JoinCodeRegistry _joinCodes = JoinCodeRegistry();
  final Uuid _uuid;
  final int booksGeneration;

  /// Optional Sync now hook (PeerSyncSession). Null means the button is a
  /// no-op success until the session is wired in DI.
  final Future<void> Function()? syncNowAction;

  /// Optional Connect-by-address hook when mDNS is blocked (real-sync 2.3).
  final Future<void> Function({
    required String peerDeviceId,
    required String host,
    required int port,
  })?
  connectByAddressAction;

  JoinCodeHost? _joinHost;

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

  JoinCode? get activeJoinCode => _joinCodes.active;

  /// Check code awaiting confirm after a successful join-code lookup.
  JoinCodeLookupSuccess? _pendingJoinCodeSuccess;
  JoinCodeLookupSuccess? get pendingJoinCodeSuccess => _pendingJoinCodeSuccess;

  /// Host-side join-by-code check code awaiting "Codes match".
  String? _pendingHostCheckCode;
  String? get pendingHostCheckCode => _pendingHostCheckCode;
  Completer<bool>? _hostCheckCompleter;

  /// Listening port of the active join-by-code host, when advertising.
  int? get activeJoinOfferPort => _joinHost?.port;

  /// Offer id of the active join code (for company-sync direct connect).
  String? get activeJoinOfferId => _joinCodes.active?.offerId;

  /// Books set id for the active join offer (joiner reserves identity for it).
  String? get activeJoinOfferBooksSetId => _activeJoinQr?.booksSetId;

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
      _canApproveClaims =
          local != null && MembershipRoleGates.canApproveClaims(local.roles);
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
      final booksName = await _activeBooksSetDisplayName(booksSetId);
      _activeJoinQr = await _membership.buildJoinQrPayload(
        hostDeviceId: _localDeviceId!,
        hostDisplayName: displayName,
        booksSetId: booksSetId,
        booksSetDisplayName: booksName,
      );
      final code = _joinCodes.issue();
      await _startJoinHost(code: code, payload: _activeJoinQr!);
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

  bool _canApproveClaims = false;
  bool get canApproveClaims => _canApproveClaims;

  /// Builds an "Add a person" QR (default Claimant). Requires
  /// [ClaimPersonService].
  Future<JoinQrPayload?> startAddPerson({
    required String personDisplayName,
    Set<LinkedDeviceRole> roles = const {LinkedDeviceRole.claimant},
  }) async {
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
      final booksName = await _activeBooksSetDisplayName(booksSetId);
      _activeJoinQr = await _people.buildAddPersonQr(
        hostDeviceId: _localDeviceId!,
        hostDisplayName: displayName,
        booksSetId: booksSetId,
        personDisplayName: name,
        roles: roles,
        booksSetDisplayName: booksName,
      );
      final code = _joinCodes.issue();
      await _startJoinHost(code: code, payload: _activeJoinQr!);
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

  Future<void> _startJoinHost({
    required JoinCode code,
    required JoinQrPayload payload,
  }) async {
    final certs = _certs;
    final identityRepo = _identity;
    final discovery = _joinDiscovery;
    if (certs == null || identityRepo == null || discovery == null) {
      // Widget tests / fakes: join code is shown but LAN host is skipped.
      return;
    }
    final identity = await identityRepo.currentIdentity();
    if (identity == null) return;
    final localCert = await certs.localCertificate(deviceId: _localDeviceId!);
    await _joinHost?.stop();
    _joinHost = JoinCodeHost(
      localCertificate: localCert,
      discovery: discovery,
      registry: _joinCodes,
      confirmCheckCode: (check) async {
        if (_disposed) return false;
        _pendingHostCheckCode = check;
        _hostCheckCompleter = Completer<bool>();
        notifyListeners();
        return _hostCheckCompleter!.future;
      },
      onJoinAccepted: (accepted) async {
        if (_localDeviceId == null) return;
        final people = _people;
        if (people != null && accepted.payload.isPersonJoin) {
          // Add-a-person must create the Claimant's Owed-to account.
          await people.acceptAddPerson(
            actorDeviceId: _localDeviceId!,
            payload: accepted.payload,
            joinerDeviceId: accepted.joinerDeviceId,
            joinerDisplayName: accepted.joinerDisplayName,
            joinerSigningPublicKey: accepted.joinerSigningPublicKey,
            joinerDeviceCertFingerprint: accepted.joinerDeviceCertFingerprint,
            joinerDeviceCertDer: accepted.joinerDeviceCertDer,
            joinerIdentityId: accepted.joinerIdentityId,
          );
        } else {
          final linked = await _membership.acceptJoinFromQr(
            actorDeviceId: _localDeviceId!,
            payload: accepted.payload,
            joinerDeviceId: accepted.joinerDeviceId,
            joinerDisplayName: accepted.joinerDisplayName,
            joinerSigningPublicKey: accepted.joinerSigningPublicKey,
            joinerDeviceCertFingerprint: accepted.joinerDeviceCertFingerprint,
            joinerDeviceCertDer: accepted.joinerDeviceCertDer,
            joinerIdentityId: accepted.joinerIdentityId,
          );
          await people?.emitLinkedDeviceMetadata(
            linked,
            signingPublicKey: accepted.joinerSigningPublicKey,
            deviceCertDer: accepted.joinerDeviceCertDer,
          );
        }
        await _load();
      },
      loadBootstrapMetadata: () async {
        final outbox = _outbox;
        if (outbox == null) return const <MetadataOperation>[];
        // linked_device ops are for peer Sync now (Approver learning Claimants).
        // Applying them in join bootstrap can overwrite the joiner's freshly
        // seeded Signing Identity / roles before the Provider tree rebuilds.
        final all = await outbox.listAll();
        return all.where((o) => o.entityType != 'linked_device').toList();
      },
    );
    await _joinHost!.start(
      code: code,
      payload: payload,
      inviterPublicKey: identity.publicKey,
    );
    await _writeCompanySyncJoinOffer(code);
  }

  Future<void> _writeCompanySyncJoinOffer(JoinCode code) async {
    const companySyncTest = bool.fromEnvironment('COMPANY_SYNC_TEST');
    const artifactsRoot = String.fromEnvironment('COMPANY_SYNC_ARTIFACTS');
    const conductorUrl = String.fromEnvironment('COMPANY_SYNC_CONDUCTOR');
    if (!companySyncTest) return;
    final port = _joinHost?.port;
    if (port == null) return;
    try {
      // Prefer loopback first (iOS Simulator → macOS); then LAN IPv4 for
      // Android emulators / physical devices on the same Wi-Fi.
      final hosts = <String>['127.0.0.1'];
      for (final iface in await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      )) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && !hosts.contains(addr.address)) {
            hosts.add(addr.address);
          }
        }
      }
      final booksSetId = _activeJoinQr?.booksSetId ?? '';
      final payload = jsonEncode({
        'hosts': hosts,
        'host': '127.0.0.1',
        'port': port,
        'offerId': code.offerId,
        'booksSetId': booksSetId,
      });
      if (artifactsRoot.isNotEmpty) {
        final dir = Directory('$artifactsRoot/conductor');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        await File('${dir.path}/join_offer.json').writeAsString(payload);
      }
      // Conductor HTTP is reachable from the iOS Simulator via 127.0.0.1 even
      // when the sim cannot read the Mac artifacts directory.
      if (conductorUrl.isNotEmpty) {
        final client = HttpClient();
        try {
          final req = await client.postUrl(Uri.parse('$conductorUrl/value'));
          req.headers.contentType = ContentType.json;
          req.write(jsonEncode({'key': 'join_offer', 'value': payload}));
          await (await req.close()).drain<void>();
        } finally {
          client.close(force: true);
        }
      }
    } catch (_) {}
  }

  void clearActiveJoinQr() {
    unawaited(_joinHost?.stop());
    _joinHost = null;
    _pendingHostCheckCode = null;
    if (_hostCheckCompleter != null && !_hostCheckCompleter!.isCompleted) {
      _hostCheckCompleter!.complete(false);
    }
    _hostCheckCompleter = null;
    _activeJoinQr = null;
    _joinCodes.clear();
    _pendingJoinCodeSuccess = null;
    notifyListeners();
  }

  /// Host/joiner cancelled because check codes did not match.
  void cancelJoinBecauseCodesDontMatch() {
    final pending = _pendingJoinCodeSuccess;
    final cancel = pending?.cancelJoin;
    if (cancel != null) {
      cancel();
    }
    if (_hostCheckCompleter != null && !_hostCheckCompleter!.isCompleted) {
      _hostCheckCompleter!.complete(false);
    }
    _hostCheckCompleter = null;
    _pendingHostCheckCode = null;
    final active = _joinCodes.active;
    active?.markUsed();
    unawaited(_joinHost?.stop());
    _joinHost = null;
    _activeJoinQr = null;
    _pendingJoinCodeSuccess = null;
    notifyListeners();
  }

  /// Host confirms the join-by-code check code matches the peer.
  void confirmHostCheckCodeMatch() {
    if (_hostCheckCompleter != null && !_hostCheckCompleter!.isCompleted) {
      _hostCheckCompleter!.complete(true);
    }
    _pendingHostCheckCode = null;
    notifyListeners();
  }

  /// Looks up a typed join code on the LAN (task 4.3). On success stores
  /// [pendingJoinCodeSuccess] for the check-code confirm step.
  Future<JoinCodeLookupResult>? _inFlightJoinLookup;

  Future<JoinCodeLookupResult> lookupJoinCode(String typed) async {
    final inFlight = _inFlightJoinLookup;
    if (inFlight != null) {
      // Coalesce re-entrant submits (tap retries) onto the same lookup so a
      // busy collision cannot surface a false "not found".
      return inFlight;
    }
    if (_isBusy) {
      return const JoinCodeLookupResult.failure(JoinCodeLookupError.notFound);
    }
    _isBusy = true;
    notifyListeners();
    final future = () async {
      try {
        final normalized = JoinCode.normalize(typed);
        if (!JoinCode.isWellFormed(normalized)) {
          return const JoinCodeLookupResult.failure(
            JoinCodeLookupError.malformed,
          );
        }
        final result = await _joinCodeLookup.lookup(typed);
        if (result.isSuccess) {
          _pendingJoinCodeSuccess = result.success;
          clearFailure();
        } else {
          _pendingJoinCodeSuccess = null;
        }
        return result;
      } catch (e) {
        setFailure(e);
        return const JoinCodeLookupResult.failure(JoinCodeLookupError.notFound);
      } finally {
        _isBusy = false;
        _inFlightJoinLookup = null;
        if (!_disposed) notifyListeners();
      }
    }();
    _inFlightJoinLookup = future;
    return future;
  }

  /// After check-code confirm on the join-by-code path, completes the payload
  /// exchange (task 4.4) and opens the joined books set on this device.
  Future<bool> confirmJoinCodeMatch() async {
    final pending = _pendingJoinCodeSuccess;
    if (pending == null || _isBusy) return false;
    _isBusy = true;
    notifyListeners();
    try {
      final complete = pending.completeJoin;
      if (complete != null) {
        final completion = await complete();
        await _adoptJoinedBooks(
          completion.payload,
          bootstrapMetadata: completion.bootstrapMetadata,
        );
      }
      _pendingJoinCodeSuccess = null;
      clearFailure();
      return true;
    } catch (e) {
      setFailure(e);
      return false;
    } finally {
      _isBusy = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Maps a lookup error to the localized user-facing sentence.
  String joinCodeErrorMessage(
    AppLocalizations l10n,
    JoinCodeLookupError error,
  ) {
    return switch (error) {
      JoinCodeLookupError.expired => l10n.settingsLinkedDevicesJoinCodeExpired,
      JoinCodeLookupError.alreadyUsed => l10n.settingsLinkedDevicesJoinCodeUsed,
      JoinCodeLookupError.notFound =>
        l10n.settingsLinkedDevicesJoinCodeNotFound,
      JoinCodeLookupError.malformed =>
        l10n.settingsLinkedDevicesJoinCodeNotFound,
    };
  }

  /// Validates a scanned join QR (expiry + check code). Returns the payload
  /// when valid, otherwise null and sets [errorMessage].
  JoinQrPayload? validateScannedJoin(JoinQrPayload payload) {
    final now = DateTime.now().toUtc();
    if (payload.isExpiredAt(now)) {
      setFailure(
        const AppFailure(
          AppErrorCode.generic,
          debugMessage: 'This join QR has expired. Ask for a new code.',
        ),
      );
      notifyListeners();
      return null;
    }
    clearFailure();
    return payload;
  }

  /// After the user confirms the check code, open the joined books set on
  /// this device (joiner side). Host still completes [acceptJoinFromQr]
  /// once the joiner's certificate is exchanged over the LAN.
  Future<bool> registerHostFromScannedJoin(JoinQrPayload payload) async {
    if (_isBusy) return false;
    _isBusy = true;
    notifyListeners();
    try {
      await _adoptJoinedBooks(payload);
      clearFailure();
      return true;
    } catch (e) {
      setFailure(e);
      return false;
    } finally {
      _isBusy = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Opens [payload.booksSetId] (keeping the previous set in the switcher),
  /// seeds Claimant/Member membership, and leaves the joiner in that set.
  Future<void> _adoptJoinedBooks(
    JoinQrPayload payload, {
    List<MetadataOperation> bootstrapMetadata = const [],
  }) async {
    final session = _booksSession;
    if (session == null) {
      // Widget tests / fakes without a multi-set session: pin host only.
      await _membership.prepareJoinerFromScannedQr(payload);
      return;
    }
    final localDeviceId = _localDeviceId ?? await _ensureLocalDeviceId();
    final displayName =
        await _settings.localDeviceDisplayName() ?? 'This device';
    var currency = 'USD';
    try {
      final row = await session.database
          .customSelect(
            'SELECT currency FROM account_groups '
            'WHERE currency IS NOT NULL AND currency != \'\' LIMIT 1',
          )
          .getSingleOrNull();
      final value = row?.read<String>('currency');
      if (value != null && value.isNotEmpty) currency = value;
    } catch (_) {}

    // Ensure this books set already has its own Signing Identity (created
    // before hello on the join-by-code path; reserved here for QR-only).
    await session.reserveJoinIdentity(
      booksSetId: payload.booksSetId,
      currency: currency,
    );

    await session.openJoinedSet(
      booksSetId: payload.booksSetId,
      displayName: payload.booksSetDisplayName ?? '',
      seed: (db, keys) async {
        await JoinedBooksSeeder.seed(
          database: db,
          signingKeyService: keys,
          certificateStore: _certs,
          payload: payload,
          localDeviceId: localDeviceId,
          localDisplayName: displayName,
          currency: currency,
        );
        if (bootstrapMetadata.isEmpty) return;
        final merge = SyncMergeRepository(
          database: db,
          signingKeyService: keys,
        );
        await merge.applyMetadataOps(
          MetadataOps(operations: bootstrapMetadata),
        );
      },
    );
  }

  Future<String?> _activeBooksSetDisplayName(String booksSetId) async {
    final session = _booksSession;
    if (session == null) return null;
    final sets = await session.listSets();
    for (final s in sets) {
      if (s.id == booksSetId && s.hasUserVisibleName) {
        return s.displayName;
      }
    }
    return null;
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

  /// Registers [host]:[port] for a linked peer when discovery is blocked.
  Future<bool> connectByAddress({
    required String peerDeviceId,
    required String host,
    required int port,
  }) async {
    if (_isBusy) return false;
    final action = connectByAddressAction;
    if (action == null) return false;
    _isBusy = true;
    notifyListeners();
    try {
      await action(peerDeviceId: peerDeviceId, host: host, port: port);
      clearFailure();
      return true;
    } catch (e) {
      setFailure(e);
      return false;
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
    if (_hostCheckCompleter != null && !_hostCheckCompleter!.isCompleted) {
      _hostCheckCompleter!.complete(false);
    }
    unawaited(_joinHost?.stop());
    _joinHost = null;
    super.dispose();
  }
}
