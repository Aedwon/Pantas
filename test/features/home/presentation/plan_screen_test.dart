import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/plan_provider.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';
import 'package:pantas/features/home/presentation/plan_screen.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/pump_app.dart';

void main() {
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
  testWidgets('unknown day uses the approved plan error layout',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planDayViewProvider('2026-10-18').overrideWith(
            (_) async => PlanDayView(
              date: DateTime(2026, 10, 18),
              plan: null,
              remaining: null,
              lessons: const [],
              kind: 'unknown',
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PlanDayScreen(date: '2026-10-18'),
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
