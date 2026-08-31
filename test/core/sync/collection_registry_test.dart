import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';

void main() {
  const requiredActive = <String>{
    'quiz_attempts',
    'assessments',
    'fsrs_cards',
    'lesson_progress',
    'lesson_bookmarks',
    'question_flags',
    'mock_exam_attempts',
    'review_logs',
    'track_scope',
    'custom_blueprints',
  };

  test('active registry is exactly the ten approved mutation sources', () {
    final actual =
        activeSyncCollections.map((entry) => entry.tableType).toSet();

    expect(activeSyncCollections, hasLength(10));
    expect(actual, requiredActive);
  });

  test('preferences and study plan are not active row collections', () {
    final preferences = syncCollections.singleWhere(
      (entry) => entry.tableType == 'preferences',
    );
    final studyPlan = syncCollections.singleWhere(
      (entry) => entry.tableType == 'study_plan',
    );

    expect(preferences.isActive, isFalse);
    expect(studyPlan.isActive, isFalse);
  });

  test('registry excludes content database tables', () {
    expect(
      syncCollections.map((entry) => entry.tableType),
      isNot(contains(startsWith('content_'))),
    );
  });

  test('mock exam collection accepts only terminal states', () {
    final entry = syncCollections.singleWhere(
      (entry) => entry.tableType == 'mock_exam_attempts',
    );

    expect(entry.shouldSync({'status': 'in_progress'}), isFalse);
    expect(entry.shouldSync({'status': 'completed'}), isTrue);
    expect(entry.shouldSync({'status': 'discarded'}), isTrue);
    expect(entry.shouldSync({'status': 'forfeited'}), isTrue);
  });

  test('every active collection has its mapper and remote adapter', () {
    for (final entry in activeSyncCollections) {
      expect(entry.firestorePath, entry.tableType);
      expect(entry.mapper.name, entry.tableType);
      expect(entry.adapter.collection, entry.tableType);
    }
  });
}
