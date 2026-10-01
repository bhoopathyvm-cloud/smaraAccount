/// Platform local-network (or nearby/Wi-Fi) permission seam.
/// Real OS adapters land in section 8; tests and desktop use [FakeLocalNetworkPermission].
abstract class LocalNetworkPermission {
  /// Whether the in-app first-open explanation has already been shown.
  Future<bool> hasShownExplanation();

  Future<void> markExplanationShown();

  /// Requests OS permission. Returns whether access is granted afterward.
  Future<bool> requestPermission();

  /// Current grant state without prompting.
  Future<bool> isGranted();
}

/// In-memory fake for unit/widget tests and platforms without a real adapter yet.
class FakeLocalNetworkPermission implements LocalNetworkPermission {
  FakeLocalNetworkPermission({
    bool explanationShown = false,
    bool granted = false,
    this.grantOnRequest = true,
  }) : _explanationShown = explanationShown,
       _granted = granted;

  bool _explanationShown;
  bool _granted;

  /// When [requestPermission] is called, set granted to this value.
  final bool grantOnRequest;

  int requestCallCount = 0;

  @override
  Future<bool> hasShownExplanation() async => _explanationShown;

  @override
  Future<void> markExplanationShown() async {
    _explanationShown = true;
  }

  @override
  Future<bool> requestPermission() async {
    requestCallCount++;
    _granted = grantOnRequest;
    return _granted;
  }

  @override
  Future<bool> isGranted() async => _granted;
}
