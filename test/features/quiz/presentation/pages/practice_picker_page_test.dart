import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/presentation/pages/practice_picker_page.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';

import '../../../../helpers/pump_app.dart';

const _index = PracticeIndex([
  PracticeSubjectEntry(
    id: 'subject_maths',
    name: 'Mathematics',
    topics: [
      PracticeTopicEntry(
        id: 'topic_algebra',
        name: 'Algebra',
        questionCount: 40,
        lessons: [
          PracticeLessonEntry(
            id: 'l_1',
            title: 'Linear equations',
            isRead: true,
            questionCount: 6,
          ),
          PracticeLessonEntry(
            id: 'l_2',
            title: 'Quadratics',
            isRead: false,
            questionCount: 6,
          ),
        ],
      ),
      PracticeTopicEntry(
        id: 'topic_empty',
        name: 'Trigonometry',
        questionCount: 0,
        lessons: [],
      ),
    ],
  ),
]);

Future<void> pumpPicker(WidgetTester tester, {int? pace}) =>
    tester.pumpAppWithProviders(
      const PracticePickerPage(examId: 'exam_cse_pro'),
      overrides: [
        practiceIndexProvider('exam_cse_pro').overrideWith((_) async => _index),
        practicePaceProvider('exam_cse_pro').overrideWith((_) async => pace),
      ],
    );

void main() {
  testWidgets('the screen names itself and explains its one mark',
      (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('Choose what to practice'), findsOneWidget);
    expect(
      find.text("Lessons you haven't read yet are marked."),
      findsOneWidget,
    );
  });

  testWidgets('only unread lessons are marked', (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('caret_topic_algebra')));
    await tester.pumpAndSettle();

    expect(find.text('not read yet'), findsOneWidget);
  });

  testWidgets('a topic with no questions says so and does not select',
      (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('no questions yet'), findsOneWidget);

    await tester.tap(find.text('Trigonometry'));
    await tester.pumpAndSettle();

    expect(find.text('Clear'), findsNothing);
  });

  testWidgets('Clear appears only once something is selected', (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('Clear'), findsNothing);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    expect(find.text('Clear'), findsOneWidget);
  });

  testWidgets('the empty footer invites a selection', (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('Pick a topic or a lesson above.'), findsOneWidget);
  });

  testWidgets('Start is disabled with nothing selected', (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    final start = tester.widget<BoardButton>(
      find.widgetWithText(BoardButton, 'Start'),
    );
    expect(start.onPressed, isNull);
  });

  testWidgets('the minutes unit is hidden without a measured pace',
      (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('questions'), findsWidgets);
    expect(find.text('minutes'), findsNothing);
  });

  testWidgets('the minutes unit appears once the pace is known',
      (tester) async {
    await pumpPicker(tester, pace: 40000);
    await tester.pumpAndSettle();

    expect(find.text('minutes'), findsOneWidget);
  });

  testWidgets('tapping the caret unfolds, tapping the row selects',
      (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('Quadratics'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('caret_topic_algebra')));
    await tester.pumpAndSettle();
    expect(find.text('Quadratics'), findsOneWidget);
    expect(find.text('Clear'), findsNothing);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();
    expect(find.text('Clear'), findsOneWidget);
  });
}
