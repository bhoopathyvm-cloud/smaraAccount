import '../models/join_qr_payload.dart';
import 'join_code.dart';
import 'join_offer_discovery.dart';

/// Outcome of typing a join code on the joining device (task 4.3).
enum JoinCodeLookupError {
  /// Code past its 2-minute lifetime.
  expired,

  /// Code already consumed by another join.
  alreadyUsed,

  /// Well-formed code but no inviter advertising on this Wi-Fi.
  notFound,

  /// Wrong shape / alphabet (after normalize).
  malformed,
}

/// Successful lookup: joiner reached the inviter and both can show [checkCode].
class JoinCodeLookupSuccess {
  const JoinCodeLookupSuccess({
    required this.checkCode,
    required this.offer,
    required this.normalizedCode,
    this.completeJoin,
    this.cancelJoin,
  });

  final String checkCode;
  final DiscoveredJoinOffer offer;
  final String normalizedCode;

  /// After both sides confirm the check code, fetch the join payload (4.4).
  final Future<JoinQrPayload> Function()? completeJoin;

  /// Cancel because check codes did not match.
  final Future<void> Function()? cancelJoin;
}

/// Result of [JoinCodeLookup.lookup].
class JoinCodeLookupResult {
  const JoinCodeLookupResult.success(JoinCodeLookupSuccess this.success)
    : error = null;

  const JoinCodeLookupResult.failure(JoinCodeLookupError this.error)
    : success = null;

  final JoinCodeLookupSuccess? success;
  final JoinCodeLookupError? error;

  bool get isSuccess => success != null;
}

/// Resolves a typed join code to a nearby offer + shared check code.
///
/// Production will complete the LAN proof in task 4.4; tests inject
/// [FakeJoinCodeLookup].
abstract class JoinCodeLookup {
  Future<JoinCodeLookupResult> lookup(String typedCode);
}

/// Controllable lookup for widget / unit tests.
class FakeJoinCodeLookup implements JoinCodeLookup {
  FakeJoinCodeLookup({this.result});

  /// Fixed result returned for every lookup. Null → notFound.
  JoinCodeLookupResult? result;

  final List<String> typedCodes = [];

  @override
  Future<JoinCodeLookupResult> lookup(String typedCode) async {
    typedCodes.add(typedCode);
    final fixed = result;
    if (fixed != null) return fixed;
    final normalized = JoinCode.normalize(typedCode);
    if (!JoinCode.isWellFormed(normalized)) {
      return const JoinCodeLookupResult.failure(JoinCodeLookupError.malformed);
    }
    return const JoinCodeLookupResult.failure(JoinCodeLookupError.notFound);
  }
}
