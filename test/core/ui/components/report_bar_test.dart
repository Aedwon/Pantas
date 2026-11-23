import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/report_providers.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/report_bar.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _Accepting implements ReportSender {
  @override
  Future<void> send(QuestionReport report) async {}
}

final _restFocus = FocusNode();
final _rest = Focus(
  focusNode: _restFocus,
  child: const Text('1 of 10', key: ValueKey('rest-content')),
);

/// The phone report bar on its own: boards QN_Report, QN_ReportOffline,
/// QN_ReportAgain and QN_ReportLimit.
void main() {
  late List<ReportDelivery?> closed;
  late ValueNotifier<bool> open;

  Future<ReportQueue> pump(
    WidgetTester tester, {
    bool online = true,
    bool still = false,
    Future<void> Function(ReportQueue queue)? seed,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = ReportQueue(
      db,
      sender: online ? _Accepting() : null,
      account: () => 'acct',
      dataOwner: () async => 'acct',
    );
    await seed?.call(queue);
    closed = [];
    open = ValueNotifier(false);
    await tester.pumpAppWithProviders(
      MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          disableAnimations: still,
          platformBrightness: brightness,
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
              child: ValueListenableBuilder<bool>(
                valueListenable: open,
                builder: (context, value, _) => ReportBar(
                  rest: _rest,
                  restState: FloatingBarState.wrong,
                  open: value,
                  questionId: 'q',
                  onClosed: (delivered) {
                    closed.add(delivered);
                    open.value = false;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      overrides: [reportQueueProvider.overrideWithValue(queue)],
    );
    await tester.pumpAndSettle();
    return queue;
  }

  Finder text(String t) => find.text(t);
  final send = find.widgetWithText(PantasButton, 'Send');
  PantasButton sendButton(WidgetTester tester) =>
      tester.widget<PantasButton>(send);

  testWidgets('the morph is 0.42 s on the shared ease', (tester) async {
    expect(reportMorphDuration, const Duration(milliseconds: 420));
    expect(reportMorphDuration, PantasDurations.medium3);
    expect(reportMorphCurve, const Cubic(.32, .72, 0, 1));
    expect(reportMorphCurve, PantasCurves.move);
    await pump(tester);
    final bar = find.byType(FloatingBar);
    final before = tester.getSize(bar).height;
    open.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final mid = tester.getSize(bar).height;
    await tester.pumpAndSettle();
    final full = tester.getSize(bar).height;
    final eased = (mid - before) / (full - before);
    expect(eased, closeTo(reportMorphCurve.transform(120 / 420), .02));
    // 420 ms later the size has landed (a tick after the form's own load).
    expect(full, greaterThanOrEqualTo(250));
  });

  testWidgets('mid-morph the bar and the form share one rounded surface',
      (tester) async {
    await pump(tester);
    open.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The bar content is leaving while the form has not arrived: one bar,
    // no dialog, no second surface.
    expect(find.byType(FloatingBar), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    final rest = tester.widget<Opacity>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('rest-content')),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(rest.opacity, closeTo(1 - 100 / 120, .01));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rest-content')), findsNothing);
  });

  testWidgets('default state: privacy line, Send waits for text',
      (tester) async {
    await pump(tester);
    open.value = true;
    await tester.pumpAndSettle();
    expect(text('Report this question'), findsOneWidget);
    expect(text(reportPrivacyLine), findsOneWidget);
    expect(
      text("Tell us what's wrong. Leave out personal details."),
      findsOneWidget,
    );
    expect(find.textContaining('Something wrong or unclear'), findsNothing);
    expect(sendButton(tester).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Two answers fit.');
    await tester.pump();
    expect(sendButton(tester).onPressed, isNotNull);
  });

  testWidgets('sent: the same bar says thanks, then gives the bar back',
      (tester) async {
    await pump(tester);
    open.value = true;
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Two answers fit.');
    await tester.pump();
    final bar = find.byType(FloatingBar);
    final element = tester.element(bar);
    await tester.tap(send);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(FloatingBar), findsOneWidget);
    expect(identical(tester.element(bar), element), isTrue);
    expect(
      find.descendant(of: bar, matching: text("Thank you. We'll take a look.")),
      findsOneWidget,
    );
    expect(find.byIcon(PantasIcons.check), findsOneWidget);
    expect(find.byType(PantasField), findsNothing);
    expect(closed, isEmpty);
    await tester.pump(reportNoticeHold);
    await tester.pump(const Duration(milliseconds: 700));
    expect(closed, [ReportDelivery.sent]);
    expect(find.byKey(const ValueKey('rest-content')), findsOneWidget);
    expect(text("Thank you. We'll take a look."), findsNothing);
  });

  testWidgets('offline: the bar says it is saved and sends later',
      (tester) async {
    await pump(tester, online: false);
    open.value = true;
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Two answers fit.');
    await tester.pump();
    final bar = find.byType(FloatingBar);
    await tester.tap(send);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 700));
    expect(
      find.descendant(
        of: bar,
        matching: text("Saved. It sends when you're back online."),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(PantasIcons.pendingSend), findsOneWidget);
    expect(find.byType(FloatingBar), findsOneWidget);
    await tester.pump(reportNoticeHold);
    await tester.pump(const Duration(milliseconds: 700));
    expect(closed, [ReportDelivery.saved]);
  });

  testWidgets('again: the form opens as usual with the same line',
      (tester) async {
    await pump(
      tester,
      seed: (q) async {
        await q.add('q', 'Earlier report', DateTime.now());
      },
    );
    open.value = true;
    await tester.pumpAndSettle();
    expect(text(reportPrivacyLine), findsOneWidget);
    expect(
      tester.widget<PantasField>(find.byType(PantasField)).enabled,
      isTrue,
    );
  });

  testWidgets('daily limit: says why, field and Send are off', (tester) async {
    await pump(
      tester,
      seed: (q) async {
        for (var i = 0; i < 20; i++) {
          await q.add('other$i', 'Report $i', DateTime.now());
        }
      },
    );
    open.value = true;
    await tester.pumpAndSettle();
    expect(
      text("You've sent a lot of reports today. You can send more tomorrow."),
      findsOneWidget,
    );
    expect(text(reportPrivacyLine), findsNothing);
    final field = tester.widget<PantasField>(find.byType(PantasField));
    expect(field.enabled, isFalse);
    expect(field.hint, 'Reports open again tomorrow');
    expect(sendButton(tester).onPressed, isNull);
  });

  testWidgets('question limit: says it was reported before', (tester) async {
    await pump(
      tester,
      seed: (q) async {
        for (var i = 0; i < 3; i++) {
          await q.add('q', 'Report $i', DateTime.now());
        }
      },
    );
    open.value = true;
    await tester.pumpAndSettle();
    expect(text('You reported this question before.'), findsOneWidget);
    expect(sendButton(tester).onPressed, isNull);
  });

  testWidgets('Cancel and Escape close the form back into the bar',
      (tester) async {
    await pump(tester);
    open.value = true;
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(closed, [null]);
    expect(find.byKey(const ValueKey('rest-content')), findsOneWidget);
    expect(find.byType(PantasField), findsNothing);

    open.value = true;
    await tester.pumpAndSettle();
    expect(find.byType(PantasField), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(closed, [null, null]);
    expect(find.byKey(const ValueKey('rest-content')), findsOneWidget);
  });

  testWidgets('focus moves into the field and back to the button',
      (tester) async {
    await pump(tester);
    _restFocus.requestFocus();
    await tester.pump();
    expect(_restFocus.hasFocus, isTrue);
    open.value = true;
    await tester.pumpAndSettle();
    final field = tester.widget<PantasField>(find.byType(PantasField));
    expect(field.focusNode!.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_restFocus.hasFocus, isTrue);
  });

  testWidgets('reduced motion: no size animation, a short dissolve',
      (tester) async {
    await pump(tester, still: true);
    final bar = find.byType(FloatingBar);
    open.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    // The size is the form's at once: nothing slides.
    final early = tester.getSize(bar).height;
    await tester.pumpAndSettle();
    expect(tester.getSize(bar).height, early);
    expect(find.byType(AnimatedSize), findsNothing);
  });

  for (final brightness in Brightness.values) {
    testWidgets('renders in $brightness without errors', (tester) async {
      await pump(tester, brightness: brightness);
      open.value = true;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
