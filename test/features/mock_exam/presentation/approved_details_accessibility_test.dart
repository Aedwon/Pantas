import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';

Widget _app({required bool dark, bool strict = false}) => ProviderScope(
      overrides: [hydratedMockQuestionProvider.overrideWith((ref, id) => null)],
      child: MaterialApp(
        theme: dark ? buildDarkTheme() : buildLightTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: MockSessionPage(
          state: MockSessionInProgress(
            attemptId: 'mock',
            durationSeconds: 3600,
            questionIds: const ['q1', 'q2', 'q3'],
            currentIndex: 0,
            elapsedSeconds: 0,
            answers: const {},
            flags: const {},
            strictMode: strict,
          ),
          remainingInPart: const Duration(minutes: 20),
          partPosition: 1,
          partTotal: 3,
          currentPartNumber: 4,
          closedPartCount: 3,
          partName: 'Mathematics',
          upcomingParts: const [
            MockUpcomingPart(number: 5, name: 'Science', count: 3),
          ],
          canGoPrevious: false,
          canGoNext: true,
          onPrevious: () {},
          onNext: () {},
          onAnswer: (_) {},
          onToggleFlag: () {},
          onPause: () {},
        ),
      ),
    );

void main() {
  for (final dark in [false, true]) {
    testWidgets('approved grid details fit 320 at 200 percent, dark=$dark',
        (tester) async {
      tester.view
        ..physicalSize = const Size(320, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_app(dark: dark));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('mock-grid')));
      await tester.pumpAndSettle();
      expect(find.text('Parts 1, 2 and 3 are closed'), findsOneWidget);
      expect(find.text('0 of 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('pause checkbox remains usable at 200 percent, dark=$dark',
        (tester) async {
      tester.view
        ..physicalSize = const Size(320, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_app(dark: dark));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('mock-pause')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text("Don't show this again"));
      await tester.tap(find.text("Don't show this again"));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
        'strict Back note contrasts with its real background, dark=$dark',
        (tester) async {
      await tester.pumpWidget(_app(dark: dark, strict: true));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(
        find.text('Strict mode is on. Back is off until you submit.'),
      );
      final bg =
          tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor!;
      final a = text.style!.color!.computeLuminance();
      final b = bg.computeLuminance();
      final ratio = ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05);
      expect(ratio, greaterThanOrEqualTo(4.5));
      expect(text.style!.fontSize, 12);
      expect(tester.takeException(), isNull);
    });
  }
}
