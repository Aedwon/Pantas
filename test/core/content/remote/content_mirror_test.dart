import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/content/remote/question_set_mapper.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';

import '../../../helpers/in_memory_database.dart';

const _stamp = '2026-01-01T00:00:00.000Z';

Map<String, Object?> _doc(String id, Map<String, Object?> fields) => {
      '_id': id,
      '_updatedAt': _stamp,
      'schemaVersion': 1,
      'isActive': true,
      ...fields,
    };

final _index = <String, Object?>{
  'id': 'index',
  'exams': [
    _doc('exam_upcat', {
      'code': 'UPCAT',
      'name': 'UP College Admission Test',
      'shortName': 'UPCAT',
      'language': 'en',
      'ordering': 1,
    }),
  ],
  'subjects': [
    _doc('subj_upcat_science', {
      'exam': {'_ref': 'exam_upcat'},
      'name': 'Science',
      'ordering': 1,
    }),
  ],
  'topics': [
    _doc('topic_upcat_biology', {
      'subject': {'_ref': 'subj_upcat_science'},
      'name': 'Biology',
      'ordering': 1,
    }),
  ],
  'catalogs': ['exam_upcat'],
};

final _exam = <String, Object?>{
  'id': 'exam_upcat',
  'lessons': [
    {
      'id': 'lesson-biology-cells',
      'topic': 'topic_upcat_biology',
      'subtopic': 'subtopic_cells',
      'title': 'Cells',
      'summary': 'Parts of a cell.',
      'estimatedMinutes': 12,
      'ordering': 2,
    },
    {
      'id': 'lesson-biology-genes',
      'topic': 'topic_upcat_biology',
      'subtopic': 'subtopic_genes',
      'title': 'Genes',
      'summary': 'Heredity.',
      'estimatedMinutes': 9,
      'ordering': 1,
    },
  ],
  'sets': [
    {
      'id': 'qs-biology__cells',
      'topic': 'topic_upcat_biology',
      'subtopic': 'subtopic_cells',
      'lesson': 'lesson-biology-cells',
      'exams': ['exam_upcat'],
      'questions': [
        {'id': 'bio-1'},
        {'id': 'bio-2', 'figure': true},
      ],
    },
  ],
};

Map<String, Object?> _lesson({String body = 'Cells are small.'}) => {
      'id': 'lesson-biology-cells',
      'title': 'Cells',
      'summary': 'Parts of a cell.',
      'subject': 'biology',
      'topic': 'topic-biology',
      'estimatedMinutes': 12,
      'body': '## Parts\n\n$body',
    };

Map<String, Object?> _set({bool notes = false}) => {
      'id': 'qs-biology__cells',
      'meta': {
        'subject': 'science',
        'topic': 'biology',
        'subtopic': 'cells',
        'exams': ['upcat'],
      },
      'questions': [
        {
          'id': 'bio-1',
          'stem': 'What holds the cell together?',
          'explanation': 'The membrane.',
          'choices': [
            {'text': 'Membrane', 'correct': true},
            {
              'text': 'Wall',
              if (notes) 'rationale': 'Plants only.',
            },
            {'text': 'Nucleus'},
          ],
        },
        {
          'id': 'bio-2',
          'stem': 'Which organelle?',
          'explanation': 'This one.',
          'figureSpec': {'kind': 'cell'},
          'choices': [
            {'text': 'A', 'correct': true},
            {'text': 'B'},
          ],
        },
      ],
    };

