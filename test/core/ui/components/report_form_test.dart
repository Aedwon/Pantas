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

class _Accepting implements ReportSender {
  final sent = <QuestionReport>[];
  @override
  Future<void> send(QuestionReport report) async => sent.add(report);
}

class _Refusing implements ReportSender {
  @override
  Future<void> send(QuestionReport report) async =>
      throw const ReportRefused('question-limit');
}

class _Offline implements ReportSender {
  @override
  Future<void> send(QuestionReport report) async =>
      throw const ReportUnavailable();
}

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'phone form at $brightness and $scale saves text and hands over '
          'the delivery', (tester) async {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        final queue = ReportQueue(db);
        final saved = <ReportDelivery>[];
        await pumpAccessibilitySurface(
          tester,
          ReportForm(
            questionId: 'q',
            queue: queue,
            onClose: () {},
            onSaved: saved.add,
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
        );
        await tester.pumpAndSettle();
        final title = tester.widget<Text>(find.text('Report this question'));
        expect(title.style!.fontSize, 17);
        expect(title.style!.fontWeight, FontWeight.w700);
        expect(find.text(reportPrivacyLine), findsOneWidget);
        expect(find.text('Save'), findsNothing);
        final send = find.widgetWithText(PantasButton, 'Send');
        expect(tester.widget<PantasButton>(send).onPressed, isNull);
        await tester.enterText(
          find.byType(TextField),
          'Two answers look right.',
        );
        await tester.pump();
        await tester.tap(send);
        await tester.pumpAndSettle();
        expect(saved, [ReportDelivery.saved]);
        expect((await queue.pending()).single.questionId, 'q');
        // The form never draws its own confirmation: the bar does.
        expect(find.textContaining('Saved'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the phone form uses PantasField and PantasButton',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final db = inMemoryDatabase();
    addTearDown(db.close);
    var closed = 0;
    await pumpAccessibilitySurface(
      tester,
      ReportForm(
        questionId: 'q',
        queue: ReportQueue(db),
        onClose: () => closed++,
        onSaved: (_) {},
      ),
      viewportSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();
    final field = find.byType(PantasField);
    expect(field, findsOneWidget);
    expect(tester.widget<PantasField>(field).showLabel, isFalse);
    expect(tester.widget<PantasField>(field).multiline, isTrue);
    expect(tester.widget<PantasField>(field).hint, 'What did you notice?');
    expect(find.bySemanticsLabel(RegExp('What did you notice')), findsWidgets);
    final buttons = find.byType(PantasButton);
    expect(buttons, findsNWidgets(2));
    expect(
      find.descendant(of: buttons, matching: find.text('Cancel')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: buttons, matching: find.text('Send')),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    expect(closed, 1);
    semantics.dispose();
  });

  void wide(WidgetTester tester) {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<Future<ReportDelivery?>?> openWide(
    WidgetTester tester,
    ReportQueue queue, {
    String? examId,
    int? questionVersion,
    bool dark = false,
  }) async {
    Future<ReportDelivery?>? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => opened = openQuestionReport(
                context,
                'q',
                queue: queue,
                examId: examId,
                questionVersion: questionVersion,
              ),
              child: const Text('Report'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    return opened;
  }

  testWidgets('the wide form is the drop-down of QN_Report', (tester) async {
    wide(tester);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = ReportQueue(db);
    await openWide(tester, queue);
    expect(find.byType(PantasField), findsOneWidget);
    expect(
      tester.widget<PantasField>(find.byType(PantasField)).showLabel,
      isFalse,
    );
    expect(find.widgetWithText(WebButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(WebButton, 'Send'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    expect(find.text(reportPrivacyLine), findsOneWidget);
    expect(find.byTooltip('Close report'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byTooltip('Close report'),
        matching: find.byType(PantasIconButton),
      ),
      findsOneWidget,
    );
    // Board: 380 wide, 60 down, 20 in from the right.
    final rect = tester.getRect(find.byType(ReportForm));
    expect(rect.width, 380);
    expect(rect.top, 60);
    expect(rect.right, 1420);
    // Board QN_Report: 40 px buttons (the 40 px control height token).
    for (final label in ['Cancel', 'Send']) {
      expect(
        tester.getSize(find.widgetWithText(WebButton, label)).height,
        40,
        reason: label,
      );
    }
    await tester.enterText(find.byType(TextField), 'Wrong answer key.');
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect((await queue.pending()).single.questionId, 'q');
  });

  testWidgets('wide again: the same line in a soft box', (tester) async {
    wide(tester);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = ReportQueue(db);
    await queue.add('q', 'Earlier report', DateTime.now());
    await openWide(tester, queue);
    final line =
        find.text('You reported this before. Leave out personal details.');
    expect(line, findsOneWidget);
    expect(
      find.ancestor(of: line, matching: find.byType(Container)),
      findsWidgets,
    );
    expect(
      tester.widget<PantasField>(find.byType(PantasField)).enabled,
      isTrue,
    );
  });

  testWidgets('wide daily limit: why, field off, Send off with no key hint',
      (tester) async {
    wide(tester);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = ReportQueue(db);
    for (var i = 0; i < 20; i++) {
      await queue.add('o$i', 'Report $i', DateTime.now());
    }
    await openWide(tester, queue);
    expect(
      find.text("You've sent a lot of reports today. "
          'You can send more tomorrow.'),
      findsOneWidget,
    );
    final field = tester.widget<PantasField>(find.byType(PantasField));
    expect(field.enabled, isFalse);
    expect(field.hint, 'Reports open again tomorrow');
    final send = tester.widget<WebButton>(
      find.widgetWithText(WebButton, 'Send'),
    );
    expect(send.onPressed, isNull);
    expect(send.keyHint, isNull);
  });

  testWidgets('a report the server accepted says so (wide)', (tester) async {
    wide(tester);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sender = _Accepting();
    final queue = ReportQueue(
      db,
      sender: sender,
      account: () => 'a',
      dataOwner: () async => 'a',
    );
    final opened = await openWide(
      tester,
      queue,
      examId: 'cse-pro',
      questionVersion: 3,
    );
    await tester.enterText(find.byType(TextField), 'Wrong answer key.');
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(await opened, ReportDelivery.sent);
    expect(
      reportDeliveryText(ReportDelivery.sent),
      "Thank you. We'll take a look.",
    );
    expect(sender.sent.single.examId, 'cse-pro');
    expect(sender.sent.single.questionVersion, 3);
    expect(await queue.pending(), isEmpty);
  });

  testWidgets('a report that could not send is saved (wide)', (tester) async {
    wide(tester);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = ReportQueue(
      db,
      sender: _Offline(),
      account: () => 'a',
      dataOwner: () async => 'a',
    );
    final opened = await openWide(tester, queue);
    await tester.enterText(find.byType(TextField), 'Wrong answer key.');
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(await opened, ReportDelivery.saved);
    expect(
      reportDeliveryText(ReportDelivery.saved),
      "Saved. It sends when you're back online.",
    );
    expect(await queue.pending(), hasLength(1));
  });

  for (final isWide in [false, true]) {
    testWidgets(
        'a report the server refused shows the limit, never thanks '
        '(wide=$isWide)', (tester) async {
      debugWebPlatformOverride = isWide;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = isWide ? const Size(1440, 900) : const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final queue = ReportQueue(
        db,
        sender: _Refusing(),
        account: () => 'a',
        dataOwner: () async => 'a',
      );
      final saved = <ReportDelivery>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: isWide ? buildLightTheme(web: true) : buildLightTheme(),
          home: Scaffold(
            body: ReportForm(
              questionId: 'q',
              queue: queue,
              onClose: () {},
              onSaved: saved.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Wrong answer key.');
      await tester.pump();
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Thank you'), findsNothing);
      expect(find.text('You reported this question before.'), findsOneWidget);
      expect(saved, isEmpty);
    });

    testWidgets('typing stops at the longest message (wide=$isWide)',
        (tester) async {
      debugWebPlatformOverride = isWide;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = isWide ? const Size(1440, 900) : const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.pumpWidget(
        MaterialApp(
          theme: isWide ? buildLightTheme(web: true) : buildLightTheme(),
          home: Scaffold(
            body: ReportForm(
              questionId: 'q',
              queue: ReportQueue(db),
              onClose: () {},
              onSaved: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'm' * 1500);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        hasLength(ReportQueue.maxMessageLength),
      );
    });
  }
}
