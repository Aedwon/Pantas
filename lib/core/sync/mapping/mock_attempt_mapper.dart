import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/sync_mapper.dart';

class MockAttemptMapper implements SyncMapper {
  const MockAttemptMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'mock_exam_attempts';

  String documentId(MockAttemptLocalRow row) => row.id;

  Map<String, Object?> toFirestore(
    MockAttemptLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'id': row.id,
      'userId': row.userId,
      'examId': row.examId,
      'blueprintId': row.blueprintId,
      'blueprintName': row.blueprintName,
      'durationMinutes': row.durationMinutes,
      'status': row.status,
      'strictMode': row.strictMode,
      'sampledQuestionsJson': row.sampledQuestionsJson,
      'elapsedSeconds': row.elapsedSeconds,
      'accumulatedPausedSeconds': row.accumulatedPausedSeconds,
      'pausedAtLastFlush': row.pausedAtLastFlush,
      'answersJson': row.answersJson,
      'flagsJson': row.flagsJson,
      'currentIndex': row.currentIndex,
      'scoreRaw': row.scoreRaw,
      'scoreTotal': row.scoreTotal,
      'sectionResultsJson': row.sectionResultsJson,
      'totalTimeSeconds': row.totalTimeSeconds,
      'startedAt': row.startedAt.toUtc().toIso8601String(),
      'lastFlushedAt': row.lastFlushedAt.toUtc().toIso8601String(),
      'submittedAt': row.submittedAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }
}
