import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/presentation/quiz_question_viewer.dart';
import 'package:pantas/features/quiz/presentation/web_quiz_question.dart';

import 'quiz_question_viewer_test.dart' show items, questions;

void main() {
  for (final dark in [false, true]) {
    for (final pro in [false, true]) {
      testWidgets('wide wrong answer notes access pro=$pro dark=$dark',
          (tester) async {
        debugWebPlatformOverride = true;
        addTearDown(() => debugWebPlatformOverride = null);
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        MistakeTag? saved;
        await tester.pumpWidget(
          MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: QuizQuestionViewer(
              questions: questions,
              items: [
                items.first
                    .copyWith(mistakeTag: pro ? MistakeTag.misread : null),
                items.last,
              ],
              pro: pro,
              onBack: () {},
              onNote: (_, tag, __) async => saved = tag,
              onReport: (_) async => false,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('your pick'), pro ? findsOneWidget : findsNothing);
        expect(
          find.text('Why did you miss it?'),
          pro ? findsOneWidget : findsNothing,
        );
        if (pro) {
          expect(find.text('Cancel'), findsOneWidget);
          expect(find.text('Your note'), findsOneWidget);
          await tester.tap(find.text("I didn't know"));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Update'));
          await tester.pumpAndSettle();
          expect(saved, MistakeTag.unknown);
        }
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets(
        'wide figure and long choices scroll clear of controls dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final question = questions.first.copyWith(
        figureSpecJson: '{"kind":"geometry-diagram","type":"triangle",'
            '"labels":["A","B","C"]}',
        choices: questions.first.choices
            .map(
              (choice) => choice.copyWith(
                text: List.filled(20, 'Long answer text.').join(' '),
              ),
            )
            .toList(),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 56, 40, 140),
              child: WebQuizQuestion(question: question, subject: 'Science'),
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('web-question-column')), findsOneWidget);
      expect(find.text('Figure is missing'), findsNothing);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide passage stays beside the question dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(40),
              child: WebQuizQuestion(
                question: questions.first,
                subject: 'Science',
                passagePosition: (ordinal: 1, total: 3),
                passage: const Passage(
                  id: 'p',
                  topicId: 't',
                  title: 'Passage',
                  body: 'The passage body.',
                  language: 'en',
                  wordCount: 3,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('PASSAGE'), findsOneWidget);
      expect(find.text('SCIENCE · 1 OF 3 ON THIS PASSAGE'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('PASSAGE')).dx,
        lessThan(
          tester
              .getTopLeft(find.byKey(const ValueKey('web-question-column')))
              .dx,
        ),
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide viewer split, reasons and navigation dark=$dark',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: QuizQuestionViewer(
            questions: questions,
            items: items,
            pro: true,
            onBack: () {},
            onNote: (_, __, ___) async {},
            onReport: (_) async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('web-question-column')), findsOneWidget);
      expect(find.byKey(const ValueKey('web-answer-column')), findsOneWidget);
      expect(find.text('Why did you miss it?'), findsOneWidget);
      expect(find.text('I forgot'), findsOneWidget);
      final question =
          tester.getTopLeft(find.byKey(const ValueKey('web-question-column')));
      final answer =
          tester.getTopLeft(find.byKey(const ValueKey('web-answer-column')));
      expect(answer.dx, greaterThan(question.dx));
      expect(answer.dy, question.dy);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('2 of 2'), findsOneWidget);
      expect(find.text('Why did you miss it?'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
