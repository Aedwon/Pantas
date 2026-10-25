import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/features/mock_exam/data/server_mock_view_cache.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('the place and flags come back for the same account and mock', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final cache = ServerMockViewCache(db);
    await cache.write(
      uid: 'uid_a',
      mockId: 'abcdefghij1',
      cursor: 4,
      flags: {'q9', 'q2'},
    );

    final read = await cache.read(uid: 'uid_a', mockId: 'abcdefghij1');
    expect(read!.cursor, 4);
    expect(read.flags, {'q2', 'q9'});
  });

  test('another account or another mock sees nothing', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final cache = ServerMockViewCache(db);
    await cache.write(
      uid: 'uid_a',
      mockId: 'abcdefghij1',
      cursor: 4,
      flags: {'q2'},
    );

    expect(await cache.read(uid: 'uid_b', mockId: 'abcdefghij1'), isNull);
    expect(await cache.read(uid: 'uid_a', mockId: 'zzzzzzzzzz2'), isNull);
  });

  test('a damaged value is ignored', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final prefs = AppPreferencesRepository(db);
    for (final bad in ['not json', '[]', '{"cursor":-1,"flags":[]}']) {
      await prefs.setDeviceValue(
        ServerMockViewCache.keyFor('uid_a', 'abcdefghij1'),
        bad,
      );
      expect(
        await ServerMockViewCache(db).read(uid: 'uid_a', mockId: 'abcdefghij1'),
        isNull,
        reason: bad,
      );
    }
  });
}
