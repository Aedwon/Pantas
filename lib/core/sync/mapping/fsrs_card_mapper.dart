import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/sync_mapper.dart';
import 'package:drift/drift.dart';

class FsrsCardMapper implements SyncMapper {
  const FsrsCardMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'fsrs_cards';

  String documentId(ReviewStateLocalRow row) => row.questionId;

  Map<String, Object?> toFirestore(
    ReviewStateLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'questionId': row.questionId,
      'questionVersion': row.questionVersion,
      'stage': row.stage,
      'stability': row.stability,
      'difficulty': row.difficulty,
      'due': row.due.toUtc().toIso8601String(),
      'lastReview': row.lastReview.toUtc().toIso8601String(),
      'reps': row.reps,
      'lapses': row.lapses,
      'elapsedDays': row.elapsedDays,
      'scheduledDays': row.scheduledDays,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  ReviewStateLocalRow fromFirestore(Map<String, Object?> doc) {
    return ReviewStateLocalRow(
      questionId: doc['questionId']! as String,
      questionVersion: doc['questionVersion']! as int,
      stage: doc['stage']! as String,
      stability: (doc['stability']! as num).toDouble(),
      difficulty: (doc['difficulty']! as num).toDouble(),
      due: DateTime.parse(doc['due']! as String),
      lastReview: DateTime.parse(doc['lastReview']! as String),
      reps: doc['reps']! as int,
      lapses: doc['lapses']! as int,
      elapsedDays: (doc['elapsedDays']! as num).toDouble(),
      scheduledDays: (doc['scheduledDays']! as num).toDouble(),
      dirty: false,
    );
  }

  ReviewStateLocalCompanion toCompanion(ReviewStateLocalRow row) {
    return ReviewStateLocalCompanion(
      questionId: Value(row.questionId),
      questionVersion: Value(row.questionVersion),
      stage: Value(row.stage),
      stability: Value(row.stability),
      difficulty: Value(row.difficulty),
      due: Value(row.due),
      lastReview: Value(row.lastReview),
      reps: Value(row.reps),
      lapses: Value(row.lapses),
      elapsedDays: Value(row.elapsedDays),
      scheduledDays: Value(row.scheduledDays),
      dirty: Value(row.dirty),
    );
  }
}
