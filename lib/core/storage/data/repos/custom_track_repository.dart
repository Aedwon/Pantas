import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:uuid/uuid.dart';

/// Creates a student's own track and stores what it hides.
///
/// This needs both databases. What the track hides is the student's own and
/// stays in [AppDatabase]; the exam row it creates and the topics it inverts
/// against are corpus, so they live in [ContentDatabase]. The custom row
/// survives a sync because the content sync only ever upserts, and
/// `isCustom` exists on the content schema for exactly this row.
class CustomTrackRepository {
  CustomTrackRepository(this._db, this._contentDb, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final ContentDatabase _contentDb;
  final Uuid _uuid;

  /// Creates the track and hides everything it did not include.
  ///
  /// The included set is turned into exclusions immediately, because the
  /// scope is stored as what is hidden. A track that includes everything
  /// therefore stores no rows at all, which is the same state a listed exam
  /// starts in.
  Future<ExamId> create({
    required String name,
    required Set<TopicId> includedTopicIds,
  }) async {
    final examId = 'exam_custom_${_uuid.v4()}';
    final now = DateTime.now();
    await _contentDb.into(_contentDb.contentExams).insert(
          ContentExamsCompanion.insert(
            id: examId,
            code: 'custom',
            name: name,
            // The name is the track's identity everywhere the short name
            // would otherwise appear, so both carry it.
            shortName: name,
            language: 'en',
            // A custom track sorts after every published exam.
            ordering: 9999,
            isCustom: const Value(true),
            schemaVersion: 1,
            updatedAt: now,
          ),
        );

    final allTopics = await _contentDb.select(_contentDb.contentTopics).get();
    await setExcluded(
      examId: examId,
      topicIds: {
        for (final topic in allTopics)
          if (!includedTopicIds.contains(topic.id)) topic.id,
      },
    );
    return examId;
  }

  /// Replaces the whole exclusion set in one transaction.
  ///
  /// The delete here is the only delete in this feature, and it deletes
  /// exclusions rather than content: re-ticking a topic brings back every
  /// attempt and every review state, because nothing was ever keyed on the
  /// scope.
  Future<void> setExcluded({
    required ExamId examId,
    required Set<TopicId> topicIds,
  }) {
    return _db.transaction(() async {
      await (_db.delete(_db.trackScopeLocal)
            ..where((s) => s.examId.equals(examId)))
          .go();
      for (final topicId in topicIds) {
        await _db.into(_db.trackScopeLocal).insertOnConflictUpdate(
              TrackScopeLocalCompanion.insert(
                examId: examId,
                topicId: topicId,
              ),
            );
      }
    });
  }

  Future<Set<TopicId>> excludedTopicIds(ExamId examId) async {
    final rows = await (_db.select(_db.trackScopeLocal)
          ..where((s) => s.examId.equals(examId)))
        .get();
    return {for (final row in rows) row.topicId};
  }
}
