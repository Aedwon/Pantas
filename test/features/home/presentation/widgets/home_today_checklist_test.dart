import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/domain/home_today_view.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';

HomeTodayLesson lesson(
  int n, {
  bool read = false,
  double? fraction,
  bool advanced = false,
}) =>
    HomeTodayLesson(
      id: 'l$n',
      title: n == 0
          ? 'Solving word problems with ratios and proportions'
          : 'Lesson $n',
      subject: 'Mathematics',
      minutes: 8,
      read: read,
      fraction: fraction,
      advanced: advanced,
    );

Widget harness(
  List<HomeTodayLesson> lessons, {
  bool dark = false,
  bool large = false,
  bool advance = false,
  bool mock = false,
  bool plan = true,
  HomeDoneNote? note,
}) =>
    MaterialApp(
      theme: dark ? buildDarkTheme() : buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(large ? 2 : 1),
          disableAnimations: true,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: HomeTodayChecklist(
              lessons: lessons,
              reviewsDone: 2,
              reviewsTotal: 7,
              newDone: 0,
              newTotal: 4,
              canAdvance: advance,
              isMockDay: mock,
              onLesson: (_) {},
              onLessons: () {},
              onReviews: () {},
              onNew: () {},
              onStartReviews: () {},
              onStartNew: () {},
              onPlan: plan ? () {} : null,
              doneNote: note,
              examShortName: 'UPCAT',
              mockSubtitle: 'UPCAT simulation',
              mockDuration: '2 hr 45 min',
              onAdvance: () {},
              onMock: () {},
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows actual lesson progress and question counts',
      (tester) async {
    await tester
        .pumpWidget(harness([lesson(0, fraction: .3), lesson(1, read: true)]));
    await tester.pumpAndSettle();
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('View full plan'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Resume Lesson'), findsOneWidget);
    expect(find.text('2 of 7'), findsOneWidget);
    expect(
      tester
          .widgetList<ProgressRing>(find.byType(ProgressRing))
          .any((r) => r.fraction == .3),
      isTrue,
    );
  });
  testWidgets('four or more lessons collapse around the next unread lesson',
      (tester) async {
    await tester.pumpWidget(
      harness([lesson(0, read: true), lesson(1), lesson(2), lesson(3)]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('1 of 4 read'), findsOneWidget);
    expect(find.text('Lesson 1'), findsOneWidget);
    expect(find.text('Lesson 2'), findsNothing);
  });
  testWidgets('advanced work preserves the completed original summary',
      (tester) async {
    await tester.pumpWidget(
      harness(
        [lesson(0, read: true), lesson(1, advanced: true)],
        advance: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Today's done"), findsOneWidget);
    expect(find.text('FROM TOMORROW'), findsOneWidget);
    expect(find.text('Lesson 1'), findsOneWidget);
  });
  testWidgets('completion only offers advance when the engine permits it',
      (tester) async {
    await tester.pumpWidget(harness([lesson(0, read: true)], advance: true));
    await tester.pumpAndSettle();
    expect(find.text('I Want to Advance'), findsOneWidget);
    await tester.pumpWidget(harness([lesson(0, read: true)]));
    await tester.pumpAndSettle();
    expect(find.text('I Want to Advance'), findsNothing);
  });
  testWidgets('long lesson titles stay on one line with ellipsis',
      (tester) async {
    await tester.pumpWidget(harness([lesson(0)], large: true));
    await tester.pumpAndSettle();
    final text = tester.widget<Text>(
      find.text('Solving word problems with ratios and proportions'),
    );
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });
  for (final dark in [false, true]) {
    testWidgets(
        'large text and mock row fit in ${dark ? "dark" : "light"} mode',
        (tester) async {
      await tester.pumpWidget(
        harness([lesson(0)], dark: dark, large: true, mock: true),
      );
      await tester.pumpAndSettle();
      expect(find.text('Start Mock Exam'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('without a plan route the link is not drawn', (tester) async {
    await tester.pumpWidget(harness([lesson(0)], plan: false));
    await tester.pumpAndSettle();
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('View full plan'), findsNothing);
  });
  testWidgets('mock row leads with its simulation name and real duration',
      (tester) async {
    await tester.pumpWidget(harness([lesson(0)], mock: true));
    await tester.pumpAndSettle();
    expect(find.text('Mock exam'), findsOneWidget);
    expect(find.text('UPCAT simulation'), findsOneWidget);
    expect(find.text('2 hr 45 min'), findsOneWidget);
  });
  testWidgets('a finished review-only week closes without an advance offer',
      (tester) async {
    await tester.pumpWidget(
      harness([], note: HomeDoneNote.reviewWeek),
    );
    await tester.pumpAndSettle();
    expect(find.text("That's all for today."), findsOneWidget);
    expect(
      find.text(
        "This last week is reviews only, so there's nothing new to bring "
        'forward.',
      ),
      findsOneWidget,
    );
    expect(find.text('I Want to Advance'), findsNothing);
  });
  testWidgets('the last day names the exam', (tester) async {
    await tester.pumpWidget(harness([], note: HomeDoneNote.lastDay));
    await tester.pumpAndSettle();
    expect(find.text('UPCAT is tomorrow. Rest well tonight.'), findsOneWidget);
  });
  testWidgets('a plain finished day shows only the closing title',
      (tester) async {
    await tester.pumpWidget(harness([], note: HomeDoneNote.plain));
    await tester.pumpAndSettle();
    expect(find.text("That's all for today."), findsOneWidget);
    expect(find.textContaining('tomorrow'), findsNothing);
  });

  group('main button goes straight into the session', () {
    for (final wide in [false, true]) {
      final layout = wide ? 'wide' : 'phone';
      var reviewRows = 0;
      var newRows = 0;
      var startReviews = 0;
      var startNew = 0;
      Widget mount({
        int reviewsDone = 0,
        int reviewsTotal = 5,
        int newDone = 0,
        int newTotal = 3,
        bool reviewsStarted = false,
        bool busy = false,
        bool advance = false,
        List<HomeTodayLesson>? lessons,
      }) {
        reviewRows = newRows = startReviews = startNew = 0;
        return MaterialApp(
          theme: wide ? buildLightTheme(web: true) : buildLightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(1440, 900),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: HomeTodayChecklist(
                  web: wide,
                  lessons: lessons ?? [lesson(1, read: true)],
                  reviewsDone: reviewsDone,
                  reviewsTotal: reviewsTotal,
                  newDone: newDone,
                  newTotal: newTotal,
                  reviewsStarted: reviewsStarted,
                  canAdvance: advance,
                  isMockDay: false,
                  advancing: busy,
                  onLesson: (_) {},
                  onLessons: () {},
                  onReviews: () => reviewRows++,
                  onNew: () => newRows++,
                  onStartReviews: () => startReviews++,
                  onStartNew: () => startNew++,
                  onAdvance: () {},
                  onMock: () {},
                ),
              ),
            ),
          ),
        );
      }

      Future<void> setUpView(WidgetTester tester) async {
        final size = wide ? const Size(1440, 900) : const Size(390, 844);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      }

      testWidgets('$layout: Start Reviews starts and opens no panel',
          (tester) async {
        await setUpView(tester);
        await tester.pumpWidget(mount());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start Reviews'));
        expect(startReviews, 1);
        expect(reviewRows, 0);
        expect(startNew, 0);
      });
      testWidgets('$layout: Continue Reviews when a session is stored',
          (tester) async {
        await setUpView(tester);
        await tester.pumpWidget(mount(reviewsDone: 2, reviewsStarted: true));
        await tester.pumpAndSettle();
        expect(find.text('Start Reviews'), findsNothing);
        await tester.tap(find.text('Continue Reviews'));
        expect(startReviews, 1);
        expect(reviewRows, 0);
      });
      testWidgets('$layout: Start New Questions once reviews are done',
          (tester) async {
        await setUpView(tester);
        await tester.pumpWidget(mount(reviewsDone: 5));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start New Questions'));
        expect(startNew, 1);
        expect(newRows, 0);
        expect(startReviews, 0);
      });
      testWidgets('$layout: lessons come before reviews', (tester) async {
        await setUpView(tester);
        await tester.pumpWidget(mount(lessons: [lesson(1)]));
        await tester.pumpAndSettle();
        expect(find.text('Continue Lesson'), findsOneWidget);
        expect(find.text('Start Reviews'), findsNothing);
      });
      testWidgets('$layout: the rows still open the panel', (tester) async {
        await setUpView(tester);
        await tester.pumpWidget(mount());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reviews'));
        await tester.tap(find.text('New questions'));
        expect(reviewRows, 1);
        expect(newRows, 1);
        expect(startReviews, 0);
        expect(startNew, 0);
      });
      testWidgets('$layout: no button when everything is done', (tester) async {
        await setUpView(tester);
        await tester.pumpWidget(
          mount(reviewsDone: 5, newDone: 3, advance: true),
        );
        await tester.pumpAndSettle();
        expect(find.text('Start Reviews'), findsNothing);
        expect(find.text('Continue Reviews'), findsNothing);
        expect(find.text('Start New Questions'), findsNothing);
        expect(find.text("That's all for today."), findsOneWidget);
        expect(find.text('I Want to Advance'), findsOneWidget);
      });
      testWidgets('$layout: busy button cannot be pressed again',
          (tester) async {
        await setUpView(tester);
        await tester.pumpWidget(mount(busy: true));
        await tester.pump();
        await tester.tap(find.text('Start Reviews'), warnIfMissed: false);
        expect(startReviews, 0);
        if (wide) {
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          expect(startReviews, 0);
        }
      });
    }
    testWidgets('wide: Enter starts the session directly', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var startReviews = 0;
      var rows = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: HomeTodayChecklist(
              web: true,
              lessons: [lesson(1, read: true)],
              reviewsDone: 0,
              reviewsTotal: 5,
              newDone: 0,
              newTotal: 0,
              canAdvance: false,
              isMockDay: false,
              onLesson: (_) {},
              onLessons: () {},
              onReviews: () => rows++,
              onNew: () => rows++,
              onStartReviews: () => startReviews++,
              onStartNew: () => rows++,
              onAdvance: () {},
              onMock: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(startReviews, 1);
      expect(rows, 0);
    });
  });
}
