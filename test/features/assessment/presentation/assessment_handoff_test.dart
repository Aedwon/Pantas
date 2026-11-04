import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/onboarding_routes.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_debrief_loading.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/presentation/assessment_results_motion.dart';
import 'package:pantas/features/assessment/presentation/assessment_skeletons.dart';
import 'package:pantas/features/home/application/study_delivery.dart';

import '../../../helpers/in_memory_database.dart';

int homeActivations = 0;

final _routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/assessment/e',
    routes: [
      ...onboardingRoutes(ref),
      GoRoute(
        path: '/home',
        // Home's main button holds focus, and a key repeat that reaches it
        // activates it, as on the real Home.
        builder: (_, __) => Scaffold(
          body: Center(
            child: ElevatedButton(
              autofocus: true,
              onPressed: () => homeActivations++,
              child: const Text('Home'),
            ),
          ),
        ),
      ),
    ],
  ),
);

/// Home with the assessment opened above it, as the real Home opens it. Home
/// stays mounted underneath, and once the assessment is done its Today panel
/// builds with an Enter shortcut and takes focus, as the real Home does.
final _stackedRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/home',
    routes: [
      // The web routes, which ask the open assessment before browser Back.
      ...onboardingRoutes(ref, web: true),
      GoRoute(path: '/home', builder: (_, __) => const _StackedHome()),
    ],
  ),
);

class _StackedHome extends ConsumerWidget {
  const _StackedHome();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done =
        ref.watch(assessmentCompletedProvider('e')).valueOrNull ?? false;
    const body = Center(child: Text('Home'));
    return Scaffold(
      body: done
          ? CallbackShortcuts(
              bindings: {
                const SingleActivator(
                  LogicalKeyboardKey.enter,
                  includeRepeats: false,
                ): () => homeActivations++,
              },
              child: const Focus(
                autofocus: true,
                skipTraversal: true,
                child: body,
              ),
            )
          : body,
    );
  }
}

