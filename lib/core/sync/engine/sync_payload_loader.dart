import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
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

class SyncLocalPayloadLoader {
  SyncLocalPayloadLoader({
    required AppDatabase db,
    required String deviceId,
    DateTime Function()? now,
  })  : _db = db,
        _deviceId = deviceId,
        _now = now ?? DateTime.now;

  final AppDatabase _db;
  final String _deviceId;
  final DateTime Function() _now;

  Future<Map<String, Object?>?> load(String collection, String rowId) async {
    final stamp = _now().toUtc();
    switch (collection) {
      case 'quiz_attempts':
        final row = await (_db.select(_db.attemptsLocal)
              ..where((item) => item.id.equals(rowId)))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          const AttemptMapper().toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      case 'assessments':
        final row = await (_db.select(_db.assessmentResultsLocal)
              ..where((item) => item.examId.equals(rowId)))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          const AssessmentMapper().toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      case 'fsrs_cards':
        final row = await (_db.select(_db.reviewStateLocal)
              ..where((item) => item.questionId.equals(rowId)))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          const FsrsCardMapper().toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      case 'lesson_progress':
        final row = await (_db.select(_db.lessonProgressLocal)
              ..where((item) => item.lessonId.equals(rowId)))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          const LessonProgressMapper().toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      case 'lesson_bookmarks':
        final row = await (_db.select(_db.lessonBookmarksLocal)
              ..where((item) => item.lessonId.equals(rowId)))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          const LessonBookmarkMapper().toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      case 'question_flags':
        final row = await (_db.select(_db.questionFlagsLocal)
              ..where((item) => item.questionId.equals(rowId)))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          const QuestionFlagMapper().toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      case 'mock_exam_attempts':
        final row = await (_db.select(_db.mockAttempts)
              ..where((item) => item.id.equals(rowId)))
            .getSingleOrNull();
        if (row == null || !_terminalMock(row.status)) return null;
        return _domainOnly(
          const MockAttemptMapper().toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      case 'review_logs':
        final row = await (_db.select(_db.reviewLogs)
              ..where((item) => item.id.equals(rowId)))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          const ReviewLogMapper().toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      case 'track_scope':
        return _loadTrackScope(rowId, stamp);
      case 'custom_blueprints':
        final row = await (_db.select(_db.customBlueprintsLocal)
              ..where((item) => item.examId.equals(rowId)))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          const CustomBlueprintMapper().toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      default:
        throw UnsupportedError('No active Sync payload loader for $collection');
    }
  }

  Future<Map<String, Object?>?> _loadTrackScope(
    String rowId,
    DateTime stamp,
  ) async {
    final identity = TrackScopeDocumentId.parse(rowId);
    const mapper = TrackScopeMapper();
    switch (identity.kind) {
      case TrackScopeDocumentKind.metadata:
        final row = await (_db.select(_db.customTrackMetaLocal)
              ..where((item) => item.examId.equals(identity.examId)))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          mapper.metadataToFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
      case TrackScopeDocumentKind.scope:
        final row = await (_db.select(_db.trackScopeLocal)
              ..where(
                (item) =>
                    item.examId.equals(identity.examId) &
                    item.topicId.equals(identity.topicId!),
              ))
            .getSingleOrNull();
        if (row == null) return null;
        return _domainOnly(
          mapper.scopeToFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        );
    }
  }

  static Map<String, Object?> _domainOnly(Map<String, Object?> source) {
    return Map<String, Object?>.from(source)
      ..remove('updatedAt')
      ..remove('originDeviceId')
      ..remove('mutationId')
      ..remove('schemaVersion')
      ..remove('deleted');
  }

  static bool _terminalMock(String status) => switch (status) {
        'completed' || 'discarded' || 'forfeited' => true,
        _ => false,
      };
}
