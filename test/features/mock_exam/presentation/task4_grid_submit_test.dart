import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';

void main() {
  // Part 3 of a four-part paper: questions 41 to 100 of 150 overall, so the
  // grid must number from one inside the part.
  MockSessionInProgress sectional({
    int index = 51,
    Map<String, MockAnswer> answers = const {},
    Set<String> flags = const {},
  }) =>
      MockSessionInProgress(
        attemptId: 'a',
        durationSeconds: 3600,
        questionIds: [for (var i = 0; i < 100; i++) 'q$i'],
        currentIndex: index,
        elapsedSeconds: 0,
        answers: answers,
        flags: flags,
        strictMode: false,
      );

  Widget page({
    required MockSessionInProgress state,
    int partPosition = 12,
    int partTotal = 60,
    bool oneBlock = false,
    int closedPartCount = 2,
    List<MockUpcomingPart> upcoming = const [],
    ValueChanged<int>? onGoTo,
    VoidCallback? onSubmitExam,
    String partName = 'Mathematics',
    int partNumber = 3,
  }) =>
      ProviderScope(
        overrides: [
          hydratedMockQuestionProvider.overrideWith((ref, id) => null),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MockSessionPage(
              state: state,
              remainingInPart: const Duration(minutes: 48),
              partPosition: partPosition,
              partTotal: partTotal,
              canGoPrevious: true,
              canGoNext: true,
              onPrevious: () {},
              onNext: () {},
              onAnswer: (_) {},
              onToggleFlag: () {},
              onPause: () {},
              currentPartNumber: partNumber,
              partName: partName,
              oneBlock: oneBlock,
              closedPartCount: closedPartCount,
              upcomingParts: upcoming,
              onGoTo: onGoTo,
              onSubmitExam: onSubmitExam,
            ),
          ),
        ),
      );

  testWidgets('the grid numbers the open part from one and jumps globally',
      (tester) async {
    final jumps = <int>[];
    await tester.pumpWidget(
      page(
        state: sectional(),
        upcoming: const [
          MockUpcomingPart(number: 4, name: 'Science', count: 12),
        ],
        onGoTo: jumps.add,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await tester.pump();

    final sheet = tester.widget<QuestionGridSheet>(
      find.byType(QuestionGridSheet),
    );
    expect(sheet.open, isTrue);
    expect(sheet.mock, isTrue);
    expect(sheet.title, 'Questions');
    expect(sheet.summary, 'Parts 1 and 2 are closed');
    expect(sheet.parts, hasLength(2));
    expect(sheet.parts[0].title, 'PART 3 · MATHEMATICS');
    expect(sheet.parts[0].enabled, isTrue);
    expect(sheet.parts[0].questions.first.number, 1);
    expect(sheet.parts[0].questions, hasLength(60));
    expect(
      sheet.parts[0].questions.where((q) => q.current).single.number,
      12,
    );
    expect(sheet.parts[1].title, 'PART 4 · SCIENCE');
    expect(sheet.parts[1].enabled, isFalse);
    expect(sheet.parts[1].questions, hasLength(12));

    // Question 12 of the part is question 51 overall (index 51 from zero).
    await tester.tap(find.byKey(const ValueKey('grid-question-0-5')));
    await tester.pump();
    expect(jumps, [44]);
    expect(
      tester.widget<QuestionGridSheet>(find.byType(QuestionGridSheet)).open,
      isFalse,
    );
  });

  testWidgets('the grid shows progress and flags, never an outcome',
      (tester) async {
    await tester.pumpWidget(
      page(
        state: sectional(
          answers: const {
            'q40': MockAnswer(selectedIndex: 1, atSec: 0),
            'q41': MockAnswer(selectedIndex: -1, atSec: 0),
          },
          flags: const {'q42'},
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await tester.pump();
    final questions = tester
        .widget<QuestionGridSheet>(find.byType(QuestionGridSheet))
        .parts
        .first
        .questions;
    expect(questions[0].state, GridQuestionState.answered);
    expect(questions[1].state, GridQuestionState.unreached);
    expect(questions[2].flagged, isTrue);
    expect(
      questions.every(
        (q) =>
            q.state == GridQuestionState.answered ||
            q.state == GridQuestionState.unreached,
      ),
      isTrue,
    );
  });

  testWidgets('a one-block paper counts answers and offers Submit the Exam',
      (tester) async {
    var submitted = 0;
    await tester.pumpWidget(
      page(
        state: sectional(
          index: 0,
          answers: const {
            'q0': MockAnswer(selectedIndex: 0, atSec: 0),
            'q1': MockAnswer(selectedIndex: 2, atSec: 0),
          },
        ),
        partPosition: 1,
        partTotal: 100,
        oneBlock: true,
        closedPartCount: 0,
        partName: 'Professional',
        partNumber: 1,
        onSubmitExam: () => submitted++,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await tester.pump();
    final sheet =
        tester.widget<QuestionGridSheet>(find.byType(QuestionGridSheet));
    expect(sheet.summary, '2 of 100 answered');
    expect(sheet.footer, isNotNull);
    expect(find.text('Submit the Exam'), findsOneWidget);

    await tester.ensureVisible(find.text('Submit the Exam'));
    await tester.pump();
    await tester.tap(find.text('Submit the Exam'));
    await tester.pump();
    expect(
      tester.widget<QuestionGridSheet>(find.byType(QuestionGridSheet)).open,
      isFalse,
    );
    expect(find.text('Submit the exam?'), findsOneWidget);
    expect(submitted, 0);
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(submitted, 1);
  });

  testWidgets('a sectional paper has no submit action in the grid',
      (tester) async {
    await tester.pumpWidget(page(state: sectional()));
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await tester.pump();
    expect(find.text('Submit the Exam'), findsNothing);
  });

  testWidgets('strict mode keeps the one-block submit out of the grid',
      (tester) async {
    final strict = sectional(index: 0);
    await tester.pumpWidget(
      page(
        state: MockSessionInProgress(
          attemptId: strict.attemptId,
          durationSeconds: strict.durationSeconds,
          questionIds: strict.questionIds,
          currentIndex: 0,
          elapsedSeconds: 0,
          answers: const {},
          flags: const {},
          strictMode: true,
        ),
        partPosition: 1,
        partTotal: 100,
        oneBlock: true,
        closedPartCount: 0,
        onSubmitExam: () {},
      ),
    );
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await tester.pump();
    expect(find.text('Submit the Exam'), findsNothing);
  });
}
