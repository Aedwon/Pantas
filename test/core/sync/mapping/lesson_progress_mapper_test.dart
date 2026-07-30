import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/lesson_progress_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lesson progress mapper uses lessonId as document id', () {
    final row = LessonProgressLocalRow(
      lessonId: 'lesson_1',
      readAt: DateTime.utc(2026, 5, 18),
      syncState: 'pending',
    );

    expect(const LessonProgressMapper().documentId(row), 'lesson_1');
  });

  test('lesson progress mapper omits local sync state', () {
    final row = LessonProgressLocalRow(
      lessonId: 'lesson_1',
      readAt: DateTime.utc(2026, 5, 18),
      syncState: 'failed',
    );

    final doc = const LessonProgressMapper().toFirestore(
      row,
      updatedAt: DateTime.utc(2026, 5, 18, 2),
      originDeviceId: 'device-1',
    );

    expect(doc, isNot(contains('syncState')));
    expect(const LessonProgressMapper().fromFirestore(doc).syncState, 'synced');
  });
}
