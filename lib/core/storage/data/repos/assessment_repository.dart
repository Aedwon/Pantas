import 'dart:convert';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';

class TopicScore {
  const TopicScore({
    required this.topicId,
    required this.correct,
    required this.total,
  });

  final String topicId;
  final int correct;
  final int total;

  Map<String, dynamic> toJson() => {
        'topicId': topicId,
        'correct': correct,
        'total': total,
      };
}

class AssessmentRepository {
  AssessmentRepository(
    this._db, {
    LocalSyncMutationRecorder? syncRecorder,
  }) : _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db);

  final AppDatabase _db;
  final LocalSyncMutationRecorder _syncRecorder;

  Future<void> saveResult(
    ExamId examId,
    DateTime completedAt,
    List<TopicScore> scores,
  ) =>
      _syncRecorder.runRecorded(
        collection: 'assessments',
        rowId: examId,
        op: SyncLocalMutationOp.upsert,
        mutate: () =>
            _db.into(_db.assessmentResultsLocal).insertOnConflictUpdate(
                  AssessmentResultsLocalCompanion.insert(
                    examId: examId,
                    completedAt: completedAt,
                    topicScoresJson:
                        jsonEncode(scores.map((s) => s.toJson()).toList()),
                  ),
                ),
      );

  Future<AssessmentResultLocalRow?> resultForExam(ExamId examId) async {
    return (_db.select(_db.assessmentResultsLocal)
          ..where((r) => r.examId.equals(examId)))
        .getSingleOrNull();
  }

  Future<bool> hasCompletedForExam(ExamId examId) async {
    final row = await resultForExam(examId);
    return row != null;
  }
}
