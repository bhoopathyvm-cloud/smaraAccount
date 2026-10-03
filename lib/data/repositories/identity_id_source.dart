/// Late-bound current signing identity for metadata outbox emits.
///
/// [AccountRepository] is constructed before [IdentityRepository] (Identity
/// depends on Account), so repos that emit metadata hold this source and
/// Identity binds it after construction.
class IdentityIdSource {
  Future<String?> Function()? _resolve;

  void bind(Future<String?> Function() resolve) {
    _resolve = resolve;
  }

  Future<String?> current() async => _resolve?.call();
}
