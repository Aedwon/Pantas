import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/answer_reveal.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/components/review_list.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const q1 = Question(
    id: 'q_1',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 'topic_1',
    language: 'en',
    stem: 'Balancing an equation stem text',
    choices: [
      Choice(
        id: 'c_a',
        label: 'A',
        text: 'Option A',
        isCorrect: false,
        rationale: 'what you picked rationale',
      ),
      Choice(
        id: 'c_b',
        label: 'B',
        text: 'Option B',
        isCorrect: true,
      ),
    ],
    explanation: 'the answer explanation',
  );

  const q2 = Question(
    id: 'q_2',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 'topic_1',
    language: 'en',
    stem: 'Second question stem text',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'Option A', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'Option B', isCorrect: true),
    ],
    explanation: 'Explanation 2',
  );

  const q3 = Question(
    id: 'q_3',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 'topic_1',
    language: 'en',
    stem: 'Third question stem text',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'Option A', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'Option B', isCorrect: true),
    ],
    explanation: 'Explanation 3',
  );

  const q4 = Question(
    id: 'q_4',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 'topic_2',
    language: 'en',
    stem: 'Fourth question stem text',
    choices: [
      Choice(
        id: 'c_a',
        label: 'A',
        text: 'Option A',
        isCorrect: false,
        rationale: 'what you picked rationale',
      ),
      Choice(id: 'c_b', label: 'B', text: 'Option B', isCorrect: true),
    ],
    explanation: 'the answer explanation 4',
  );

  const q5 = Question(
    id: 'q_5',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 'topic_2',
    language: 'en',
    stem: 'Fifth question stem text',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'Option A', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'Option B', isCorrect: true),
    ],
    explanation: 'Explanation 5',
  );

  final sampleEntries = [
    const ReviewEntry(
      number: 1,
      question: q1,
      chosenChoiceId: 'c_b',
      isFlagged: false,
      subjectName: 'Mathematics',
      label: 'Balancing an equation',
      labelIsStem: false,
    ),
    const ReviewEntry(
      number: 2,
      question: q2,
      chosenChoiceId: 'c_b',
      isFlagged: true,
      subjectName: 'Mathematics',
      label: 'Q2 Label',
      labelIsStem: false,
    ),
    const ReviewEntry(
      number: 3,
      question: q3,
      chosenChoiceId: 'c_b',
      isFlagged: false,
      subjectName: 'Mathematics',
      label: 'Q3 Label',
      labelIsStem: false,
    ),
    const ReviewEntry(
      number: 4,
      question: q4,
      chosenChoiceId: 'c_a',
      isFlagged: false,
      subjectName: 'Science',
      label: 'Q4 Miss',
      labelIsStem: false,
    ),
    const ReviewEntry(
      number: 5,
      question: q5,
      isFlagged: false,
      subjectName: 'Science',
      label: 'Q5 Blank',
      labelIsStem: false,
    ),
  ];

  testWidgets('Wrong is the default filter', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: true,
        onToggleFlag: (_) {},
      ),
    );

    expect(find.byType(ReviewRow), findsNWidgets(2));
  });

  testWidgets('the filter row counts each and uses no pills', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: true,
        onToggleFlag: (_) {},
      ),
    );

    expect(find.text('All 5'), findsOneWidget);
    expect(find.text('Wrong 2'), findsOneWidget);
    expect(find.text('Flagged 1'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Wrong 2')),
      matchesSemantics(
        label: 'Wrong 2',
        hasSelectedState: true,
        isSelected: true,
        isButton: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets('rows expose expansion and a separate named flag action',
      (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: false,
        initialFilter: ReviewFilter.all,
        onToggleFlag: (_) {},
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Question 2. Q2 Label')),
      matchesSemantics(
        label: 'Question 2. Q2 Label',
        value: 'Correct',
        isButton: true,
        hasExpandedState: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Unflag question 2')),
      matchesSemantics(
        label: 'Unflag question 2',
        hasToggledState: true,
        isToggled: true,
        isButton: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('All is one tap away', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: true,
        onToggleFlag: (_) {},
      ),
    );

    await tester.tap(find.text('All 5'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewRow), findsNWidgets(5));
  });

  testWidgets('grouped mode heads each subject with a count', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: true,
        initialFilter: ReviewFilter.all,
        onToggleFlag: (_) {},
      ),
    );

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('flat mode has no headings', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: false,
        initialFilter: ReviewFilter.all,
        onToggleFlag: (_) {},
      ),
    );

    expect(find.text('Mathematics'), findsNothing);
  });

  testWidgets('tapping a row expands it in place', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: false,
        initialFilter: ReviewFilter.all,
        onToggleFlag: (_) {},
      ),
    );

    expect(find.byType(AnswerReveal), findsNothing);
    await tester.tap(find.text('Balancing an equation'));
    await tester.pumpAndSettle();
    expect(find.byType(AnswerReveal), findsOneWidget);
    expect(find.byType(ReviewList), findsOneWidget);
  });

  testWidgets('two rows can be open at once', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: false,
        initialFilter: ReviewFilter.all,
        onToggleFlag: (_) {},
      ),
    );

    await tester.tap(find.text('Balancing an equation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Q2 Label'));
    await tester.pumpAndSettle();

    expect(find.byType(AnswerReveal), findsNWidgets(2));
  });

  testWidgets('Free sees note A and nothing about note B', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: false,
        onToggleFlag: (_) {},
      ),
    );

    await tester.tap(find.text('Q4 Miss'));
    await tester.pumpAndSettle();

    expect(find.text('the answer'), findsOneWidget);
    expect(find.text('what you picked'), findsNothing);
    expect(find.textContaining('Pro'), findsNothing);
  });

  testWidgets('Pro sees note B', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: true,
        grouped: false,
        onToggleFlag: (_) {},
      ),
    );

    await tester.tap(find.text('Q4 Miss'));
    await tester.pumpAndSettle();

    expect(find.text('what you picked'), findsOneWidget);
  });

  testWidgets('the pennant is tappable and reports the question',
      (tester) async {
    final toggled = <String>[];
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: false,
        initialFilter: ReviewFilter.all,
        onToggleFlag: toggled.add,
      ),
    );

    await tester.tap(find.byType(PennantMark).first);
    await tester.pumpAndSettle();
    expect(toggled, equals(['q_1']));
  });

  testWidgets('a footer renders when one is given', (tester) async {
    await tester.pumpApp(
      ReviewList(
        entries: sampleEntries,
        proIsActive: false,
        grouped: false,
        footer: const Text('Practice these 12'),
        onToggleFlag: (_) {},
      ),
    );

    expect(find.text('Practice these 12'), findsOneWidget);
  });
}
