import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:flutter_test/flutter_test.dart';

Question question(String id, {String topicId = 'topic_algebra'}) => Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: topicId,
      language: 'en',
      stem: 'stem $id',
      choices: const [
        Choice(id: 'c_a', label: 'A', text: 'a', isCorrect: true),
        Choice(id: 'c_b', label: 'B', text: 'b', isCorrect: false),
      ],
      explanation: 'because',
    );

List<Question> many(String prefix, int count,
        {String topicId = 'topic_algebra'}) =>
    [for (var i = 0; i < count; i++) question('$prefix$i', topicId: topicId)];

void main() {
  QuizPreferences prefs({
    int sessionLength = 10,
    QuizOrdering ordering = QuizOrdering.blocked,
  }) =>
      QuizPreferences(
        sessionLength: sessionLength,
        ordering: ordering,
        newCardCap: 10,
      );

  test('an empty backlog makes an empty plan', () {
    final plan = BuildTodayPlan.call(
      due: const [],
      weakness: const [],
      fresh: const [],
      allQuestions: const [],
      preferences: prefs(),
    );

    expect(plan.isEmpty, isTrue);
    expect(plan.length, 0);
  });

  test('the plan is no longer than the session length', () {
    final due = many('d_', 40);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: const [],
      fresh: const [],
      allQuestions: due,
      preferences: prefs(),
    );

    expect(plan.length, 10);
  });

  test('the counts add up to the length of the plan', () {
    final due = many('d_', 20);
    final weakness = many('w_', 20);
    final fresh = many('f_', 20);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: weakness,
      fresh: fresh,
      allQuestions: [...due, ...weakness, ...fresh],
      preferences: prefs(),
    );

    expect(
      plan.dueCount + plan.weaknessCount + plan.freshCount,
      equals(plan.length),
    );
  });

  test('due leads the composition when there is due work', () {
    final due = many('d_', 20);
    final weakness = many('w_', 20);
    final fresh = many('f_', 20);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: weakness,
      fresh: fresh,
      allQuestions: [...due, ...weakness, ...fresh],
      preferences: prefs(),
    );

    expect(plan.dueCount, 6);
    expect(plan.weaknessCount, 3);
    expect(plan.freshCount, 1);
  });

  test('the plan carries the topic it is named after', () {
    final due = many('d_', 12);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: const [],
      fresh: const [],
      allQuestions: due,
      preferences: prefs(),
      topicId: 'topic_algebra',
      topicName: 'Algebra',
    );

    expect(plan.topicId, 'topic_algebra');
    expect(plan.topicName, 'Algebra');
  });

  test('the interleaved tail draws from other topics', () {
    final due = [
      ...many('d_', 5),
      ...many('o_', 12, topicId: 'topic_geometry'),
    ];

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: const [],
      fresh: const [],
      allQuestions: due,
      preferences: prefs(ordering: QuizOrdering.interleavedTail),
      topicId: 'topic_algebra',
      topicName: 'Algebra',
    );

    expect(
      plan.questions.map((q) => q.topicId).toSet(),
      contains('topic_geometry'),
    );
  });

  test('all-due length asks for everything available', () {
    final due = many('d_', 14);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: const [],
      fresh: const [],
      allQuestions: due,
      preferences: prefs(
        sessionLength: QuizPreferences.allDueSessionLength,
      ),
    );

    expect(plan.length, 14);
  });
}
