import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';

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
      'attemptUpdatedAt': row.updatedAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  MockAttemptLocalRow fromFirestore(Map<String, Object?> doc) {
    final domainUpdatedAt =
        doc['attemptUpdatedAt'] as String? ?? doc['updatedAt']! as String;
    return MockAttemptLocalRow(
      id: doc['id']! as String,
      userId: doc['userId']! as String,
      examId: doc['examId']! as String,
      blueprintId: doc['blueprintId']! as String,
      blueprintName: doc['blueprintName']! as String,
      durationMinutes: doc['durationMinutes']! as int,
      status: doc['status']! as String,
      strictMode: doc['strictMode']! as bool,
      sampledQuestionsJson: doc['sampledQuestionsJson']! as String,
      elapsedSeconds: doc['elapsedSeconds'] as int? ?? 0,
      accumulatedPausedSeconds: doc['accumulatedPausedSeconds'] as int? ?? 0,
      pausedAtLastFlush: doc['pausedAtLastFlush'] as bool? ?? false,
      answersJson: doc['answersJson'] as String? ?? '{}',
      flagsJson: doc['flagsJson'] as String? ?? '[]',
      currentIndex: doc['currentIndex'] as int? ?? 0,
      scoreRaw: doc['scoreRaw'] as int?,
      scoreTotal: doc['scoreTotal'] as int?,
      sectionResultsJson: doc['sectionResultsJson'] as String?,
      totalTimeSeconds: doc['totalTimeSeconds'] as int?,
      startedAt: DateTime.parse(doc['startedAt']! as String),
      lastFlushedAt: DateTime.parse(doc['lastFlushedAt']! as String),
      submittedAt: _dateTimeOrNull(doc['submittedAt']),
      updatedAt: DateTime.parse(domainUpdatedAt),
    );
  }

  MockAttemptsCompanion toCompanion(MockAttemptLocalRow row) {
    return MockAttemptsCompanion(
      id: Value(row.id),
      userId: Value(row.userId),
      examId: Value(row.examId),
      blueprintId: Value(row.blueprintId),
      blueprintName: Value(row.blueprintName),
      durationMinutes: Value(row.durationMinutes),
      status: Value(row.status),
      strictMode: Value(row.strictMode),
      sampledQuestionsJson: Value(row.sampledQuestionsJson),
      elapsedSeconds: Value(row.elapsedSeconds),
      accumulatedPausedSeconds: Value(row.accumulatedPausedSeconds),
      pausedAtLastFlush: Value(row.pausedAtLastFlush),
      answersJson: Value(row.answersJson),
      flagsJson: Value(row.flagsJson),
      currentIndex: Value(row.currentIndex),
      scoreRaw: Value(row.scoreRaw),
      scoreTotal: Value(row.scoreTotal),
      sectionResultsJson: Value(row.sectionResultsJson),
      totalTimeSeconds: Value(row.totalTimeSeconds),
      startedAt: Value(row.startedAt),
      lastFlushedAt: Value(row.lastFlushedAt),
      submittedAt: Value(row.submittedAt),
      updatedAt: Value(row.updatedAt),
    );
  }

  DateTime? _dateTimeOrNull(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
