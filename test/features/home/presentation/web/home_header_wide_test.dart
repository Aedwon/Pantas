import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';

void main() {
  final now = DateTime(2026, 10, 14, 20);
  for (final dark in [false, true]) {
    for (final date in <ExamDate?>[
      null,
      ExamDate.inMonth(year: 2026, month: 11),
      ExamDate.onDay(DateTime(2026, 11, 11)),
      ExamDate.onDay(now),
      ExamDate.onDay(DateTime(2026, 10)),
    ]) {
      testWidgets('wide header ${date?.storageValue}, dark=$dark',
          (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              homeMastheadProvider.overrideWith(
                (ref) async => HomeMastheadData(
                  name: 'Aedwon',
                  examShortName: 'CSE',
                  examDate: date,
                ),
              ),
              weekStripProvider('cse').overrideWith(
                (ref) async => HomeWeekStripData(
                  states: const [
                    WeekDayState.dayOff,
                    WeekDayState.done,
                    WeekDayState.partial,
                    WeekDayState.today,
                    WeekDayState.plain,
                    WeekDayState.plain,
                    WeekDayState.plain,
                  ],
                  todayFraction: date == null ? 1 : .5,
                ),
              ),
            ],
            child: MaterialApp(
              theme:
                  dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
              home: Scaffold(
                body: SizedBox(
                  width: 1080,
                  child: HomeMasthead(
                    web: true,
                    examId: 'cse',
                    now: now,
                    dayNote: "Items you missed are in today's reviews.",
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Wednesday, October 14'), findsOneWidget);
        expect(find.text('Magandang gabi'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('Magandang gabi')).style!.fontSize,
          38,
        );
        expect(find.text('CSE'), findsOneWidget);
        expect(
          find.text("Items you missed are in today's reviews."),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('web-week-day-0')), findsOneWidget);
        expect(find.byKey(const ValueKey('web-week-day-6')), findsOneWidget);
        expect(find.byType(WeekStrip), findsNothing);
        if (date == null) {
          expect(
            find.descendant(
              of: find.byKey(const ValueKey('web-week-day-3')),
              matching: find.byType(CheckMark),
            ),
            findsOneWidget,
          );
          expect(
            tester
                .widget<ProgressRing>(
                  find.byKey(const ValueKey('web-today-progress')),
                )
                .fraction,
            1,
          );
        } else {
          expect(
            tester
                .widget<ProgressRing>(
                  find.byKey(const ValueKey('web-today-progress')),
                )
                .fraction,
            .5,
          );
        }
        if (date == null) expect(find.text('Add date'), findsOneWidget);
        if (date?.daysUntil(now) == 28) {
          expect(find.text('28 days'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }
    for (final width in [390.0, 1023.0, 1440.0]) {
      testWidgets('native state stays native at $width, dark=$dark',
          (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? buildDarkTheme() : buildLightTheme(),
            home: const Scaffold(
              body: HomeStateCard(
                web: false,
                state: HomeState.dayOff,
                examName: 'CSE',
                examShortName: 'CSE',
                onPrimary: null,
              ),
            ),
          ),
        );
        expect(find.byType(WebCard), findsNothing);
        expect(find.byType(WebButton), findsNothing);
        expect(find.text('Day off'), findsOneWidget);
      });
    }
    testWidgets('narrow web keeps native presentation, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(1023, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme() : buildLightTheme(),
          home: const Scaffold(
            body: HomeStateCard(
              web: true,
              state: HomeState.dayOff,
              examName: 'CSE',
              examShortName: 'CSE',
              onPrimary: null,
            ),
          ),
        ),
      );
      expect(find.byType(WebCard), findsNothing);
      expect(find.byType(WebButton), findsNothing);
    });
  }

  group('wide today ring motion', () {
    Future<void> pumpHeader(
      WidgetTester tester, {
      required bool still,
      double fraction = .5,
    }) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeMastheadProvider.overrideWith(
              (ref) async => const HomeMastheadData(
                name: 'Aedwon',
                examShortName: 'CSE',
                examDate: null,
              ),
            ),
            weekStripProvider('cse').overrideWith(
              (ref) async => HomeWeekStripData(
                states: const [
                  WeekDayState.plain,
                  WeekDayState.plain,
                  WeekDayState.plain,
                  WeekDayState.today,
                  WeekDayState.plain,
                  WeekDayState.plain,
                  WeekDayState.plain,
                ],
                todayFraction: fraction,
              ),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: still),
              child: child!,
            ),
            home: Scaffold(
              body: SizedBox(
                width: 1080,
                child: HomeMasthead(web: true, examId: 'cse', now: now),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    double sweep(WidgetTester tester) {
      final ring = find.descendant(
        of: find.byKey(const ValueKey('web-today-progress')),
        matching: find.byKey(const ValueKey('progress-ring-paint')),
      );
      var angle = -1.0;
      final canvas = tester.renderObject(ring) as RenderBox;
      final recorder = paints
        ..something((method, args) {
          if (method != #drawArc) return false;
          angle = args[2] as double;
          return true;
        });
      expect(canvas, recorder);
      return angle;
    }

    testWidgets('fills after a delay and settles on the fraction',
        (tester) async {
      await pumpHeader(tester, still: false);
      expect(find.byType(ProgressRing), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      final mid = sweep(tester);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(math.pi));
      await tester.pumpAndSettle();
      expect(sweep(tester), closeTo(math.pi, .001));
    });

    double checkScale(WidgetTester tester) => tester
        .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')))
        .transform
        .entry(0, 0);

    testWidgets('at 100% the ring stays and the check pops in over the digit',
        (tester) async {
      await pumpHeader(tester, still: false, fraction: 1);
      expect(find.byKey(const ValueKey('web-today-progress')), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      // The pop begins 100 ms before the 1200 ms fill ends, after its delay.
      await tester.pump(const Duration(milliseconds: 1000));
      final before = checkScale(tester);
      await tester.pump(const Duration(milliseconds: 300));
      final mid = checkScale(tester);
      expect(mid, isNot(before));
      await tester.pumpAndSettle();
      expect(checkScale(tester), closeTo(1, .001));
      expect(sweep(tester), closeTo(2 * math.pi, .001));
    });

    testWidgets('at 100% reduced motion shows the finished check at once',
        (tester) async {
      await pumpHeader(tester, still: true, fraction: 1);
      expect(checkScale(tester), closeTo(1, .001));
      expect(sweep(tester), closeTo(2 * math.pi, .001));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion shows the end state at once', (tester) async {
      await pumpHeader(tester, still: true);
      expect(sweep(tester), closeTo(math.pi, .001));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
