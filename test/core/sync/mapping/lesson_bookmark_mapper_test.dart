import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/mapping/lesson_bookmark_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = LessonBookmarkMapper();

  test('a bookmark row becomes a firestore document', () {
    final doc = mapper.toFirestore(
      LessonBookmarkLocalRow(
        lessonId: 'l1',
        markedAt: DateTime.utc(2026, 8, 2, 9, 30),
        sortIndex: 3,
        syncState: 'pending',
      ),
      updatedAt: DateTime.utc(2026, 8, 2, 10),
      originDeviceId: 'device-1',
    );

    expect(doc, {
      'lessonId': 'l1',
      'markedAt': '2026-08-02T09:30:00.000Z',
      'sortIndex': 3,
      'updatedAt': '2026-08-02T10:00:00.000Z',
      'originDeviceId': 'device-1',
      'schemaVersion': 1,
    });
  });

  test('a firestore document becomes a synced bookmark row', () {
    final row = mapper.fromFirestore({
      'lessonId': 'l1',
      'markedAt': '2026-08-02T09:30:00.000Z',
      'sortIndex': null,
    });

    expect(row.lessonId, 'l1');
    expect(row.markedAt, DateTime.utc(2026, 8, 2, 9, 30));
    expect(row.sortIndex, isNull);
    expect(row.syncState, 'synced');
  });

  test('the document id is the lesson id', () {
    expect(
      mapper.documentId(
        LessonBookmarkLocalRow(
          lessonId: 'l7',
          markedAt: DateTime.utc(2026, 8, 2),
          syncState: 'pending',
        ),
      ),
      'l7',
    );
  });

  test('lesson bookmarks are an active sync collection', () {
    final entry = activeSyncCollections
        .firstWhere((entry) => entry.tableType == 'lesson_bookmarks');

    expect(entry.firestorePath, 'lesson_bookmarks');
    expect(entry.mapper, isA<LessonBookmarkMapper>());
  });
}
