import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('publishing the same owner keeps the token', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = SyncActiveContextStore(db);

    await store.publishStable(uid: 'uid-1', generationId: 'gen-1');
    final token = (await store.readSnapshot())!.token;
    await store.publishStable(uid: 'uid-1', generationId: 'gen-1');

    expect((await store.readSnapshot())!.token, token);
  });

  test('suspension remembers its owner across store instances', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = SyncActiveContextStore(db);
    const owner = SyncActiveContext(uid: 'uid-1', generationId: 'gen-1');

    await store.publishStable(uid: owner.uid, generationId: owner.generationId);
    final token = (await store.readSnapshot())!.token;
    await store.suspendStable();
    final reloaded = SyncActiveContextStore(db);
    await reloaded.suspendStable();
    final suspended = (await reloaded.readSnapshot())!;
    expect(suspended.token, token);
    expect(suspended.context, isNull);
    expect(await reloaded.readStable(), isNull);
    expect(suspended.rememberedContext, owner);

    await reloaded.publishStable(
      uid: owner.uid,
      generationId: owner.generationId,
    );
    expect((await reloaded.readSnapshot())!.token, token);
    expect(await reloaded.readStable(), owner);
  });

  for (final owner in [
    const SyncActiveContext(uid: 'uid-2', generationId: 'gen-1'),
    const SyncActiveContext(uid: 'uid-1', generationId: 'gen-2'),
  ]) {
    final label = '${owner.uid}/${owner.generationId}';
    test('publishing $label replaces a suspended token', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final store = SyncActiveContextStore(db);
      await store.publishStable(uid: 'uid-1', generationId: 'gen-1');
      final token = (await store.readSnapshot())!.token;
      await store.suspendStable();

      await store.publishStable(
        uid: owner.uid,
        generationId: owner.generationId,
      );

      expect((await store.readSnapshot())!.token, isNot(token));
      expect(await store.readStable(), owner);
    });
  }

  test('clearing a suspended context forgets its owner and replaces its token',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = SyncActiveContextStore(db);
    await store.publishStable(uid: 'uid-1', generationId: 'gen-1');
    final token = (await store.readSnapshot())!.token;
    await store.suspendStable();

    await store.clearStable();
    final cleared = (await store.readSnapshot())!;
    expect(cleared.token, isNot(token));
    expect(cleared.context, isNull);
    expect(cleared.rememberedContext, isNull);
    await store.clearStable();
    expect((await store.readSnapshot())!.token, cleared.token);

    await store.publishStable(uid: 'uid-1', generationId: 'gen-1');
    expect((await store.readSnapshot())!.token, isNot(token));
    expect((await store.readSnapshot())!.token, isNot(cleared.token));
  });

  test('suspending an empty store establishes one token without an owner',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = SyncActiveContextStore(db);

    await store.suspendStable();
    final suspended = (await store.readSnapshot())!;
    expect(suspended.context, isNull);
    expect(suspended.rememberedContext, isNull);
    await store.suspendStable();
    expect((await store.readSnapshot())!.token, suspended.token);

    await store.publishStable(uid: 'uid-1', generationId: 'gen-1');
    expect((await store.readSnapshot())!.token, isNot(suspended.token));
  });

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

  test('clearing an already cleared context keeps its token', () async {
    // Every entitlement refresh asks the runtime to clear the context. A
    // refresh that changes nothing must not invalidate the launch guards that
    // Home and Quiz captured from the token.
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = SyncActiveContextStore(db);

    await store.clearStable();
    final first = (await store.readSnapshot())!.token;
    await store.clearStable();
    expect((await store.readSnapshot())!.token, first);

    await store.publishStable(uid: 'uid-1', generationId: 'gen-1');
    final published = (await store.readSnapshot())!.token;
    expect(published, isNot(first));
    await store.clearStable();
    expect((await store.readSnapshot())!.token, isNot(published));
  });
}
