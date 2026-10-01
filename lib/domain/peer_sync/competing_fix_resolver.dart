/// Deterministic competing-Fix resolution (design Decision 7 / task 6.3).
///
/// Among Fixes that reverse the same original entry, the winner is the
/// lowest `(recordedAt, signedByIdentityId, entryId)` tuple. The loser is
/// cancelled by a new signed cancel record at merge time.
class CompetingFixCandidate {
  const CompetingFixCandidate({
    required this.entryId,
    required this.reversesEntryId,
    required this.recordedAt,
    required this.signedByIdentityId,
  });

  final String entryId;
  final String reversesEntryId;
  final DateTime recordedAt;
  final String signedByIdentityId;
}

class CompetingFixResolution {
  const CompetingFixResolution({required this.winner, required this.losers});

  final CompetingFixCandidate winner;
  final List<CompetingFixCandidate> losers;
}

/// Pure competing-Fix rules — no I/O.
class CompetingFixResolver {
  const CompetingFixResolver();

  /// Groups [candidates] by [CompetingFixCandidate.reversesEntryId] and
  /// returns a resolution for every group that has two or more Fixes.
  List<CompetingFixResolution> resolve(
    Iterable<CompetingFixCandidate> candidates,
  ) {
    final byOriginal = <String, List<CompetingFixCandidate>>{};
    for (final c in candidates) {
      byOriginal.putIfAbsent(c.reversesEntryId, () => []).add(c);
    }

    final resolutions = <CompetingFixResolution>[];
    for (final group in byOriginal.values) {
      if (group.length < 2) continue;
      final sorted = [...group]..sort(_compare);
      resolutions.add(
        CompetingFixResolution(winner: sorted.first, losers: sorted.sublist(1)),
      );
    }
    return resolutions;
  }

  /// Negative when [a] wins over [b] (first-Fix-wins).
  static int _compare(CompetingFixCandidate a, CompetingFixCandidate b) {
    final byTime = a.recordedAt.compareTo(b.recordedAt);
    if (byTime != 0) return byTime;
    final byIdentity = a.signedByIdentityId.compareTo(b.signedByIdentityId);
    if (byIdentity != 0) return byIdentity;
    return a.entryId.compareTo(b.entryId);
  }
}
