import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/debrief_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  for (final revised in [false, true]) {
    test(
        'completed review rejects '
        '${revised ? 'revised' : 'missing'} original content', () async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
        await content.close();
      });
      await seedContentExam(content, examId: 'e');
      await seedContentSubject(content, examId: 'e', subjectId: 's');
      await seedContentTopic(content, subjectId: 's', topicId: 't');
      await seedContentQuestion(
        content,
        questionId: 'q1',
        topicId: 't',
        examId: 'e',
      );
      if (revised) {
        await seedContentQuestion(
          content,
          questionId: 'q2',
          topicId: 't',
          examId: 'e',
        );
      }
      final at = DateTime.utc(2026, 10, 16);
      final attempt = Attempt(
        id: 'a',
        examId: 'e',
        startedAt: at,
        completedAt: at.add(const Duration(minutes: 1)),
        items: [
          const AttemptItem(
            questionId: 'q1',
            questionVersion: 1,
            chosenChoiceId: 'q1_a',
            correctChoiceId: 'q1_a',
            responseMs: 1,
          ),
          AttemptItem(
            questionId: 'q2',
            questionVersion: revised ? 2 : 1,
            chosenChoiceId: 'q2_a',
            correctChoiceId: 'q2_a',
            responseMs: 1,
          ),
        ],
      );
      await expectLater(
        container.read(
          sessionDebriefProvider(
            (
              attemptId: 'a',
              proIsActive: false,
              sessionOverride: null,
              attemptOverride: attempt
            ),
          ).future,
        ),
        throwsStateError,
      );
    });
  }
}
