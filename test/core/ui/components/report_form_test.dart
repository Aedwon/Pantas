import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

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
        expect(find.text('Save'), findsOneWidget);
        final send = find.widgetWithText(TextButton, 'Save');
        expect(tester.widget<TextButton>(send).onPressed, isNull);
        await tester.enterText(
          find.byType(TextField),
          'Two answers look right.',
        );
        await tester.pump();
        await tester.tap(send);
        await tester.pumpAndSettle();
        expect(
          find.text('Saved on this device.'),
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
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await ReportQueue(db).pending()).single.questionId, 'entry-q');
  });

  // Design system 4.0: the form is built from the system's components.
  testWidgets('the phone form uses PantasField and PantasButton',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = ReportQueue(db);
    var closed = 0;
    await pumpAccessibilitySurface(
      tester,
      ReportForm(questionId: 'q', queue: queue, onClose: () => closed++),
      viewportSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();
    final field = find.byType(PantasField);
    expect(field, findsOneWidget);
    // No visible label: the placeholder is the hint, the name is semantic.
    expect(tester.widget<PantasField>(field).showLabel, isFalse);
    expect(tester.widget<PantasField>(field).multiline, isTrue);
    expect(tester.widget<PantasField>(field).maxLines, 5);
    expect(tester.widget<PantasField>(field).hint, 'What did you notice?');
    expect(find.bySemanticsLabel(RegExp('What did you notice')), findsWidgets);
    expect(
      find.ancestor(of: find.byType(TextField), matching: field),
      findsOneWidget,
    );
    // Cancel and Save are PantasButtons, and no raw TextButton sits beside.
    final buttons = find.byType(PantasButton);
    expect(buttons, findsNWidgets(2));
    expect(
      find.descendant(of: buttons, matching: find.text('Cancel')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: buttons, matching: find.text('Save')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is TextButton,
        description: 'a TextButton outside a PantasButton',
      ),
      findsNWidgets(2),
      reason: 'only the two inside PantasButton',
    );
    // Save waits for text; Cancel closes; saving queues.
    expect(
      tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, 'Save'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Cancel'));
    expect(closed, 1);
    await tester.enterText(find.byType(TextField), 'Two answers look right.');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await queue.pending()).single.questionId, 'q');
    expect(find.text('Saved on this device.'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the wide form uses PantasField, WebButton and PantasIconButton',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = ReportQueue(db);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
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
    expect(find.byType(PantasField), findsOneWidget);
    expect(
      tester.widget<PantasField>(find.byType(PantasField)).showLabel,
      isFalse,
    );
    expect(find.widgetWithText(WebButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(WebButton, 'Save'), findsOneWidget);
    // The close icon is a PantasIconButton with its name.
    expect(find.byTooltip('Close report'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byTooltip('Close report'),
        matching: find.byType(PantasIconButton),
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'Wrong answer key.');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await queue.pending()).single.questionId, 'q');
  });

  for (final wide in [false, true]) {
    testWidgets(
        'reduced motion fades the report in place over 150 ms '
        '(wide=$wide)', (tester) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final queue = ReportQueue(db);
      await tester.pumpWidget(
        MaterialApp(
          theme: wide ? buildLightTheme(web: true) : buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final form = find.byType(ReportForm);
      final opacity = find
          .ancestor(of: form, matching: find.byType(Opacity))
          .evaluate()
          .map((e) => (e.widget as Opacity).opacity)
          .reduce((a, b) => a * b);
      expect(opacity, inExclusiveRange(0, 1));
      final topAt60 = tester.getTopLeft(form);
      await tester.pump(const Duration(milliseconds: 200));
      // No slide: it faded where it stays.
      expect(tester.getTopLeft(form), topAt60);
    });
  }
}
