import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/part_clock.dart';
import 'package:pantas/features/mock_exam/presentation/clock_rule.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';

void main() {
  Widget paper({
    required ThemeData theme,
    required Duration remaining,
    double textScale = 1,
    bool still = false,
  }) =>
      ProviderScope(
        overrides: [
          hydratedMockQuestionProvider.overrideWith((ref, id) => null),
        ],
        child: MaterialApp(
          theme: theme,
          home: MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: still,
            ),
            child: MockSessionPage(
              state: const MockSessionInProgress(
                attemptId: 'paper',
                durationSeconds: 10800,
                questionIds: ['q1'],
                currentIndex: 0,
                elapsedSeconds: 0,
                answers: {},
                flags: {},
                strictMode: false,
              ),
              remainingInPart: remaining,
              partLength: const Duration(hours: 3),
              partPosition: 1,
              partTotal: 1,
              canGoPrevious: false,
              canGoNext: false,
              onPrevious: () {},
              onNext: () {},
              onAnswer: (_) {},
              onToggleFlag: () {},
              onPause: () {},
              onShowNavigator: () {},
            ),
          ),
        ),
      );

  test('proctor only calls ten, five, and one minutes', () {
    expect(callThresholdsMinutes, [1, 5, 10]);
    expect(
      callThresholdCrossed(
        before: const Duration(minutes: 21),
        after: const Duration(minutes: 20),
      ),
      isNull,
    );
  });

  for (final dark in [false, true]) {
    final theme = dark ? buildDarkTheme() : buildLightTheme();
    testWidgets('paper clock includes hours and shared bar, dark=$dark',
        (tester) async {
      await tester.pumpWidget(
        paper(
          theme: theme,
          remaining: const Duration(hours: 1, minutes: 12, seconds: 40),
        ),
      );
      expect(find.text('1:12:40'), findsOneWidget);
      expect(find.byType(FloatingBar), findsOneWidget);
      expect(tester.getSize(find.byType(ClockRule)).width, 120);
      expect(tester.getSize(find.byType(ClockRule)).height, 5);
    });
    testWidgets('last-minute clock has readable red, dark=$dark',
        (tester) async {
      await tester.pumpWidget(
        paper(
          theme: theme,
          remaining: const Duration(seconds: 58),
          textScale: 2,
          still: true,
        ),
      );
      final context = tester.element(find.byType(MockSessionPage));
      final text = tester.widget<Text>(find.text('00:58'));
      expect(text.style!.color, context.colors.wrongText);
      final a = text.style!.color!.computeLuminance();
      final b = context.colors.background.computeLuminance();
      expect(
        (a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05)),
        greaterThanOrEqualTo(4.5),
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('five-minute bar uses amber, dark=$dark', (tester) async {
      await tester.pumpWidget(
        paper(
          theme: theme,
          remaining: const Duration(minutes: 4, seconds: 52),
        ),
      );
      final context = tester.element(find.byType(ClockRule));
      final bar =
          tester.widget<Container>(find.byKey(const Key('clock-rule-bar')));
      expect(
        (bar.decoration! as BoxDecoration).color,
        context.colors.warningText,
      );
    });
  }
}
