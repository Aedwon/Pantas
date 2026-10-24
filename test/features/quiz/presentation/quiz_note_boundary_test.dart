import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/quiz/presentation/quiz_note_boundary.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('actual anonymous wipe expires the captured core token', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contexts = SyncActiveContextStore(db);
    await contexts.clearStable();
    final boundary =
        (await QuizNoteBoundary.capture(db, isCurrent: () => true))!;
    expect(await boundary.allows(), isTrue);
    await SyncLocalStateWiper(db).wipeAll();
    expect(await boundary.allows(), isFalse);
    await contexts.clearStable();
    expect(await boundary.allows(), isFalse);
  });
  test('runtime account exam and entitlement invalidation cannot rebind retry',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    var current = true;
    final boundary =
        (await QuizNoteBoundary.capture(db, isCurrent: () => current))!;
    expect(await boundary.allows(), isTrue);
    current = false;
    expect(await boundary.allows(), isFalse);
    expect(
      await QuizNoteBoundary.capture(db, isCurrent: () => current),
      isNull,
    );
  });
  test('missing envelope is accepted only until an envelope appears', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final boundary =
        (await QuizNoteBoundary.capture(db, isCurrent: () => true))!;
    expect(await boundary.allows(), isTrue);
    await SyncActiveContextStore(db).clearStable();
    expect(await boundary.allows(), isFalse);
  });
}
