import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../helpers/accessibility.dart';

void main() {
  testWidgets('loading announces itself and appears only after 300ms',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      loadingFor(const AsyncLoading<int>()),
    );
    expect(find.byType(LoadingShapes), findsOneWidget);
    expect(find.byKey(const ValueKey('loading-shapes-opacity')), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            (w.properties.liveRegion ?? false) &&
            w.properties.label == 'Loading',
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 299));
    expect(find.byKey(const ValueKey('loading-shapes-opacity')), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    expect(
      find.byKey(const ValueKey('loading-shapes-opacity')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 650));
    expect(
      tester
          .widget<Opacity>(
            find.byKey(const ValueKey('loading-shapes-opacity')),
          )
          .opacity,
      closeTo(.45, .001),
    );
    await pumpAccessibilitySurface(tester, loadingFor(const AsyncData(4)));
    expect(find.byType(LoadingShapes), findsNothing);
    await pumpAccessibilitySurface(
      tester,
      loadingFor(AsyncError<int>(Exception('private'), StackTrace.empty)),
    );
    expect(find.byType(LoadingShapes), findsNothing);
    expect(find.textContaining('private'), findsNothing);
  });

  testWidgets('load failure uses calm copy and retries from keyboard',
      (tester) async {
    var retries = 0;
    final exception = Exception('private database path');
    await pumpAccessibilitySurface(
      tester,
      errorFor('topics', () => retries++, error: exception),
    );
    expect(find.byType(StateView), findsOneWidget);
    expect(find.text('Could not load your topics.'), findsOneWidget);
    expect(find.textContaining('private'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(retries, 1);
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && (w.properties.liveRegion ?? false),
      ),
      findsWidgets,
    );
  });

  testWidgets('save failure stays in place and offers retry', (tester) async {
    var retries = 0;
    await pumpAccessibilitySurface(tester, saveFailureLine(() => retries++));
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(
      tester.widget<PantasButton>(find.byType(PantasButton)).variant,
      PantasButtonVariant.tertiary,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(retries, 1);
    await expectSurvivesTextScale(
      tester,
      saveFailureLine(() {}),
      viewportSize: const Size(390, 844),
    );
  });

  testWidgets('Choose Exam pushes the picker and preserves its return route',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(body: chooseExamFallback(context)),
        ),
        GoRoute(
          path: '/settings/exam/change',
          builder: (_, __) => const Scaffold(body: Text('exam picker')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(find.text('Choose your exam'), findsOneWidget);
    expect(find.text('Pick the exam you are reviewing for.'), findsOneWidget);
    await tester.tap(find.text('Choose Exam'));
    await tester.pumpAndSettle();
    expect(find.text('exam picker'), findsOneWidget);
    expect(router.canPop(), isTrue);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Choose your exam'), findsOneWidget);
  });

  testWidgets('unavailable assessment retains its copy and returns to Quiz',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/assessment',
      routes: [
        GoRoute(
          path: '/assessment',
          builder: (_, __) => Scaffold(body: assessmentNotReady()),
        ),
        GoRoute(
          path: '/quiz',
          builder: (_, __) => const Scaffold(body: Text('Quiz destination')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(find.text("Assessment isn't ready yet"), findsOneWidget);
    expect(
      find.text(
        "We're still adding questions for this exam. "
        'You can use the rest of Pantas for now.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Back to Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz destination'), findsOneWidget);
  });
  for (final brightness in Brightness.values) {
    testWidgets('error and save colors, motion and large text $brightness',
        (tester) async {
      for (final widget in [
        errorFor('progress', () {}),
        saveFailureLine(() {}),
      ]) {
        await pumpAccessibilitySurface(
          tester,
          widget,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        final context = tester.element(find.byType(Scaffold));
        final background = Theme.of(context).scaffoldBackgroundColor;
        for (final text in tester.widgetList<Text>(find.byType(Text))) {
          final foreground = text.style!.color!;
          final button = find.ancestor(
            of: find.text(text.data!),
            matching: find.byType(TextButton),
          );
          final fill = button.evaluate().isEmpty
              ? background
              : tester
                  .widget<TextButton>(button)
                  .style!
                  .backgroundColor!
                  .resolve({})!;
          final realBackground = Color.alphaBlend(fill, background);
          final values = [
            foreground.computeLuminance(),
            realBackground.computeLuminance(),
          ]..sort();
          expect(
            (values.last + .05) / (values.first + .05),
            greaterThanOrEqualTo(4.5),
          );
        }
        await expectSurvivesTextScale(
          tester,
          widget,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
      }
    });
  }
}
