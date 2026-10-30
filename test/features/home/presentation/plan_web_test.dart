import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/plan_provider.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/plan_day_page.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';
import 'package:pantas/features/home/presentation/plan_screen.dart';
import 'package:pantas/features/home/presentation/plan_web.dart';

void main() {
  Future<void> pumpWide(
    WidgetTester tester,
    Widget child, {
    required bool dark,
  }) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
        home: Scaffold(body: child),
      ),
    );
    await tester.pump();
  }

  for (final dark in [false, true]) {
    testWidgets('History Back restores Plan and Today goes Home dark=$dark',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Text('Home destination'),
          ),
          GoRoute(path: '/plan', builder: (_, __) => const PlanScreen()),
          GoRoute(
            path: '/plan/week/:start',
            builder: (_, __) => const PlanScreen(),
          ),
          GoRoute(
            path: '/plan/day/:date',
            builder: (_, __) => const PlanScreen(),
          ),
          GoRoute(
            path: '/plan/history',
            builder: (_, __) => const PlanHistoryScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await pumpWide(
        tester,
        ProviderScope(
          overrides: [
            currentStudyCoverageProvider.overrideWith((_) => true),
            planViewProvider(5).overrideWith(
              (_) async => const PlanView(
                done: 0,
                total: 1,
                nodes: [],
                history: [],
              ),
            ),
            planViewProvider(15).overrideWith(
              (_) async => const PlanView(
                done: 0,
                total: 1,
                nodes: [],
                history: [],
              ),
            ),
          ],
          child: MaterialApp.router(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            routerConfig: router,
          ),
        ),
        dark: dark,
      );
      unawaited(router.push<void>('/plan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See more'));
      await tester.pumpAndSettle();
      expect(
        find.text('Every time your plan adjusted, and why.'),
        findsOneWidget,
      );
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('COMING UP'), findsOneWidget);
      for (final path in ['/plan/week/2026-10-18', '/plan/day/2026-10-20']) {
        unawaited(router.push<void>(path));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0 of 1 done'));
        await tester.pumpAndSettle();
        expect(find.text('Home destination'), findsOneWidget);
        unawaited(router.push<void>('/plan'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('wide plan columns and free gate dark=$dark', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Widget page({required bool pro}) => MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: Scaffold(
              body: PlanPage(
                pro: pro,
                paused: false,
                done: 2,
                total: 4,
                nodes: const [
                  PlanNode(
                    kind: PlanNodeKind.week,
                    title: 'Next week',
                    subtitle: 'Biology',
                    target: '2026-11-01',
                  ),
                ],
                history: const [
                  PlanHistoryEntry(
                    id: '1',
                    date: 'Today',
                    text: 'Your plan changed.',
                  ),
                ],
                onBack: () {},
                onToday: () {},
                onWeek: (_) {},
                onPro: () {},
              ),
            ),
          );
      await tester.pumpWidget(page(pro: true));
      await tester.pumpAndSettle();
      expect(find.byType(WebCard), findsNWidgets(3));
      expect(
        tester.getTopLeft(find.text('HISTORY')).dx,
        greaterThan(tester.getTopLeft(find.text('COMING UP')).dx),
      );
      expect(find.text('Your plan changed.'), findsOneWidget);
      await tester.pumpWidget(page(pro: false));
      await tester.pumpAndSettle();
      expect(find.text('Next week'), findsNothing);
      expect(find.text('Your plan changed.'), findsNothing);
      expect(find.text('Unlock with Pro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wide week rest days, selection and Esc dark=$dark',
        (tester) async {
      DateTime? opened;
      var closed = 0;
      await pumpWide(
        tester,
        SizedBox(
          width: 470,
          child: PlanWeekPage(
            title: 'Oct 18 – 24',
            days: [
              PlanWeekDay(
                date: DateTime(2026, 10, 18),
                rest: true,
                lessonTitles: const [],
              ),
              PlanWeekDay(
                date: DateTime(2026, 10, 19),
                rest: false,
                lessonTitles: const [
                  'Mendelian inheritance, Punnett squares, DNA and genes',
                ],
              ),
            ],
            studyDaysLabel: 'You study Monday to Saturday.',
            onBack: () => closed++,
            onDay: (date) => opened = date,
          ),
        ),
        dark: dark,
      );
      await tester.tap(find.text('Rest day'));
      expect(opened, isNull);
      final title =
          find.text('Mendelian inheritance, Punnett squares, DNA and genes');
      expect(tester.widget<Text>(title).maxLines, isNull);
      expect(tester.getSize(title).height, greaterThan(30));
      await tester.tap(title);
      expect(opened, DateTime(2026, 10, 19));
      expect(find.text('OCT 18 – 24 · LESSONS BY DAY'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(closed, 1);
      expect(tester.takeException(), isNull);
    });
    for (final past in [false, true]) {
      testWidgets('wide day past=$past read state dark=$dark', (tester) async {
        var read = 0;
        await pumpWide(
          tester,
          SizedBox(
            width: 470,
            child: PlanDayPage(
              date: DateTime(2026, 10, 20),
              past: past,
              rest: false,
              lessons: const [
                HomeTodayLesson(
                  id: 'l',
                  title: 'DNA and genes',
                  subject: 'Biology',
                  minutes: 8,
                  read: false,
                ),
              ],
              reviewsDone: 2,
              reviewsTotal: 3,
              newDone: 1,
              newTotal: 4,
              onBack: () {},
              onLesson: (_) => read++,
            ),
          ),
          dark: dark,
        );
        expect(find.text('Tuesday, Oct 20'), findsOneWidget);
        expect(find.text('PLANNED'), findsOneWidget);
        final rings =
            tester.widgetList<ProgressRing>(find.byType(ProgressRing)).toList();
        expect(
          rings.map((ring) => ring.fraction),
          past ? [0, 2 / 3, 1 / 4] : [0, 0, 0],
        );
        expect(find.text('2 of 3'), past ? findsOneWidget : findsNothing);
        expect(
          find.text('Set that morning'),
          past ? findsNothing : findsOneWidget,
        );
        if (!past) await tester.tap(find.text('Read'));
        expect(read, past ? 0 : 1);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('completed past day has three completion indicators dark=$dark',
        (tester) async {
      await pumpWide(
        tester,
        SizedBox(
          width: 400,
          child: PlanDayPage(
            date: DateTime(2026, 10, 20),
            past: true,
            rest: false,
            lessons: const [
              HomeTodayLesson(
                id: 'l',
                title: 'DNA and genes',
                subject: 'Biology',
                minutes: 8,
                read: true,
              ),
            ],
            reviewsDone: 3,
            reviewsTotal: 3,
            newDone: 4,
            newTotal: 4,
            onBack: () {},
            onLesson: (_) {},
          ),
        ),
        dark: dark,
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(
        tester
            .widgetList<ProgressRing>(find.byType(ProgressRing))
            .map((ring) => ring.fraction),
        [1, 1],
      );
    });

    testWidgets('wide History pagination and end dark=$dark', (tester) async {
      var more = 0;
      await pumpWide(
        tester,
        PlanWebFrame(
          title: 'History',
          backLabel: 'Your plan',
          subtitle: 'Every time your plan adjusted, and why.',
          onBack: () {},
          child: PlanWebHistory(
            entries: const [
              PlanHistoryEntry(id: '1', date: 'Today', text: 'Stored reason'),
            ],
            hasMore: true,
            onMore: () => more++,
          ),
        ),
        dark: dark,
      );
      expect(find.text('Stored reason'), findsOneWidget);
      await tester.tap(find.text('See more'));
      expect(more, 1);
      await pumpWide(tester, const PlanWebHistory(entries: []), dark: dark);
      expect(find.text("That's everything since you started."), findsOneWidget);
    });
    testWidgets('wide plan loading and error retry dark=$dark', (tester) async {
      final pending = Completer<PlanView>();
      var calls = 0;
      await pumpWide(
        tester,
        ProviderScope(
          overrides: [
            currentStudyCoverageProvider.overrideWith((_) => true),
            planViewProvider(5).overrideWith((_) {
              calls++;
              return pending.future;
            }),
          ],
          child: const PlanScreen(),
        ),
        dark: dark,
      );
      expect(find.text('Your plan'), findsOneWidget);
      expect(find.text('Unlock with Pro'), findsNothing);
      pending.completeError(StateError('private details'));
      await tester.pumpAndSettle();
      expect(find.text('Could not load your plan.'), findsOneWidget);
      expect(find.textContaining('private details'), findsNothing);
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(calls, 2);
    });
  }
}
