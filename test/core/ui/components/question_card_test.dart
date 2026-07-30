import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/answer_row.dart';
import 'package:pantas/core/ui/components/portable_text_renderer.dart';
import 'package:pantas/core/ui/components/question_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const sampleQuestion = Question(
    id: 'q_1',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 'topic_1',
    language: 'en',
    stem: r'What is $F_{net} = ma$?',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'the wrong one', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'the right one', isCorrect: true),
      Choice(
        id: 'c_c',
        label: 'C',
        text: 'another wrong one',
        isCorrect: false,
      ),
    ],
    explanation: 'Newton second law.',
  );

  testWidgets('an unanswered card offers every choice plainly', (tester) async {
    await tester.pumpApp(
      QuestionCard(
        question: sampleQuestion,
        onAnswer: (_) {},
      ),
    );

    final rows = tester.widgetList<AnswerRow>(find.byType(AnswerRow));
    expect(rows.every((row) => row.state == AnswerRowState.plain), isTrue);
    expect(rows.every((row) => row.onTap != null), isTrue);
  });

  testWidgets('a right answer marks the chosen row correct', (tester) async {
    await tester.pumpApp(
      QuestionCard(
        question: sampleQuestion,
        chosenChoiceId: 'c_b',
        onAnswer: (_) {},
        revealed: true,
      ),
    );

    final chosen = tester.widget<AnswerRow>(
      find.widgetWithText(AnswerRow, 'the right one'),
    );
    expect(chosen.state, AnswerRowState.correct);
  });

  testWidgets('a wrong answer marks both rows', (tester) async {
    await tester.pumpApp(
      QuestionCard(
        question: sampleQuestion,
        chosenChoiceId: 'c_a',
        onAnswer: (_) {},
        revealed: true,
      ),
    );

    expect(
      tester
          .widget<AnswerRow>(find.widgetWithText(AnswerRow, 'the wrong one'))
          .state,
      AnswerRowState.incorrect,
    );
    expect(
      tester
          .widget<AnswerRow>(find.widgetWithText(AnswerRow, 'the right one'))
          .state,
      AnswerRowState.correctMissed,
    );
  });

  testWidgets('revealed rows cannot be answered again', (tester) async {
    await tester.pumpApp(
      QuestionCard(
        question: sampleQuestion,
        chosenChoiceId: 'c_b',
        onAnswer: (_) {},
        revealed: true,
      ),
    );

    final rows = tester.widgetList<AnswerRow>(find.byType(AnswerRow));
    expect(rows.every((row) => row.onTap == null), isTrue);
  });

  testWidgets('the stem renders through the shared renderer', (tester) async {
    await tester.pumpApp(
      QuestionCard(
        question: sampleQuestion,
        onAnswer: (_) {},
      ),
    );

    expect(find.byType(PortableTextRenderer), findsOneWidget);
  });

  testWidgets('a passage renders above the question when attached',
      (tester) async {
    const samplePassage = Passage(
      id: 'pas_1',
      topicId: 'topic_1',
      title: 'Passage Title',
      body: 'Passage Body Content',
      language: 'en',
      wordCount: 10,
    );

    await tester.pumpApp(
      QuestionCard(
        question: sampleQuestion,
        passage: samplePassage,
        onAnswer: (_) {},
      ),
    );

    expect(find.text('Passage Title'), findsOneWidget);
    expect(find.text('Passage Body Content'), findsOneWidget);
  });
}
