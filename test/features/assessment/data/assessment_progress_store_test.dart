import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/assessment/data/assessment_progress_store.dart';
import 'package:pantas/features/assessment/domain/models/assessment_progress.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AssessmentProgressStore store;

  AssessmentProgress progress(String examId) => AssessmentProgress(
        examId: examId,
        attemptId: 'a1',
        startedAt: DateTime.utc(2026, 11, 26),
        questionIds: const ['q1', 'q2'],
        picks: const {'q1': 'c1'},
      );

  setUp(() {
    db = inMemoryDatabase();
    store = AssessmentProgressStore(AppPreferencesRepository(db));
  });
  tearDown(() => db.close());

  test('saves and reads per account and exam', () async {
    await store.save('u1', progress('e1'));
    expect((await store.load('u1', 'e1'))!.picks, {'q1': 'c1'});
    expect(await store.load('u2', 'e1'), isNull);
    expect(await store.load('u1', 'e2'), isNull);
  });

  test('clear removes only that account and exam', () async {
    await store.save('u1', progress('e1'));
    await store.save('u1', progress('e2'));
    await store.clear('u1', 'e1');
    expect(await store.load('u1', 'e1'), isNull);
    expect(await store.load('u1', 'e2'), isNotNull);
  });

  test('an account wipe clears every saved assessment', () async {
    await store.save('u1', progress('e1'));
    await store.save('u2', progress('e2'));
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(
            key: 'payment_trusted_clock_v1',
            value: 'keep',
          ),
        );
    await SyncLocalStateWiper(db).wipeAll();
    expect(await store.load('u1', 'e1'), isNull);
    expect(await store.load('u2', 'e2'), isNull);
    expect((await db.select(db.devicePrefs).get()).map((row) => row.key), [
      'payment_trusted_clock_v1',
    ]);
  });
}
