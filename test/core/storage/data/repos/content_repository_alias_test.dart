import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';

import '../../../../helpers/in_memory_database.dart';
import '../../../../helpers/retired_lessons.dart';

/// Records which lesson ids the web hook was asked to fetch.
class _Hook implements ContentFetchHook {
  final lessonCalls = <String>[];

  @override
  Future<bool> ensureLesson(String id) async {
    lessonCalls.add(id);
    return true;
  }

  @override
  Future<bool> ensurePassage(String id) async => true;

  @override
  Future<Set<String>> ensureQuestions(Iterable<String> ids) async => {...ids};
}

void main() {
  late ContentDatabase db;

  setUp(() async {
    db = inMemoryContentDatabase();
    addTearDown(db.close);
    await seedContentExam(
      db,
      examId: 'e1',
      code: 'E1',
      name: 'Exam',
      shortName: 'E1',
    );
    await seedContentSubject(db, subjectId: 's1', examId: 'e1', name: 'S');
    await seedContentTopic(db, topicId: 't1', subjectId: 's1', name: 'T');
    for (final id in ['orig', 'p1', 'p2', 'mid']) {
      await seedContentLesson(db, lessonId: id, topicId: 't1');
      await seedContentQuestion(
        db,
        questionId: 'q_$id',
        topicId: 't1',
        examId: 'e1',
        lessonId: id,
      );
    }
  });

  group('ContentRepository', () {
    test('a retired id opens the first part', () async {
      await retireTestLesson(db, 'orig', ['p1', 'p2']);
      final lesson = await ContentRepository(db).lessonById('orig');
      expect(lesson?.id, 'p1');
    });

    test('a chain of retired ids is followed to the active lesson', () async {
      await retireTestLesson(db, 'orig', ['mid', 'p2']);
      await retireTestLesson(db, 'mid', ['p1']);
      expect((await ContentRepository(db).lessonById('orig'))?.id, 'p1');
    });

    test('a replacedBy cycle resolves to nothing instead of looping', () async {
      await retireTestLesson(db, 'orig', ['mid']);
      await retireTestLesson(db, 'mid', ['orig']);
      expect(await ContentRepository(db).lessonById('orig'), isNull);
    });

    test('lists and metadata leave retired lessons out', () async {
      await retireTestLesson(db, 'orig', ['p1', 'p2']);
      final repo = ContentRepository(db);
      expect(
        (await repo.lessonsByTopic('t1', examId: 'e1')).map((l) => l.id),
        isNot(contains('orig')),
      );
      expect(
        (await repo.lessonMetaByTopics(['t1'], examId: 'e1'))['t1']!
            .map((l) => l.id),
        isNot(contains('orig')),
      );
    });

    test('search does not list a retired lesson', () async {
      await retireTestLesson(db, 'orig', ['p1', 'p2']);
      final rows = await ContentRepository(db)
          .searchLessonRows(topicIds: ['t1'], query: 'lesson');
      expect(rows.map((r) => r.id), isNot(contains('orig')));
      expect(rows.map((r) => r.id), contains('p1'));
    });

    test('the web hook is asked for the part, never the retired lesson',
        () async {
      await retireTestLesson(db, 'orig', ['p1', 'p2']);
      final hook = _Hook();
      final lesson =
          await ContentRepository(db, fetchHook: hook).lessonById('orig');
      expect(lesson?.id, 'p1');
      expect(hook.lessonCalls, ['p1']);
    });

    test('resolveLessonIds maps only the retired ids it can resolve', () async {
      await retireTestLesson(db, 'orig', ['p1', 'p2']);
      final resolved = await ContentRepository(db)
          .resolveLessonIds(['orig', 'p2', 'unknown']);
      expect(resolved, {'orig': 'p1'});
    });

    test('the retired map holds every retired lesson and no active one',
        () async {
      final repo = ContentRepository(db);
      expect(await repo.retiredReplacements(), isEmpty);
      await retireTestLesson(db, 'orig', ['p1', 'p2']);
      await retireTestLesson(db, 'mid', ['p1']);
      expect(await repo.retiredReplacements(), {
        'orig': ['p1', 'p2'],
        'mid': ['p1'],
      });
      expect(
        (await repo.lessonsByTopic('t1', examId: 'e1')).map((l) => l.id),
        isNot(contains('orig')),
        reason: 'lists still leave retired lessons out',
      );
    });

    test('the lesson-set revision is empty until a lesson is retired',
        () async {
      final repo = ContentRepository(db);
      expect(await repo.lessonSetRevision(), '');
      await retireTestLesson(db, 'orig', ['p1', 'p2']);
      final split = await repo.lessonSetRevision();
      expect(split, isNotEmpty);
      await retireTestLesson(db, 'mid', ['p1']);
      expect(await repo.lessonSetRevision(), isNot(split));
    });
  });

  group('LessonRepo', () {
    test('findById resolves a retired id to the first part', () async {
      await retireTestLesson(db, 'orig', ['p1', 'p2']);
      expect((await LessonRepo(db).findById('orig'))?.id, 'p1');
    });

    test('byTopic leaves retired lessons out', () async {
      await retireTestLesson(db, 'orig', ['p1', 'p2']);
      final ids = (await LessonRepo(db).byTopic('t1')).map((l) => l.id);
      expect(ids, isNot(contains('orig')));
    });
  });
}
