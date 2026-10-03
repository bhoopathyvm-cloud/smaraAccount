import 'dart:math';

import 'package:smara_accounting/domain/linked_devices/join_code.dart';
import 'package:test/test.dart';

void main() {
  test('generates 8-char look-alike-free codes as XXXX-XXXX', () {
    final code = JoinCode.generate(random: _FixedRandom(0));
    expect(code.raw.length, 8);
    expect(JoinCode.isWellFormed(code.raw), isTrue);
    expect(
      code.display,
      matches(RegExp(r'^[2-9A-HJ-NP-Z]{4}-[2-9A-HJ-NP-Z]{4}$')),
    );
    expect(code.display.contains('0'), isFalse);
    expect(code.display.contains('O'), isFalse);
    expect(code.display.contains('1'), isFalse);
    expect(code.display.contains('I'), isFalse);
    expect(code.display.contains('L'), isFalse);
  });

  test('normalize accepts lowercase and missing dash', () {
    expect(JoinCode.normalize('k7qf-3m9p'), 'K7QF3M9P');
    expect(JoinCode.normalize('k7qf3m9p'), 'K7QF3M9P');
    expect(JoinCode.normalize(' K7QF 3M9P '), 'K7QF3M9P');
  });

  test('expires after 2 minutes and refuses reuse', () {
    var now = DateTime.utc(2026, 10, 2, 12, 0);
    final registry = JoinCodeRegistry();
    final code = registry.issue(clock: () => now, random: _FixedRandom(1));
    expect(code.expiresAt, now.add(JoinCode.joinCodeTtl));

    now = now.add(JoinCode.joinCodeTtl);
    expect(code.validateTyped(code.raw, now: now), JoinCodeValidation.expired);

    now = DateTime.utc(2026, 10, 2, 12, 0);
    final fresh = registry.issue(clock: () => now, random: _FixedRandom(2));
    expect(fresh.validateTyped(fresh.raw, now: now), JoinCodeValidation.ok);
    fresh.markUsed();
    expect(
      fresh.validateTyped(fresh.raw, now: now),
      JoinCodeValidation.alreadyUsed,
    );
  });

  test('five wrong attempts rotate to a new code', () {
    var now = DateTime.utc(2026, 10, 2, 12, 0);
    final registry = JoinCodeRegistry();
    final first = registry.issue(clock: () => now, random: _FixedRandom(3));

    for (var i = 0; i < 4; i++) {
      final result = registry.acceptTyped(
        'ZZZZZZZZ',
        now: now,
        clock: () => now,
        random: _FixedRandom(10 + i),
      );
      expect(result.validation, JoinCodeValidation.mismatch);
      expect(result.rotated, isFalse);
      expect(registry.active!.raw, first.raw);
    }

    final rotated = registry.acceptTyped(
      'ZZZZZZZZ',
      now: now,
      clock: () => now,
      random: _FixedRandom(99),
    );
    expect(rotated.rotated, isTrue);
    expect(registry.active!.raw, isNot(first.raw));
  });

  test('acceptTyped succeeds once then refuses', () {
    final now = DateTime.utc(2026, 10, 2, 12, 0);
    final registry = JoinCodeRegistry();
    final code = registry.issue(clock: () => now, random: _FixedRandom(5));
    final ok = registry.acceptTyped(
      code.display.toLowerCase(),
      now: now,
      clock: () => now,
    );
    expect(ok.validation, JoinCodeValidation.ok);
    expect(ok.code!.isUsed, isTrue);

    final again = registry.acceptTyped(code.raw, now: now, clock: () => now);
    expect(again.validation, JoinCodeValidation.alreadyUsed);
  });
}

/// Deterministic Random for stable alphabet picks in tests.
class _FixedRandom implements Random {
  _FixedRandom(this.seed);
  int seed;

  @override
  bool nextBool() => seed.isEven;

  @override
  double nextDouble() => (seed % 1000) / 1000;

  @override
  int nextInt(int max) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed % max;
  }
}
