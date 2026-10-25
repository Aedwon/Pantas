import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_date_sheet.dart';

void main() {
  final today = DateTime(2026, 10, 28);

  Future<List<ExamDate>> show(
    WidgetTester tester, {
    ExamDate? initial,
    bool requireDay = false,
    bool saving = false,
  }) async {
    final saved = <ExamDate>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: HomeExamDateSheet(
                today: today,
                initial: initial,
                requireDay: requireDay,
                saving: saving,
                onSave: saved.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return saved;
  }

  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, 'Save'))
          .onPressed !=
      null;

  testWidgets('Save stays grey until a month is picked', (tester) async {
    final saved = await show(tester);
    expect(find.text('When is your exam?'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
    await tester.tap(find.byKey(const ValueKey('date-month-11')));
    await tester.pumpAndSettle();
    expect(saveEnabled(tester), isTrue);
    await tester.tap(find.text('Save'));
    expect(saved.single, ExamDate.inMonth(year: 2026, month: 11));
  });

  testWidgets('month-only strip keeps Save grey until a day is picked',
      (tester) async {
    final saved = await show(
      tester,
      initial: ExamDate.inMonth(year: 2026, month: 11),
      requireDay: true,
    );
    expect(saveEnabled(tester), isFalse);
    await tester.tap(find.text('11').first);
    await tester.pumpAndSettle();
    expect(saveEnabled(tester), isTrue);
    await tester.tap(find.text('Save'));
    expect(saved.single, ExamDate.onDay(DateTime(2026, 11, 11)));
  });

  testWidgets('saving shows busy and blocks a second tap', (tester) async {
    await show(
      tester,
      initial: ExamDate.onDay(DateTime(2026, 11, 11)),
      saving: true,
    );
    expect(
      tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, 'Save'))
          .busy,
      isTrue,
    );
  });
}
