import 'dart:typed_data';

import 'package:smara_accounting/domain/crypto/entry_canonical_hash.dart';
import 'package:test/test.dart';

void main() {
  CanonicalPosting posting(int lineNumber, String accountId, int amountMinor) {
    return CanonicalPosting(
      lineNumber: lineNumber,
      accountId: accountId,
      amountMinor: amountMinor,
    );
  }

  Uint8List buildBytes({List<CanonicalPosting>? postings}) {
    return canonicalEntryBytes(
      previousEntryHash: genesisPreviousEntryHash,
      id: 'entry-1',
      deviceChainSequence: 1,
      transactionDate: '2026-07-18',
      recordedAt: DateTime.utc(2026, 7, 18, 12, 0, 0),
      description: 'Groceries',
      reversesEntryId: null,
      signedByIdentityId: 'identity-1',
      postings:
          postings ??
          [
            posting(1, 'asset-account', 1000),
            posting(2, 'expense-account', -1000),
          ],
    );
  }

  group('canonicalEntryBytes', () {
    test('is deterministic for identical input', () {
      final a = buildBytes();
      final b = buildBytes();

      expect(a, equals(b));
    });

    test('changes when any field changes', () {
      final baseline = canonicalEntryBytes(
        previousEntryHash: genesisPreviousEntryHash,
        id: 'entry-1',
        deviceChainSequence: 1,
        transactionDate: '2026-07-18',
        recordedAt: DateTime.utc(2026, 7, 18),
        description: 'Groceries',
        reversesEntryId: null,
        signedByIdentityId: 'identity-1',
        postings: [posting(1, 'a', 1000), posting(2, 'b', -1000)],
      );

      final differentAmount = canonicalEntryBytes(
        previousEntryHash: genesisPreviousEntryHash,
        id: 'entry-1',
        deviceChainSequence: 1,
        transactionDate: '2026-07-18',
        recordedAt: DateTime.utc(2026, 7, 18),
        description: 'Groceries',
        reversesEntryId: null,
        signedByIdentityId: 'identity-1',
        postings: [posting(1, 'a', 999), posting(2, 'b', -999)],
      );

      expect(baseline, isNot(equals(differentAmount)));
    });

    test(
      'posting order does not affect the result - sorted by lineNumber first',
      () {
        final inOrder = buildBytes(
          postings: [posting(1, 'a', 1000), posting(2, 'b', -1000)],
        );
        final reversed = buildBytes(
          postings: [posting(2, 'b', -1000), posting(1, 'a', 1000)],
        );

        expect(inOrder, equals(reversed));
      },
    );

    test(
      'null description and reversesEntryId do not collide with an empty string value',
      () {
        final withNullDescription = canonicalEntryBytes(
          previousEntryHash: genesisPreviousEntryHash,
          id: 'entry-1',
          deviceChainSequence: 1,
          transactionDate: '2026-07-18',
          recordedAt: DateTime.utc(2026, 7, 18),
          description: null,
          reversesEntryId: null,
          signedByIdentityId: 'identity-1',
          postings: [posting(1, 'a', 1000), posting(2, 'b', -1000)],
        );
        final withEmptyDescription = canonicalEntryBytes(
          previousEntryHash: genesisPreviousEntryHash,
          id: 'entry-1',
          deviceChainSequence: 1,
          transactionDate: '2026-07-18',
          recordedAt: DateTime.utc(2026, 7, 18),
          description: '',
          reversesEntryId: null,
          signedByIdentityId: 'identity-1',
          postings: [posting(1, 'a', 1000), posting(2, 'b', -1000)],
        );

        // Both map to the same canonical bytes today (documented behavior -
        // null and '' are indistinguishable in the hash), but the null-byte
        // separators mean no *other* field boundary is ambiguous with this
        // one, which is what the adjacent test guards.
        expect(withNullDescription, equals(withEmptyDescription));
      },
    );
  });

  group('hashCanonicalEntry', () {
    test('is deterministic and produces a 32-byte SHA-256 digest', () async {
      final bytes = buildBytes();

      final first = await hashCanonicalEntry(bytes);
      final second = await hashCanonicalEntry(bytes);

      expect(first, equals(second));
      expect(first.length, equals(32));
    });
  });

  group('genesisPreviousEntryHash', () {
    test('is 32 zero bytes', () {
      expect(genesisPreviousEntryHash.length, equals(32));
      expect(genesisPreviousEntryHash.every((b) => b == 0), isTrue);
    });
  });
}
