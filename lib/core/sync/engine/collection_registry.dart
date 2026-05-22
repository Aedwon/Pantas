import 'package:cse_cet_reviewer/core/sync/mapping/sync_mapper.dart';

class SyncCollectionEntry {
  const SyncCollectionEntry({
    required this.tableType,
    required this.firestorePath,
    required this.mapper,
    this.isActive = true,
  });

  final String tableType;
  final String firestorePath;
  final SyncMapper mapper;
  final bool isActive;
}

const syncCollections = <SyncCollectionEntry>[
  SyncCollectionEntry(
    tableType: 'quiz_attempts',
    firestorePath: 'quiz_attempts',
    mapper: PlaceholderSyncMapper('quiz_attempts'),
  ),
  SyncCollectionEntry(
    tableType: 'assessments',
    firestorePath: 'assessments',
    mapper: PlaceholderSyncMapper('assessments'),
  ),
  SyncCollectionEntry(
    tableType: 'fsrs_cards',
    firestorePath: 'fsrs_cards',
    mapper: PlaceholderSyncMapper('fsrs_cards'),
  ),
  SyncCollectionEntry(
    tableType: 'lesson_progress',
    firestorePath: 'lesson_progress',
    mapper: PlaceholderSyncMapper('lesson_progress'),
  ),
  SyncCollectionEntry(
    tableType: 'preferences',
    firestorePath: 'preferences',
    mapper: PlaceholderSyncMapper('preferences'),
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
    mapper: PlaceholderSyncMapper('mock_exam_attempts'),
    isActive: false,
  ),
];

final activeSyncCollections =
    syncCollections.where((entry) => entry.isActive).toList(growable: false);