void main() {
  late AppDatabase db;
  late ContentDatabase content;

  setUp(() async {
    homeActivations = 0;
    db = inMemoryDatabase();
    content = inMemoryContentDatabase();
    await seedContentExam(content, examId: 'e', code: 'CSE', name: 'CSE');
    await seedContentSubject(
      content,
      subjectId: 's',
      examId: 'e',
      name: 'Verbal',
    );
    await seedContentTopic(
      content,
      topicId: 't',
      subjectId: 's',
      name: 'Vocabulary',
    );
    await seedContentQuestion(
      content,
      questionId: 'q',
      topicId: 't',
      examId: 'e',
      stem: 'A question?',
      correctText: 'First choice',
      wrongText: 'Second choice',
    );
  });
  tearDown(() async {
    debugWebPlatformOverride = null;
    await db.close();
    await content.close();
  });

  /// Pumps the real assessment and results routes at [width].
  Future<void> pumpRoutes(
    WidgetTester tester, {
    required double width,
    List<Override> overrides = const [],
    bool reduceMotion = false,
    String location = '/assessment/e',
    bool stacked = false,
  }) async {
    debugWebPlatformOverride = width >= 1024;
    tester.view
      ..physicalSize = Size(width, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    final router =
        container.read(stacked ? _stackedRouterProvider : _routerProvider);
    if (location != '/assessment/e') router.go(location);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: width >= 1024 ? buildDarkTheme(web: true) : buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reduceMotion,
            ),
            child: child!,
          ),
          routerConfig: router,
        ),
      ),
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    if (stacked) {
      unawaited(router.push<void>('/assessment/e'));
      await tester.pumpAndSettle();
    }
  }

  Future<void> answerAndFinish(
    WidgetTester tester, {
    required bool wide,
  }) async {
    await tester.tap(find.text('First choice'));
    await tester.pump();
    if (wide) {
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    } else {
      await tester.tap(find.text('Finish'));
    }
  }

  void expectNoLoadingScreen() {
    expect(find.byType(SkeletonQuestionPage), findsNothing);
    expect(find.byType(AssessmentResultsSkeleton), findsNothing);
    expect(find.byType(WebDebriefLoading), findsNothing);
    expect(find.byType(SkeletonPulse), findsNothing);
  }

  for (final width in [390.0, 1440.0]) {
    final wide = width >= 1024;
    final name = wide ? 'wide' : 'phone';

    testWidgets('$name: the last question goes straight to results',
        (tester) async {
      final gate = Completer<void>();
      await pumpRoutes(
        tester,
        width: width,
        overrides: [
          studySettingsCaptureProvider.overrideWithValue(({examId}) async {
            await gate.future;
            return StudySettingsPublication(() async {});
          }),
        ],
      );
      await answerAndFinish(tester, wide: wide);
      var sawResults = false;
      for (var i = 0; i < 180; i++) {
        // Saving takes about 200 ms here, as it can on a slow connection.
        if (i == 12) gate.complete();
        await tester.pump(const Duration(milliseconds: 16));
        // Every frame shows the question or the results, never a loading
        // screen, a blank page or a skeleton.
        expectNoLoadingScreen();
        final question = find.text('A question?').evaluate().isNotEmpty;
        final results =
            find.text("Where you're starting").evaluate().isNotEmpty;
        expect(question || results, isTrue, reason: 'blank frame $i');
        sawResults = sawResults || results;
      }
      expect(sawResults, isTrue);
      expect(find.text('A question?'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name: results play once and end on the final values',
        (tester) async {
      await pumpRoutes(tester, width: width);
      await answerAndFinish(tester, wide: wide);
      // Past the route fade, part way through the sequence.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final gauge = find.byType(HalfRingGauge);
      final during = tester.widget<HalfRingGauge>(gauge).fraction;
      expect(during, inInclusiveRange(0.01, 0.99));
      await tester.pumpAndSettle();
      final ring = tester.widget<HalfRingGauge>(gauge);
      expect(ring.fraction, 1);
      for (final bar in tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      )) {
        expect(bar.value, 1);
      }
      expect(find.text("Where you're starting"), findsOneWidget);
      expect(find.text('Go to Today'), findsOneWidget);
    });

    testWidgets('$name: reduced motion shows the final values at once',
        (tester) async {
      await pumpRoutes(tester, width: width, reduceMotion: true);
      await answerAndFinish(tester, wide: wide);
      await tester.pump();
      await tester.pump();
      final ring = tester.widget<HalfRingGauge>(find.byType(HalfRingGauge));
      expect(ring.fraction, 1);
      final title = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.text("Where you're starting"),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(title.opacity.value, 1);
      for (final bar in tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      )) {
        expect(bar.value, 1);
      }
    });

    testWidgets('$name: Go to Today leaves without a loading screen',
        (tester) async {
      await pumpRoutes(tester, width: width);
      await answerAndFinish(tester, wide: wide);
      await tester.pumpAndSettle();
      if (wide) {
        // Enter works while the sequence is still playing.
        expect(find.byType(WebButton), findsWidgets);
      }
      await tester.tap(find.text('Go to Today'));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expectNoLoadingScreen();
      }
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  }

  testWidgets('Enter and Go to Today work at once, before the sequence ends',
      (tester) async {
    await pumpRoutes(tester, width: 1440);
    await answerAndFinish(tester, wide: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Where you're starting"), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a held Enter ends on the results page and does not reach Home',
      (tester) async {
    await pumpRoutes(tester, width: 1440);
    await answerAndFinish(tester, wide: true);
    await tester.pumpAndSettle();
    expect(find.text("Where you're starting"), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // The key is still down: the page waits, and repeats stop here.
    expect(find.text("Where you're starting"), findsOneWidget);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text("Where you're starting"), findsNothing);
    expect(homeActivations, 0);
  });

  // 3L-7: with Home underneath, Enter on Go to Today opened the first lesson.
  // Home's Today panel takes focus when the assessment finishes, so the press
  // reached its Enter shortcut as well as this page's.
  testWidgets('with Home underneath, one Enter goes Home and starts nothing',
      (tester) async {
    await pumpRoutes(tester, width: 1440, stacked: true);
    await answerAndFinish(tester, wide: true);
    await tester.pumpAndSettle();
    expect(find.text("Where you're starting"), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Home'), findsOneWidget);
    expect(find.text("Where you're starting"), findsNothing);
    expect(homeActivations, 0);
  });

  // 3M-7: browser Back changes the address without a pop, so the assessment
  // left at once and the answers were lost. Go back to an address outside the
  // assessment, as the browser's Back does.
  group('browser Back in the assessment', () {
    testWidgets('shows the leave dialog and keeps the answer', (tester) async {
      await pumpRoutes(tester, width: 1440, stacked: true);
      final router = GoRouter.of(tester.element(find.text('A question?')));
      await tester.tap(find.text('First choice'));
      await tester.pump();

      router.go('/home');
      await tester.pumpAndSettle();
      expect(find.text('Leave the assessment?'), findsOneWidget);
      expect(find.text('A question?'), findsOneWidget);

      // Keep going: still on the question, and the answer is still picked.
      await tester.tap(find.text('Keep Going'));
      await tester.pumpAndSettle();
      expect(find.text('Leave the assessment?'), findsNothing);
      expect(find.text('A question?'), findsOneWidget);
      final choice = tester.widget<WebAnswerOption>(
        find.ancestor(
          of: find.text('First choice'),
          matching: find.byType(WebAnswerOption),
        ),
      );
      expect(choice.state, WebOptionState.selected);

      // Back again, and this time leave: Home, with no second dialog.
      router.go('/home');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(find.text('Leave the assessment?'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('does not ask when the assessment finishes itself',
        (tester) async {
      await pumpRoutes(tester, width: 1440, stacked: true);
      await answerAndFinish(tester, wide: true);
      await tester.pumpAndSettle();
      expect(find.text("Where you're starting"), findsOneWidget);
      expect(find.text('Leave the assessment?'), findsNothing);
    });
  });

  testWidgets('Go to Today does not wait for a key that never comes up',
      (tester) async {
    await pumpRoutes(tester, width: 1440);
    await answerAndFinish(tester, wide: true);
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
  });

  testWidgets('a resize does not play the sequence again', (tester) async {
    await pumpRoutes(tester, width: 1440);
    await answerAndFinish(tester, wide: true);
    await tester.pumpAndSettle();
    expect(
      tester.widget<HalfRingGauge>(find.byType(HalfRingGauge)).fraction,
      1,
    );
    tester.view.physicalSize = const Size(390, 900);
    debugWebPlatformOverride = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      tester.widget<HalfRingGauge>(find.byType(HalfRingGauge)).fraction,
      1,
    );
    for (final bar in tester.widgetList<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    )) {
      expect(bar.value, 1);
    }
  });

  testWidgets('slow saving shows work on Finish only after 400 ms',
      (tester) async {
    final gate = Completer<void>();
    await pumpRoutes(
      tester,
      width: 1440,
      overrides: [
        studySettingsCaptureProvider.overrideWithValue(({examId}) async {
          await gate.future;
          return StudySettingsPublication(() async {});
        }),
      ],
    );
    await answerAndFinish(tester, wide: true);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('A question?'), findsOneWidget);
    expect(find.byType(SkeletonQuestionPage), findsNothing);
    expect(
      tester.widget<WebButton>(find.widgetWithText(WebButton, 'Finish')).busy,
      isFalse,
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('A question?'), findsOneWidget);
    expect(
      tester.widget<WebButton>(find.widgetWithText(WebButton, 'Finish')).busy,
      isTrue,
    );
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text("Where you're starting"), findsOneWidget);
    expect(await AssessmentRepository(db).hasCompletedForExam('e'), isTrue);
  });

  test('the bars start in order and all finish inside the sequence', () {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: AssessmentResultsSequence.duration,
    );
    addTearDown(controller.dispose);
    final sequence = AssessmentResultsSequence(controller, subjectCount: 4);
    controller.value = 0.5;
    final values = <double>[for (var i = 0; i < 4; i++) sequence.bar(i).value];
    final descending = [...values]..sort((a, b) => b.compareTo(a));
    expect(values, orderedEquals(descending));
    controller.value = 1;
    expect(
      [
        sequence.title.value,
        sequence.ring.value,
        sequence.plan.value,
        for (var i = 0; i < 4; i++) sequence.bar(i).value,
      ],
      everyElement(1),
    );
    expect(AssessmentResultsSequence.duration.inMilliseconds, 1400);
  });
}
