import 'dart:math';

/// Short join code for "Enter code instead" (real-sync task 4.1 / design
/// Decision 3). Alphabet omits look-alikes (0/O, 1/I/L).
class JoinCode {
  JoinCode({
    required this.raw,
    required this.createdAt,
    required this.offerId,
    this.maxWrongAttempts = 5,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       expiresAt = createdAt.toUtc().add(joinCodeTtl);

  /// How long a freshly shown code remains acceptable.
  static const joinCodeTtl = Duration(minutes: 2);

  /// 31 symbols without 0/O/1/I/L.
  static const alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  final String raw;
  final String offerId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int maxWrongAttempts;
  final DateTime Function() _clock;

  int _wrongAttempts = 0;
  bool _used = false;

  int get wrongAttempts => _wrongAttempts;
  bool get isUsed => _used;

  /// Display form `XXXX-XXXX`.
  String get display => '${raw.substring(0, 4)}-${raw.substring(4, 8)}';

  bool isExpiredAt(DateTime now) => !now.toUtc().isBefore(expiresAt);

  bool get isExpired => isExpiredAt(_clock());

  Duration timeRemainingAt(DateTime now) {
    final left = expiresAt.difference(now.toUtc());
    return left.isNegative ? Duration.zero : left;
  }

  /// Normalizes typed input: strips dashes/spaces, uppercases.
  static String normalize(String input) {
    return input.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
  }

  static bool isWellFormed(String normalized) {
    if (normalized.length != 8) return false;
    for (final rune in normalized.runes) {
      if (!alphabet.contains(String.fromCharCode(rune))) return false;
    }
    return true;
  }

  /// Generates an 8-character code and a random offer id.
  static JoinCode generate({
    Random? random,
    DateTime Function()? clock,
    String? offerId,
  }) {
    final rng = random ?? Random.secure();
    final buf = StringBuffer();
    for (var i = 0; i < 8; i++) {
      buf.write(alphabet[rng.nextInt(alphabet.length)]);
    }
    final now = (clock ?? DateTime.now)().toUtc();
    return JoinCode(
      raw: buf.toString(),
      createdAt: now,
      offerId: offerId ?? _randomOfferId(rng),
      clock: clock,
    );
  }

  static String _randomOfferId(Random rng) {
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Records a successful use (single-use).
  void markUsed() {
    _used = true;
  }

  /// Records a failed proof attempt. Returns true when the code must be
  /// replaced (too many wrong attempts).
  bool recordWrongAttempt() {
    _wrongAttempts++;
    return _wrongAttempts >= maxWrongAttempts;
  }

  /// Validates [typed] against this offer without consuming it.
  JoinCodeValidation validateTyped(String typed, {DateTime? now}) {
    final instant = (now ?? _clock()).toUtc();
    if (_used) return JoinCodeValidation.alreadyUsed;
    if (isExpiredAt(instant)) return JoinCodeValidation.expired;
    final normalized = normalize(typed);
    if (!isWellFormed(normalized)) return JoinCodeValidation.malformed;
    if (normalized != raw) return JoinCodeValidation.mismatch;
    return JoinCodeValidation.ok;
  }
}

enum JoinCodeValidation { ok, expired, alreadyUsed, malformed, mismatch }

/// Tracks the active invite code on the host (process-local).
class JoinCodeRegistry {
  JoinCode? _active;

  JoinCode? get active => _active;

  JoinCode issue({Random? random, DateTime Function()? clock}) {
    final code = JoinCode.generate(random: random, clock: clock);
    _active = code;
    return code;
  }

  void clear() => _active = null;

  /// Accepts [typed] against the active code. On success marks it used.
  /// On mismatch increments wrong attempts and may rotate.
  JoinCodeAcceptResult acceptTyped(
    String typed, {
    DateTime? now,
    Random? random,
    DateTime Function()? clock,
  }) {
    final active = _active;
    if (active == null) {
      return const JoinCodeAcceptResult(
        validation: JoinCodeValidation.mismatch,
        rotated: false,
      );
    }
    final validation = active.validateTyped(typed, now: now);
    if (validation == JoinCodeValidation.ok) {
      active.markUsed();
      return JoinCodeAcceptResult(
        validation: validation,
        rotated: false,
        code: active,
      );
    }
    if (validation == JoinCodeValidation.mismatch) {
      final mustRotate = active.recordWrongAttempt();
      if (mustRotate) {
        final next = issue(random: random, clock: clock);
        return JoinCodeAcceptResult(
          validation: validation,
          rotated: true,
          code: next,
        );
      }
    }
    return JoinCodeAcceptResult(validation: validation, rotated: false);
  }
}

class JoinCodeAcceptResult {
  const JoinCodeAcceptResult({
    required this.validation,
    required this.rotated,
    this.code,
  });

  final JoinCodeValidation validation;
  final bool rotated;
  final JoinCode? code;
}
