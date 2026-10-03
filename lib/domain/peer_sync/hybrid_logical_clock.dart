/// Hybrid logical clock (real-sync design Decision 5 / task 5.2).
///
/// Each tick is (wall UTC ms, counter, deviceId). Receiving a remote stamp
/// advances local time so a 10-minute wall-clock skew cannot reverse winners.
class HybridLogicalClock {
  HybridLogicalClock({
    required this.deviceId,
    DateTime Function()? wallClock,
    DateTime? initialWall,
    int initialCounter = 0,
  }) : _wallClock = wallClock ?? DateTime.now,
       _lastWall =
           (initialWall ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true))
               .toUtc(),
       _counter = initialCounter;

  final String deviceId;
  final DateTime Function() _wallClock;
  DateTime _lastWall;
  int _counter;

  DateTime get lastWall => _lastWall;
  int get counter => _counter;

  /// Next stamp for a local event.
  HybridLogicalTimestamp tick() {
    final now = _wallClock().toUtc();
    if (now.isAfter(_lastWall)) {
      _lastWall = now;
      _counter = 0;
    } else {
      _counter += 1;
    }
    return HybridLogicalTimestamp(
      wall: _lastWall,
      counter: _counter,
      deviceId: deviceId,
    );
  }

  /// Incorporate a remote stamp, then return a stamp strictly after both.
  HybridLogicalTimestamp receive(HybridLogicalTimestamp remote) {
    final now = _wallClock().toUtc();
    final maxWall = _maxWall(now, _lastWall, remote.wall);
    if (maxWall == now && now.isAfter(_lastWall) && now.isAfter(remote.wall)) {
      _lastWall = now;
      _counter = 0;
    } else if (maxWall == _lastWall && maxWall == remote.wall) {
      _lastWall = maxWall;
      _counter = (_counter > remote.counter ? _counter : remote.counter) + 1;
    } else if (maxWall == _lastWall) {
      _counter += 1;
    } else {
      // maxWall == remote.wall (and >= local)
      _lastWall = remote.wall;
      _counter = remote.counter + 1;
    }
    return HybridLogicalTimestamp(
      wall: _lastWall,
      counter: _counter,
      deviceId: deviceId,
    );
  }

  static DateTime _maxWall(DateTime a, DateTime b, DateTime c) {
    var m = a;
    if (b.isAfter(m)) m = b;
    if (c.isAfter(m)) m = c;
    return m;
  }
}

class HybridLogicalTimestamp {
  const HybridLogicalTimestamp({
    required this.wall,
    required this.counter,
    required this.deviceId,
  });

  final DateTime wall;
  final int counter;
  final String deviceId;

  /// Positive when [this] is strictly after [other].
  int compareTo(HybridLogicalTimestamp other) {
    final byWall = wall.toUtc().compareTo(other.wall.toUtc());
    if (byWall != 0) return byWall;
    final byCounter = counter.compareTo(other.counter);
    if (byCounter != 0) return byCounter;
    return deviceId.compareTo(other.deviceId);
  }

  bool isAfter(HybridLogicalTimestamp other) => compareTo(other) > 0;
}
