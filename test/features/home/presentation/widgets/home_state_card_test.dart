import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';

void main() {
  Future<void> show(
    WidgetTester tester,
    HomeState state, {
    bool large = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            textScaler: TextScaler.linear(large ? 2 : 1),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: HomeStateCard(
                state: state,
                examName: 'CSE Professional',
                examShortName: 'CSE-P',
                onPrimary: () {},
                onSecondary: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('assessment has only its approved action and no quick quiz',
      (tester) async {
    await show(tester, HomeState.assessment);
    expect(find.text('First, a short assessment'), findsOneWidget);
    expect(find.text('Start Assessment'), findsOneWidget);
    expect(find.textContaining('quick quiz'), findsNothing);
  });
  testWidgets('empty states use actual condition copy and no invented counts',
      (tester) async {
    for (final state in [
      HomeState.noContent,
      HomeState.nothingDue,
      HomeState.reviewOnly,
      HomeState.dayOff,
    ]) {
      await show(tester, state, large: true);
      expect(tester.takeException(), isNull);
      expect(find.textContaining('10'), findsNothing);
    }
  });
  testWidgets('passed exam offers a new date and switching exams',
      (tester) async {
    await show(tester, HomeState.passed);
    expect(find.text('Did you take CSE-P?'), findsOneWidget);
    expect(find.text('Set a New Date'), findsOneWidget);
    expect(find.text('Switch Exams'), findsOneWidget);
  });
  testWidgets('day off draws no icon and hides advance when it adds nothing',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: HomeStateCard(
            state: HomeState.dayOff,
            examName: 'CSE Professional',
            examShortName: 'CSE-P',
            onPrimary: null,
          ),
        ),
      ),
    );
    expect(find.text('Day off'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
    expect(find.text('I Want to Advance'), findsNothing);
  });
  testWidgets('no content offers only Switch Exam', (tester) async {
    await show(tester, HomeState.noContent);
    expect(find.text('Switch Exam'), findsOneWidget);
    expect(find.text('Switch Exams'), findsNothing);
  });
}
