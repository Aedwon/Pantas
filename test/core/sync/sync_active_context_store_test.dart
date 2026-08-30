import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('publishes and clears one stable uid/generation context atomically',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = SyncActiveContextStore(db);

    expect(await store.readStable(), isNull);

    await store.publishStable(uid: 'uid-1', generationId: 'gen-1');
    expect(
      await store.readStable(),
      const SyncActiveContext(uid: 'uid-1', generationId: 'gen-1'),
    );

    await store.clearStable();
    expect(await store.readStable(), isNull);
  });

  test('malformed stored context is never treated as stable', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = SyncActiveContextStore(db);

    await db.customStatement(
      "insert into sync_meta (key,value) values ('syncActiveContext','{}')",
    );

    expect(await store.readStable(), isNull);
  });
}
