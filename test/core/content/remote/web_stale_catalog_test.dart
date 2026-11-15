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
import 'package:pantas/features/quiz/application/quiz_starts.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart';

import '../../../helpers/in_memory_database.dart';

const _stamp = '2026-01-01T00:00:00.000Z';
const _topic = 'topic_upcat_data_interpretation';
const _original = 'lesson-data-interpretation-averages';
const _part1 = 'lesson-data-interpretation-averages-1';
const _part2 = 'lesson-data-interpretation-averages-2';

Map<String, Object?> _doc(String id, Map<String, Object?> fields) => {
      '_id': id,
      '_updatedAt': _stamp,
      'schemaVersion': 1,
      'isActive': true,
      ...fields,
    };

/// Serves documents with a version each and honors the client's known
/// versions, like the server.
class StaleRemote implements ContentRemote {
  final docs = <String, Map<String, Object?>>{};
  final versions = <String, String>{};
  final catalogAsks = <String>[];

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async {
    final entries = <String, RemoteEntry>{};
    for (final id in ids) {
      final key = '${kind.wire}/$id';
      if (kind == ContentKind.catalog) catalogAsks.add(id);
      final data = docs[key];
      final version = versions[key] ?? 'v1.f';
      entries[id] = data == null
          ? const RemoteEntry.missing()
          : knownVersions[id] == version
              ? RemoteEntry.unchanged(version: version)
              : RemoteEntry.ok(version: version, data: data);
    }
    return ContentFetch(tier: 'free', entries: entries);
  }
}

const _questions = {
  'p1a': (_part1, 1),
  'p1b': (_part1, 2),
  'p1c': (_part1, 2),
  'p1d': (_part1, 1),
  'p2a': (_part2, 1),
  'p2b': (_part2, 2),
};

Map<String, Object?> staleIndex() => {
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
    };

Map<String, Object?> _lesson(String id, int ordering, [int? part]) => {
      'id': id,
      'topic': _topic,
      'title': 'Finding Averages',
      'summary': 's',
      'ordering': ordering,
      if (part != null) ...{'quizSize': 4, 'part': part, 'partCount': 2},
    };

/// The catalog a client cached before the upload: the original, no parts.
Map<String, Object?> staleCatalog() => {
      'id': 'exam_upcat',
      'lessons': [_lesson(_original, 1)],
      'sets': [
        {
          'id': 'qs-di',
          'topic': _topic,
          'lesson': _original,
          'exams': ['exam_upcat'],
          'questions': [
            for (final id in _questions.keys) {'id': id},
          ],
        },
      ],
    };

/// The catalog after the upload: the original is retired, two parts exist.
Map<String, Object?> newCatalog() => {
      'id': 'exam_upcat',
      'lessons': [
        {
          ..._lesson(_original, 1),
          'status': 'retired',
          'replacedBy': [_part1, _part2],
        },
        _lesson(_part1, 2, 1),
        _lesson(_part2, 3, 2),
      ],
      'sets': [
        {
          'id': 'qs-di',
          'topic': _topic,
          'lesson': _original,
          'exams': ['exam_upcat'],
          'questions': [
            for (final e in _questions.entries)
              {'id': e.key, 'lesson': e.value.$1, 'keyPoint': e.value.$2},
          ],
        },
      ],
    };

Map<String, Object?> splitQuestionSet() => {
      'id': 'qs-di',
      'meta': {
        'topic': 'data-interpretation',
        'subtopic': 'averages',
        'exams': ['upcat'],
      },
      'questions': [
        for (final e in _questions.entries)
          {
            'id': e.key,
            'lesson': e.value.$1,
            'keyPoint': e.value.$2,
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

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late ContentService service;
  late ContentMirror mirror;
  late StaleRemote remote;

  setUp(() async {
    appDb = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    remote = StaleRemote()
      ..docs['catalog/index'] = staleIndex()
      ..docs['catalog/exam_upcat'] = staleCatalog()
      ..versions['catalog/exam_upcat'] = 'old.f'
      ..docs['questions/qs-di'] = splitQuestionSet();
    for (final id in [_original, _part1, _part2]) {
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

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        contentDatabaseProvider.overrideWithValue(contentDb),
        contentFetchHookProvider.overrideWithValue(mirror),
        activeExamFocusProvider
            .overrideWith((_) async => const ActiveExamFocus.selected(_exam)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('a stale catalog still finds the original lesson its quiz', () async {
    final c = container();
    expect(
      await c.read(
        lessonQuizAvailableProvider((examId: 'exam_upcat', lessonId: _original))
            .future,
      ),
      isTrue,
    );
    expect(await c.read(lessonQuizCountProvider(_original).future), 5);
    final result = await StartInlineLessonQuiz(
      content: ContentRepository(contentDb, fetchHook: mirror),
      sessions: QuizSessionRepository(appDb),
    )(
      userId: 'user',
      examId: 'exam_upcat',
      lessonId: _original,
      now: DateTime.utc(2026, 11),
    );
    expect(result, isA<StartInlineLessonQuizStarted>());
  });

  test('after the catalog refreshes the questions move to their parts',
      () async {
    remote
      ..docs['catalog/exam_upcat'] = newCatalog()
      ..versions['catalog/exam_upcat'] = 'new.f';
    await mirror.refreshCatalog(force: true);
    await mirror.idle;
    final c = container();
    expect(await c.read(lessonQuizCountProvider(_part1).future), 4);
    expect(await c.read(lessonQuizCountProvider(_part2).future), 2);
    expect(
      await c.read(
        lessonQuizAvailableProvider((examId: 'exam_upcat', lessonId: _original))
            .future,
      ),
      isFalse,
    );
    final row = await (contentDb.select(contentDb.contentLessons)
          ..where((l) => l.id.equals(_original)))
        .getSingle();
    expect(row.status, 'retired');
  });
}
