import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';

final assessmentResultProvider =
    FutureProvider.family<AssessmentResult?, ExamId>((ref, examId) async {
  final row =
      await ref.watch(assessmentRepositoryProvider).resultForExam(examId);
  if (row == null) return null;
  final topics = await ref.watch(scopedTopicsProvider(examId).future);
  return AssessmentResult.fromRow(row, topics);
});
