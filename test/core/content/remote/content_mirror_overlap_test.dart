import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';

import '../../../helpers/in_memory_database.dart';

/// Counts the rows each batched insert writes, per table.
class _RowCounter extends QueryInterceptor {
  final rows = <String, int>{};

  @override
  Future<void> runBatched(QueryExecutor executor, BatchedStatements batch) {
    for (final args in batch.arguments) {
      final sql = batch.statements[args.statementIndex];
      final match = RegExp('INSERT[A-Z ]* INTO "([a-z_]+)"').firstMatch(sql);
      if (match != null) {
        rows.update(match.group(1)!, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    return super.runBatched(executor, batch);
  }
}

const _stamp = '2026-01-01T00:00:00.000Z';

Map<String, Object?> _doc(String id, Map<String, Object?> fields) => {
      '_id': id,
      '_updatedAt': _stamp,
      'schemaVersion': 1,
      'isActive': true,
      ...fields,
    };

Map<String, Object?> _exam(String id, List<Map<String, Object?>> sets) => {
      'id': id,
      'lessons': <Object>[],
      'sets': sets,
    };

Map<String, Object?> _set(
  String id,
  List<String> exams,
  List<String> questions,
) =>
    {
      'id': id,
      'topic': 'topic_a',
      'subtopic': 'subtopic_a',
      'lesson': 'lesson-a',
      'exams': exams,
      'questions': [
        for (final question in questions) {'id': question},
      ],
    };

class _Remote implements ContentRemote {
  final docs = <String, Map<String, Object?>>{};

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async {
    return ContentFetch(
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
}

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late _RowCounter counter;
  late _Remote remote;
  late ContentService service;
  late ContentMirror mirror;

  setUp(() {
    appDb = inMemoryDatabase();
    counter = _RowCounter();
    contentDb = ContentDatabase(
      NativeDatabase.memory().interceptWith(counter),
    );
    remote = _Remote()
      ..docs['catalog/index'] = {
        'id': 'index',
        'exams': [
          for (final id in ['exam_a', 'exam_b'])
            _doc(id, {
              'code': id,
              'name': id,
              'shortName': id,
              'language': 'en',
              'ordering': 1,
            }),
        ],
        'subjects': <Object>[],
        'topics': <Object>[],
        'catalogs': ['exam_a', 'exam_b'],
      }
      // Both exams list the shared set, as the real catalogs do.
      ..docs['catalog/exam_a'] = _exam('exam_a', [
        _set('qs-shared', ['exam_a', 'exam_b'], ['q1', 'q2', 'q3']),
        _set('qs-a-only', ['exam_a'], ['q4']),
      ])
      ..docs['catalog/exam_b'] = _exam('exam_b', [
        _set('qs-shared', ['exam_a', 'exam_b'], ['q1', 'q2', 'q3']),
      ]);
    service = ContentService(remote: remote, cache: ContentCache(appDb));
    mirror = ContentMirror(db: contentDb, service: service);
  });

  tearDown(() async {
    await mirror.dispose();
    await service.dispose();
    await appDb.close();
    await contentDb.close();
  });

  test('a question two exam catalogs share is written once', () async {
    await mirror.start();
    await mirror.idle;

    expect(counter.rows['content_questions'], 4, reason: 'q1 to q4, once each');
    expect(
      counter.rows['content_question_exams'],
      7,
      reason: 'q1 to q3 for both exams and q4 for one, never repeated',
    );
  });

  test('the shared rows still end up the same as before', () async {
    await mirror.start();
    await mirror.idle;

    final questions = await contentDb.select(contentDb.contentQuestions).get();
    expect(questions.map((q) => q.id).toSet(), {'q1', 'q2', 'q3', 'q4'});
    final links = await contentDb.select(contentDb.contentQuestionExams).get();
    expect(
      {for (final link in links) '${link.questionId}|${link.examId}'},
      {
        'q1|exam_a',
        'q1|exam_b',
        'q2|exam_a',
        'q2|exam_b',
        'q3|exam_a',
        'q3|exam_b',
        'q4|exam_a',
      },
    );
  });
}
