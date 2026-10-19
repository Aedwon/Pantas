import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';

import '../../../helpers/in_memory_database.dart';

/// Stands in for the web mirror: only the ids in [available] ever get text.
class _Hook implements ContentFetchHook {
  _Hook(this.db, this.available);

  final ContentDatabase db;
  final Set<String> available;
  final calls = <String>[];

  @override
  Future<bool> ensureLesson(String id) async {
    calls.add('lesson:$id');
    if (!available.contains(id)) return false;
    await seedContentLesson(
      db,
      lessonId: id,
      topicId: 't1',
      body: [
        {'_type': 'block'},
      ],
    );
    return true;
  }

  @override
  Future<bool> ensurePassage(String id) async {
    calls.add('passage:$id');
    return available.contains(id);
  }

  @override
  Future<Set<String>> ensureQuestions(Iterable<String> ids) async {
    final wanted = ids.toList();
    calls.add('questions:${wanted.join(",")}');
    final ready = {
      for (final id in wanted)
        if (available.contains(id)) id,
    };
    for (final id in ready) {
      // The text arrives with the fetch.
      await seedContentQuestion(
        db,
        questionId: id,
        topicId: 't1',
        examId: 'e1',
        stem: 'Fetched $id',
      );
    }
    return ready;
  }
}

void main() {
  late ContentDatabase db;

  Future<void> seedIndexRows() async {
    // Index rows as the catalog leaves them: no text yet.
    for (final id in ['q1', 'q2', 'q3']) {
      await seedContentQuestion(
        db,
        questionId: id,
        topicId: 't1',
        examId: 'e1',
        stem: 'Not fetched',
      );
    }
    await seedContentLesson(db, lessonId: 'l1', topicId: 't1');
  }

  setUp(() async {
    db = openTestContentDatabase();
    await seedIndexRows();
  });

  group('ContentRepository', () {
    test('without a hook it reads what is there', () async {
      final repo = ContentRepository(db);
      expect((await repo.questionById('q1'))!.stem, 'Not fetched');
      expect(await repo.lessonById('l1'), isNotNull);
    });

    test('questionById fetches first and drops what cannot be fetched',
        () async {
      final hook = _Hook(db, {'q1'});
      final repo = ContentRepository(db, fetchHook: hook);
      expect((await repo.questionById('q1'))!.stem, 'Fetched q1');
      expect(await repo.questionById('q2'), isNull);
    });

    test('hydrateSelectedQuestions keeps order and drops the unavailable',
        () async {
      final hook = _Hook(db, {'q1', 'q3'});
      final repo = ContentRepository(db, fetchHook: hook);
      final questions = await repo.hydrateSelectedQuestions(['q3', 'q2', 'q1']);
      expect(questions.map((q) => q.id), ['q3', 'q1']);
      expect(questions.map((q) => q.stem), ['Fetched q3', 'Fetched q1']);
      expect(hook.calls, ['questions:q3,q2,q1']);
    });

    test('questionsByTopic reads the text the fetch brought', () async {
      final hook = _Hook(db, {'q1', 'q2'});
      final repo = ContentRepository(db, fetchHook: hook);
      final questions = await repo.questionsByTopic('t1');
      expect(questions.map((q) => q.id).toSet(), {'q1', 'q2'});
      expect(questions.every((q) => q.stem.startsWith('Fetched')), isTrue);
    });

    test('lessonById fetches the body, or returns nothing', () async {
      final hook = _Hook(db, {'l1'});
      final repo = ContentRepository(db, fetchHook: hook);
      expect((await repo.lessonById('l1'))!.bodyJson, hasLength(1));
      expect(await repo.lessonById('l2'), isNull);
      expect(hook.calls, ['lesson:l1', 'lesson:l2']);
    });

    test('passageById asks the hook first', () async {
      await db.into(db.contentPassages).insert(
            ContentPassagesCompanion.insert(
              id: 'p1',
              schemaVersion: 1,
              updatedAt: DateTime.utc(2026),
              topicId: 't1',
              title: 'T',
              body: 'B',
              language: 'en',
              wordCount: 1,
            ),
          );
      final hook = _Hook(db, {'p1'});
      final repo = ContentRepository(db, fetchHook: hook);
      expect((await repo.passageById('p1'))!.body, 'B');
      expect(await repo.passageById('p2'), isNull);
      expect(hook.calls, ['passage:p1', 'passage:p2']);
    });

    test('listing lessons by topic fetches nothing', () async {
      final hook = _Hook(db, {'l1'});
      final repo = ContentRepository(db, fetchHook: hook);
      expect(await repo.lessonsByTopic('t1'), hasLength(1));
      expect(hook.calls, isEmpty);
    });
  });

  group('QuestionRepo', () {
    test('byTopic, bySubtopic, findById and byIds fetch first', () async {
      final hook = _Hook(db, {'q1', 'q2'});
      final repo = QuestionRepo(db, fetchHook: hook);
      expect((await repo.findById('q1'))!.stem, 'Fetched q1');
      expect(await repo.findById('q3'), isNull);
      final byTopic = await repo.byTopic('t1');
      expect(byTopic.map((q) => q.id), ['q1', 'q2']);
      expect((await repo.byIds(['q2', 'q3'])).map((q) => q.id), ['q2']);
      expect(await repo.bySubtopic('none'), isEmpty);
    });

    test('byExam stops fetching at the limit', () async {
      final hook = _Hook(db, {'q1', 'q2', 'q3'});
      final repo = QuestionRepo(db, fetchHook: hook);
      final questions = await repo.byExam('e1', limit: 1);
      expect(questions, hasLength(1));
      expect(hook.calls, hasLength(1));
    });
  });

  group('LessonRepo', () {
    test('findById fetches the body; byTopic does not', () async {
      final hook = _Hook(db, {'l1'});
      final repo = LessonRepo(db, fetchHook: hook);
      expect(await repo.byTopic('t1'), hasLength(1));
      expect(hook.calls, isEmpty);
      expect((await repo.findById('l1'))!.bodyJson, hasLength(1));
      expect(await repo.findById('l9'), isNull);
    });
  });
}
