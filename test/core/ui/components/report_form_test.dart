import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'report at $brightness and $scale saves text and disables blank',
          (tester) async {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        final queue = ReportQueue(db);
        await pumpAccessibilitySurface(
          tester,
          ReportForm(
            questionId: 'q',
            queue: queue,
            onClose: () {},
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Text>(find.text('Report this question'))
              .style!
              .fontSize,
          17,
        );
        expect(
          tester
              .widget<Text>(find.text('Report this question'))
              .style!
              .fontWeight,
          FontWeight.w700,
        );
        expect(find.text('Send'), findsOneWidget);
        final send = find.widgetWithText(TextButton, 'Send');
        expect(tester.widget<TextButton>(send).onPressed, isNull);
        await tester.enterText(
          find.byType(TextField),
          'Two answers look right.',
        );
        await tester.pump();
        await tester.tap(send);
        await tester.pumpAndSettle();
        expect(
          find.text("Saved. It sends when you're back online."),
          findsOneWidget,
        );
        expect((await queue.pending()).single.questionId, 'q');
        expect(find.byType(TextField), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('report entry opens for the supplied question', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => openQuestionReport(
                context,
                'entry-q',
                queue: ReportQueue(db),
              ),
              child: const Text('Report'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Wrong answer key.');
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect((await ReportQueue(db).pending()).single.questionId, 'entry-q');
  });
}
