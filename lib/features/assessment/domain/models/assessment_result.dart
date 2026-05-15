import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';

class AssessmentResult {
  const AssessmentResult({
    required this.examId,
    required this.completedAt,
    required this.topicMasteries,
  });

  factory AssessmentResult.fromRow(
    AssessmentResultLocalRow row,
    List<Topic> topics,
  ) {
    final raw =
        (jsonDecode(row.topicScoresJson) as List).cast<Map<String, dynamic>>();
    final topicById = {for (final t in topics) t.id: t};
    final masteries = raw
        .where((s) => topicById.containsKey(s['topicId'] as String))
        .map(
          (s) => TopicMastery(
            topic: topicById[s['topicId'] as String]!,
            correct: s['correct'] as int,
            total: s['total'] as int,
          ),
        )
        .toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    return AssessmentResult(
      examId: row.examId,
      completedAt: row.completedAt,
      topicMasteries: masteries,
    );
  }

  final ExamId examId;
  final DateTime completedAt;

  /// Sorted weakest-first (ascending accuracy).
  final List<TopicMastery> topicMasteries;
}
