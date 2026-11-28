import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_gap.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

const _stamp = '2026-01-01T00:00:00.000Z';
const _topic = 'topic_upcat_data_interpretation';
const _part1 = 'lesson-data-interpretation-averages-1';
const _part2 = 'lesson-data-interpretation-averages-2';
const _plain = 'lesson-data-interpretation-tables';

Map<String, Object?> _doc(String id, Map<String, Object?> fields) => {
      '_id': id,
      '_updatedAt': _stamp,
      'schemaVersion': 1,
      'isActive': true,
      ...fields,
    };

class _Remote implements ContentRemote {
  final docs = <String, Map<String, Object?>>{};

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async =>
      ContentFetch(
        tier: 'free',
        entries: {
          for (final id in ids)
            id: docs.containsKey('${kind.wire}/$id')
                ? RemoteEntry.ok(
                    version: 'v1.f',
                    data: docs['${kind.wire}/$id'] ?? const {},
                  )
                : const RemoteEntry.missing(),
        },
      );
}

// Part 1: 6 questions over 2 key points, quiz size 4 (2 key points plus 2
// worked examples). Part 2: 2 questions, quiz size 3. One unsplit lesson.
const _lessonOfQuestion = {
  'p1a': (_part1, 1),
  'p1b': (_part1, 1),
  'p1c': (_part1, 1),
  'p1d': (_part1, 2),
  'p1e': (_part1, 2),
  'p1f': (_part1, 2),
  'p2a': (_part2, 1),
  'p2b': (_part2, 2),
  'plain1': (null, null),
  'plain2': (null, null),
  'plain3': (null, null),
};

Map<String, Object?> _catalog() => {
      'id': 'exam_upcat',
      'lessons': [
        {
          'id': 'lesson-data-interpretation-averages',
          'topic': _topic,
          'title': 'Finding Averages',
          'summary': 's',
          'ordering': 1,
          'status': 'retired',
          'replacedBy': [_part1, _part2],
        },
        for (final (id, part, size) in [(_part1, 1, 4), (_part2, 2, 3)])
          {
            'id': id,
            'topic': _topic,
            'title': 'Finding Averages',
            'summary': 's',
            'ordering': 1 + part,
            'quizSize': size,
            'part': part,
            'partCount': 2,
            'keyPoints': ['One', 'Two'],
          },
        {
          'id': _plain,
          'topic': _topic,
          'title': 'Tables',
          'summary': 's',
          'ordering': 5,
        },
      ],
      'sets': [
        {
          'id': 'qs-di',
          'topic': _topic,
          'lesson': 'lesson-data-interpretation-averages',
          'exams': ['exam_upcat'],
          'questions': [
            for (final e in _lessonOfQuestion.entries)
              if (e.value.$1 != null)
                {
                  'id': e.key,
                  'lesson': e.value.$1,
                  'keyPoint': e.value.$2,
                },
          ],
        },
        {
          'id': 'qs-plain',
          'topic': _topic,
          'lesson': _plain,
          'exams': ['exam_upcat'],
          'questions': [
            for (final id in ['plain1', 'plain2', 'plain3']) {'id': id},
          ],
        },
      ],
    };

Map<String, Object?> _plainSet() => {
      'id': 'qs-plain',
      'meta': {
        'topic': 'data-interpretation',
        'subtopic': 'tables',
        'exams': ['upcat'],
      },
      'questions': [
        for (final id in ['plain1', 'plain2', 'plain3'])
          {
            'id': id,
            'stem': 'Stem $id',
            'explanation': 'Because.',
            'choices': [
              {'text': 'Yes', 'correct': true},
              {'text': 'No'},
            ],
          },
      ],
    };

Map<String, Object?> _questionSet() => {
      'id': 'qs-di',
      'meta': {
        'topic': 'data-interpretation',
        'subtopic': 'averages',
        'exams': ['upcat'],
      },
      'questions': [
        for (final e in _lessonOfQuestion.entries)
          if (e.value.$1 != null)
            {
              'id': e.key,
              if (e.value.$1 != null) 'lesson': e.value.$1,
              if (e.value.$2 != null) 'keyPoint': e.value.$2,
              'stem': 'Stem ${e.key}',
              'explanation': 'Because.',
              'choices': [
                {'text': 'Yes', 'correct': true},
                {'text': 'No'},
              ],
            },
      ],
    };

