import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('wide report opens at top, drags, and queues dark=$dark',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final queue = ReportQueue(db);
      await queue.add('q', 'Earlier report', DateTime.now());
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => openQuestionReport(context, 'q', queue: queue),
                child: const Text('Report'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('You reported this question before.'),
        findsOneWidget,
      );
      final header = find.text('Report this question');
      final before = tester.getTopLeft(header);
      expect(tester.getRect(find.byType(ReportForm)).top, 60);
      expect(tester.getRect(find.byType(ReportForm)).right, 1420);
      expect(tester.getSize(find.byType(ReportForm)).width, 380);
      await tester.drag(header, const Offset(-100, 50));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(header).dx, lessThan(before.dx));
      await tester.enterText(
        find.byType(TextField),
        'Two choices seem correct.',
      );
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect((await queue.pending()).length, 2);
      expect(find.byType(ReportForm), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
