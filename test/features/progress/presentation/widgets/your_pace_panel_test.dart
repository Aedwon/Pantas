import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/progress/application/pace_provider.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/your_pace_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness({
  required int read,
  required int total,
  int? daysLeft,
  int? rate,
  int? past,
  int? fix,
  bool isPro = false,
}) {
  final reading = PaceReading(
    lessonsRead: read,
    lessonsTotal: total,
    daysLeft: daysLeft,
    lessonsPerWeek: rate,
    daysPastExam: past,
    rateToFinishInTime: fix,
  );
  return ProviderScope(
    overrides: [
      paceProvider.overrideWith((ref) async => reading),
    ],
    child: MaterialApp(
      theme: buildLightTheme(),
      home: const Scaffold(
        body: YourPacePanel(),
      ),
    ),
  );
}

Iterable<TextSpan> allTextSpans(WidgetTester tester) {
  final spans = <TextSpan>[];
  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    void visit(InlineSpan span) {
      if (span is TextSpan) {
        if (span.text != null && span.text!.isNotEmpty) {
          spans.add(span);
        }
        span.children?.forEach(visit);
      }
    }

    visit(richText.text);
  }
  return spans;
}

void main() {
  testWidgets('prints two figures and the overshoot sentence', (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 120, rate: 3, past: 9, fix: 4),
    );
    await tester.pumpAndSettle();

    expect(find.text('43%'), findsOneWidget);
    expect(find.text('lessons read'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('days left'), findsOneWidget);
    expect(
      find.textContaining(
        'At three lessons a week you finish nine days after the exam.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Four a week closes the gap.'), findsOneWidget);
  });

  testWidgets('only the overshoot carries amber', (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 120, rate: 3, past: 9, fix: 4),
    );
    await tester.pumpAndSettle();

    final amberSpans = allTextSpans(tester)
        .where((s) => s.style?.color == AppColors.light.amber);
    expect(amberSpans, hasLength(1));
    expect(amberSpans.single.text, contains('nine days after the exam'));
  });

  testWidgets('finishing in time says so and carries no amber', (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 200, rate: 8, past: null),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('At eight lessons a week you finish before the exam.'),
      findsOneWidget,
    );
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(t.style?.color, isNot(AppColors.light.amber));
    }
  });

  testWidgets('a zero rate states the fact and the remainder', (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 120, rate: 0, past: null),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('You have not read a lesson in four weeks. There are 55 left.'),
      findsOneWidget,
    );
  });

  testWidgets('below the floor the figures stand alone', (tester) async {
    await tester.pumpWidget(
      harness(read: 2, total: 96, daysLeft: 120, rate: null),
    );
    await tester.pumpAndSettle();

    expect(find.text('days left'), findsOneWidget);
    expect(find.textContaining('a week'), findsNothing);
  });

  testWidgets('with no day count the sentence never mentions the exam',
      (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: null, rate: 3),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('weeks of reading left'), findsOneWidget);
    expect(find.textContaining('the exam'), findsNothing);
    expect(find.text('days left'), findsNothing);
  });

  testWidgets('one day and one lesson read as singular', (tester) async {
    await tester.pumpWidget(
      harness(read: 95, total: 96, daysLeft: 1, rate: 1, past: 1, fix: 2),
    );
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('day left'), findsOneWidget);
    expect(find.textContaining('one day after the exam'), findsOneWidget);
  });

  testWidgets('never a score, a band, a chance or the word readiness',
      (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 120, rate: 3, past: 9, fix: 4),
    );
    await tester.pumpAndSettle();

    for (final word in [
      'score',
      'Score',
      'pass',
      'Pass',
      'chance',
      'likely',
      'readiness',
      'Readiness',
      '—',
    ]) {
      expect(find.textContaining(word), findsNothing);
    }
  });

  testWidgets('no teaser and no redaction, on either tier', (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(harness(read: 41, total: 96, isPro: isPro));
      await tester.pumpAndSettle();
      expect(find.text('Unlock with Pro'), findsNothing);
      expect(find.byType(FaintBars), findsNothing);
    }
  });
}
