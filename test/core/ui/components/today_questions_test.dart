import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('empty Today question ring matches the drawn border',
      (tester) async {
    await tester.pumpApp(
      TodayQuestionRow(
        title: 'New questions',
        subtitle: "From today's lessons",
        done: 0,
        total: 7,
        onTap: () {},
      ),
    );
    await tester.pumpAndSettle();
    final colors = tester.element(find.byType(TodayQuestionRow)).colors;
    expect(
      find.byKey(const ValueKey('progress-ring-paint')),
      paints..circle(radius: 11, strokeWidth: 2, color: colors.separator),
    );
  });

  discardGapTests();

  for (final scale in [1.0, 2.0]) {
    testWidgets('Today question row opens the shared sheet at scale=$scale',
        (tester) async {
      var opened = false;
      var started = false;
      await tester.pumpApp(
        MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            textScaler: TextScaler.linear(scale),
          ),
          child: Column(
            children: [
              TodayQuestionRow(
                title: 'Reviews',
                subtitle: 'Questions due today',
                done: 2,
                total: 6,
                onTap: () => opened = true,
              ),
              TodayQuestionsSheet(
                title: 'Reviews',
                done: 2,
                total: 6,
                rows: const [Text('Session 1'), Text('Session 2')],
                startLabel: 'Start Reviews',
                onStart: () => started = true,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Reviews').first);
      expect(opened, isTrue);
      await tester.tap(find.text('Start Reviews'));
      expect(started, isTrue);
      expect(find.text('2 of 6'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }
}

// Board A, P_Sheet (own session paused): the Discard line's box is 20.25 high
// (15 px, line height 1.35) with 16 above it (flex gap 10 + padding 6) and 16
// below it before the sheet's 34 bottom rest. Its centre is 26.125 from both
// the Resume button's bottom and the end of the content.
void discardGapTests() {
  testWidgets('own-session Discard text centres 26.125 from Resume and the end',
      (tester) async {
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: TodayQuestionsSheet(
            title: 'Reviews',
            done: 1,
            total: 11,
            showCount: false,
            rows: const [Text('Session 1')],
            startLabel: 'Resume',
            onStart: () {},
            onDiscard: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final resume = tester.getRect(
      find
          .ancestor(of: find.text('Resume'), matching: find.byType(InkWell))
          .first,
    );
    final text = tester.getRect(find.text('Discard this session'));
    final sheet = tester.getRect(find.byType(TodayQuestionsSheet));
    final bottomRest = sheet.bottom - 34;
    expect(text.center.dy - resume.bottom, closeTo(26.125, 0.6));
    expect(bottomRest - text.center.dy, closeTo(26.125, 0.6));
  });
}
