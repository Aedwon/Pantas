import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(HomeMastheadData data, {DateTime? now}) {
  return ProviderScope(
    overrides: [
      homeMastheadProvider.overrideWith((ref) async => data),
    ],
    child: MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: HomeMasthead(now: now ?? DateTime(2026, 8, 2, 20)),
      ),
    ),
  );
}

void main() {
  testWidgets('greets by name in the evening', (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.onDay(DateTime(2026, 9, 13)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // The name shares the greeting's line and its size.
    expect(find.text('Magandang gabi, Aedwon'), findsOneWidget);
  });

  testWidgets('a day-precision date prints a day count', (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.onDay(DateTime(2026, 9, 13)),
        ),
        now: DateTime(2026, 8, 2, 20),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('42 days to go'), findsOneWidget);
    expect(find.text('UPCAT'), findsOneWidget);
  });

  testWidgets('a month-precision date never prints a day count',
      (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.inMonth(year: 2026, month: 10),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your exam is in October 2026'), findsOneWidget);
    expect(find.textContaining('days'), findsNothing);
  });

  testWidgets('no date prints the exam short name alone', (tester) async {
    await tester.pumpWidget(
      harness(
        const HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('UPCAT'), findsOneWidget);
    expect(find.textContaining('days'), findsNothing);
    expect(find.textContaining('Your exam'), findsNothing);
  });

  testWidgets('no name closes the greeting rather than trailing a comma',
      (tester) async {
    await tester.pumpWidget(
      harness(
        const HomeMastheadData(
          name: null,
          examShortName: 'UPCAT',
          examDate: null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // A comma leads into a name and reads as an unfinished sentence
    // without one.
    expect(find.text('Add your name'), findsNothing);
    expect(find.text('Magandang gabi!'), findsOneWidget);
    expect(find.text('UPCAT'), findsOneWidget);
  });

  testWidgets('an exam today prints zero days, not a negative', (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.onDay(DateTime(2026, 8, 2)),
        ),
        now: DateTime(2026, 8, 2, 20),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0 days to go'), findsOneWidget);
  });

  testWidgets('one day reads "1 day", not "1 days"', (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.onDay(DateTime(2026, 8, 3)),
        ),
        now: DateTime(2026, 8, 2, 20),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 day to go'), findsOneWidget);
  });

  testWidgets('the kicker follows the hour', (tester) async {
    for (final (hour, kicker) in [
      (8, 'Magandang umaga, Aedwon'),
      (14, 'Magandang hapon, Aedwon'),
      (21, 'Magandang gabi, Aedwon'),
    ]) {
      await tester.pumpWidget(
        harness(
          const HomeMastheadData(
            name: 'Aedwon',
            examShortName: 'UPCAT',
            examDate: null,
          ),
          now: DateTime(2026, 8, 2, hour),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(kicker), findsOneWidget);
    }
  });
}
