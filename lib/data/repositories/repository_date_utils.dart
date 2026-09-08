export '../../domain/time/iso_date.dart'
    show dateOnly, truncateToStoredPrecision;

/// Shared byte comparison for public keys / hashes (signing identity and
/// chain verification).
bool bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
