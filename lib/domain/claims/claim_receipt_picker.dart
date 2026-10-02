/// How the Claimant chooses a receipt source (claim-receipts spec).
enum ClaimReceiptSource { camera, gallery, pdf }

/// Bytes + metadata from a successful pick, ready for [ClaimReceiptStore.attach].
class ClaimReceiptPickResult {
  const ClaimReceiptPickResult({
    required this.bytes,
    required this.contentType,
    required this.fileName,
  });

  final List<int> bytes;
  final String contentType;
  final String fileName;
}

/// Seam for camera / gallery / PDF pick so widget tests can inject a Fake
/// without platform channels (shared-accounts task 10.2).
abstract class ClaimReceiptPicker {
  Future<ClaimReceiptPickResult?> pick(ClaimReceiptSource source);
}

/// Test double that returns a canned result (or null) per source.
class FakeClaimReceiptPicker implements ClaimReceiptPicker {
  FakeClaimReceiptPicker({
    Map<ClaimReceiptSource, ClaimReceiptPickResult?>? results,
  }) : _results = results ?? {};

  final Map<ClaimReceiptSource, ClaimReceiptPickResult?> _results;
  final List<ClaimReceiptSource> pickLog = [];

  void setResult(ClaimReceiptSource source, ClaimReceiptPickResult? result) {
    _results[source] = result;
  }

  @override
  Future<ClaimReceiptPickResult?> pick(ClaimReceiptSource source) async {
    pickLog.add(source);
    return _results[source];
  }
}
