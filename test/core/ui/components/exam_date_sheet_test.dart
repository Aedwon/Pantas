import 'package:cse_cet_reviewer/core/storage/domain/exam_date.dart';
import 'package:cse_cet_reviewer/core/ui/components/exam_date_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

Future<ExamDateSheetResult?> _open(
  WidgetTester tester, {
  ExamDate? current,
}) async {
  ExamDateSheetResult? result;
  await tester.pumpApp(
    Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          result = await showExamDateSheet(
            context: context,
            current: current,
            today: DateTime(2026, 8, 3),
          );
        },
        child: const Text('open'),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('the sheet offers all three answers', (tester) async {
    await _open(tester);

    expect(find.text('Exam date'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text("I don't know yet"), findsOneWidget);
    // The dash is the day column's unset state.
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('the lede tells the student what the dash is for',
      (tester) async {
    await _open(tester);

    expect(
      find.text('Leave the day on the dash if you only know the month.'),
      findsOneWidget,
    );
  });

  testWidgets('"I don\'t know yet" clears rather than dismissing',
      (tester) async {
    ExamDateSheetResult? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showExamDateSheet(
              context: context,
              current: ExamDate.onDay(DateTime(2026, 10, 12)),
              today: DateTime(2026, 8, 3),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I don't know yet"));
    await tester.pumpAndSettle();

    expect(result, isA<ExamDateCleared>());
  });

  testWidgets('saving with the day on the dash returns month precision',
      (tester) async {
    ExamDateSheetResult? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showExamDateSheet(
              context: context,
              current: ExamDate.inMonth(year: 2026, month: 10),
              today: DateTime(2026, 8, 3),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final chosen = (result! as ExamDateChosen).date;
    expect(chosen.precision, ExamDatePrecision.month);
    expect(chosen.day, isNull);
  });

  testWidgets('the wheels never offer a month already finished',
      (tester) async {
    await _open(tester);

    // today is 3 August 2026, so July 2026 must not be reachable.
    expect(find.text('Jul'), findsNothing);
    expect(find.text('Aug'), findsOneWidget);
  });
}
