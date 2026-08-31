import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/value_wheel_sheet.dart';

void main() {
  const subjects = [
    Subject(
      id: 'math',
      examId: 'exam_custom_1',
      name: 'Mathematics',
      ordering: 0,
    ),
    Subject(
      id: 'sci',
      examId: 'exam_custom_1',
      name: 'Science',
      ordering: 1,
    ),
  ];

  late List<CustomBlueprint> saved;

  setUp(() => saved = []);

  Widget harness({int available = 240}) {
    final router = GoRouter(
      initialLocation: '/setup',
      routes: [
        GoRoute(
          path: '/setup',
          builder: (_, __) => CustomMockSetupPage(
            data: CustomMockSetupData(
              examId: 'exam_custom_1',
              subjects: subjects,
              topicsBySubject: const {},
              availableQuestions: available,
            ),
            onSave: (blueprint) async => saved.add(blueprint),
          ),
        ),
        GoRoute(
          path: '/settings/exam/included',
          builder: (_, __) => const Scaffold(body: Text('whats included')),
        ),
      ],
    );

    return MaterialApp.router(
      theme: buildLightTheme(),
      routerConfig: router,
    );
  }

  testWidgets('the rows open wheels rather than keyboards', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Questions'));
    await tester.pumpAndSettle();

    expect(find.byType(ValueWheel), findsOneWidget);
  });

  testWidgets('the breakdown is collapsed to begin with', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('I know the section breakdown'), findsOneWidget);
    expect(find.text('Mathematics'), findsNothing);
  });

  testWidgets('value rows and breakdown expose state with 48dp targets',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    final questionsFinder = find.bySemanticsLabel('Questions, 120');
    final breakdownFinder = find.bySemanticsLabel(
      'I know the section breakdown',
    );
    final questions = tester.getSemantics(questionsFinder);
    final breakdown = tester.getSemantics(breakdownFinder);

    expect(questions.flagsCollection.isButton, isTrue);
    expect(questions.flagsCollection.isEnabled, Tristate.isTrue);
    expect(breakdown.flagsCollection.isExpanded, Tristate.isFalse);
    for (final finder in [questionsFinder, breakdownFinder]) {
      expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
    }

    await tester.tap(breakdownFinder);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(breakdownFinder).flagsCollection.isExpanded,
      Tristate.isTrue,
    );
  });

  testWidgets('opening the breakdown lists the ticked subjects',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('I know the section breakdown'));
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
    expect(find.text('Time each part separately'), findsOneWidget);
  });

  testWidgets('the parts win over the totals once they exist', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('I know the section breakdown'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mathematics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // The default part is 40 questions, so the top row reads the sum and
    // not the 120 it started at.
    expect(find.text('40'), findsOneWidget);
    expect(find.text('120'), findsNothing);
  });

  testWidgets('a paper larger than the corpus refuses at Save', (tester) async {
    await tester.pumpWidget(harness(available: 60));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "You've ticked subjects with 60 questions. A 120 question paper "
        'needs more.',
      ),
      findsOneWidget,
    );

    final save = tester.widget<BoardButton>(find.byType(BoardButton));
    expect(save.onPressed, isNull);

    // The student's number stays on screen.
    expect(find.text('120'), findsOneWidget);
  });

  testWidgets('widening is one tap away', (tester) async {
    await tester.pumpWidget(harness(available: 60));
    await tester.pumpAndSettle();

    expect(find.text('Tick more subjects'), findsOneWidget);

    await tester.tap(find.text('Tick more subjects'));
    await tester.pumpAndSettle();

    expect(find.text('whats included'), findsOneWidget);
  });

  testWidgets('the correction action is named and reaches 48dp',
      (tester) async {
    await tester.pumpWidget(harness(available: 60));
    await tester.pumpAndSettle();

    final finder = find.bySemanticsLabel('Tick more subjects');
    expect(tester.getSemantics(finder).flagsCollection.isButton, isTrue);
    expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
  });

  testWidgets('a paper that fits saves', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved, hasLength(1));
    expect(saved.single.effectiveQuestions, 120);
    expect(saved.single.hasBreakdown, isFalse);
  });

  testWidgets('the copy never says paper or sit', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.textContaining('paper'), findsNothing);
    expect(find.textContaining('—'), findsNothing);
  });
}
