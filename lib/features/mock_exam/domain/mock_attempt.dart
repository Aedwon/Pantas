import 'package:pantas/core/storage/data/app_database.dart';

/// Mock attempts belong to the device-local study profile.
///
/// Signing out wipes this profile before another account can use the device.
const mockAttemptLocalUserId = 'local';

enum MockAttemptStatus {
  inProgress('in_progress'),
  completed('completed'),
  discarded('discarded'),
  forfeited('forfeited');

  const MockAttemptStatus(this.value);

  final String value;

  static MockAttemptStatus parse(String value) {
    for (final status in values) {
      if (status.value == value) return status;
    }
    throw ArgumentError.value(value, 'value', 'Unknown mock attempt status');
  }
}

class MockAttempt {
  const MockAttempt({
    required this.id,
    required this.userId,
    required this.examId,
    required this.blueprintId,
    required this.blueprintName,
    required this.durationMinutes,
    required this.status,
    required this.strictMode,
    required this.sampledQuestionsJson,
    required this.elapsedSeconds,
    required this.accumulatedPausedSeconds,
    required this.pausedAtLastFlush,
    required this.answersJson,
    required this.flagsJson,
    required this.currentIndex,
    required this.startedAt,
    required this.lastFlushedAt,
    required this.updatedAt,
    this.scoreRaw,
    this.scoreTotal,
    this.sectionResultsJson,
    this.totalTimeSeconds,
    this.submittedAt,
  });

  factory MockAttempt.fromRow(MockAttemptLocalRow row) {
    return MockAttempt(
      id: row.id,
      userId: row.userId,
      examId: row.examId,
      blueprintId: row.blueprintId,
      blueprintName: row.blueprintName,
      durationMinutes: row.durationMinutes,
      status: MockAttemptStatus.parse(row.status),
      strictMode: row.strictMode,
      sampledQuestionsJson: row.sampledQuestionsJson,
      elapsedSeconds: row.elapsedSeconds,
      accumulatedPausedSeconds: row.accumulatedPausedSeconds,
      pausedAtLastFlush: row.pausedAtLastFlush,
      answersJson: row.answersJson,
      flagsJson: row.flagsJson,
      currentIndex: row.currentIndex,
      scoreRaw: row.scoreRaw,
      scoreTotal: row.scoreTotal,
      sectionResultsJson: row.sectionResultsJson,
      totalTimeSeconds: row.totalTimeSeconds,
      startedAt: row.startedAt,
      lastFlushedAt: row.lastFlushedAt,
      submittedAt: row.submittedAt,
      updatedAt: row.updatedAt,
    );
  }

  final String id;
  final String userId;
  final String examId;
  final String blueprintId;
  final String blueprintName;
  final int durationMinutes;
  final MockAttemptStatus status;
  final bool strictMode;
  final String sampledQuestionsJson;
  final int elapsedSeconds;
  final int accumulatedPausedSeconds;
  final bool pausedAtLastFlush;
  final String answersJson;
  final String flagsJson;
  final int currentIndex;
  final int? scoreRaw;
  final int? scoreTotal;
  final String? sectionResultsJson;
  final int? totalTimeSeconds;
  final DateTime startedAt;
  final DateTime lastFlushedAt;
  final DateTime? submittedAt;
  final DateTime updatedAt;
}

class MockAttemptStart {
  const MockAttemptStart({
    required this.id,
    required this.userId,
    required this.examId,
    required this.blueprintId,
    required this.blueprintName,
    required this.durationMinutes,
    required this.strictMode,
    required this.sampledQuestionsJson,
    required this.startedAt,
  });

  final String id;
  final String userId;
  final String examId;
  final String blueprintId;
  final String blueprintName;
  final int durationMinutes;
  final bool strictMode;
  final String sampledQuestionsJson;
  final DateTime startedAt;
}
