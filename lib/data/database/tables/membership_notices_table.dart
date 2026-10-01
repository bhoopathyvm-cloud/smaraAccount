import 'package:drift/drift.dart';

import '../../../domain/models/membership_notice.dart';

export '../../../domain/models/membership_notice.dart';

/// Membership / erase / claim notices for Home and Device history
/// (linked-devices design Decision 2 NoticeOps; task 4.5).
@DataClassName('MembershipNoticeRow')
class MembershipNotices extends Table {
  TextColumn get noticeId => text()();

  TextColumn get kind => textEnum<MembershipNoticeKind>()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get relatedDeviceId => text().nullable()();

  TextColumn get relatedDisplayName => text().nullable()();

  TextColumn get detail => text().nullable()();

  DateTimeColumn get acknowledgedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {noticeId};
}
