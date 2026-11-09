// Explanation below 1134 wide (design system 4.0, Explanation README): a
// modal 440 Drawer that opens on reveal, takes focus to its heading, traps
// Tab, closes on Esc or the scrim and returns focus to the bar's action. At
// 1134 and up it is a region beside the question.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedSession;

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: DateTime.utc(2026));
  }

  /// Swaps in the session after the student checked an answer.
  void checked(QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: DateTime.utc(2026));
  }

  @override
  Future<void> start({
    required String examId,
    String? topicId,
    int count = 10,
    int? randomSeed,
  }) async {}
}

late _Controller _controller;
late QuizSession _after;

Future<void> _pump(
  WidgetTester tester,
  double width, {
  bool still = false,
  bool dark = false,
  double scale = 1,
}) async {
  debugWebPlatformOverride = true;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = Size(width, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final completed = completedSession(batch: true);
  final before = completed.copyWith(
    currentIndex: 3,
    outcomes: completed.outcomes.take(3).toList(),
  );
  _after = before.copyWith(outcomes: completed.outcomes.take(4).toList());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        flaggedIdsProvider.overrideWith((_) async => <String>{}),
        quizControllerProvider.overrideWith(
          (ref) => _controller = _Controller(ref, before),
        ),
      ],
      child: MaterialApp(
        theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: still,
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        ),
        home: const QuizPage(examId: 'e', proIsActive: false),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _drawer => find.byKey(const ValueKey('web-side-drawer'));
Finder get _barNext => find.descendant(
      of: find.byType(WebBottomBar),
      matching: find.widgetWithText(WebButton, 'Next'),
    );

/// The widget that holds primary focus, climbed to its nearest [T].
T? _focusedWithin<T extends Widget>() =>
    FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<T>();

void main() {
  testWidgets(
      'below 1134 the explanation opens in a Drawer on reveal, '
      'with focus on its heading', (tester) async {
    await _pump(tester, 1100);
    expect(_drawer, findsNothing);
    expect(_barNext, findsNothing);
    _controller.checked(_after);
    await tester.pumpAndSettle();
    expect(_drawer, findsOneWidget);
    expect(tester.getSize(_drawer).width, 440);
    expect(find.text('Explanation'), findsWidgets);
    expect(find.text('Explanation 3'), findsOneWidget);
    // The foot: the counter and Next, and the bar's action is hidden.
    expect(
      find.descendant(of: _drawer, matching: find.text('4 of 10')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _drawer,
        matching: find.widgetWithText(WebButton, 'Next'),
      ),
      findsOneWidget,
    );
    expect(_barNext, findsNothing);
    // Focus is on the heading.
    final heading = tester.widget<Focus>(
      find.byKey(const ValueKey('explanation-heading')),
    );
    expect(heading.focusNode!.hasPrimaryFocus, isTrue);
  });

  testWidgets('Tab stays inside the Drawer', (tester) async {
    await _pump(tester, 1100);
    _controller.checked(_after);
    await tester.pumpAndSettle();
    final seen = <String>{};
    for (var i = 0; i < 6; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      final context = FocusManager.instance.primaryFocus?.context;
      expect(context, isNotNull);
      expect(
        find.descendant(of: _drawer, matching: find.byWidget(context!.widget)),
        findsWidgets,
        reason: 'Tab $i left the Drawer',
      );
      seen.add('${context.widget.runtimeType}');
    }
    expect(_drawer, findsOneWidget);
  });

  testWidgets('Esc closes the Drawer and focus returns to the bar action',
      (tester) async {
    await _pump(tester, 1100);
    _controller.checked(_after);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_drawer, findsNothing);
    expect(_barNext, findsOneWidget);
    expect(_focusedWithin<WebButton>()?.label, 'Next');
    // Closed, the explanation can be opened again.
    await tester.tap(find.text('Show Explanation'));
    await tester.pumpAndSettle();
    expect(_drawer, findsOneWidget);
    expect(_barNext, findsNothing);
  });

  testWidgets('the scrim and the Close button close it', (tester) async {
    await _pump(tester, 1100);
    _controller.checked(_after);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(40, 400));
    await tester.pumpAndSettle();
    expect(_drawer, findsNothing);
    expect(_focusedWithin<WebButton>()?.label, 'Next');
    await tester.tap(find.text('Show Explanation'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close explanation'));
    await tester.pumpAndSettle();
    expect(_drawer, findsNothing);
  });

  testWidgets('Next in the foot moves on and closes the Drawer',
      (tester) async {
    await _pump(tester, 1100);
    _controller.checked(_after);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: _drawer,
        matching: find.widgetWithText(WebButton, 'Next'),
      ),
    );
    await tester.pumpAndSettle();
    expect(_drawer, findsNothing);
  });

  for (final width in [1134.0, 1440.0]) {
    testWidgets('at $width there is no Drawer and no scrim: a region',
        (tester) async {
      await _pump(tester, width);
      _controller.checked(_after);
      await tester.pumpAndSettle();
      expect(_drawer, findsNothing);
      expect(find.byType(AnimatedModalBarrier), findsNothing);
      expect(find.byKey(const ValueKey('web-answer-column')), findsOneWidget);
      expect(find.text('Explanation 3'), findsOneWidget);
      expect(_barNext, findsOneWidget);
      expect(find.text('Show Explanation'), findsNothing);
    });
  }

  testWidgets('1133 is below the split: a Drawer', (tester) async {
    await _pump(tester, 1133);
    _controller.checked(_after);
    await tester.pumpAndSettle();
    expect(_drawer, findsOneWidget);
  });

  testWidgets('reduced motion fades the Drawer in place over 150 ms',
      (tester) async {
    await _pump(tester, 1100, still: true);
    _controller.checked(_after);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final fade = find.ancestor(of: _drawer, matching: find.byType(Opacity));
    expect(fade, findsWidgets);
    final opacity = tester.widget<Opacity>(fade.first).opacity;
    expect(opacity, inExclusiveRange(0, 1));
    // No slide: the Drawer is already at its place.
    expect(tester.getTopRight(_drawer).dx, 1100);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.widget<Opacity>(fade.first).opacity, 1);
  });

  for (final cell in [
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) DsCell(1100, scale, dark: dark),
  ]) {
    testWidgets('the Drawer does not overflow ($cell)', (tester) async {
      await tester.runAsync(loadDsFonts);
      await _pump(tester, 1100, dark: cell.dark, scale: cell.scale);
      _controller.checked(_after);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_drawer, findsOneWidget);
    });
  }
}