class _Remote implements ContentRemote {
  final docs = <String, Map<String, Object?>>{};
  String tier = 'free';
  String version = 'v1';
  bool offline = false;
  final calls = <String>[];

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async {
    calls.add('${kind.wire}:${ids.join(",")}');
    if (offline) throw StateError('offline');
    final suffix = tier == 'pro' ? 'p' : 'f';
    return ContentFetch(
      tier: tier,
      entries: {
        for (final id in ids)
          id: docs.containsKey('${kind.wire}/$id')
              ? (knownVersions[id] == '$version.$suffix'
                  ? RemoteEntry.unchanged(version: '$version.$suffix')
                  : RemoteEntry.ok(
                      version: '$version.$suffix',
                      data: docs['${kind.wire}/$id'] ?? const {},
                    ))
              : const RemoteEntry.missing(),
      },
    );
  }
}

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late _Remote remote;
  late ContentService service;
  late ContentMirror mirror;

  ContentMirror newMirror() => ContentMirror(db: contentDb, service: service);

  setUp(() {
    appDb = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    remote = _Remote()
      ..docs['catalog/index'] = _index
      ..docs['catalog/exam_upcat'] = _exam
      ..docs['lessons/lesson-biology-cells'] = _lesson()
      ..docs['questions/qs-biology__cells'] = _set();
    service = ContentService(remote: remote, cache: ContentCache(appDb));
    mirror = newMirror();
  });

  tearDown(() async {
    await mirror.dispose();
    await service.dispose();
    await appDb.close();
    await contentDb.close();
  });

  Future<List<ContentQuestionRow>> questionRows() =>
      contentDb.select(contentDb.contentQuestions).get();

  test('the catalog fills the structure but no text', () async {
    await mirror.start();
    await mirror.idle;

    final exams = await contentDb.select(contentDb.contentExams).get();
    expect(exams.single.id, 'exam_upcat');
    expect(
      (await contentDb.select(contentDb.contentTopics).get()).single.name,
      'Biology',
    );
    final lessons = await contentDb.select(contentDb.contentLessons).get();
    expect(lessons.map((l) => l.id).toSet(), {
      'lesson-biology-cells',
      'lesson-biology-genes',
    });
    expect(lessons.every((l) => l.bodyJson == '[]'), isTrue);
    final cells = lessons.firstWhere((l) => l.id == 'lesson-biology-cells');
    expect(cells.ordering, 2);
    expect(cells.subtopicId, 'subtopic_cells');

    final rows = await questionRows();
    expect(rows.map((r) => r.id).toSet(), {'bio-1', 'bio-2'});
    expect(rows.every((r) => r.stemJson == '[]'), isTrue);
    expect(rows.firstWhere((r) => r.id == 'bio-2').figureSpecJson, isNotNull);
    expect(rows.firstWhere((r) => r.id == 'bio-1').figureSpecJson, isNull);
    expect(rows.first.lessonId, 'lesson-biology-cells');
    expect(await contentDb.select(contentDb.contentChoices).get(), isEmpty);
    final links = await contentDb.select(contentDb.contentQuestionExams).get();
    expect(links.map((l) => l.examId).toSet(), {'exam_upcat'});
  });

  test('with nothing cached, start waits for the first catalog', () async {
    await mirror.start();
    expect(await contentDb.select(contentDb.contentTopics).get(), hasLength(1));
  });

  test('with nothing cached and no network, start still completes', () async {
    remote.offline = true;
    await mirror.start();
    expect(await contentDb.select(contentDb.contentTopics).get(), isEmpty);
  });

  test('follows the parts of a split exam catalog', () async {
    remote.docs['catalog/exam_upcat'] = {
      ..._exam,
      'sets': <Object>[],
      'parts': ['exam_upcat.science'],
    };
    remote.docs['catalog/exam_upcat.science'] = {
      'id': 'exam_upcat.science',
      'sets': _exam['sets'],
    };
    await mirror.start();
    await mirror.idle;
    expect((await questionRows()).map((r) => r.id).toSet(), {
      'bio-1',
      'bio-2',
    });
  });

  test('a lesson is fetched before it is read, then served from memory',
      () async {
    await mirror.start();
    await mirror.idle;
    remote.calls.clear();

    expect(await mirror.ensureLesson('lesson-biology-cells'), isTrue);
    final repo = ContentRepository(contentDb);
    final lesson = (await repo.lessonById('lesson-biology-cells'))!;
    expect(lesson.bodyJson.first['_type'], 'block');
    expect(lesson.bodyJson.first['style'], 'h2');
    expect(lesson.ordering, 2, reason: 'the catalog order is kept');
    expect(remote.calls, ['lessons:lesson-biology-cells']);

    remote.calls.clear();
    expect(await mirror.ensureLesson('lesson-biology-cells'), isTrue);
    await mirror.idle;
    expect(
      remote.calls,
      isEmpty,
      reason: 'the stored copy is current, so the revalidation answered '
          '"unchanged" from the cache without a second request',
    );
  });

  test('a lesson that cannot be fetched is not present', () async {
    await mirror.start();
    await mirror.idle;
    remote.offline = true;
    expect(await mirror.ensureLesson('lesson-biology-cells'), isFalse);
    expect(await mirror.ensureLesson('lesson-not-in-catalog'), isFalse);
  });

  test('question sets are fetched by the questions asked for', () async {
    await mirror.start();
    await mirror.idle;
    remote.calls.clear();

    final ready = await mirror.ensureQuestions(['bio-1', 'bio-2', 'nope']);
    expect(ready, {'bio-1', 'bio-2'});
    expect(remote.calls, ['questions:qs-biology__cells']);

    final repo = ContentRepository(contentDb);
    final question = (await repo.questionById('bio-1'))!;
    expect(question.stem, 'What holds the cell together?');
    expect(question.choices, hasLength(3));
    expect(question.examIds, ['exam_upcat']);
    expect(question.choices.every((c) => c.rationale == null), isTrue);
    final figure = await contentDb.select(contentDb.contentQuestions).get();
    expect(
      jsonDecode(
        figure.firstWhere((r) => r.id == 'bio-2').figureSpecJson!,
      ),
      {'kind': 'cell'},
    );
  });

  test('hydrated questions equal the mapper output for the same set', () async {
    await mirror.start();
    await mirror.idle;
    await mirror.ensureQuestions(['bio-1', 'bio-2']);
    final repo = ContentRepository(contentDb);
    final fromDb = await repo.hydrateSelectedQuestions(['bio-1', 'bio-2']);
    final fromMapper = questionsFromSet(_set());
    expect(fromDb.map((q) => q.id), fromMapper.map((q) => q.id));
    for (var i = 0; i < fromDb.length; i++) {
      final a = fromDb[i];
      final b = fromMapper[i];
      expect(a.stem, b.stem);
      expect(a.explanation, b.explanation);
      expect(a.topicId, b.topicId);
      expect(a.examIds, b.examIds);
      expect(a.lessonId, b.lessonId);
      expect(a.figureSpecJson, b.figureSpecJson);
      expect(
        a.choices.map((c) => (c.id, c.label, c.text, c.isCorrect)).toList(),
        b.choices.map((c) => (c.id, c.label, c.text, c.isCorrect)).toList(),
      );
    }
  });

  test('a later catalog refresh does not erase fetched text', () async {
    await mirror.start();
    await mirror.idle;
    await mirror.ensureLesson('lesson-biology-cells');
    await mirror.ensureQuestions(['bio-1']);

    remote.version = 'v2';
    await mirror.refreshCatalog();
    await mirror.idle;

    final lesson = await (contentDb.select(contentDb.contentLessons)
          ..where((l) => l.id.equals('lesson-biology-cells')))
        .getSingle();
    expect(lesson.bodyJson, isNot('[]'));
    final question = await (contentDb.select(contentDb.contentQuestions)
          ..where((q) => q.id.equals('bio-1')))
        .getSingle();
    expect(question.stemJson, isNot('[]'));
  });

  test('a new version of a set replaces its choices', () async {
    await mirror.start();
    await mirror.idle;
    await mirror.ensureQuestions(['bio-1']);

    final changed = _set();
    ((changed['questions']! as List).first as Map<String, Object?>)['choices'] =
        [
      {'text': 'Only', 'correct': true},
    ];
    remote
      ..docs['questions/qs-biology__cells'] = changed
      ..version = 'v2';
    await service.refresh(ContentKind.questions, ['qs-biology__cells']);
    await mirror.idle;

    final choices = await (contentDb.select(contentDb.contentChoices)
          ..where((c) => c.questionId.equals('bio-1')))
        .get();
    expect(choices.map((c) => c.textValue), ['Only']);
  });

  test('a Pro copy keeps its notes and a Free downgrade strips them', () async {
    remote
      ..tier = 'pro'
      ..docs['questions/qs-biology__cells'] = _set(notes: true);
    await mirror.start();
    await mirror.idle;
    await mirror.ensureQuestions(['bio-1']);

    Future<List<String?>> notes() async => [
          for (final c in await (contentDb.select(contentDb.contentChoices)
                ..where((c) => c.questionId.equals('bio-1')))
              .get())
            c.rationale,
        ];
    expect(await notes(), contains('Plants only.'));

    await service.onSignedOut();
    await mirror.idle;
    expect(await notes(), everyElement(isNull));
  });

  test('a restart fills the database from the cache without the network',
      () async {
    await mirror.start();
    await mirror.idle;
    await mirror.ensureLesson('lesson-biology-cells');
    await mirror.ensureQuestions(['bio-1']);
    await mirror.dispose();

    final fresh = inMemoryContentDatabase();
    addTearDown(fresh.close);
    remote
      ..offline = true
      ..calls.clear();
    final second = ContentMirror(db: fresh, service: service);
    addTearDown(second.dispose);
    await second.start();
    await second.idle;

    expect(await fresh.select(fresh.contentTopics).get(), hasLength(1));
    expect(await second.ensureLesson('lesson-biology-cells'), isTrue);
    expect(
      await second.ensureQuestions(['bio-1', 'bio-2']),
      {'bio-1', 'bio-2'},
    );
    final question = await ContentRepository(fresh).questionById('bio-1');
    expect(question!.stem, 'What holds the cell together?');
  });

  test('preloads the next lessons of the topic after one opens', () async {
    remote.docs['lessons/lesson-biology-genes'] = {
      ..._lesson(),
      'id': 'lesson-biology-genes',
      'title': 'Genes',
    };
    await mirror.start();
    await mirror.idle;
    remote.calls.clear();

    // Genes (ordering 1) comes before Cells (2); opening Genes preloads Cells.
    await mirror.ensureLesson('lesson-biology-genes');
    await mirror.idle;
    expect(remote.calls, contains('lessons:lesson-biology-cells'));
  });

  test('unusable catalog documents are skipped, not fatal', () async {
    remote.docs['catalog/exam_upcat'] = {'id': 'exam_upcat', 'sets': 5};
    await mirror.start();
    await mirror.idle;
    expect(await contentDb.select(contentDb.contentTopics).get(), hasLength(1));
    expect(await questionRows(), isEmpty);
  });
}
