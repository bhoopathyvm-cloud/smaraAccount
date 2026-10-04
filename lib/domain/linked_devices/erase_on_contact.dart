import '../../data/repositories/membership_repository.dart';
import '../models/linked_device.dart';

/// Erase-on-next-contact (real-sync task 5.4 / design Decision 6).
class EraseOnContact {
  /// If [localDeviceId] is erase-pending on this device, wipe the local books
  /// copy and return the erase timestamp to report back to the Owner.
  static Future<DateTime?> maybeEraseLocalCopy({
    required MembershipRepository membership,
    required String localDeviceId,
    required Future<void> Function() wipeLocalBooksCopy,
    DateTime Function()? clock,
  }) async {
    final self = await membership.findByDeviceId(localDeviceId);
    if (self == null || !self.isErasePending) return null;
    await wipeLocalBooksCopy();
    return (clock ?? DateTime.now)().toUtc();
  }

  /// Owner side: record that the removed device completed erase.
  static Future<LinkedDevice> acknowledgeErased({
    required MembershipRepository membership,
    required String targetDeviceId,
    required DateTime erasedAt,
  }) {
    return membership.markErased(targetDeviceId: targetDeviceId, at: erasedAt);
  }
}
