import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';

abstract interface class CustomTrackProjection {
  Future<void> upsert({required String examId, required String name});

  Future<void> delete(String examId);
}

class ContentDatabaseCustomTrackProjection implements CustomTrackProjection {
  ContentDatabaseCustomTrackProjection(
    this._contentDb, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ContentDatabase _contentDb;
  final DateTime Function() _now;

  @override
  Future<void> upsert({required String examId, required String name}) {
    return _contentDb.into(_contentDb.contentExams).insertOnConflictUpdate(
          ContentExamsCompanion.insert(
            id: examId,
            code: 'custom',
            name: name,
            shortName: name,
            language: 'en',
            ordering: 9999,
            isCustom: const Value(true),
            schemaVersion: 1,
            updatedAt: _now(),
          ),
        );
  }

  @override
  Future<void> delete(String examId) {
    return (_contentDb.delete(_contentDb.contentExams)
          ..where((row) => row.id.equals(examId)))
        .go();
  }
}
