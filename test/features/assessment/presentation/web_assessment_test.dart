import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';

void main() {
  const question = Question(
    id: 'q',
    version: 1,
    examIds: ['e'],
    language: 'en',
    topicId: 't',
    stem: 'Which organelle makes ATP?',
    explanation: 'Hidden answer',
    choices: [
      Choice(id: 'a', label: 'A', text: 'Nucleus', isCorrect: false),
      Choice(id: 'b', label: 'B', text: 'Ribosome', isCorrect: false),
      Choice(id: 'c', label: 'C', text: 'Mitochondrion', isCorrect: true),
      Choice(id: 'd', label: 'D', text: 'Golgi apparatus', isCorrect: false),
    ],
  );
  for (final dark in [false, true]) {
    testWidgets('wide assessment question, picked and leave, dark=$dark',
        (tester) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? picked;
      var next = 0;
      var leave = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: WebAssessmentLayout(
                question: question,
                subject: 'Science · Biology',
                examName: 'CSE',
                index: 7,
                total: 30,
                chosenId: picked,
                onPick: (id) => setState(() => picked = id),
                onNext: () => next++,
                onLeave: () => leave++,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Assessment · CSE'), findsOneWidget);
      expect(find.text('SCIENCE · BIOLOGY'), findsOneWidget);
      expect(find.text('8 of 30'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('8 of 30'),
          matching: find.byType(TextButton),
        ),
        findsNothing,
      );
      expect(find.text('Answers show at the end.'), findsOneWidget);
      expect(find.text('Hidden answer'), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('web-question-column'))).width,
        720,
      );
      expect(
        tester
            .widget<WebButton>(find.widgetWithText(WebButton, 'Next'))
            .onPressed,
        isNull,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pump();
      expect(picked, 'c');
      expect(
        tester
            .widget<WebAnswerOption>(
              find.widgetWithText(WebAnswerOption, 'Mitochondrion'),
            )
            .state,
        WebOptionState.selected,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(next, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(leave, 1);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide assessment results split layout, dark=$dark',
        (tester) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var done = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: WebAssessmentResults(
              examName: 'CSE',
              correct: 18,
              total: 30,
              elapsed: const Duration(minutes: 24),
              subjects: const [
                (name: 'Science', correct: 9, total: 20),
                (name: 'Math', correct: 9, total: 10),
              ],
              weakestTopic: 'Chemistry',
              weakestSubject: 'Science',
              onAcknowledge: () => done++,
            ),
          ),
        ),
      );
      expect(find.text("Where you're starting"), findsOneWidget);
      expect(find.text('CSE · 30 questions'), findsOneWidget);
      expect(find.text('BY SUBJECT · WEAKEST FIRST'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('in 24 minutes'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('half-ring-paint')),
        paints
          ..arc(
            rect: const Rect.fromLTWH(18, 16, 228, 228),
            strokeWidth: 16,
          ),
      );
      final score = tester.getRect(
        find.byKey(const ValueKey('web-assessment-score')),
      );
      final label = tester.getRect(find.text('correct'));
      expect(label.bottom, lessThanOrEqualTo(score.bottom));
      expect(label.top, greaterThan(score.top));
      expect(
        tester.getSize(find.byKey(const ValueKey('half-ring-paint'))),
        const Size(264, 140),
      );
      expect(find.text('Chemistry'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('BY SUBJECT · WEAKEST FIRST')).dx,
        greaterThan(
          tester
              .getTopLeft(find.byKey(const ValueKey('web-assessment-score')))
              .dx,
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(done, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
