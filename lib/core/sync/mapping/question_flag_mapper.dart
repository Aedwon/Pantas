import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';
import 'package:drift/drift.dart';

class QuestionFlagMapper implements SyncMapper {
  const QuestionFlagMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'question_flags';

  String documentId(QuestionFlagLocalRow row) => row.questionId;

  Map<String, Object?> toFirestore(
    QuestionFlagLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'questionId': row.questionId,
      'flaggedAt': row.flaggedAt.toUtc().toIso8601String(),
      'sortIndex': row.sortIndex,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  QuestionFlagLocalRow fromFirestore(Map<String, Object?> doc) {
    return QuestionFlagLocalRow(
      questionId: doc['questionId']! as String,
      flaggedAt: DateTime.parse(doc['flaggedAt']! as String),
      sortIndex: doc['sortIndex'] as int?,
      syncState: 'synced',
    );
  }

  QuestionFlagsLocalCompanion toCompanion(QuestionFlagLocalRow row) {
    return QuestionFlagsLocalCompanion(
      questionId: Value(row.questionId),
      flaggedAt: Value(row.flaggedAt),
      sortIndex: Value(row.sortIndex),
      syncState: Value(row.syncState),
    );
  }
}
