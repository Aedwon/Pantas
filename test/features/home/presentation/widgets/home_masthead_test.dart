import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';

const _examId = 'upcat';

final _week = HomeWeekStripData(
  states: const [
    WeekDayState.dayOff,
    WeekDayState.done,
    WeekDayState.partial,
    WeekDayState.today,
    WeekDayState.plain,
    WeekDayState.plain,
    WeekDayState.plain,
  ],
  todayFraction: .48,
);

Widget harness(
  HomeMastheadData masthead, {
  DateTime? now,
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
}) {
  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      homeMastheadProvider.overrideWith((ref) async => masthead),
      weekStripProvider(_examId).overrideWith((ref) async => _week),
    ],
    child: MaterialApp(
      theme: theme ?? buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          textScaler: textScaler,
          disableAnimations: disableAnimations,
        ),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: HomeMasthead(
              examId: _examId,
              now: now ?? DateTime(2026, 10, 15, 20),
            ),
          ),
        ),
      ),
    ),
  );
}

HomeMastheadData data(ExamDate? date) => HomeMastheadData(
      name: 'Aedwon',
      examShortName: 'UPCAT',
      examDate: date,
    );

void main() {
  testWidgets('failed masthead shows the existing retry state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeMastheadProvider
              .overrideWith((ref) async => throw StateError('offline')),
          weekStripProvider(_examId).overrideWith((ref) async => _week),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: HomeMasthead(examId: _examId, now: DateTime(2026)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load your plan.'), findsOneWidget);
    final state = tester.widget<StateView>(find.byType(StateView));
    expect(state.boardLayout, isTrue);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('renders Sunday-first week, exact-date chip, and greeting only',
      (tester) async {
    await tester.pumpWidget(
      harness(
        data(ExamDate.onDay(DateTime(2026, 11, 26))),
        now: DateTime(2026, 10, 15, 20),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);
    expect(find.text('UPCAT'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('NOV'), findsOneWidget);
    expect(find.text('42 days'), findsOneWidget);
    final novText = tester.widget<Text>(find.text('NOV'));
    final countdownText = tester.widget<Text>(find.text('42 days'));
    final exactDateColors = tester.element(find.text('NOV')).colors;
    expect(novText.style?.color, exactDateColors.secondaryLabel);
    expect(countdownText.style?.color, exactDateColors.secondaryLabel);
    expect(find.text('Magandang gabi'), findsOneWidget);
    expect(find.textContaining('Aedwon'), findsNothing);
    expect(find.byTooltip('Settings'), findsNothing);
  });

  testWidgets('renders no-date and month-only chip states', (tester) async {
    await tester.pumpWidget(harness(data(null)));
    await tester.pumpAndSettle();
    expect(find.text('+'), findsOneWidget);
    expect(tester.widget<Text>(find.text('+')).style?.fontSize, 16);
    expect(find.text('Add date'), findsOneWidget);

    await tester.pumpWidget(
      harness(data(ExamDate.inMonth(year: 2026, month: 11))),
    );
    await tester.pumpAndSettle();
    expect(find.text('NOV'), findsOneWidget);
    expect(find.text('in Nov'), findsOneWidget);
  });

  testWidgets('renders exam-day and passed chip states', (tester) async {
    await tester.pumpWidget(
      harness(
        data(ExamDate.onDay(DateTime(2026, 10, 15))),
        now: DateTime(2026, 10, 15, 8),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    final examDayMonth = tester.widget<Text>(find.text('OCT'));
    final examDayColors = tester.element(find.text('OCT')).colors;
    expect(examDayMonth.style?.color, examDayColors.onAccent);
    expect(find.text('Magandang umaga'), findsOneWidget);

    await tester.pumpWidget(
      harness(
        data(ExamDate.onDay(DateTime(2026, 10, 14))),
        now: DateTime(2026, 10, 15, 20),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Passed'), findsOneWidget);
  });

  testWidgets('dark, 200% text, and reduced motion remain usable',
      (tester) async {
    await tester.pumpWidget(
      harness(
        data(ExamDate.onDay(DateTime(2026, 11, 26))),
        theme: buildDarkTheme(),
        textScaler: const TextScaler.linear(2),
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Magandang gabi'), findsOneWidget);
    expect(find.text('42 days'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets('phone week card edge follows dark mode: $dark',
        (tester) async {
      await tester.pumpWidget(
        harness(data(null), theme: dark ? buildDarkTheme() : buildLightTheme()),
      );
      await tester.pumpAndSettle();
      final card = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(WeekStrip),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = card.decoration! as BoxDecoration;
      expect(decoration.color, dark ? const Color(0xFF1F1F1F) : Colors.white);
      expect(
        (card.foregroundDecoration as BoxDecoration?)?.border,
        dark ? Border.all(color: const Color(0xFF2C2C2C)) : isNull,
      );
    });
  }

  test('greeting bands remain unchanged', () {
    expect(greetingFor(DateTime(2026, 10, 15, 8)), 'Magandang umaga');
    expect(greetingFor(DateTime(2026, 10, 15, 14)), 'Magandang hapon');
    expect(greetingFor(DateTime(2026, 10, 15, 21)), 'Magandang gabi');
  });
}
