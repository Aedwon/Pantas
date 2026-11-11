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
