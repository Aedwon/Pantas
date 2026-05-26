import 'package:cse_cet_reviewer/core/sync/mapping/assessment_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/attempt_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/fsrs_card_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/lesson_progress_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/mock_attempt_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/preferences_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/sync_mapper.dart';

class SyncCollectionEntry {
  const SyncCollectionEntry({
    required this.tableType,
    required this.firestorePath,
    required this.mapper,
    this.isActive = true,
    this.shouldSync = _alwaysSync,
  });

  final String tableType;
  final String firestorePath;
  final SyncMapper mapper;
  final bool isActive;
  final bool Function(Map<String, Object?> row) shouldSync;
}

bool _alwaysSync(Map<String, Object?> row) => true;

bool _isTerminalMockAttempt(Map<String, Object?> row) {
  return switch (row['status']) {
    'completed' || 'discarded' || 'forfeited' => true,
    _ => false,
  };
}

const syncCollections = <SyncCollectionEntry>[
  SyncCollectionEntry(
    tableType: 'quiz_attempts',
    firestorePath: 'quiz_attempts',
    mapper: AttemptMapper(),
  ),
  SyncCollectionEntry(
    tableType: 'assessments',
    firestorePath: 'assessments',
    mapper: AssessmentMapper(),
  ),
  SyncCollectionEntry(
    tableType: 'fsrs_cards',
    firestorePath: 'fsrs_cards',
    mapper: FsrsCardMapper(),
  ),
  SyncCollectionEntry(
    tableType: 'lesson_progress',
    firestorePath: 'lesson_progress',
    mapper: LessonProgressMapper(),
  ),
  SyncCollectionEntry(
    tableType: 'preferences',
    firestorePath: 'preferences',
    mapper: PreferencesMapper(),
  ),
  SyncCollectionEntry(
    tableType: 'study_plan',
    firestorePath: 'study_plan',
    mapper: PlaceholderSyncMapper('study_plan'),
    isActive: false,
  ),
  SyncCollectionEntry(
    tableType: 'mock_exam_attempts',
    firestorePath: 'mock_exam_attempts',
    mapper: MockAttemptMapper(),
    shouldSync: _isTerminalMockAttempt,
  ),
];

final activeSyncCollections =
    syncCollections.where((entry) => entry.isActive).toList(growable: false);
