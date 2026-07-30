import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assessmentResultProvider =
    FutureProvider.family<AssessmentResult?, ExamId>((ref, examId) async {
  final row =
      await ref.watch(assessmentRepositoryProvider).resultForExam(examId);
  if (row == null) return null;
  final topics =
      await ref.watch(contentRepositoryProvider).topicsByExam(examId);
  return AssessmentResult.fromRow(row, topics);
});
