import 'package:pantas/core/sync/engine/sync_collection_adapter.dart';
import 'package:pantas/core/sync/mapping/assessment_mapper.dart';
import 'package:pantas/core/sync/mapping/attempt_mapper.dart';
import 'package:pantas/core/sync/mapping/custom_blueprint_mapper.dart';
import 'package:pantas/core/sync/mapping/fsrs_card_mapper.dart';
import 'package:pantas/core/sync/mapping/lesson_bookmark_mapper.dart';
import 'package:pantas/core/sync/mapping/lesson_progress_mapper.dart';
import 'package:pantas/core/sync/mapping/mock_attempt_mapper.dart';
import 'package:pantas/core/sync/mapping/preferences_mapper.dart';
import 'package:pantas/core/sync/mapping/question_flag_mapper.dart';
import 'package:pantas/core/sync/mapping/review_log_mapper.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';

class SyncCollectionEntry {
  const SyncCollectionEntry({
    required this.tableType,
    required this.firestorePath,
    required this.mapper,
    required this.adapter,
    this.isActive = true,
    this.shouldSync = _alwaysSync,
  });

  final String tableType;
  final String firestorePath;
  final SyncMapper mapper;
  final SyncCollectionAdapter adapter;
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
    adapter: SyncCollectionAdapter('quiz_attempts'),
  ),
  SyncCollectionEntry(
    tableType: 'assessments',
    firestorePath: 'assessments',
    mapper: AssessmentMapper(),
    adapter: SyncCollectionAdapter('assessments'),
  ),
  SyncCollectionEntry(
    tableType: 'fsrs_cards',
    firestorePath: 'fsrs_cards',
    mapper: FsrsCardMapper(),
    adapter: SyncCollectionAdapter('fsrs_cards'),
  ),
  SyncCollectionEntry(
    tableType: 'lesson_progress',
    firestorePath: 'lesson_progress',
    mapper: LessonProgressMapper(),
    adapter: SyncCollectionAdapter('lesson_progress'),
  ),
  SyncCollectionEntry(
    tableType: 'lesson_bookmarks',
    firestorePath: 'lesson_bookmarks',
    mapper: LessonBookmarkMapper(),
    adapter: SyncCollectionAdapter('lesson_bookmarks'),
  ),
  SyncCollectionEntry(
    tableType: 'question_flags',
    firestorePath: 'question_flags',
    mapper: QuestionFlagMapper(),
    adapter: SyncCollectionAdapter('question_flags'),
  ),
  SyncCollectionEntry(
    tableType: 'mock_exam_attempts',
    firestorePath: 'mock_exam_attempts',
    mapper: MockAttemptMapper(),
    adapter: SyncCollectionAdapter('mock_exam_attempts'),
    shouldSync: _isTerminalMockAttempt,
  ),
  SyncCollectionEntry(
    tableType: 'review_logs',
    firestorePath: 'review_logs',
    mapper: ReviewLogMapper(),
    adapter: SyncCollectionAdapter('review_logs'),
  ),
  SyncCollectionEntry(
    tableType: 'track_scope',
    firestorePath: 'track_scope',
    mapper: TrackScopeMapper(),
    adapter: SyncCollectionAdapter('track_scope'),
  ),
  SyncCollectionEntry(
    tableType: 'custom_blueprints',
    firestorePath: 'custom_blueprints',
    mapper: CustomBlueprintMapper(),
    adapter: SyncCollectionAdapter('custom_blueprints'),
  ),
  SyncCollectionEntry(
    tableType: 'preferences',
    firestorePath: 'preferences',
    mapper: PreferencesMapper(),
    adapter: SyncCollectionAdapter('preferences'),
    isActive: false,
  ),
  SyncCollectionEntry(
    tableType: 'study_plan',
    firestorePath: 'study_plan',
    mapper: PlaceholderSyncMapper('study_plan'),
    adapter: SyncCollectionAdapter('study_plan'),
    isActive: false,
  ),
];

final activeSyncCollections =
    syncCollections.where((entry) => entry.isActive).toList(growable: false);
