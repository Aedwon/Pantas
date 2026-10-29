import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/domain/home_today_view.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_date_sheet.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_day.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_card.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  testWidgets('drawer opens and closes after build at the browser edge',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var open = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(44),
            child: StatefulBuilder(
              builder: (context, update) => HomeWebOverlay(
                page: TextButton(
                  onPressed: () => update(() => open = true),
                  child: const Text('Open drawer'),
                ),
                open: open,
                label: 'Reviews',
                drawer: true,
                onDismiss: () => update(() => open = false),
                child: const Text('Drawer body'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open drawer'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopRight(find.byKey(const ValueKey('home-web-drawer'))),
      const Offset(1440, 0),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Drawer body'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  additionalTests();
  for (final dark in [false, true]) {
    testWidgets('wide checklist rows, natural action and Enter, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var opened = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: SizedBox(
              width: 620,
              child: HomeTodayChecklist(
                web: true,
                lessons: const [
                  HomeTodayLesson(
                    id: 'one',
                    title: 'Ratios',
                    subject: 'Mathematics',
                    minutes: 8,
                    read: false,
                  ),
                ],
                reviewsDone: 0,
                reviewsTotal: 18,
                newDone: 0,
                newTotal: 7,
                canAdvance: false,
                isMockDay: false,
                onLesson: (_) => opened++,
                onLessons: () {},
                onReviews: () {},
                onNew: () {},
                onAdvance: () {},
                onMock: () {},
                onPlan: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WebCard), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('Questions due today'), findsOneWidget);
      expect(find.text('0 of 18'), findsOneWidget);
      expect(find.byType(WebKeyHint), findsOneWidget);
      if (dark) {
        final footer = tester
            .widgetList<Container>(
              find.ancestor(
                of: find.byType(WebButton),
                matching: find.byType(Container),
              ),
            )
            .firstWhere(
              (c) =>
                  c.decoration is BoxDecoration &&
                  (c.decoration! as BoxDecoration).border != null,
            );
        expect(
          (footer.decoration! as BoxDecoration).color,
          const Color(0xFF1F1F1F),
        );
      }
      expect(
        tester
            .getSize(
              find.descendant(
                of: find.byType(WebButton),
                matching: find.byType(TextButton),
              ),
            )
            .width,
        lessThan(500),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(opened, 1);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide completed review week has no advance, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: SizedBox(
              width: 620,
              child: HomeTodayChecklist(
                web: true,
                lessons: const [],
                reviewsDone: 20,
                reviewsTotal: 20,
                newDone: 0,
                newTotal: 0,
                canAdvance: false,
                isMockDay: false,
                doneNote: HomeDoneNote.reviewWeek,
                onLesson: (_) {},
                onLessons: () {},
                onReviews: () {},
                onNew: () {},
                onAdvance: () {},
                onMock: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WebCard), findsOneWidget);
      expect(find.text("That's all for today."), findsOneWidget);
      expect(find.text('I Want to Advance'), findsNothing);
      expect(find.text('Start Reviews'), findsNothing);
    });
  }
}

Future<void> mountWide(
  WidgetTester tester,
  Widget child, {
  required bool dark,
}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
      home: Scaffold(body: Center(child: SizedBox(width: 1080, child: child))),
    ),
  );
  await tester.pumpAndSettle();
}

