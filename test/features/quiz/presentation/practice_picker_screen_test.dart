import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/data/repos/practice_preferences_repository.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_practice.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_screen.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

const index = PracticeIndex([
  PracticeSubjectEntry(
    id: 's',
    name: 'Mathematics',
    topics: [
      PracticeTopicEntry(
        id: 't',
        name: 'Algebra',
        questionCount: 40,
        lessons: [
          PracticeLessonEntry(
            id: 'a',
            title: 'Linear equations',
            isRead: true,
            questionCount: 20,
          ),
          PracticeLessonEntry(
            id: 'b',
            title: 'Quadratics',
            isRead: false,
            questionCount: 20,
          ),
          PracticeLessonEntry(
            id: 'none',
            title: 'Empty lesson',
            isRead: false,
            questionCount: 0,
          ),
        ],
      ),
      PracticeTopicEntry(
        id: 'empty',
        name: 'Trigonometry',
        questionCount: 0,
        lessons: [],
      ),
    ],
  ),
]);

class _MockStartPractice extends Mock implements StartPractice {}

class _FailingPreferences extends PracticePreferencesRepository {
  _FailingPreferences(super.db);
  bool failSave = false;
  Completer<void>? pendingSave;
  Completer<void>? saveEntered;
  int reads = 0;

  @override
  Future<SavedPracticePicks> read(String examId) {
    reads++;
    return super.read(examId);
  }

