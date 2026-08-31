import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';

class ReviewLogMapper implements SyncMapper {
  const ReviewLogMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'review_logs';

  String documentId(ReviewLogRow row) => row.id;

  Map<String, Object?> toFirestore(
    ReviewLogRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'id': row.id,
      'questionId': row.questionId,
      'rating': row.rating,
      'state': row.state,
      'due': row.due.toUtc().toIso8601String(),
      'stability': row.stability,
      'difficulty': row.difficulty,
      'elapsedDays': row.elapsedDays,
      'lastElapsedDays': row.lastElapsedDays,
      'scheduledDays': row.scheduledDays,
      'review': row.review.toUtc().toIso8601String(),
      'durationMs': row.durationMs,
      'isCorrect': row.isCorrect,
      'heuristicVersion': row.heuristicVersion,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  ReviewLogRow fromFirestore(Map<String, Object?> doc) {
    return ReviewLogRow(
      id: doc['id']! as String,
      questionId: doc['questionId']! as String,
      rating: doc['rating']! as int,
      state: doc['state']! as int,
      due: DateTime.parse(doc['due']! as String),
      stability: (doc['stability']! as num).toDouble(),
      difficulty: (doc['difficulty']! as num).toDouble(),
      elapsedDays: (doc['elapsedDays']! as num).toDouble(),
      lastElapsedDays: (doc['lastElapsedDays']! as num).toDouble(),
      scheduledDays: (doc['scheduledDays']! as num).toDouble(),
      review: DateTime.parse(doc['review']! as String),
      durationMs: doc['durationMs']! as int,
      isCorrect: doc['isCorrect']! as bool,
      heuristicVersion: doc['heuristicVersion'] as int? ?? 1,
    );
  }

  ReviewLogsCompanion toCompanion(ReviewLogRow row) {
    return ReviewLogsCompanion(
      id: Value(row.id),
      questionId: Value(row.questionId),
      rating: Value(row.rating),
      state: Value(row.state),
      due: Value(row.due),
      stability: Value(row.stability),
      difficulty: Value(row.difficulty),
      elapsedDays: Value(row.elapsedDays),
      lastElapsedDays: Value(row.lastElapsedDays),
      scheduledDays: Value(row.scheduledDays),
      review: Value(row.review),
      durationMs: Value(row.durationMs),
      isCorrect: Value(row.isCorrect),
      heuristicVersion: Value(row.heuristicVersion),
    );
  }
}