void additionalTests() {
  for (final dark in [false, true]) {
    for (final state in HomeState.values) {
      testWidgets('wide state $state, dark=$dark', (tester) async {
        var called = 0;
        await mountWide(
          tester,
          HomeStateCard(
            web: true,
            state: state,
            examName: 'CSE Professional',
            examShortName: 'CSE',
            onPrimary: () => called++,
            onSecondary: () {},
          ),
          dark: dark,
        );
        expect(find.byType(WebCard), findsOneWidget);
        expect(find.byType(WebButton), findsWidgets);
        if (state == HomeState.assessment) {
          expect(find.text('First, a short assessment'), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          expect(called, 1);
        }
        if (state == HomeState.passed) {
          expect(find.text('Did you take CSE?'), findsOneWidget);
          expect(
            tester.getCenter(find.text('Set a New Date')).dy,
            tester.getCenter(find.text('Switch Exams')).dy,
          );
          expect(
            tester
                .widgetList<WebButton>(find.byType(WebButton))
                .firstWhere((b) => b.label == 'Switch Exams')
                .variant,
            WebButtonVariant.white,
          );
        }
        if (state == HomeState.noContent) {
          expect(find.text('Lessons are on the way'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }
    for (final variant in [
      'Main',
      'HM_DayStart',
      'HM_DayDone',
      'HM_Advanced',
      'HM_AdvanceAgain',
      'HM_Resume',
      'HM_LongTitle',
      'HM_ManyLessons',
      'HM_Everything',
      'HM_MockDay',
      'HM_ReviewWeek',
      'HM_LastDay',
    ]) {
      testWidgets('$variant wide checklist, dark=$dark', (tester) async {
        final advanced =
            variant == 'HM_Advanced' || variant == 'HM_AdvanceAgain';
        final complete = [
          'HM_DayDone',
          'HM_AdvanceAgain',
          'HM_ReviewWeek',
          'HM_LastDay',
        ].contains(variant);
        final many = variant == 'HM_ManyLessons' || variant == 'HM_Everything';
        final mock = variant == 'HM_Everything' || variant == 'HM_MockDay';
        final reviewOnly =
            variant == 'HM_ReviewWeek' || variant == 'HM_LastDay';
        final long = variant == 'HM_LongTitle';
        final title = long
            ? 'Solving word problems with ratios, rates and proportions '
                'in everyday situations'
            : 'Ratios';
        var opened = '';
        await mountWide(
          tester,
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 620,
              child: HomeTodayChecklist(
                web: true,
                lessons: [
                  if (!reviewOnly && variant != 'HM_MockDay')
                    for (var i = 0; i < (many ? 10 : 1); i++)
                      HomeTodayLesson(
                        id: '$i',
                        title: i == 0 ? title : 'Lesson $i',
                        subject: 'Mathematics',
                        minutes: 8,
                        read: complete,
                        fraction: variant == 'HM_Resume' ? .5 : null,
                        advanced: advanced,
                      ),
                ],
                reviewsDone: complete
                    ? 18
                    : variant == 'Main'
                        ? 12
                        : 0,
                reviewsTotal: 18,
                newDone: complete ? 7 : 0,
                newTotal: reviewOnly ? 0 : 7,
                canAdvance:
                    variant == 'HM_DayDone' || variant == 'HM_AdvanceAgain',
                isMockDay: mock,
                mockSubtitle: 'CSE simulation',
                mockDuration: '3 hr 10 min',
                originalSummary: '2 lessons · 25 questions',
                examShortName: 'CSE',
                doneNote: variant == 'HM_LastDay'
                    ? HomeDoneNote.lastDay
                    : variant == 'HM_ReviewWeek'
                        ? HomeDoneNote.reviewWeek
                        : null,
                onLesson: (_) => opened = 'lesson',
                onLessons: () => opened = 'lessons',
                onReviews: () => opened = 'reviews',
                onNew: () => opened = 'new',
                onAdvance: () => opened = 'advance',
                onMock: () => opened = 'mock',
                onPlan: () {},
              ),
            ),
          ),
          dark: dark,
        );
        expect(find.byType(WebCard), findsOneWidget);
        if (advanced) expect(find.text('FROM TOMORROW'), findsOneWidget);
        if (many) {
          expect(find.text('Up next'), findsOneWidget);
          expect(find.text('Lessons'), findsOneWidget);
          await tester.tap(find.text('Lessons'));
          expect(opened, 'lessons');
        }
        if (mock) {
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          expect(opened, 'mock');
        }
        if (variant == 'HM_Resume') {
          expect(find.text('Resume Lesson'), findsOneWidget);
        }
        if (complete) {
          if (!reviewOnly) {
            expect(
              tester.widget<Text>(find.text('Ratios')).style!.color,
              dark ? const Color(0xFFA3A3A3) : const Color(0xFF6E6E73),
            );
          }
          expect(find.text("That's all for today."), findsOneWidget);
        }
        if (long) {
          final text = tester.widget<Text>(find.text(title));
          expect(text.maxLines, 1);
          expect(text.overflow, TextOverflow.ellipsis);
          expect(find.byTooltip(title), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }
    for (final title in ['Lessons', 'Reviews', 'New questions']) {
      testWidgets('$title wide drawer and shortcuts, dark=$dark',
          (tester) async {
        var starts = 0;
        var closes = 0;
        await mountWide(
          tester,
          HomeWebOverlay(
            page: const Text('Page'),
            open: true,
            label: title,
            drawer: true,
            onDismiss: () => closes++,
            child: HomeWebQuestionsSheet(
              title: title,
              done: 0,
              total: 18,
              rows: const [WebRow(title: 'Session 1', value: '10')],
              startLabel:
                  title == 'Lessons' ? 'Continue Lesson' : 'Start $title',
              onStart: () => starts++,
            ),
          ),
          dark: dark,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('home-web-drawer'))).width,
          440,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('home-web-drawer'))).height,
          900,
        );
        expect(find.text(title), findsOneWidget);
        expect(
          tester.getBottomLeft(find.byType(WebButton)).dy,
          greaterThan(800),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(starts, 1);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        expect(closes, 1);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('two columns and More rows, dark=$dark', (tester) async {
      var route = '';
      await mountWide(
        tester,
        HomeWebLayout(
          header: const Text('Greeting'),
          today: const Text('Today column'),
          performance: const Text('Performance column'),
          onRecord: () => route = 'record',
          onTendencies: () => route = 'tendencies',
        ),
        dark: dark,
      );
      expect(
        tester.getTopLeft(find.text('Today column')).dy,
        tester.getTopLeft(find.text('Performance column')).dy,
      );
      expect(
        tester.getTopLeft(find.text('Performance column')).dx,
        greaterThan(tester.getTopLeft(find.text('Today column')).dx),
      );
      await tester.tap(find.text('Your record'));
      expect(route, 'record');
      await tester.tap(find.text('Your tendencies'));
      expect(route, 'tendencies');
    });
    testWidgets('performance measured data and Free tag, dark=$dark',
        (tester) async {
      await mountWide(
        tester,
        HomePerformanceCard(
          web: true,
          rows: const [
            PerformanceRow(
              id: 'math',
              title: 'Mathematics',
              subtext: null,
              correct: 61,
              answered: 100,
              secondsPerQuestion: null,
            ),
          ],
          pro: false,
          onOpen: () {},
        ),
        dark: dark,
      );
      expect(find.byType(WebCard), findsOneWidget);
      expect(find.text('61%'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('See all topics and lessons'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('half-ring-paint'))),
        const Size(224, 118),
      );
    });
    testWidgets('exam day optional measured warmup, dark=$dark',
        (tester) async {
      await mountWide(
        tester,
        HomeExamDay(
          web: true,
          examShortName: 'CSE',
          reviewsTotal: 10,
          reviewsDone: 0,
          onRow: () {},
          onStart: () {},
        ),
        dark: dark,
      );
      expect(find.text('CSE is today.'), findsOneWidget);
      expect(find.text('0 of 10'), findsOneWidget);
      expect(find.text('Start Warm-up'), findsOneWidget);
      expect(find.byType(WebButton), findsOneWidget);
    });
    for (final requireDay in [false, true]) {
      testWidgets('date dialog requireDay=$requireDay, dark=$dark',
          (tester) async {
        await mountWide(
          tester,
          HomeWebOverlay(
            page: const Text('Page'),
            open: true,
            label: 'Exam date',
            dialogWidth: requireDay ? 440 : 560,
            onDismiss: () {},
            child: SingleChildScrollView(
              child: HomeExamDateSheet(
                web: true,
                today: DateTime(2026, 10, 14),
                requireDay: requireDay,
                initial:
                    requireDay ? ExamDate.inMonth(year: 2026, month: 11) : null,
                onSave: (_) {},
                onCancel: () {},
              ),
            ),
          ),
          dark: dark,
        );
        expect(find.byKey(const ValueKey('home-web-dialog')), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('home-web-dialog'))).width,
          requireDay ? 440 : 560,
        );
        expect(
          tester.getCenter(find.byTooltip('Close')).dy,
          lessThan(
            tester
                    .getTopLeft(
                      find.text(
                        requireDay
                            ? 'Pick a day in November.'
                            : 'Pick the month. Add the day if you know it.',
                      ),
                    )
                    .dy +
                20,
          ),
        );
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        final save = tester
            .widgetList<WebButton>(find.byType(WebButton))
            .firstWhere((b) => b.label == 'Save');
        expect(save.onPressed, isNull);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('wide date calendar selects and saves with Enter, dark=$dark',
        (tester) async {
      ExamDate? saved;
      await mountWide(
        tester,
        SingleChildScrollView(
          child: HomeExamDateSheet(
            web: true,
            today: DateTime(2026, 10, 14),
            onSave: (date) => saved = date,
          ),
        ),
        dark: dark,
      );
      expect(find.byKey(const ValueKey('home-web-months')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('date-month-11')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('home-web-calendar')), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('home-web-calendar'))).dx,
        greaterThan(
          tester.getTopLeft(find.byKey(const ValueKey('home-web-months'))).dx,
        ),
      );
      await tester.tap(find.byKey(const ValueKey('date-day-11')));
      await tester.pumpAndSettle();
      expect(find.text('28 days from today'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(
        saved?.storageValue,
        ExamDate.onDay(DateTime(2026, 11, 11)).storageValue,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('notice folded and open actions, dark=$dark', (tester) async {
      var primary = 0;
      await mountWide(
        tester,
        HomeWebNotice(
          title: 'Add your exam date',
          detail: 'Your plan paces each day to it.',
          onClose: () {},
          onToggle: () {},
          primaryLabel: 'Add Exam Date',
          onPrimary: () => primary++,
        ),
        dark: dark,
      );
      expect(find.text('Add your exam date'), findsOneWidget);
      expect(find.text('Your plan paces each day to it.'), findsNothing);
      await mountWide(
        tester,
        HomeWebNotice(
          title: 'Add your exam date',
          detail: 'Your plan paces each day to it.',
          expanded: true,
          onClose: () {},
          onToggle: () {},
          primaryLabel: 'Add Exam Date',
          onPrimary: () => primary++,
        ),
        dark: dark,
      );
      await tester.tap(find.text('Add Exam Date'));
      expect(primary, 1);
      expect(find.text('Your plan paces each day to it.'), findsOneWidget);
    });
    for (final notice in <(String, String?, String?)>[
      ('Pro trial ends in 2 days', 'You won’t be charged.', 'See Pro'),
      (
        "You're in. Welcome to Pro.",
        'Topics, lessons and your tendencies are open now.',
        "See What's New"
      ),
      (
        'Do you know the day of your CSE?',
        'Your plan is paced to the end of November.',
        'Pick the Day'
      ),
      (
        'Backup is paused for a few hours. '
            'Your progress is safe in this browser.',
        null,
        null
      ),
    ]) {
      testWidgets('wide notice ${notice.$1}, dark=$dark', (tester) async {
        await mountWide(
          tester,
          HomeWebNotice(
            title: notice.$1,
            detail: notice.$2,
            primaryLabel: notice.$3,
            onPrimary: () {},
            expanded: true,
            onClose: () {},
          ),
          dark: dark,
        );
        expect(find.text(notice.$1), findsOneWidget);
        if (notice.$2 != null) expect(find.text(notice.$2!), findsOneWidget);
        if (notice.$3 != null) expect(find.text(notice.$3!), findsOneWidget);
        expect(find.textContaining("You'll be charged"), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('slow loading waits 300ms, dark=$dark', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: const Scaffold(body: HomeWebLoading()),
        ),
      );
      expect(find.byType(Container), findsNothing);
      await tester.pump(const Duration(milliseconds: 299));
      expect(find.byType(Container), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byType(Container), findsNWidgets(2));
    });
  }
}