  @override
  Future<void> save(
    String examId, {
    required Set<String> lessonIds,
    required PracticeUnitMode mode,
    required int value,
    required Map<String, int> adjustments,
  }) async {
    if (pendingSave != null) {
      saveEntered?.complete();
      await pendingSave!.future;
    }
    if (failSave) throw StateError('private storage diagnostic');
    return super.save(
      examId,
      lessonIds: lessonIds,
      mode: mode,
      value: value,
      adjustments: adjustments,
    );
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(<PracticeUnit>[]);
    registerFallbackValue(<String, int>{});
    registerFallbackValue(DateTime.utc(2026));
  });
  Future<PracticePreferencesRepository> pump(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    double scale = 1,
    PracticeIndex source = index,
    Set<String>? saved,
    PracticeUnitMode mode = PracticeUnitMode.questions,
    int value = 10,
    StartPractice? start,
    int? measuredPace,
    bool reduceMotion = true,
    Future<int?> Function()? loadPace,
    Future<PracticeIndex> Function()? loadIndex,
    bool settle = true,
  }) async {
    final db = inMemoryDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
    final prefs = _FailingPreferences(db);
    if (saved != null) {
      await prefs.save(
        'e',
        lessonIds: saved,
        mode: mode,
        value: value,
        adjustments: {},
      );
    }
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authStateProvider.overrideWith(
            (_) => Stream.value(const AuthState.anonymous(uid: 'test')),
          ),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          practicePreferencesRepositoryProvider.overrideWithValue(prefs),
          practiceIndexProvider('e').overrideWith(
            (_) => loadIndex?.call() ?? Future<PracticeIndex>.value(source),
          ),
          practicePaceProvider('e').overrideWith(
            (_) => loadPace?.call() ?? Future<int?>.value(measuredPace),
          ),
          if (start != null) startPracticeProvider.overrideWithValue(start),
        ],
        child: MaterialApp.router(
          theme: brightness == Brightness.dark
              ? buildDarkTheme()
              : buildLightTheme(),
          routerConfig: GoRouter(
            initialLocation: '/quiz/practice/e',
            routes: [
              GoRoute(
                path: '/quiz',
                builder: (context, state) => Scaffold(
                  body: Column(
                    children: [
                      const Text('Quiz home'),
                      TextButton(
                        onPressed: () => context.push('/quiz/practice/e'),
                        child: const Text('Customize'),
                      ),
                    ],
                  ),
                ),
              ),
              GoRoute(
                path: '/quiz/practice/e',
                builder: (_, state) => const PracticePickerScreen(examId: 'e'),
              ),
              GoRoute(
                path: '/quiz/practice/e/run',
                builder: (context, state) => Scaffold(
                  body: Column(
                    children: [
                      const Text('Practice running'),
                      Text('Custom source: ${state.extra is ({
                        String customSessionId
                      }) ? (state.extra! as ({
                          String customSessionId
                        })).customSessionId : 'missing'}'),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Return to picker'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(scale),
              disableAnimations: reduceMotion,
            ),
            child: child!,
          ),
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PracticePickerScreen)),
    );
    await tester.runAsync(() async {
      await container.read(authStateProvider.future);
      await container.read(activeExamFocusProvider.future);
    });
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
    return prefs;
  }

  testWidgets(
      'custom Start retains the boundary before pending preference writes',
      (tester) async {
    final start = _MockStartPractice();
    var calls = 0;
    when(
      () => start(
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
        units: any(named: 'units'),
        perUnit: any(named: 'perUnit'),
        countsByUnit: any(named: 'countsByUnit'),
        now: any(named: 'now'),
        canPersist: any(named: 'canPersist'),
      ),
    ).thenAnswer((_) async {
      calls++;
      return StartPracticeStarted(
        QuizSession.start(
          sessionId: 'late',
          examId: 'e',
          questions: const [],
          startedAt: DateTime.utc(2026),
        ),
      );
    });
    final prefs = await pump(tester, start: start) as _FailingPreferences;
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PracticePickerScreen)),
    );
    await tester.runAsync(
      () => SyncActiveContextStore(container.read(appDatabaseProvider))
          .clearStable(),
    );
    prefs
      ..pendingSave = Completer<void>()
      ..saveEntered = Completer<void>();
    await tester.tap(find.byKey(const ValueKey('scope-select-t')));
    await tester.pump();
    expect(prefs.saveEntered!.isCompleted, isTrue);
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.runAsync(
      () => SyncLocalStateWiper(container.read(appDatabaseProvider)).wipeAll(),
    );
    prefs.pendingSave!.complete();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 2)),
      );
    }
    expect(calls, 0);
    expect(find.text('Practice running'), findsNothing);
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('picker and length states at $brightness scale=$scale',
          (tester) async {
        final prefs = await pump(tester, brightness: brightness, scale: scale);
        expect(find.text('Customize your own'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('Customize your own')).style!.fontSize,
          28,
        );
        expect(find.text('Nothing picked yet'), findsOneWidget);
        final start = tester.widget<PantasButton>(
          find.widgetWithText(PantasButton, 'Start'),
        );
        expect(start.onPressed, isNull);
        await tester.tap(find.byKey(const ValueKey('scope-select-t')));
        await tester.pumpAndSettle();
        expect(find.text('2 lessons picked'), findsOneWidget);
        expect(find.text('20 questions · ~17 min'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('practice-size')));
        await tester.pumpAndSettle();
        expect(find.text('How long?'), findsOneWidget);
        expect(
          find.text('You set the questions. Time follows.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Total time'));
        await tester.pumpAndSettle();
        expect(
          find.text('You set the time. Questions follow.'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Adjust'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Adjust'));
        await tester.pumpAndSettle();
        expect(find.text('Reset'), findsOneWidget);
        await tester.ensureVisible(find.text('Reset'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Done'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        expect(find.text('Nothing picked yet'), findsOneWidget);
        expect((await prefs.read('e')).lessonIds, isEmpty);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('singleton Questions overrides, Reset and wheel change',
      (tester) async {
    await pump(tester, saved: {'a'});
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase Linear equations'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('practice-count-Linear equations')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const ValueKey('practice-count-Linear equations'),
            ),
          )
          .data,
      '11',
    );
    expect(
      tester.widget<ValueWheel>(find.byType(ValueWheel)).values[
          tester.widget<ValueWheel>(find.byType(ValueWheel)).selectedIndex],
      '10',
    );
    await tester.ensureVisible(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const ValueKey('practice-count-Linear equations'),
            ),
          )
          .data,
      '10',
    );
    await tester.ensureVisible(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase Linear equations'));
    await tester.pumpAndSettle();
    final wheel = find.byType(ValueWheel);
    final focus =
        find.descendant(of: wheel, matching: find.byType(Focus)).first;
    Focus.of(
      tester.element(
        find
            .descendant(
              of: focus,
              matching: find.byType(ListView),
            )
            .first,
      ),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const ValueKey('practice-count-Linear equations'),
            ),
          )
          .data,
      '11',
    );
    expect(
      tester
          .widget<ValueWheel>(wheel)
          .values[tester.widget<ValueWheel>(wheel).selectedIndex],
      '11',
    );
  });

  testWidgets(
      'selected Questions tab preserves the manual count and base wheel',
      (tester) async {
    final prefs = await pump(tester, saved: {'a'});
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase Linear equations'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Questions per lesson'));
    await tester.pumpAndSettle();
    final saved = await prefs.read('e');
    expect(saved.value, 10);
    expect(saved.adjustments, {'lesson:a': 11});
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const ValueKey('practice-count-Linear equations'),
            ),
          )
          .data,
      '11',
    );
  });

  testWidgets('saved picks discard removed and questionless lesson ids',
      (tester) async {
    await pump(tester, saved: {'a', 'none', 'removed'}, value: 12);
    expect(find.text('1 lesson picked'), findsOneWidget);
    expect(find.text('12 questions · ~10 min'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scope-expand-t')));
    await tester.pumpAndSettle();
    expect(find.text('Unread'), findsWidgets);
    expect(find.text('No questions yet'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('many lessons scroll and too-short times cannot be selected',
      (tester) async {
    final many = PracticeIndex([
      PracticeSubjectEntry(
        id: 's',
        name: 'Subject',
        topics: [
          PracticeTopicEntry(
            id: 't',
            name: 'Topic',
            questionCount: 400,
            lessons: [
              for (var i = 0; i < 8; i++)
                PracticeLessonEntry(
                  id: '$i',
                  title: 'Lesson $i',
                  isRead: true,
                  questionCount: 50,
                ),
            ],
          ),
        ],
      ),
    ]);
    await pump(
      tester,
      source: many,
      saved: {for (var i = 0; i < 8; i++) '$i'},
      mode: PracticeUnitMode.minutes,
      value: 5,
    );
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
    expect(wheel.invalidIndices, contains(0));
    expect(wheel.values[wheel.selectedIndex], '10');
    expect(find.byKey(const ValueKey('practice-pick-list')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Total time caption and singleton adjustments stay bounded',
      (tester) async {
    await pump(tester, saved: {'a'}, mode: PracticeUnitMode.minutes);
    expect(find.text('~12 questions · 10 min'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    final segment = tester.widget<Text>(find.text('Questions per lesson'));
    expect(segment.style!.fontWeight, FontWeight.w600);
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    for (final verb in ['Increase', 'Decrease']) {
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(
                IconButton,
                verb == 'Increase' ? Icons.add : Icons.remove,
              ),
            )
            .onPressed,
        isNull,
      );
    }
    expect(
      tester.widget<ValueWheel>(find.byType(ValueWheel)).values[
          tester.widget<ValueWheel>(find.byType(ValueWheel)).selectedIndex],
      '10',
    );
  });

  testWidgets('rapid selections and overrides survive leaving and reopening',
      (tester) async {
    final prefs = await pump(tester, saved: {'a'});
    await tester.tap(find.byKey(const ValueKey('scope-expand-t')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scope-select-b')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('scope-select-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase Quadratics'));
    await tester.pumpAndSettle();
    final saved = await prefs.read('e');
    expect(saved.lessonIds, {'b'});
    expect(saved.value, 10);
    expect(saved.adjustments, {'lesson:b': 11});
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz home'), findsOneWidget);
    await tester.tap(find.text('Customize'));
    await tester.pumpAndSettle();
    expect(find.text('1 lesson picked'), findsOneWidget);
    expect(find.text('11 questions · ~9 min'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Start forwards actual override and keeps picker below run route',
      (tester) async {
    final start = _MockStartPractice();
    final pending = Completer<StartPracticeResult>();
    when(
      () => start(
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
        units: any(named: 'units'),
        perUnit: any(named: 'perUnit'),
        countsByUnit: any(named: 'countsByUnit'),
        now: any(named: 'now'),
        canPersist: any(named: 'canPersist'),
      ),
    ).thenAnswer((_) => pending.future);
    await pump(tester, saved: {'a'}, start: start);
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase Linear equations'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.tap(find.text('Start'));
    await tester.pump();
    verify(
      () => start(
        userId: 'local',
        examId: 'e',
        units: any(named: 'units'),
        perUnit: 10,
        countsByUnit: {'lesson:a': 11},
        now: any(named: 'now'),
        canPersist: any(named: 'canPersist'),
      ),
    ).called(1);
    pending.complete(
      StartPracticeStarted(
        QuizSession.start(
          sessionId: 'practice-test',
          examId: 'e',
          questions: const [],
          startedAt: DateTime.utc(2026, 10, 14),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Practice running'), findsOneWidget);
    expect(find.text('Custom source: practice-test'), findsOneWidget);
    await tester.tap(find.text('Return to picker'));
    await tester.pumpAndSettle();
    expect(find.text('11 questions · ~9 min'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Start failure retains picks without opening a run route',
      (tester) async {
    final start = _MockStartPractice();
    when(
      () => start(
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
        units: any(named: 'units'),
        perUnit: any(named: 'perUnit'),
        countsByUnit: any(named: 'countsByUnit'),
        now: any(named: 'now'),
        canPersist: any(named: 'canPersist'),
      ),
    ).thenAnswer((_) async => const StartPracticeNoQuestions('empty'));
    await pump(tester, saved: {'a'}, start: start);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Practice running'), findsNothing);
    expect(find.text('1 lesson picked'), findsOneWidget);
    expect(find.text('Could not start your quiz.'), findsOneWidget);
    expect(find.byType(StateView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Total time redistributes counts and keeps its selected budget',
      (tester) async {
    final split = PracticeIndex([
      PracticeSubjectEntry(
        id: 's',
        name: 'Subject',
        topics: [
          for (final id in ['a', 'b'])
            PracticeTopicEntry(
              id: id,
              name: 'Topic $id',
              questionCount: 20,
              lessons: [
                PracticeLessonEntry(
                  id: id,
                  title: 'Lesson $id',
                  isRead: true,
                  questionCount: 20,
                ),
              ],
            ),
        ],
      ),
    ]);
    final prefs = await pump(
      tester,
      source: split,
      saved: {'a', 'b'},
      mode: PracticeUnitMode.minutes,
    );
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase Lesson a'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('practice-count-Lesson a')))
          .data,
      '7',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('practice-count-Lesson b')))
          .data,
      '5',
    );
    final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
    expect(wheel.values[wheel.selectedIndex], '10');
    expect((await prefs.read('e')).adjustments, {'lesson:a': 7, 'lesson:b': 5});
    await tester.tap(find.text('Total time'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 10);
    expect((await prefs.read('e')).adjustments, {'lesson:a': 7, 'lesson:b': 5});
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('practice-count-Lesson a')))
          .data,
      '6',
    );
    expect((await prefs.read('e')).adjustments, isEmpty);
  });

  testWidgets('large request displays actual pool caps and derived hours',
      (tester) async {
    final long = PracticeIndex([
      PracticeSubjectEntry(
        id: 's',
        name: 'Subject',
        topics: [
          PracticeTopicEntry(
            id: 't',
            name: 'Topic',
            questionCount: 400,
            lessons: [
              for (var i = 0; i < 8; i++)
                PracticeLessonEntry(
                  id: '$i',
                  title: 'Lesson $i',
                  isRead: true,
                  questionCount: 50,
                ),
            ],
          ),
        ],
      ),
    ]);
    await pump(
      tester,
      source: long,
      saved: {for (var i = 0; i < 8; i++) '$i'},
      value: 50,
    );
    expect(find.text('400 questions · ~5.6 hr'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    expect(find.text('hours'), findsOneWidget);
    expect(find.text('5.6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('counts stay at real capacity when the base requests more',
      (tester) async {
    await pump(tester, saved: {'a'}, value: 50);
    expect(find.text('20 questions · ~17 min'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add))
          .onPressed,
      isNull,
    );
  });

  testWidgets('measured pace replaces the starting estimate on the picker',
      (tester) async {
    await pump(tester, saved: {'a'}, measuredPace: 40000);
    expect(find.text('10 questions · ~7 min'), findsOneWidget);
  });

  testWidgets('failed Start retry retries the launch', (tester) async {
    final start = _MockStartPractice();
    var calls = 0;
    when(
      () => start(
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
        units: any(named: 'units'),
        perUnit: any(named: 'perUnit'),
        countsByUnit: any(named: 'countsByUnit'),
        now: any(named: 'now'),
        canPersist: any(named: 'canPersist'),
      ),
    ).thenAnswer((_) async {
      calls++;
      if (calls == 1) return const StartPracticeNoQuestions('empty');
      return StartPracticeStarted(
        QuizSession.start(
          sessionId: 'retry',
          examId: 'e',
          questions: const [],
          startedAt: DateTime.utc(2026, 10, 14),
        ),
      );
    });
    await pump(tester, saved: {'a'}, start: start);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Practice running'), findsOneWidget);
  });

  testWidgets('picker header uses drawn navigation and heading positions',
      (tester) async {
    await pump(tester, saved: {'a'});
    expect(tester.getTopLeft(find.byIcon(PantasIcons.back)).dx, 4);
    expect(
      tester.getTopLeft(find.text('Customize your own')),
      const Offset(20, 54),
    );
  });

  testWidgets('length summary and adjustment labels match drawn metrics',
      (tester) async {
    await pump(tester, saved: {'a', 'b'});
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    expect(find.text('PICKED'), findsNothing);
    expect(tester.widget<Text>(find.text('Adjust')).style!.fontSize, 15);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('practice-summary-divider')))
          .width,
      .5,
    );
    final label = tester.getTopLeft(find.text('Algebra').last);
    final meta = tester.getTopLeft(find.text('2 lessons'));
    expect((label.dy - meta.dy).abs(), lessThan(5));
  });

  testWidgets('empty picker keeps drawn helper and dimmed solid Start',
      (tester) async {
    await pump(tester);
    expect(find.text('Pick a topic or a lesson'), findsOneWidget);
    final start = find.widgetWithText(PantasButton, 'Start');
    final button = tester.widget<TextButton>(
      find.descendant(of: start, matching: find.byType(TextButton)),
    );
    expect(
      button.style!.backgroundColor!.resolve({}),
      tester.element(start).colors.accentFill,
    );
    expect(
      tester
          .widget<Opacity>(
            find.descendant(of: start, matching: find.byType(Opacity)).first,
          )
          .opacity,
      .35,
    );
  });

  testWidgets('picker caption carries the drawn downward caret',
      (tester) async {
    await pump(tester, saved: {'a'});
    expect(
      tester.widget<Text>(find.text('1 lesson picked')).style!.fontWeight,
      FontWeight.w700,
    );
    final caret = find.descendant(
      of: find.byKey(const ValueKey('practice-size')),
      matching: find.byType(RotatedBox),
    );
    expect(tester.widget<RotatedBox>(caret).quarterTurns, 1);
  });

  for (final pace in [0, -50000]) {
    testWidgets(
        'nonpositive pace $pace uses the approved estimate in the time wheel',
        (tester) async {
      await pump(
        tester,
        saved: {'a'},
        mode: PracticeUnitMode.minutes,
        measuredPace: pace,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('~12 questions · 10 min'), findsOneWidget);
      expect(
        tester
            .widget<PantasButton>(find.widgetWithText(PantasButton, 'Start'))
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(const ValueKey('practice-size')));
      await tester.pumpAndSettle();
      final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
      expect(wheel.invalidIndices, isEmpty);
      expect(wheel.values[wheel.selectedIndex], '10');
    });
  }

  testWidgets('positive sub-minute estimate stays bounded without a clamp',
      (tester) async {
    await pump(tester, saved: {'a'}, value: 3, measuredPace: 5000);
    expect(find.text('3 questions · under 1 min'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    expect(find.text('<1'), findsOneWidget);
    expect(find.text('minute'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending picker announces loading before delayed shapes appear',
      (tester) async {
    final pending = Completer<int?>();
    addTearDown(() {
      if (!pending.isCompleted) pending.complete(null);
    });
    final semantics = tester.ensureSemantics();
    try {
      await pump(tester, loadPace: () => pending.future, settle: false);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 299));
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsOneWidget,
      );
      pending.complete(50000);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Loading'), findsNothing);
      expect(find.text('Nothing picked yet'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('load failure uses shared state and retries every picker input',
      (tester) async {
    var failed = true;
    var poolReads = 0;
    var paceReads = 0;
    final prefs = await pump(
      tester,
      saved: {'a'},
      loadIndex: () async {
        poolReads++;
        if (failed) throw StateError('private index diagnostic');
        return index;
      },
      loadPace: () async {
        paceReads++;
        return 50000;
      },
    ) as _FailingPreferences;
    expect(find.byType(StateView), findsOneWidget);
    expect(find.text('Could not load your picks.'), findsOneWidget);
    expect(find.textContaining('private index'), findsNothing);
    expect(find.text('Customize your own'), findsOneWidget);
    expect(prefs.reads, 1);
    failed = false;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(poolReads, 2);
    expect(paceReads, 2);
    expect(prefs.reads, 2);
    expect(find.text('1 lesson picked'), findsOneWidget);
  });

  testWidgets('save failure retains picks and shared retry saves them',
      (tester) async {
    final prefs = (await pump(tester) as _FailingPreferences)..failSave = true;
    await tester.tap(find.byKey(const ValueKey('scope-select-t')));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('private storage'), findsNothing);
    expect(find.text('2 lessons picked'), findsOneWidget);
    prefs.failSave = false;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).lessonIds, {'a', 'b'});
    expect(find.text('Could not save your progress.'), findsNothing);
    expect(find.text('2 lessons picked'), findsOneWidget);
  });

  testWidgets('empty picker keeps its helper with a positive sub-minute pace',
      (tester) async {
    await pump(tester, measuredPace: 5000);
    expect(find.text('Nothing picked yet'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    expect(find.text('How long?'), findsNothing);
    expect(find.text('<1'), findsNothing);
    expect(find.text('Pick a topic or a lesson'), findsOneWidget);
  });

  testWidgets('time budget stays selected with a positive fast pace',
      (tester) async {
    await pump(
      tester,
      saved: {'a'},
      mode: PracticeUnitMode.minutes,
      value: 5,
      measuredPace: 5000,
    );
    expect(find.text('~20 questions · 5 min'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    expect(find.text('<1'), findsNothing);
    expect(find.text('minutes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  PracticeIndex capIndex(List<int> capacities) => PracticeIndex([
        PracticeSubjectEntry(
          id: 's',
          name: 'Subject',
          topics: [
            PracticeTopicEntry(
              id: 't',
              name: 'Topic',
              questionCount: capacities.fold<int>(0, (sum, n) => sum + n),
              lessons: [
                for (final (i, n) in capacities.indexed)
                  PracticeLessonEntry(
                    id: '$i',
                    title: 'Lesson $i',
                    isRead: true,
                    questionCount: n,
                  ),
              ],
            ),
          ],
        ),
      ]);

  testWidgets('mode switches match six lessons and settle at the same count',
      (tester) async {
    final prefs = await pump(
      tester,
      source: capIndex(List.filled(6, 50)),
      saved: {for (var i = 0; i < 6; i++) '$i'},
    );
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Total time'));
      await tester.pumpAndSettle();
      expect((await prefs.read('e')).value, 50);
      await tester.tap(find.text('Questions per lesson'));
      await tester.pumpAndSettle();
      expect((await prefs.read('e')).value, 10);
    }
  });

  testWidgets('mode switches match capped aggregate counts', (tester) async {
    final prefs = await pump(
      tester,
      source: capIndex([2, 4, 50]),
      saved: {'0', '1', '2'},
    );
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Total time'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 25);
    await tester.tap(find.text('Questions per lesson'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 10);
  });

  testWidgets(
      'repeated mode toggles keep the original capped conversion target',
      (tester) async {
    final prefs = await pump(
      tester,
      source: capIndex([24, 2, 13]),
      saved: {'0', '1', '2'},
      value: 13,
      measuredPace: 70000,
    );
    expect(find.text('28 questions · ~33 min'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    final converted = <int>[];
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Total time'));
      await tester.pumpAndSettle();
      converted.add((await prefs.read('e')).value);
      await tester.tap(find.text('Questions per lesson'));
      await tester.pumpAndSettle();
      converted.add((await prefs.read('e')).value);
    }
    expect(converted, [45, 13, 45, 13]);
  });

  Future<PracticePreferencesRepository> cappedConversion(
    WidgetTester tester, {
    Future<int?> Function()? loadPace,
    Future<PracticeIndex> Function()? loadIndex,
  }) async {
    final prefs = await pump(
      tester,
      source: capIndex([24, 2, 13]),
      saved: {'0', '1', '2'},
      value: 13,
      measuredPace: 70000,
      loadPace: loadPace,
      loadIndex: loadIndex,
    );
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Total time'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 45);
    return prefs;
  }

  testWidgets('explicit wheel change starts a new conversion target',
      (tester) async {
    final prefs = await cappedConversion(tester);
    final wheel = find.byType(ValueWheel);
    Focus.of(
      tester.element(
        find
            .descendant(
              of: wheel,
              matching: find.byType(ListView),
            )
            .first,
      ),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 40);
    await tester.tap(find.text('Questions per lesson'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 11);
  });

  testWidgets('manual allocation starts a new conversion target',
      (tester) async {
    final prefs = await cappedConversion(tester);
    await tester.tap(find.text('Questions per lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Decrease Topic'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Total time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Questions per lesson'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 12);
  });

  testWidgets('Reset starts a new conversion target from the even time split',
      (tester) async {
    final prefs = await cappedConversion(tester);
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Questions per lesson'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 12);
  });

  testWidgets('changed selected pool starts a new conversion target',
      (tester) async {
    var source = capIndex([24, 2, 13]);
    final prefs = await cappedConversion(
      tester,
      loadIndex: () async => source,
    );
    source = capIndex([24, 2, 3]);
    ProviderScope.containerOf(tester.element(find.byType(PracticePickerScreen)))
        .invalidate(practiceIndexProvider('e'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Questions per lesson'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 13);
  });

  testWidgets('changed effective pace starts a new conversion target',
      (tester) async {
    var pace = 70000;
    final prefs = await cappedConversion(tester, loadPace: () async => pace);
    pace = 50000;
    ProviderScope.containerOf(tester.element(find.byType(PracticePickerScreen)))
        .invalidate(practicePaceProvider('e'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Questions per lesson'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 18);
  });

  testWidgets('changed selection starts a new conversion target',
      (tester) async {
    final prefs = await cappedConversion(tester);
    await tester.tap(find.text('Questions per lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scope-caret-t')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scope-select-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Total time'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).value, 30);
  });

  testWidgets('matching clears manual overrides on explicit mode change',
      (tester) async {
    final prefs = await pump(tester, saved: {'a'});
    await tester.tap(find.byKey(const ValueKey('practice-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase Linear equations'));
    await tester.pumpAndSettle();
    expect((await prefs.read('e')).adjustments, {'lesson:a': 11});
    await tester.tap(find.text('Total time'));
    await tester.pumpAndSettle();
    final saved = await prefs.read('e');
    expect(saved.adjustments, isEmpty);
    expect(saved.value, 10);
  });

  testWidgets('normal picker motion steps bar at 200ms then fades Clear',
      (tester) async {
    await pump(tester, reduceMotion: false);
    await tester.tap(find.byKey(const ValueKey('scope-select-t')));
    await tester.pump();
    expect(find.text('Nothing picked yet'), findsOneWidget);
    expect(
      tester
          .widget<PantasButton>(
            find.widgetWithText(PantasButton, 'Start'),
          )
          .onPressed,
      isNull,
    );
    await tester.pump(const Duration(milliseconds: 199));
    expect(find.text('Nothing picked yet'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('2 lessons picked'), findsOneWidget);
    expect(
      tester
          .widget<Opacity>(
            find.byKey(const ValueKey('practice-clear-opacity')),
          )
          .opacity,
      0,
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester
          .widget<Opacity>(
            find.byKey(const ValueKey('practice-clear-opacity')),
          )
          .opacity,
      closeTo(.5, .01),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester
          .widget<Opacity>(
            find.byKey(const ValueKey('practice-clear-opacity')),
          )
          .opacity,
      1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('picker uses the drawn thirteen-point filled check',
      (tester) async {
    await pump(tester, saved: {'a', 'b'});
    expect(tester.widget<Icon>(find.byIcon(PantasIcons.check).first).size, 13);
  });

  testWidgets('pace refresh keeps the picker visible and updates its estimate',
      (tester) async {
    final refreshed = Completer<int?>();
    addTearDown(() {
      if (!refreshed.isCompleted) refreshed.complete(null);
    });
    var reads = 0;
    await pump(
      tester,
      saved: {'a'},
      loadPace: () {
        reads++;
        return reads == 1 ? Future<int?>.value() : refreshed.future;
      },
    );
    expect(find.text('10 questions · ~8 min'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PracticePickerScreen)),
    )..invalidate(practicePaceProvider('e'));
    final loading = container.read(practicePaceProvider('e'));
    expect(reads, 2);
    expect(loading.isLoading, isTrue);
    await tester.pump();
    await tester.pump();
    expect(find.text('10 questions · ~8 min'), findsOneWidget);
    refreshed.complete(40000);
    await tester.pumpAndSettle();
    expect(find.text('10 questions · ~7 min'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('motion hold never delays saving picks or survives leaving',
      (tester) async {
    final prefs = await pump(tester, reduceMotion: false);
    await tester.tap(find.byKey(const ValueKey('scope-select-t')));
    await tester.pump();
    expect(find.text('Nothing picked yet'), findsOneWidget);
    expect((await prefs.read('e')).lessonIds, {'a', 'b'});
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
