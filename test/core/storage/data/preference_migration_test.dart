import 'package:pantas/core/storage/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('new installs create device and account preference tables', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final tables = await db
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name in ('device_prefs', 'account_prefs') order by name",
        )
        .get();

    expect(
      tables.map((row) => row.read<String>('name')).toList(),
      equals(['account_prefs', 'device_prefs']),
    );
  });

  test('device prefs and account prefs store independent key spaces', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(
            key: 'selected_exam_id',
            value: 'cse',
          ),
        );
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(
            key: 'reminder_time',
            value: '07:30',
          ),
        );

    expect((await db.select(db.devicePrefs).get()).single.value, 'cse');
    expect((await db.select(db.accountPrefs).get()).single.value, '07:30');
  });
}
