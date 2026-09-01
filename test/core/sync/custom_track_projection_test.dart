import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/sync/custom_track/custom_track_projection.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';

import '../../helpers/in_memory_database.dart';

class _FailOnceProjection implements CustomTrackProjection {
  bool shouldFail = true;
  final Map<String, String> projectedNames = {};

  @override
  Future<void> upsert({required String examId, required String name}) async {
    if (shouldFail) {
      shouldFail = false;
      throw StateError('projection failed');
    }
    projectedNames[examId] = name;
  }

  @override
  Future<void> delete(String examId) async {
    if (shouldFail) {
      shouldFail = false;
      throw StateError('projection failed');
    }
    projectedNames.remove(examId);
  }
}

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  Future<void> seedCorpus() async {
    await seedContentExam(contentDb, examId: 'exam_upcat', code: 'UPCAT');
    await seedContentSubject(
      contentDb,
      subjectId: 'math',
      examId: 'exam_upcat',
      name: 'Math',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'science',
      examId: 'exam_upcat',
      name: 'Science',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'algebra',
      subjectId: 'math',
      name: 'Algebra',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'chem',
      subjectId: 'science',
      name: 'Chemistry',
    );
  }

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    await seedCorpus();
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  test('projection failure preserves authority and marker for retry', () async {
    final projection = _FailOnceProjection();
    final repo = CustomTrackRepository(
      db,
      contentDb,
      projection: projection,
    );

    final examId = await repo.create(
      name: 'Recoverable',
      includedTopicIds: {'algebra'},
    );

    final meta = await (db.select(db.customTrackMetaLocal)
          ..where((row) => row.examId.equals(examId)))
        .getSingle();
    expect(meta.name, 'Recoverable');
    expect(await repo.excludedTopicIds(examId), {'chem'});
    expect(await repo.projectionRequired(examId), isTrue);
    expect(projection.projectedNames, isEmpty);

    await repo.retryProjection(examId);

    expect(await repo.projectionRequired(examId), isFalse);
    expect(projection.projectedNames[examId], 'Recoverable');
  });

  test('projection rebuild is idempotent and reconstructs from AppDatabase',
      () async {
    final repo = CustomTrackRepository(db, contentDb);
    final examId = await repo.create(
      name: 'Canonical',
      includedTopicIds: {'algebra'},
    );
    final scopeBefore = await repo.excludedTopicIds(examId);

    await (contentDb.delete(contentDb.contentExams)
          ..where((row) => row.id.equals(examId)))
        .go();
    expect(
      await (contentDb.select(contentDb.contentExams)
            ..where((row) => row.id.equals(examId)))
          .getSingleOrNull(),
      isNull,
    );

    await repo.retryProjection(examId);
    await repo.retryProjection(examId);

    final rebuilt = await (contentDb.select(contentDb.contentExams)
          ..where((row) => row.id.equals(examId)))
        .getSingle();
    expect(rebuilt.name, 'Canonical');
    expect(rebuilt.id, examId);
    expect(await repo.excludedTopicIds(examId), scopeBefore);
    expect(await repo.projectionRequired(examId), isFalse);
  });

  test('typed track_scope document IDs round-trip without delimiter collisions',
      () {
    const exam = 'exam:custom/a.b';
    const topic = 'topic:math/a.b';
    final metaId = TrackScopeDocumentId.metadata(exam);
    final scopeId = TrackScopeDocumentId.scope(exam, topic);

    expect(TrackScopeDocumentId.parse(metaId).examId, exam);
    expect(
      TrackScopeDocumentId.parse(metaId).kind,
      TrackScopeDocumentKind.metadata,
    );
    expect(TrackScopeDocumentId.parse(scopeId).examId, exam);
    expect(TrackScopeDocumentId.parse(scopeId).topicId, topic);
    expect(
      TrackScopeDocumentId.parse(scopeId).kind,
      TrackScopeDocumentKind.scope,
    );
    expect(metaId, isNot(scopeId));
    expect(
      TrackScopeDocumentId.scope('a:b', 'c'),
      isNot(TrackScopeDocumentId.scope('a', 'b:c')),
    );
  });
}