const _exam = Exam(
  id: 'exam_upcat',
  code: 'UPCAT',
  name: 'UPCAT',
  shortName: 'UPCAT',
  language: 'en',
  isActive: true,
  subjects: [],
);

/// Database and mirror work runs on real timers, so the widget clock waits on
/// them outside fake async.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
}

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late ContentService service;
  late ContentMirror mirror;

  setUp(() async {
    appDb = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    final remote = _Remote()
      ..docs['catalog/index'] = {
        'id': 'index',
        'exams': [
          _doc('exam_upcat', {
            'code': 'UPCAT',
            'name': 'UPCAT',
            'shortName': 'UPCAT',
            'language': 'en',
            'ordering': 1,
          }),
        ],
        'subjects': [
          _doc('subj_upcat_math', {
            'exam': {'_ref': 'exam_upcat'},
            'name': 'Mathematics',
            'ordering': 1,
          }),
        ],
        'topics': [
          _doc(_topic, {
            'subject': {'_ref': 'subj_upcat_math'},
            'name': 'Data Interpretation',
            'ordering': 1,
          }),
        ],
        'catalogs': ['exam_upcat'],
      }
      ..docs['catalog/exam_upcat'] = _catalog()
      ..docs['questions/qs-di'] = _questionSet()
      ..docs['questions/qs-plain'] = _plainSet();
    for (final id in [_part1, _part2, _plain]) {
      remote.docs['lessons/$id'] = {
        'id': id,
        'title': 'Lesson',
        'summary': 's',
        'topic': 'topic-data-interpretation',
        'estimatedMinutes': 1,
        'body': '## Body\n\nText.',
      };
    }
    service = ContentService(remote: remote, cache: ContentCache(appDb));
    mirror = ContentMirror(db: contentDb, service: service);
    await mirror.start();
    await mirror.idle;
  });

  tearDown(() async {
    await mirror.dispose();
    await service.dispose();
    await appDb.close();
    await contentDb.close();
  });

  List<Override> overrides() => [
        appDatabaseProvider.overrideWithValue(appDb),
        contentDatabaseProvider.overrideWithValue(contentDb),
        contentFetchHookProvider.overrideWithValue(mirror),
        activeExamFocusProvider
            .overrideWith((_) async => const ActiveExamFocus.selected(_exam)),
      ];

  test('a split part offers its quiz with min(quizSize, questions)', () async {
    final container = ProviderContainer(overrides: overrides());
    addTearDown(container.dispose);
    for (final (id, count) in [(_part1, 4), (_part2, 2)]) {
      expect(
        await container.read(
          lessonQuizAvailableProvider((examId: 'exam_upcat', lessonId: id))
              .future,
        ),
        isTrue,
        reason: id,
      );
      expect(
        await container.read(lessonQuizCountProvider(id).future),
        count,
        reason: id,
      );
    }
    expect(
      await container.read(
        lessonQuizAvailableProvider(
          (
            examId: 'exam_upcat',
            lessonId: 'lesson-data-interpretation-averages'
          ),
        ).future,
      ),
      isFalse,
    );
  });

  testWidgets('the reader end shows Quiz yourself with the part count',
      (tester) async {
    await tester.pumpAppWithProviders(
      const Scaffold(
        body: ReaderGap(isRead: true, examId: 'exam_upcat', lessonId: _part1),
      ),
      overrides: overrides(),
    );
    await settle(tester);
    expect(find.text('Quiz yourself, 4 questions'), findsOneWidget);
  });

  test('a split part quiz serves quizSize, one per key point first', () async {
    for (var run = 0; run < 10; run++) {
      final result = await StartInlineLessonQuiz(
        content: ContentRepository(contentDb, fetchHook: mirror),
        sessions: QuizSessionRepository(appDb),
      )(
        userId: 'user$run',
        examId: 'exam_upcat',
        lessonId: _part1,
        now: DateTime.utc(2026, 11),
      );
      final session = (result as StartInlineLessonQuizStarted).session;
      expect(session.questions, hasLength(4));
      expect(session.questions.every((q) => q.lessonId == _part1), isTrue);
      expect(session.questions.map((q) => q.keyPoint).toSet(), {1, 2});
    }
  });
}
