import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many answered questions also belong to `examId`.
///
/// Measured from the student's own attempts, which is why the number may be
/// printed. Nothing here is inferred.
final carryableCountProvider =
    FutureProvider.family<int, String>((ref, examId) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.select(db.attemptsLocal).get();

  final answeredQuestionIds = <String>{};
  for (final row in rows) {
    final items =
        (jsonDecode(row.itemsJson) as List).cast<Map<String, dynamic>>();
    for (final item in items) {
      final qId = item['questionId'] as String?;
      if (qId != null) {
        answeredQuestionIds.add(qId);
      }
    }
  }

  if (answeredQuestionIds.isEmpty) {
    return 0;
  }

// Exam membership is corpus, so the count comes from the content repository
  // rather than from this feature reaching into the content database itself.
  return ref.watch(contentRepositoryProvider).countQuestionsTaggedForExam(
        questionIds: answeredQuestionIds,
        examId: examId,
      );
});
