import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/features/first_run/data/first_run_store.dart';
import 'package:pantas/features/first_run/domain/first_run_progress.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late FirstRunStore store;
  setUp(() {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    store = FirstRunStore(AppPreferencesRepository(db));
  });

  test('nothing is pending until a run opens', () async {
    expect(await store.load(uid: 'u1', examId: 'exam_upcat'), isNull);
  });

  test('open marks the run pending at the intro', () async {
    await store.open(uid: 'u1', examId: 'exam_upcat');
    final p = await store.load(uid: 'u1', examId: 'exam_upcat');
    expect(p, isNotNull);
    expect(p!.step, FirstRunStep.intro);
    expect(p.picks, isEmpty);
  });

  test('the step and answers come back after a reload', () async {
    await store.open(uid: 'u1', examId: 'exam_upcat');
    await store.save(
      const FirstRunProgress(
        uid: 'u1',
        examId: 'exam_upcat',
        step: FirstRunStep.question2,
        picks: {'q1': 'c1', 'q2': 'c3'},
        checked: {'q1'},
      ),
    );
    final p = await store.load(uid: 'u1', examId: 'exam_upcat');
    expect(p!.step, FirstRunStep.question2);
    expect(p.picks, {'q1': 'c1', 'q2': 'c3'});
    expect(p.checked, {'q1'});
  });

  test('another account or exam does not see the run', () async {
    await store.open(uid: 'u1', examId: 'exam_upcat');
    expect(await store.load(uid: 'u2', examId: 'exam_upcat'), isNull);
    expect(await store.load(uid: 'u1', examId: 'exam_acet'), isNull);
  });

  test('clear ends the run', () async {
    await store.open(uid: 'u1', examId: 'exam_upcat');
    await store.clear();
    expect(await store.load(uid: 'u1', examId: 'exam_upcat'), isNull);
  });

  test('a damaged value reads as no run', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);
    await repo.setDeviceValue(FirstRunStore.key, '{not json');
    expect(
      await FirstRunStore(repo).load(uid: 'u1', examId: 'exam_upcat'),
      isNull,
    );
  });
}
