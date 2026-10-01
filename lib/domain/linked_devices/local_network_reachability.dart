/// Whether peers are on the same local network (no internet relay).
/// Real LAN checks land with mDNS/TLS (section 5); tests use [FakeLocalNetworkReachability].
abstract class LocalNetworkReachability {
  /// True when this device and the peer can talk on the local link only.
  Future<bool> arePeersOnLocalNetwork({required String peerHint});
}

class FakeLocalNetworkReachability implements LocalNetworkReachability {
  FakeLocalNetworkReachability({this.onLocalNetwork = true});

  bool onLocalNetwork;

  @override
  Future<bool> arePeersOnLocalNetwork({required String peerHint}) async {
    return onLocalNetwork;
  }
}
