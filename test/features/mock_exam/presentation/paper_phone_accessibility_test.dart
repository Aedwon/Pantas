import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/figures/chart_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';

const _lastChoice = 'The final answer remains reachable.';

HydratedMockQuestion _question() => HydratedMockQuestion(
      const Question(
        id: 'q125',
        version: 1,
        examIds: [],
        topicId: 'topic',
        language: 'en',
        figureSpecJson:
            '{"kind":"chart","type":"bar","labels":["A","B"],"values":[1,2]}',
        stem: 'Which statement follows from this passage?',
        explanation: 'Explanation.',
        choices: [
          Choice(
            id: 'a',
            label: 'A',
            text: 'The first answer.',
            isCorrect: true,
          ),
          Choice(
            id: 'b',
            label: 'B',
            text: 'The second answer.',
            isCorrect: false,
          ),
          Choice(
            id: 'c',
            label: 'C',
            text: 'The third answer.',
            isCorrect: false,
          ),
          Choice(id: 'd', label: 'D', text: _lastChoice, isCorrect: false),
        ],
      ),
      Passage(
        id: 'passage',
        topicId: 'topic',
        title: 'A reading passage',
        body: List.filled(
          12,
          'The office reviews each request before it sends a reply.',
        ).join('\n\n'),
        language: 'en',
        wordCount: 144,
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });

  for (final missing in [false, true]) {
    testWidgets(
        'question failure retries the original content, missing=$missing',
        (tester) async {
      var attempts = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hydratedMockQuestionProvider.overrideWith((ref, id) {
              expect(id, 'q125');
              if (attempts++ == 0) {
                if (missing) return null;
                throw StateError('private diagnostic details');
              }
              return _question();
            }),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: MockSessionPage(
              state: const MockSessionInProgress(
                attemptId: 'paper',
                durationSeconds: 11400,
                questionIds: ['q125'],
                currentIndex: 0,
                elapsedSeconds: 0,
                answers: {},
                flags: {},
                strictMode: false,
              ),
              remainingInPart: const Duration(hours: 3),
              partPosition: 1,
              partTotal: 1,
              canGoPrevious: false,
              canGoNext: false,
              onPrevious: () {},
              onNext: () {},
              onAnswer: (_) {},
              onToggleFlag: () {},
              onPause: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Could not load your question.'), findsOneWidget);
      expect(find.textContaining('private diagnostic'), findsNothing);
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.text('A reading passage'), findsOneWidget);
      expect(find.byType(ChartFigure), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final dark in [false, true]) {
    for (final width in [320.0, 390.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
            'paper controls and last answer remain reachable '
            '$width dark=$dark scale=$scale', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 640);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final actions = <String>[];
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                hydratedMockQuestionProvider
                    .overrideWith((ref, id) => _question()),
              ],
              child: MaterialApp(
                theme: dark ? buildDarkTheme() : buildLightTheme(),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
                home: MockSessionPage(
                  state: MockSessionInProgress(
                    attemptId: 'paper',
                    durationSeconds: 11400,
                    questionIds: [for (var i = 1; i <= 250; i++) 'q$i'],
                    currentIndex: 124,
                    elapsedSeconds: 0,
                    answers: const {},
                    flags: const {},
                    strictMode: false,
                  ),
                  remainingInPart: const Duration(hours: 3),
                  partPosition: 125,
                  partTotal: 250,
                  partName: 'Verbal Ability',
                  oneBlock: true,
                  canGoPrevious: true,
                  canGoNext: true,
                  onPrevious: () => actions.add('previous'),
                  onNext: () => actions.add('next'),
                  onAnswer: (index) => actions.add('answer-$index'),
                  onToggleFlag: () => actions.add('flag'),
                  onPause: () {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(ChartFigure), findsOneWidget);
          expect(find.text('A reading passage'), findsOneWidget);
          final counter = tester.getRect(find.text('125 of 250'));
          expect(counter.center.dx, closeTo(width / 2, .1));
          if (scale == 1) {
            expect(tester.getSize(find.byType(FloatingBar)).height, 60);
          }
          final controls = ['mock-prev', 'mock-grid', 'mock-flag', 'mock-next'];
          final rectangles = [
            for (final key in controls)
              tester.getRect(find.byKey(ValueKey(key))),
          ];
          for (var i = 0; i < rectangles.length; i++) {
            final rectangle = rectangles[i];
            expect(rectangle.width, greaterThanOrEqualTo(44));
            expect(rectangle.height, greaterThanOrEqualTo(44));
            expect(rectangle.left, greaterThanOrEqualTo(0));
            expect(rectangle.right, lessThanOrEqualTo(width));
            expect(counter.overlaps(rectangle), isFalse);
            for (var j = i + 1; j < rectangles.length; j++) {
              expect(rectangle.overlaps(rectangles[j]), isFalse);
            }
            await tester.tap(find.byKey(ValueKey(controls[i])));
            if (controls[i] == 'mock-grid') {
              await tester.pumpAndSettle();
              final grid = tester.widget<QuestionGridSheet>(
                find.byType(QuestionGridSheet),
              );
              expect(grid.open, isTrue);
              grid.onDismiss();
              await tester.pumpAndSettle();
            }
          }
          expect(actions, ['previous', 'flag', 'next']);
          await tester.scrollUntilVisible(
            find.text(_lastChoice),
            250,
            scrollable: find.descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            ),
          );
          await tester.pumpAndSettle();
          final answer = tester.getRect(find.text(_lastChoice));
          final bar = tester.getRect(find.byType(FloatingBar));
          expect(answer.bottom, lessThanOrEqualTo(bar.top));
          await tester.tap(find.text(_lastChoice));
          expect(actions.last, 'answer-3');
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
