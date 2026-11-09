// Mock bar (FloatingBar README, R3-O04): after an answer is picked there is
// no reveal, so the hint reads "Saved on this device".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

const _question = Question(
  id: 'q',
  version: 1,
  examIds: [],
  language: 'en',
  topicId: 't',
  stem: 'Which answer is correct?',
  choices: [
    Choice(id: 'a', label: 'A', text: 'First answer', isCorrect: true),
    Choice(id: 'b', label: 'B', text: 'Second answer', isCorrect: false),
  ],
  explanation: 'The first answer is correct.',
);

void main() {
  for (final answered in [false, true]) {
    testWidgets('wide mock bar hint, answered=$answered', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hydratedMockQuestionProvider.overrideWith(
              (ref, id) async => const HydratedMockQuestion(_question, null),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: MockSessionPage(
              state: MockSessionInProgress(
                attemptId: 'a',
                durationSeconds: 5400,
                questionIds: const ['q', 'q2'],
                currentIndex: 0,
                elapsedSeconds: 0,
                answers: {
                  if (answered)
                    'q': const MockAnswer(selectedIndex: 0, atSec: 5),
                },
                flags: const {},
                strictMode: false,
              ),
              remainingInPart: const Duration(minutes: 30),
              partPosition: 1,
              partTotal: 2,
              oneBlock: true,
              canGoPrevious: false,
              canGoNext: true,
              onPrevious: () {},
              onNext: () {},
              onAnswer: (_) {},
              onToggleFlag: () {},
              onPause: () {},
              onSubmitExam: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Saved on this device'),
        answered ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
