import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';

const result = MockResults(
  scoreRaw: 171,
  scoreTotal: 250,
  percent: 61.2,
  sections: [
    SectionResult(
      sectionId: 's',
      name: 'Mathematics',
      correct: 171,
      wrong: 72,
      blank: 7,
      total: 250,
      retiredCount: 0,
      timeSeconds: 60,
    ),
  ],
  topWeak: [],
  totalTimeSeconds: 60,
  wasStrict: true,
);
Widget harness({
  bool pro = false,
  bool canReview = true,
  bool paused = false,
  bool forfeited = false,
  bool dark = false,
  double scale = 1,
  VoidCallback? done,
}) =>
    MaterialApp(
      theme: dark ? buildDarkTheme() : buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: true,
          textScaler: TextScaler.linear(scale),
        ),
        child: MockResultsPage(
          results: result,
          examId: 'exam_upcat',
          proIsActive: pro,
          proPaused: paused,
          canReview: canReview,
          forfeited: forfeited,
          forfeitedPart: 3,
          reviewUntil: DateTime(2026, 10, 17),
          blueprintName: 'UPCAT simulation',
          dateFormatted: 'Saturday, Oct 3',
          onReviewTap: () {},
          onDone: done,
          onSeePro: () {},
        ),
      ),
    );
void main() {
  testWidgets('approved score uses the mock gauge and stored deduction',
      (t) async {
    await t.pumpWidget(harness());
    await t.pumpAndSettle();
    expect(find.text('61.2'), findsOneWidget);
    expect(find.text('171 correct, minus 18 wrong'), findsOneWidget);
    expect(find.text('PERFORMANCE BREAKDOWN'), findsOneWidget);
    expect(find.text('171 / 250'), findsOneWidget);
    expect(find.text('Practice these next'), findsNothing);
    expect(find.textContaining('Reopens in 7 days'), findsNothing);
    expect(find.text('VERSUS PAST RESULTS'), findsNothing);
    final gauge = find.byKey(const ValueKey('half-ring-paint'));
    expect(t.getSize(gauge), const Size(264, 128));
    final text = t.widget<Text>(find.text('61.2'));
    expect(text.style!.fontSize, 56);
    expect(find.byType(HalfRingGauge), findsOneWidget);
  });
  testWidgets('Free window is explicit and locked results keep breakdown',
      (t) async {
    await t.pumpWidget(harness());
    await t.pumpAndSettle();
    expect(
      find.textContaining('next mock opens on Sat, Oct 17.'),
      findsOneWidget,
    );
    await t.pumpWidget(harness(canReview: false));
    await t.pumpAndSettle();
    expect(
      find.text('Go through all 250 questions again with Pro.'),
      findsOneWidget,
    );
    expect(find.text('See all 250 questions'), findsNothing);
    expect(find.text('See Pro'), findsOneWidget);
    expect(find.text('PERFORMANCE BREAKDOWN'), findsOneWidget);
  });
  testWidgets('paused Pro uses the shared line', (t) async {
    await t.pumpWidget(harness(canReview: false, paused: true));
    await t.pumpAndSettle();
    expect(find.text('Connect once to keep using Pro.'), findsOneWidget);
    expect(find.text('See Pro'), findsNothing);
  });
  testWidgets('not finished scores answered work and Done returns origin',
      (t) async {
    var done = false;
    await t.pumpWidget(harness(forfeited: true, done: () => done = true));
    await t.pumpAndSettle();
    expect(find.text('Not finished'), findsOneWidget);
    expect(find.textContaining('during Part 3'), findsOneWidget);
    await t.tap(find.text('Done'));
    expect(done, isTrue);
  });
  testWidgets('light dark and large text fit phone widths', (t) async {
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    for (final dark in [false, true]) {
      for (final width in [320.0, 390.0]) {
        t.view.physicalSize = Size(width, 844);
        await t.pumpWidget(harness(dark: dark, scale: 2));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      }
    }
  });
}
