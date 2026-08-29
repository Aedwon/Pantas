import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/mapping/assessment_mapper.dart';
import 'package:pantas/core/sync/mapping/attempt_mapper.dart';
import 'package:pantas/core/sync/mapping/custom_blueprint_mapper.dart';
import 'package:pantas/core/sync/mapping/fsrs_card_mapper.dart';
import 'package:pantas/core/sync/mapping/lesson_bookmark_mapper.dart';
import 'package:pantas/core/sync/mapping/lesson_progress_mapper.dart';
import 'package:pantas/core/sync/mapping/mock_attempt_mapper.dart';
import 'package:pantas/core/sync/mapping/question_flag_mapper.dart';
import 'package:pantas/core/sync/mapping/review_log_mapper.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';

/// Sync-owned local application seam for accepted remote documents.
///
/// This path intentionally bypasses feature repositories and their local
/// mutation recorders. The authoritative domain write and accepted row meta
/// advance happen in one Drift transaction.
class SyncCollectionAdapter {
  const SyncCollectionAdapter(this.collection);

  final String collection;

  Future<void> applyRemote({
    required AppDatabase db,
    required String rowId,
    required Map<String, Object?>? payload,
    required bool deleted,
    required DateTime updatedAt,
    String? originDeviceId,
  }) {
    return db.transaction(() async {
      if (deleted) {
        await _delete(db, rowId);
      } else {
        if (payload == null) {
          throw const FormatException('live Sync document requires a payload');
        }
        await _upsert(db, rowId, payload);
      }

      await SyncRowMetaRepository(db).acceptKnownVersion(
        collection: collection,
        rowId: rowId,
        updatedAt: updatedAt,
        originDeviceId: originDeviceId,
      );
    });
  }

  Future<void> _upsert(
    AppDatabase db,
    String rowId,
    Map<String, Object?> payload,
  ) async {
    switch (collection) {
      case 'quiz_attempts':
        const mapper = AttemptMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(rowId, mapper.documentId(row));
        await db.into(db.attemptsLocal).insertOnConflictUpdate(
              mapper.toCompanion(row),
            );
      case 'assessments':
        const mapper = AssessmentMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(rowId, mapper.documentId(row));
        await db.into(db.assessmentResultsLocal).insertOnConflictUpdate(
              mapper.toCompanion(row),
            );
      case 'fsrs_cards':
        const mapper = FsrsCardMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(rowId, mapper.documentId(row));
        await db.into(db.reviewStateLocal).insertOnConflictUpdate(
              mapper.toCompanion(row),
            );
      case 'lesson_progress':
        const mapper = LessonProgressMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(rowId, mapper.documentId(row));
        await db.into(db.lessonProgressLocal).insertOnConflictUpdate(
              mapper.toCompanion(row),
            );
      case 'lesson_bookmarks':
        const mapper = LessonBookmarkMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(rowId, mapper.documentId(row));
        await db.into(db.lessonBookmarksLocal).insertOnConflictUpdate(
              mapper.toCompanion(row),
            );
      case 'question_flags':
        const mapper = QuestionFlagMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(rowId, mapper.documentId(row));
        await db.into(db.questionFlagsLocal).insertOnConflictUpdate(
              mapper.toCompanion(row),
            );
      case 'mock_exam_attempts':
        const mapper = MockAttemptMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(rowId, mapper.documentId(row));
        if (!_isTerminalMock(row.status)) {
          throw const FormatException(
            'in-progress mock attempts are not cloud Sync documents',
          );
        }
        await db.into(db.mockAttempts).insertOnConflictUpdate(
              mapper.toCompanion(row),
            );
      case 'review_logs':
        const mapper = ReviewLogMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(rowId, mapper.documentId(row));
        await db.into(db.reviewLogs).insertOnConflictUpdate(
              mapper.toCompanion(row),
            );
      case 'track_scope':
        const mapper = TrackScopeMapper();
        final mapped = mapper.fromFirestore(rowId, payload);
        switch (mapped.kind) {
          case TrackScopeDocumentKind.metadata:
            await db.into(db.customTrackMetaLocal).insertOnConflictUpdate(
                  CustomTrackMetaLocalCompanion.insert(
                    examId: mapped.examId,
                    name: mapped.name!,
                  ),
                );
          case TrackScopeDocumentKind.scope:
            await db.into(db.trackScopeLocal).insertOnConflictUpdate(
                  TrackScopeLocalCompanion.insert(
                    examId: mapped.examId,
                    topicId: mapped.topicId!,
                  ),
                );
        }
      case 'custom_blueprints':
        const mapper = CustomBlueprintMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(rowId, mapper.documentId(row));
        await db.into(db.customBlueprintsLocal).insertOnConflictUpdate(
              mapper.toCompanion(row),
            );
      default:
        throw UnsupportedError('No active Sync adapter for $collection');
    }
  }

  Future<void> _delete(AppDatabase db, String rowId) async {
    switch (collection) {
      case 'quiz_attempts':
        await (db.delete(db.attemptsLocal)
              ..where((row) => row.id.equals(rowId)))
            .go();
      case 'assessments':
        await (db.delete(db.assessmentResultsLocal)
              ..where((row) => row.examId.equals(rowId)))
            .go();
      case 'fsrs_cards':
        await (db.delete(db.reviewStateLocal)
              ..where((row) => row.questionId.equals(rowId)))
            .go();
      case 'lesson_progress':
        await (db.delete(db.lessonProgressLocal)
              ..where((row) => row.lessonId.equals(rowId)))
            .go();
      case 'lesson_bookmarks':
        await (db.delete(db.lessonBookmarksLocal)
              ..where((row) => row.lessonId.equals(rowId)))
            .go();
      case 'question_flags':
        await (db.delete(db.questionFlagsLocal)
              ..where((row) => row.questionId.equals(rowId)))
            .go();
      case 'mock_exam_attempts':
        await (db.delete(db.mockAttempts)..where((row) => row.id.equals(rowId)))
            .go();
      case 'review_logs':
        await (db.delete(db.reviewLogs)..where((row) => row.id.equals(rowId)))
            .go();
      case 'track_scope':
        final identity = TrackScopeDocumentId.parse(rowId);
        switch (identity.kind) {
          case TrackScopeDocumentKind.metadata:
            await (db.delete(db.customTrackMetaLocal)
                  ..where((row) => row.examId.equals(identity.examId)))
                .go();
          case TrackScopeDocumentKind.scope:
            await (db.delete(db.trackScopeLocal)
                  ..where(
                    (row) =>
                        row.examId.equals(identity.examId) &
                        row.topicId.equals(identity.topicId!),
                  ))
                .go();
        }
      case 'custom_blueprints':
        await (db.delete(db.customBlueprintsLocal)
              ..where((row) => row.examId.equals(rowId)))
            .go();
      default:
        throw UnsupportedError('No active Sync adapter for $collection');
    }
  }

  void _requireIdentity(String expected, String actual) {
    if (expected != actual) {
      throw FormatException(
        'Sync document identity mismatch: expected $expected, got $actual',
      );
    }
  }

  bool _isTerminalMock(String status) => switch (status) {
        'completed' || 'discarded' || 'forfeited' => true,
        _ => false,
      };
}
