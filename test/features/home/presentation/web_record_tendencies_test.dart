import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/presentation/record_page.dart';
import 'package:pantas/features/home/presentation/record_screen.dart';
import 'package:pantas/features/home/presentation/tendencies_page.dart';
import 'package:pantas/features/home/presentation/tendencies_screen.dart';
import 'package:pantas/features/home/presentation/widgets/accuracy_line.dart';
import 'package:pantas/features/home/presentation/widgets/web_record_layout.dart';
import 'package:pantas/features/home/presentation/widgets/web_tendencies_layout.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    required bool dark,
  }) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
        home: Padding(
          padding: const EdgeInsets.fromLTRB(288, 28, 44, 44),
          child: child,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  StudentRecord record({bool first = false, bool rest = false}) =>
      StudentRecord(
        weeksIn: first ? 1 : 6,
        dayStreak: 12,
        streakStartedOn: rest ? null : DateTime(2026, 10, 3),
        questionsAnswered: 1284,
        sessionMinutes: 2130,
        lessonsRead: 46,
        daysActive: 37,
        longestStreak: 15,
        bestMockPercent: first ? null : 64,
        accuracySeries: first
            ? []
            : [
                (weekStart: DateTime(2026, 9, 2), accuracy: 52),
                (weekStart: DateTime(2026, 10, 8), accuracy: 61),
              ],
        mocks: const [],
      );
  for (final dark in [false, true]) {
    testWidgets(
        'wide chart uses three rules and aligned inset endpoint dark=$dark',
        (tester) async {
      await mount(
        tester,
        AccuracyLine(series: record().accuracySeries, web: true),
        dark: dark,
      );
      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(AccuracyLine),
          matching: find.byType(CustomPaint),
        ),
      );
      void draw(Canvas canvas) =>
          paint.painter!.paint(canvas, const Size(600, 170));
      expect(draw, paintsExactlyCountTimes(#drawLine, 3));
      expect(draw, paints..circle(x: 590, y: 66.3, radius: 6));
    });
    testWidgets('pressure represents full score range dark=$dark',
        (tester) async {
      for (final scores in [(85, 95), (20, 35)]) {
        await mount(
          tester,
          TendenciesPage(
            data: HowYouWork(
              name: 'Ana',
              archetype: null,
              archetypeLine: null,
              tendencies: [
                Tendency(
                  id: TendencyId.underPressure,
                  heading: 'Under pressure',
                  leftLabel: 'practicing',
                  rightLabel: 'under time',
                  leftFigure: '${scores.$1}%',
                  rightFigure: '${scores.$2}%',
                  sentence: 'Measured pressure',
                  isLoss: false,
                  gap: null,
                  unlockAction: '',
                  confidence: TendencyConfidence.clear,
                ),
              ],
              whenYouWork: const [],
            ),
            pro: true,
            paused: false,
            onBack: () {},
            onName: () {},
            onPro: () {},
          ),
          dark: dark,
        );
        final bars = tester
            .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
            .toList();
        expect(bars[0].widthFactor, greaterThan(0));
        expect(bars[1].widthFactor, greaterThan(bars[0].widthFactor!));
      }
    });
    for (final path in ['/record', '/tendencies']) {
      testWidgets('MY sidebar keeps Home active $path dark=$dark',
          (tester) async {
        await mount(
          tester,
          ProviderScope(
            overrides: [
              userSettingsProvider
                  .overrideWith((_) => Completer<Never>().future),
              activeExamShortNameProvider.overrideWithValue('CSE'),
              proForActiveExamProvider.overrideWith((_) async => false),
            ],
            child: WebRouteShell(path: path, child: const Text('MY screen')),
          ),
          dark: dark,
        );
        expect(
          tester.widget<WebShellFrame>(find.byType(WebShellFrame)).activeIndex,
          0,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
    for (final profile in archetypeCatalog) {
      testWidgets('MY_Profiles ${profile.label} dark=$dark', (tester) async {
        await mount(
          tester,
          TendenciesPage(
            data: HowYouWork(
              name: 'Ana',
              archetype: profile.label,
              archetypeLine: archetypeIdentityLine(profile.id),
              tendencies: const [],
              whenYouWork: const [],
            ),
            pro: true,
            paused: false,
            onBack: () {},
            onName: () {},
            onPro: () {},
          ),
          dark: dark,
        );
        expect(find.byType(WebTendencyProfile), findsOneWidget);
        expect(find.text(profile.label), findsOneWidget);
        expect(find.text(archetypeIdentityLine(profile.id)), findsOneWidget);
        expect(
          tester
              .getSize(find.byKey(const ValueKey('tendencies-profile')))
              .height,
          greaterThanOrEqualTo(148),
        );
        expect(tester.takeException(), isNull);
      });
    }
    for (final error in [false, true]) {
      for (final recordScreen in [false, true]) {
        testWidgets(
            'MY loading and error record=$recordScreen error=$error dark=$dark',
            (tester) async {
          final pendingRecord = Completer<StudentRecord>();
          final pendingWork = Completer<HowYouWork>();
          await mount(
            tester,
            ProviderScope(
              overrides: [
                recordProvider.overrideWith(
                  (_) => error
                      ? Future<StudentRecord>.error(StateError('offline'))
                      : pendingRecord.future,
                ),
                mockHistoryProvider.overrideWith(
                  (_) => Stream.value(<MockHistoryEntry>[]),
                ),
                howYouWorkProvider.overrideWith(
                  (_) => error
                      ? Future<HowYouWork>.error(StateError('offline'))
                      : pendingWork.future,
                ),
              ],
              child: recordScreen
                  ? const RecordScreen()
                  : const TendenciesScreen(),
            ),
            dark: dark,
          );
          expect(find.byType(WebMyPage), findsOneWidget);
          if (error) {
            expect(find.text('Could not load your progress.'), findsOneWidget);
            expect(find.text('Try Again'), findsOneWidget);
          } else {
            expect(find.byType(WebMyLoading), findsOneWidget);
            await tester.pump(const Duration(milliseconds: 301));
            expect(find.byType(LoadingShapes), findsNWidgets(6));
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
    for (final first in [false, true]) {
      testWidgets('record columns and measured figures first=$first dark=$dark',
          (tester) async {
        String? opened;
        await mount(
          tester,
          RecordPage(
            record: record(first: first),
            mocks: first
                ? []
                : [
                    RecordMockRow(
                      id: 'm',
                      name: 'CSE simulation',
                      date: DateTime(2026, 10, 8),
                      percent: 64,
                    ),
                  ],
            onBack: () {},
            onMock: (id) => opened = id,
            wrappedRow: const Text('Your Wrapped'),
          ),
          dark: dark,
        );
        expect(find.byType(WebCard), findsWidgets);
        expect(find.text('Your Wrapped'), findsNothing);
        expect(find.text('35h 30m'), findsOneWidget);
        final questions = tester.getTopLeft(find.text('questions answered'));
        final time = tester.getTopLeft(find.text('time in sessions'));
        final lessons = tester.getTopLeft(find.text('lessons read'));
        expect(time.dy, questions.dy);
        expect(lessons.dy, questions.dy);
        if (first) {
          expect(
            find.text('Your line starts after two weeks of answers.'),
            findsOneWidget,
          );
          expect(find.text('best mock'), findsNothing);
          expect(find.text('YOUR MOCKS'), findsNothing);
        } else {
          expect(
            tester.getTopLeft(find.text('YOUR MOCKS')).dx,
            greaterThan(tester.getTopLeft(find.text('YOUR TOTALS')).dx),
          );
          expect(tester.getSize(find.byType(AccuracyLine)).height, 170);
          await tester.tap(find.text('CSE simulation'));
          expect(opened, 'm');
        }
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('rest day omits since date dark=$dark', (tester) async {
      await mount(
        tester,
        RecordPage(
          record: record(rest: true),
          mocks: const [],
          onBack: () {},
          onMock: (_) {},
        ),
        dark: dark,
      );
      expect(find.textContaining('since Oct'), findsNothing);
    });
    for (final pro in [false, true]) {
      for (final clear in [false, true]) {
        testWidgets('tendency grid pro=$pro clear=$clear dark=$dark',
            (tester) async {
          final data = HowYouWork(
            name: clear ? 'Ana' : null,
            archetype: clear ? 'Deep Thinker' : null,
            archetypeLine:
                clear ? 'You take your sweet time, and it shows.' : null,
            whenYouWork: const [
              (title: 'Peak hour', subtext: '', meta: '9 pm'),
            ],
            tendencies: [
              for (final id in TendencyId.values)
                Tendency(
                  id: id,
                  heading: id.name,
                  leftLabel: 'left ${id.name}',
                  rightLabel: 'right ${id.name}',
                  gap: '14s',
                  leftFigure: '62%',
                  rightFigure: '56%',
                  sentence: 'Measured ${id.name}',
                  isLoss: true,
                  unlockAction: 'Finish one full length mock',
                  confidence: clear
                      ? TendencyConfidence.clear
                      : TendencyConfidence.early,
                ),
            ],
          );
          await mount(
            tester,
            TendenciesPage(
              data: data,
              pro: pro,
              paused: false,
              onBack: () {},
              onName: () {},
              onPro: () {},
            ),
            dark: dark,
          );
          expect(find.text('WHAT WE FOUND'), findsOneWidget);
          final a = tester.getTopLeft(find.text('UNDERPRESSURE'));
          final b = tester.getTopLeft(find.text('STAMINA'));
          expect(a.dy, b.dy);
          expect(b.dx, greaterThan(a.dx));
          expect(
            find.text('Deep Thinker'),
            clear ? findsOneWidget : findsNothing,
          );
          if (!clear) expect(find.text('Needs more usage data'), findsWidgets);
          if (pro && clear) {
            expect(find.text('Measured underPressure'), findsOneWidget);
            expect(find.text('WHEN YOU WORK'), findsOneWidget);
            final badge = find
                .ancestor(
                  of: find.text('+14s on wrong answers'),
                  matching: find.byType(Container),
                )
                .first;
            expect(badge, findsOneWidget);
            final decoration =
                tester.widget<Container>(badge).decoration! as BoxDecoration;
            expect(decoration.borderRadius, BorderRadius.circular(99));
          } else {
            expect(find.text('Measured underPressure'), findsNothing);
          }
          if (!pro) {
            expect(find.text('Unlock with Pro'), findsOneWidget);
            expect(find.text('62%'), findsNothing);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
