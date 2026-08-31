import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/answer_reveal.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const question = Question(
    id: 'q_1',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 'topic_1',
    language: 'en',
    stem: 'Which is correct?',
    choices: [
      Choice(
        id: 'c_a',
        label: 'A',
        text: 'Option A',
        isCorrect: false,
        rationale: 'A is incorrect because reason A.',
      ),
      Choice(
        id: 'c_b',
        label: 'B',
        text: 'Option B',
        isCorrect: true,
      ),
    ],
    explanation: 'Only coefficients may be changed.',
  );

  testWidgets('a correct answer says so with its interval', (tester) async {
    await tester.pumpApp(
      const AnswerReveal(
        question: question,
        chosenChoiceId: 'c_b',
        proIsActive: false,
        nextReviewIntervalDays: 9,
      ),
    );

    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('back in 9 days'), findsOneWidget);
    expect(
      tester.getSemantics(
        find.bySemanticsLabel('Correct, back in 9 days'),
      ),
      matchesSemantics(
        label: 'Correct, back in 9 days',
        isLiveRegion: true,
      ),
    );
  });

  testWidgets('one day reads as tomorrow', (tester) async {
    await tester.pumpApp(
      const AnswerReveal(
        question: question,
        chosenChoiceId: 'c_b',
        proIsActive: false,
        nextReviewIntervalDays: 1,
      ),
    );

    expect(find.text('back tomorrow'), findsOneWidget);
  });

  testWidgets('a miss says Not this one', (tester) async {
    await tester.pumpApp(
      const AnswerReveal(
        question: question,
        chosenChoiceId: 'c_a',
        proIsActive: false,
        nextReviewIntervalDays: 1,
      ),
    );

    expect(find.text('Not this one'), findsOneWidget);
  });

  testWidgets('note A always renders, lettered for the answer', (tester) async {
    await tester.pumpApp(
      const AnswerReveal(
        question: question,
        chosenChoiceId: 'c_b',
        proIsActive: false,
        nextReviewIntervalDays: 9,
      ),
    );

    expect(find.text('the answer'), findsOneWidget);
    expect(find.text('Only coefficients may be changed.'), findsOneWidget);
  });

  testWidgets('note B renders for Pro on a miss', (tester) async {
    await tester.pumpApp(
      const AnswerReveal(
        question: question,
        chosenChoiceId: 'c_a',
        proIsActive: true,
        nextReviewIntervalDays: 1,
      ),
    );

    expect(find.text('what you picked'), findsOneWidget);
    expect(find.text('A is incorrect because reason A.'), findsOneWidget);
  });

  testWidgets('note B is absent for Free, with nothing in its place',
      (tester) async {
    await tester.pumpApp(
      const AnswerReveal(
        question: question,
        chosenChoiceId: 'c_a',
        proIsActive: false,
        nextReviewIntervalDays: 1,
      ),
    );

    expect(find.text('what you picked'), findsNothing);
    expect(find.textContaining('Pro'), findsNothing);
    expect(find.textContaining('Upgrade'), findsNothing);
  });

  testWidgets('note B is absent on a correct answer', (tester) async {
    await tester.pumpApp(
      const AnswerReveal(
        question: question,
        chosenChoiceId: 'c_b',
        proIsActive: true,
        nextReviewIntervalDays: 9,
      ),
    );

    expect(find.text('what you picked'), findsNothing);
  });

  testWidgets('note B is absent when the content has no rationale',
      (tester) async {
    const questionNoRationale = Question(
      id: 'q_2',
      version: 1,
      examIds: ['cse_prof'],
      topicId: 'topic_1',
      language: 'en',
      stem: 'Stem',
      choices: [
        Choice(
          id: 'c_a',
          label: 'A',
          text: 'Option A',
          isCorrect: false,
        ),
        Choice(
          id: 'c_b',
          label: 'B',
          text: 'Option B',
          isCorrect: true,
        ),
      ],
      explanation: 'Explanation',
    );

    await tester.pumpApp(
      const AnswerReveal(
        question: questionNoRationale,
        chosenChoiceId: 'c_a',
        proIsActive: true,
        nextReviewIntervalDays: 1,
      ),
    );

    expect(find.text('what you picked'), findsNothing);
  });
}
