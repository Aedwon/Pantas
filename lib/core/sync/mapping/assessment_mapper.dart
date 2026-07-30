import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';

class AssessmentMapper implements SyncMapper {
  const AssessmentMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'assessments';

  String documentId(AssessmentResultLocalRow row) => row.examId;

  Map<String, Object?> toFirestore(
    AssessmentResultLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'examId': row.examId,
      'completedAt': row.completedAt.toUtc().toIso8601String(),
      'topicScoresJson': row.topicScoresJson,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  AssessmentResultLocalRow fromFirestore(Map<String, Object?> doc) {
    return AssessmentResultLocalRow(
      examId: doc['examId']! as String,
      completedAt: DateTime.parse(doc['completedAt']! as String),
      topicScoresJson: doc['topicScoresJson']! as String,
      syncState: 'synced',
    );
  }

  AssessmentResultsLocalCompanion toCompanion(AssessmentResultLocalRow row) {
    return AssessmentResultsLocalCompanion(
      examId: Value(row.examId),
      completedAt: Value(row.completedAt),
      topicScoresJson: Value(row.topicScoresJson),
      syncState: Value(row.syncState),
    );
  }
}
