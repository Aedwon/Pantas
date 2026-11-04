import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/plan_provider.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/plan_day_page.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';
import 'package:pantas/features/home/presentation/plan_screen.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

import 'package:pantas/features/roadmap/domain/roadmap.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('today deep link waits for Home data after its guard',
      (tester) async {
    final pending = Completer<HomeTodayData>();
    var signals = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firstScreenSignalProvider
              .overrideWithValue(FirstScreenSignal(() => signals++)),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          todayQuestionLauncherProvider.overrideWith(_PlanLauncher.new),
          homeTodayLoaderProvider
              .overrideWith((_) => (exam, guard) => pending.future),
          planDayViewProvider('2026-10-26').overrideWith(
            (_) async => PlanDayView(
              date: DateTime(2026, 10, 26),
              plan: DayPlan(
                day: DateTime(2026, 10, 26),
                lessonIds: const [],
                reviewQuestionIds: const [],
                newQuestionIds: const [],
                isMockDay: false,
                advancedIds: const {},
              ),
              remaining: null,
              lessons: const [],
              kind: 'today',
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanDayScreen(date: '2026-10-26'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(signals, 0);
    pending.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(signals, 1);
  });

  testWidgets('coverage loading never shows the Free invitation',
      (tester) async {
    final pending = Completer<bool>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proForActiveExamProvider.overrideWith((_) => pending.future),
          planViewProvider(5).overrideWith(
            (_) async =>
                const PlanView(done: 0, total: 0, nodes: [], history: []),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanWeekScreen(start: '2026-10-25'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Unlock with Pro'), findsNothing);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    pending.complete(false);
    await tester.pumpAndSettle();
  });

  testWidgets('a day opened from Home names Home as its return destination',
      (tester) async {
    final date = DateTime(2026, 10, 26);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          todayQuestionLauncherProvider.overrideWith(_PlanLauncher.new),
          planDayViewProvider('2026-10-26').overrideWith(
            (_) async => PlanDayView(
              date: date,
              plan: DayPlan(
                day: date,
                lessonIds: const ['l'],
                reviewQuestionIds: const [],
                newQuestionIds: const [],
                isMockDay: false,
                advancedIds: const {},
              ),
              remaining: null,
              lessons: const [
                HomeTodayLesson(
                  id: 'l',
                  title: 'Cells',
                  subject: 'Science',
                  minutes: 8,
                  read: false,
                ),
              ],
              kind: 'future',
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanDayScreen(date: '2026-10-26'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cells'), findsOneWidget);
  });
  testWidgets('a week that starts before the plan shows the days it has',
      (tester) async {
    DayPlan plan(int day) => DayPlan(
          day: DateTime(2026, 10, day),
          lessonIds: const [],
          reviewQuestionIds: const [],
          newQuestionIds: const [],
          isMockDay: false,
          advancedIds: const {},
        );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStudyCoverageProvider.overrideWith((_) => true),
          planWeekViewProvider('2026-10-18').overrideWith(
            (_) async => [
              for (var i = 0; i < 7; i++)
                PlanDayView(
                  date: DateTime(2026, 10, 18 + i),
                  plan: i < 2 ? null : plan(18 + i),
                  remaining: null,
                  lessons: const [],
                  kind: i < 2 ? 'unknown' : 'future',
                ),
            ],
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanWeekScreen(start: '2026-10-18'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load your plan.'), findsNothing);
    expect(
      tester.widget<PlanWeekPage>(find.byType(PlanWeekPage)).days,
      hasLength(5),
    );
  });
  testWidgets('week days without lessons say what they are, never blank',
      (tester) async {
    DayPlan plan(int day, {bool mock = false, bool rest = false}) => DayPlan(
          day: DateTime(2026, 11, day),
          lessonIds: const [],
          reviewQuestionIds: const [],
          newQuestionIds: const [],
          isMockDay: mock,
          advancedIds: const {},
          isRestDay: rest,
        );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStudyCoverageProvider.overrideWith((_) => true),
          planWeekViewProvider('2026-11-22').overrideWith(
            (_) async => [
              for (var i = 0; i < 7; i++)
                PlanDayView(
                  date: DateTime(2026, 11, 22 + i),
                  plan: plan(22 + i, mock: i == 4, rest: i == 0),
                  remaining: null,
                  lessons: const [],
                  kind: 'future',
                ),
            ],
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanWeekScreen(start: '2026-11-22'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rest day'), findsOneWidget);
    expect(find.text('Mock exam'), findsOneWidget);
    expect(find.text('Reviews only'), findsNWidgets(5));
  });
  testWidgets('History opens as its own page on the phone', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStudyCoverageProvider.overrideWith((_) => true),
          planViewProvider(15).overrideWith(
            (_) async => const PlanView(
              done: 0,
              total: 0,
              nodes: [],
              history: [
                PlanHistoryEntry(id: 'h1', date: 'Today', text: 'A change'),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PlanHistoryPage), findsOneWidget);
    expect(find.text('HISTORY'), findsOneWidget);
    expect(find.text('A change'), findsOneWidget);
    expect(find.text('Your plan'), findsNothing);
  });
  testWidgets('a week with unknown stored days shows a recoverable error',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStudyCoverageProvider.overrideWith((_) => true),
          planWeekViewProvider('2026-10-18').overrideWith(
            (_) async => [
              PlanDayView(
                date: DateTime(2026, 10, 18),
                plan: null,
                remaining: null,
                lessons: const [],
                kind: 'unknown',
              ),
            ],
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanWeekScreen(start: '2026-10-18'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load your plan.'), findsOneWidget);
    expect(find.text('Lessons by day'), findsNothing);
    expect(
      tester.widget<StateView>(find.byType(StateView)).boardLayout,
      isTrue,
    );
  });
  PlanDayView unknownDay(DateTime date) => PlanDayView(
        date: date,
        plan: null,
        remaining: null,
        lessons: const [],
        kind: 'unknown',
      );

  testWidgets('an unknown day still to come uses the approved error layout',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planDayViewProvider('2099-01-02')
              .overrideWith((_) async => unknownDay(DateTime(2099, 1, 2))),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanDayScreen(date: '2099-01-02'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<StateView>(find.byType(StateView)).boardLayout,
      isTrue,
    );
    expect(find.text('Could not load your plan.'), findsOneWidget);
  });

  testWidgets('a day before the plan began says so, with no error',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planDayViewProvider('2026-10-18')
              .overrideWith((_) async => unknownDay(DateTime(2026, 10, 18))),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanDayScreen(date: '2026-10-18'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StateView), findsNothing);
    expect(find.text('Could not load your plan.'), findsNothing);
    expect(find.text('Try Again'), findsNothing);
    expect(
      find.text('Your plan had not started on this day.'),
      findsOneWidget,
    );
  });

  testWidgets('the week strip opens no card for a day before the plan began',
      (tester) async {
    late BuildContext inside;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planDayViewProvider('2026-10-18')
              .overrideWith((_) async => unknownDay(DateTime(2026, 10, 18))),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: Builder(
            builder: (context) {
              inside = context;
              return const Scaffold(body: Text('Home'));
            },
          ),
        ),
      ),
    );
    unawaited(showPlanPastDay(inside, DateTime(2026, 10, 18)));
    await tester.pumpAndSettle();
    expect(find.byType(PlanDayScreen), findsNothing);
    expect(find.text('Could not load your plan.'), findsNothing);
  });

  testWidgets(
      'a card opened while the day was slow closes itself when the '
      'day turns out to be before the plan', (tester) async {
    final slow = Completer<PlanDayView>();
    late BuildContext inside;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planDayViewProvider('2026-10-18').overrideWith((_) => slow.future),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: Builder(
            builder: (context) {
              inside = context;
              return const Scaffold(body: Text('Home'));
            },
          ),
        ),
      ),
    );
    unawaited(showPlanPastDay(inside, DateTime(2026, 10, 18)));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PlanDayScreen), findsOneWidget);
    slow.complete(unknownDay(DateTime(2026, 10, 18)));
    await tester.pumpAndSettle();
    expect(find.byType(PlanDayScreen), findsNothing);
    expect(find.text('Could not load your plan.'), findsNothing);
  });
  testWidgets(
      'history appends without replacing the visible plan while loading',
      (tester) async {
    final next = Completer<PlanView>();
    List<PlanHistoryEntry> history(int n) => [
          for (var i = 0; i < n; i++)
            PlanHistoryEntry(
              id: 'h$i',
              date: 'Today',
              text: 'Actual change $i',
            ),
        ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStudyCoverageProvider.overrideWith((_) => true),
          entitlementProvider
              .overrideWith((_) => Stream.value(const Entitlement.free())),
          planViewProvider(5).overrideWith(
            (_) async => PlanView(
              done: 0,
              total: 0,
              nodes: const [],
              history: history(5),
              next: const {},
            ),
          ),
          planViewProvider(15).overrideWith((_) => next.future),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: PlanScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('See more'), 150);
    await tester.tap(find.text('See more'));
    await tester.pump();
    expect(find.text('Actual change 4'), findsOneWidget);
    next.complete(
      PlanView(done: 0, total: 0, nodes: const [], history: history(15)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Actual change 14'), 150);
    expect(find.text('Actual change 14'), findsOneWidget);
  });
  for (final settling in [true, false]) {
    testWidgets(
        settling
            ? 'a plan read that fails as the app settles stays a skeleton and '
                'retries'
            : 'a plan read that really fails shows the error at once',
        (tester) async {
      var reads = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentStudyCoverageProvider.overrideWith((_) => true),
            entitlementProvider
                .overrideWith((_) => Stream.value(const Entitlement.free())),
            planViewProvider(5).overrideWith((_) async {
              reads++;
              if (!settling) throw StateError('Plan content unavailable');
              if (reads <= 2) throw StateError('Quiz account is unavailable');
              return const PlanView(
                done: 1,
                total: 4,
                nodes: [],
                history: [],
              );
            }),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: PlanScreen(),
            ),
          ),
        ),
      );
      for (var i = 0; i < 20 && (!settling || reads < 3); i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (settling) {
          expect(find.text('Could not load your plan.'), findsNothing);
          expect(find.text('Try Again'), findsNothing);
        }
      }
      await tester.pump(const Duration(milliseconds: 100));
      if (settling) {
        expect(reads, 3);
        expect(find.text('Could not load your plan.'), findsNothing);
      } else {
        expect(reads, 1);
        expect(find.text('Could not load your plan.'), findsOneWidget);
      }
    });
  }
  testWidgets('Free future date uses plan invitation without lesson payload',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementProvider
              .overrideWith((_) => Stream.value(const Entitlement.free())),
          currentStudyCoverageProvider.overrideWith((_) => false),
          planDayViewProvider('2026-10-26').overrideWith(
            (_) async => PlanDayView(
              date: DateTime(2026, 10, 26),
              plan: null,
              remaining: null,
              lessons: const [],
              kind: 'locked',
            ),
          ),
          planViewProvider(5).overrideWith(
            (_) async =>
                const PlanView(done: 0, total: 0, nodes: [], history: []),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanDayScreen(date: '2026-10-26'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Unlock with Pro'), 150);
    expect(find.text('Unlock with Pro'), findsOneWidget);
    expect(find.text('Set that morning'), findsNothing);
  });
  testWidgets('retry after a real context change recaptures the owner',
      (tester) async {
    var token = 'a';
    var reads = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          todayQuestionLauncherProvider
              .overrideWith((ref) => _TokenPlanLauncher(ref, () => token)),
          planDayViewProvider('2026-10-18').overrideWith((_) async {
            reads++;
            return PlanDayView(
              date: DateTime(2026, 10, 18),
              plan: DayPlan(
                day: DateTime(2026, 10, 18),
                lessonIds: const [],
                reviewQuestionIds: const [],
                newQuestionIds: const [],
                isMockDay: false,
                advancedIds: const {},
              ),
              remaining: null,
              lessons: const [],
              kind: 'past',
            );
          }),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanDayScreen(date: '2026-10-18'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsNothing);
    // The context changes after the screen captured its owner, then the
    // screen rebuilds.
    token = 'b';
    ProviderScope.containerOf(tester.element(find.byType(PlanDayScreen)))
        .invalidate(planDayViewProvider('2026-10-18'));
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsNothing);
    expect(reads, greaterThan(1));
  });
}

class _TokenPlanLauncher extends TodayQuestionLauncher {
  _TokenPlanLauncher(Ref ref, this.readToken) : super(ref, () => true);
  final String Function() readToken;
  @override
  Future<Future<bool> Function()> captureGuard(
    String examId, {
    required bool Function() isAlive,
  }) async {
    final captured = readToken();
    return () async => isAlive() && readToken() == captured;
  }
}

class _PlanLauncher extends TodayQuestionLauncher {
  _PlanLauncher(Ref ref) : super(ref, () => true);
  @override
  Future<Future<bool> Function()> captureGuard(
    String examId, {
    required bool Function() isAlive,
  }) async =>
      () async => isAlive();
}
