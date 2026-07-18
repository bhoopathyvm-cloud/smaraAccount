import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// The genesis entry's `previous_entry_hash`: a well-defined 32-zero-byte
/// constant, never an arbitrary null (spec: "Chained and Signed Journal
/// Entries" - "The genesis entry's previous hash SHALL be a well-defined
/// constant rather than an arbitrary null").
final Uint8List genesisPreviousEntryHash = Uint8List(32);

/// One posting's contribution to the canonical hash input, ordered by
/// [CanonicalPosting.lineNumber] before hashing (design.md: "canonical_postings
/// -- ordered by line_number: account_id + amount_minor").
class CanonicalPosting {
  const CanonicalPosting({
    required this.lineNumber,
    required this.accountId,
    required this.amountMinor,
  });

  final int lineNumber;
  final String accountId;
  final int amountMinor;
}

/// Pure, deterministic canonical serialization of one journal entry's
/// content, exactly matching design.md's `entry_hash` formula. Fields are
/// separated with a null byte, which never appears in any of the string
/// fields hashed here (UUIDs, ISO date strings), so two different field
/// splits can never collide into the same byte sequence.
Uint8List canonicalEntryBytes({
  required List<int> previousEntryHash,
  required String id,
  required int deviceChainSequence,
  required String transactionDate,
  required DateTime recordedAt,
  required String? description,
  required String? reversesEntryId,
  required String signedByIdentityId,
  required List<CanonicalPosting> postings,
}) {
  const separator = 0;
  final orderedPostings = [...postings]
    ..sort((a, b) => a.lineNumber.compareTo(b.lineNumber));

  final builder = BytesBuilder();
  builder.add(previousEntryHash);
  builder.addByte(separator);
  builder.add(utf8.encode(id));
  builder.addByte(separator);
  builder.add(utf8.encode(deviceChainSequence.toString()));
  builder.addByte(separator);
  builder.add(utf8.encode(transactionDate));
  builder.addByte(separator);
  builder.add(utf8.encode(recordedAt.toUtc().toIso8601String()));
  builder.addByte(separator);
  builder.add(utf8.encode(description ?? ''));
  builder.addByte(separator);
  builder.add(utf8.encode(reversesEntryId ?? ''));
  builder.addByte(separator);
  builder.add(utf8.encode(signedByIdentityId));
  for (final posting in orderedPostings) {
    builder.addByte(separator);
    builder.add(utf8.encode(posting.accountId));
    builder.addByte(separator);
    builder.add(utf8.encode(posting.amountMinor.toString()));
  }
  return builder.toBytes();
}

/// SHA-256 of [canonicalEntryBytes]'s output - the `entry_hash` that gets
/// signed and chained.
Future<Uint8List> hashCanonicalEntry(Uint8List canonicalBytes) async {
  final hash = await Sha256().hash(canonicalBytes);
  return Uint8List.fromList(hash.bytes);
}
