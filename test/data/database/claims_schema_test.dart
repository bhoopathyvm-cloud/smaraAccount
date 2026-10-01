import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:test/test.dart';

void main() {
  test(
    'fresh schema includes empty claim tables and role-set columns',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      expect(await db.select(db.claims).get(), isEmpty);
      expect(await db.select(db.claimItems).get(), isEmpty);
      expect(await db.select(db.claimItemDecisions).get(), isEmpty);
      expect(await db.select(db.claimReceipts).get(), isEmpty);
      expect(await db.select(db.claimAdvances).get(), isEmpty);
      expect(await db.select(db.claimCategoryAllowlist).get(), isEmpty);
      expect(await db.select(db.claimSpendingHints).get(), isEmpty);

      // linked_devices has roles_csv / owed_to / person_display columns.
      final info = await db
          .customSelect('PRAGMA table_info(linked_devices)')
          .get();
      final names = info.map((r) => r.data['name'] as String).toSet();
      expect(names.contains('roles_csv'), isTrue);
      expect(names.contains('owed_to_account_id'), isTrue);
      expect(names.contains('person_display_name'), isTrue);

      final metaInfo = await db
          .customSelect('PRAGMA table_info(books_set_metadata)')
          .get();
      final metaNames = metaInfo.map((r) => r.data['name'] as String).toSet();
      expect(metaNames.contains('receipt_required_above_minor'), isTrue);

      // Role enum includes Approver and Claimant.
      expect(LinkedDeviceRole.values, contains(LinkedDeviceRole.approver));
      expect(LinkedDeviceRole.values, contains(LinkedDeviceRole.claimant));
    },
  );
}
