import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many answered questions also belong to `examId`.
///
/// Measured from the student's own attempts, which is why the number may be
/// printed. Nothing here is inferred.
final carryableCountProvider =
    FutureProvider.family<int, String>((ref, examId) async {
  final db = ref.watch(appDatabaseProvider);
  final contentDb = ref.watch(contentDatabaseProvider);
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

  // Which exams a question belongs to is a table of its own now, not a JSON
  // column, so the exam filter is part of the query rather than a loop.
  final tagged = await (contentDb.select(contentDb.contentQuestionExams)
        ..where(
          (qe) =>
              qe.questionId.isIn(answeredQuestionIds) &
              qe.examId.equals(examId),
        ))
      .get();

  return tagged.length;
});
