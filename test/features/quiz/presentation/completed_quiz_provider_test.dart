import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/completed_quiz_provider.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('completed data keeps original order and actual subjects and source',
      () async {
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
    await seedContentSubject(
      content,
      subjectId: 's',
      examId: 'e',
      name: 'Mathematics',
    );
    await seedContentTopic(
      content,
      topicId: 't',
      subjectId: 's',
      name: 'Algebra',
    );
    for (final id in ['q1', 'q2']) {
      await seedContentQuestion(
        content,
        questionId: id,
        topicId: 't',
        examId: 'e',
      );
    }
    final attempt = Attempt(
      id: 'a',
      examId: 'e',
      startedAt: DateTime.utc(2026),
      completedAt: DateTime.utc(2026, 1, 2),
      origin: 'drill',
      items: [
        for (final id in ['q2', 'q1'])
          AttemptItem(
            questionId: id,
            questionVersion: 1,
            chosenChoiceId: '${id}_a',
            correctChoiceId: '${id}_a',
            responseMs: 12,
          ),
      ],
    );
    for (final (origin, custom, label) in [
      ('drill', false, 'Quiz'),
      ('drill', true, 'Your quiz · Algebra'),
      ('flagged', false, 'Flagged questions'),
      ('retake', false, 'Your past mistakes'),
      ('today_topic', false, "Today's session"),
    ]) {
      final data = await container.read(
        completedQuizProvider(
          (
            boundary: Object(),
            attemptId: 'a',
            session: null,
            attempt: attempt.copyWith(origin: origin),
            custom: custom
          ),
        ).future,
      );
      expect(data.session.questions.map((q) => q.id), ['q2', 'q1']);
      expect(data.session.outcomes.map((o) => o.questionId), ['q2', 'q1']);
      expect(data.subjectNames, {'t': 'Mathematics'});
      expect(data.sourceLine, label);
      expect(data.attempt.completedAt, attempt.completedAt);
    }
  });
}
