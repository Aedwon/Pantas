import 'package:cse_cet_reviewer/core/sync/engine/collection_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry includes only app db user-data collections', () {
    expect(
      activeSyncCollections.map((entry) => entry.tableType).toList(),
      equals([
        'quiz_attempts',
        'assessments',
        'fsrs_cards',
        'lesson_progress',
        'preferences',
      ]),
    );
  });

  test('registry excludes content database tables', () {
    expect(
      syncCollections.map((entry) => entry.tableType),
      isNot(contains(startsWith('content_'))),
    );
  });

  test('registry marks study plan and mock exam attempts as future inactive',
      () {
    final inactive = syncCollections.where((entry) => !entry.isActive).toList();

    expect(inactive.map((entry) => entry.tableType), [
      'study_plan',
      'mock_exam_attempts',
    ]);
  });

  test('each active entry has table type subcollection and mapper', () {
    for (final entry in activeSyncCollections) {
      expect(entry.tableType, isNotEmpty);
      expect(entry.firestorePath, isNotEmpty);
      expect(entry.mapper, isNotNull);
    }
  });
}
