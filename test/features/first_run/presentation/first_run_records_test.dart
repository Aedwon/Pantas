import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';

import '../../../helpers/recording_telemetry.dart';
import '../first_run_harness.dart';

void main() {
  testWidgets('a full run records nothing that counts', (tester) async {
    final telemetry = RecordingTelemetry();
    final rig = await pumpFirstRun(
      tester,
      extra: [telemetryProvider.overrideWithValue(telemetry)],
    );
    // intro, lesson, three questions (one wrong), end
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Answer 3 Questions'));
    await tester.tap(find.text('Answer 3 Questions'));
    await tester.pumpAndSettle();
    for (final pick in ['3.75%', '17/20', '1/4']) {
      await tester.tap(find.text(pick));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Next question'));
      await tester.pumpAndSettle(const Duration(seconds: 4));
    }
    expect(find.text('You finished the lesson'), findsOneWidget);
    final db = rig.db;
    await tester.runAsync(() async {
      expect(await db.select(db.attemptsLocal).get(), isEmpty);
      expect(await db.select(db.reviewStateLocal).get(), isEmpty);
      expect(await db.select(db.reviewLogs).get(), isEmpty);
      expect(await db.select(db.streakLocal).get(), isEmpty);
      expect(await db.select(db.quizSessions).get(), isEmpty);
      expect(await db.select(db.dailyNewCardIntro).get(), isEmpty);
    });
    expect(
      telemetry.events.map((e) => e.name),
      isNot(contains('questionAnswered')),
    );
    expect(telemetry.events, isEmpty);
  });

  testWidgets('the lesson counts as read once, after the dwell and the end',
      (tester) async {
    final rig = await pumpFirstRun(
      tester,
      progressJson: '{"uid":"u1","examId":"exam_upcat","step":"lesson",'
          '"picks":{},"checked":[]}',
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    // Before the end of the shown text is reached it is not read.
    var rows = await tester.runAsync(
      () => rig.db.select(rig.db.lessonProgressLocal).get(),
    );
    expect(rows, isEmpty);
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -3000));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    rows = await tester.runAsync(
      () => rig.db.select(rig.db.lessonProgressLocal).get(),
    );
    expect(rows!.map((r) => r.lessonId), ['l1']);
  });

  testWidgets('before the dwell the lesson is not read', (tester) async {
    final rig = await pumpFirstRun(
      tester,
      progressJson: '{"uid":"u1","examId":"exam_upcat","step":"lesson",'
          '"picks":{},"checked":[]}',
    );
    final rows = await tester.runAsync(
      () => rig.db.select(rig.db.lessonProgressLocal).get(),
    );
    expect(rows, isEmpty);
    await tester.pump(const Duration(milliseconds: 200));
  });
}
