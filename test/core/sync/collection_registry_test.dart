import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';

void main() {
  test('registry includes only app db user-data collections', () {
    expect(
      activeSyncCollections.map((entry) => entry.tableType).toList(),
      equals([
        'quiz_attempts',
        'assessments',
        'fsrs_cards',
        'lesson_progress',
        'lesson_bookmarks',
        'question_flags',
        'preferences',
        'mock_exam_attempts',
      ]),
    );
  });

  test('registry excludes content database tables', () {
    expect(
      syncCollections.map((entry) => entry.tableType),
      isNot(contains(startsWith('content_'))),
    );
  });

  test('registry marks study plan as future inactive', () {
    final inactive = syncCollections.where((entry) => !entry.isActive).toList();

    expect(inactive.map((entry) => entry.tableType), ['study_plan']);
  });

  test('registry activates mock exam attempts with terminal predicate', () {
    final entry = syncCollections.singleWhere(
      (entry) => entry.tableType == 'mock_exam_attempts',
    );

    expect(entry.isActive, isTrue);
    expect(entry.shouldSync({'status': 'in_progress'}), isFalse);
    expect(entry.shouldSync({'status': 'completed'}), isTrue);
    expect(entry.shouldSync({'status': 'discarded'}), isTrue);
    expect(entry.shouldSync({'status': 'forfeited'}), isTrue);
  });

  test('each active entry has table type subcollection and mapper', () {
    for (final entry in activeSyncCollections) {
      expect(entry.tableType, isNotEmpty);
      expect(entry.firestorePath, isNotEmpty);
      expect(entry.mapper, isNotNull);
    }
  });
}
