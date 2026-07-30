import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';
import 'package:drift/drift.dart';

class AttemptMapper implements SyncMapper {
  const AttemptMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'quiz_attempts';

  String documentId(AttemptLocalRow row) => row.id;

  Map<String, Object?> toFirestore(
    AttemptLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'id': row.id,
      'examId': row.examId,
      'startedAt': row.startedAt.toUtc().toIso8601String(),
      'completedAt': row.completedAt?.toUtc().toIso8601String(),
      'origin': row.origin,
      'itemsJson': row.itemsJson,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  AttemptLocalRow fromFirestore(Map<String, Object?> doc) {
    return AttemptLocalRow(
      id: doc['id']! as String,
      examId: doc['examId']! as String,
      startedAt: DateTime.parse(doc['startedAt']! as String),
      completedAt: _dateTimeOrNull(doc['completedAt']),
      origin: doc['origin'] as String? ?? 'today_topic',
      itemsJson: doc['itemsJson']! as String,
      syncState: 'synced',
      syncAttempts: 0,
    );
  }

  AttemptsLocalCompanion toCompanion(AttemptLocalRow row) {
    return AttemptsLocalCompanion(
      id: Value(row.id),
      examId: Value(row.examId),
      startedAt: Value(row.startedAt),
      completedAt: Value(row.completedAt),
      origin: Value(row.origin),
      itemsJson: Value(row.itemsJson),
      syncState: Value(row.syncState),
      syncAttempts: Value(row.syncAttempts),
      lastSyncError: Value(row.lastSyncError),
    );
  }

  DateTime? _dateTimeOrNull(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
