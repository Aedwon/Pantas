import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';

/// How many answered questions also belong to `examId`.
///
/// Measured from the student's own attempts, which is why the number may be
/// printed. Nothing here is inferred.
///
/// On the phone the student's answers are in the local database. On the web the
/// server owns the study record and this browser holds none of the history, so
/// the server counts them from the stored answers.
final carryableCountProvider =
    FutureProvider.family<int, String>((ref, examId) async {
  if (ref.read(studyUsesServerProvider)) {
    final auth = await ref.read(authStateProvider.future);
    final uid = switch (auth) {
      SignedInAuthState(:final user) => user.uid,
      AnonymousAuthState(:final uid) => uid,
      _ => null,
    };
    if (uid == null) return 0;
    try {
      final reply = await ref.read(studyApiProvider).request(
            'getCarryableCount',
            expectedUid: uid,
            examId: examId,
          );
      final count = reply['count'];
      if (count is! int || count < 0) {
        throw const FormatException('Invalid carryable count');
      }
      return count;
    } on Object catch (error, stack) {
      // The prompt is optional and the exam switch must not fail because the
      // server could not be reached. With no count there is no prompt, and
      // the carry-over setting keeps its value; Settings still has the row.
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
      return 0;
    }
  }
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
