// Frame work regression tests (Nov 3, item 16: choppy frame rate on phones).
//
// WHAT THIS FILE CANNOT DO: it asserts no frame rate and no frame time. A VM
// test has no GPU and no real raster step, so it cannot measure either. Real
// numbers come from a profile build on the phone with `?localFps=1` (see
// tools/local/run_web_local.py). What a VM test can count, and what this file
// asserts, is work the framework does per frame: widgets rebuilt, render
// objects repainted, tickers left running, and which source files use a blur.
// Each budget below is the measured value after the fix. A change that makes
// the same screen do more work per frame fails here, with the cause named.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/pull_to_advance.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_topic_section.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

import '../features/home/presentation/home_tab_test.dart' as home;
import '../helpers/in_memory_database.dart';
import '../helpers/pump_app.dart';

/// Counts rebuilds of widgets that were already built, by widget type.
///
/// A widget's first build is not a rebuild, so elements are registered when
/// the counter is created and as they first appear.
class _Rebuilds {
  _Rebuilds(WidgetTester tester) {
    _seen.addAll(tester.allElements);
    debugOnRebuildDirtyWidget = (element, _) {
      if (_seen.add(element)) return;
      final type = element.widget.runtimeType;
      _counts[type] = (_counts[type] ?? 0) + 1;
    };
  }

  final Set<Element> _seen = Set<Element>.identity();
  final Map<Type, int> _counts = {};

  int of(Type type) => _counts[type] ?? 0;
  void reset() => _counts.clear();
  void stop() => debugOnRebuildDirtyWidget = null;
}

/// Counts how often render objects are painted while [body] runs.
Future<int> _paints(
  bool Function(RenderObject object) match,
  Future<void> Function() body,
) async {
  var count = 0;
  debugOnProfilePaint = (object) {
    if (match(object)) count++;
  };
  try {
    await body();
  } finally {
    debugOnProfilePaint = null;
  }
  return count;
}

bool _text(RenderObject object, String prefix) =>
    object is RenderParagraph && object.text.toPlainText().startsWith(prefix);

void _phone(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(390 * 3, 844 * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _drag(
  WidgetTester tester, {
  required Offset from,
  int steps = 15,
  double step = 30,
}) async {
  final gesture = await tester.startGesture(from);
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(Offset(0, -step));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
}

/// Tears the tree down and closes the database, as the other screen tests do.
Future<void> _close(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}

void _expectIdle(WidgetTester tester) {
  expect(
    tester.binding.transientCallbackCount,
    0,
    reason: 'a ticker or animation is still running on an idle screen',
  );
  expect(tester.binding.hasScheduledFrame, isFalse);
}

void main() {
  group('screen work', () {
    late AppDatabase db;
    late ContentDatabase contentDb;
    const subjects = 8;
    const topics = 6;

    setUp(() async {
      db = inMemoryDatabase();
      contentDb = openTestContentDatabase();
      await seedContentExam(
        contentDb,
        examId: 'e1',
        code: 'CSE',
        name: 'Civil Service Exam',
        shortName: 'CSE',
      );
      for (var s = 0; s < subjects; s++) {
        await seedContentSubject(
          contentDb,
          subjectId: 's$s',
          examId: 'e1',
          name: 'Subject $s',
          ordering: s,
        );
        for (var t = 0; t < topics; t++) {
          await seedContentTopic(
            contentDb,
            topicId: 's${s}t$t',
            subjectId: 's$s',
            name: 'Topic $s.$t',
            ordering: t,
          );
          await seedContentLesson(
            contentDb,
            lessonId: 'l$s$t',
            topicId: 's${s}t$t',
            title: 'Lesson $s.$t',
          );
        }
      }
      // A long lesson: sixty paragraphs, about ten screens on a phone.
      await seedContentTopic(
        contentDb,
        topicId: 'long',
        subjectId: 's0',
        name: 'Long topic',
        ordering: 99,
      );
      await seedContentLesson(
        contentDb,
        lessonId: 'long',
        topicId: 'long',
        title: 'A long lesson',
        bodyJson: jsonEncode([
          for (var i = 0; i < 60; i++)
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {
                  '_type': 'span',
                  'text': 'Body paragraph $i. ' * 12,
                  'marks': <String>[],
                },
              ],
            },
        ]),
      );
      await AppPreferencesRepository(db).setSelectedExamId('e1');
    });

    tearDown(() {
      debugOnProfilePaint = null;
      debugOnRebuildDirtyWidget = null;
    });

    List<Override> overrides() => [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ];

    Future<void> pumpStudy(WidgetTester tester) async {
      _phone(tester);
      await tester.pumpAppWithProviders(
        const StudyTabHome(),
        overrides: overrides(),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    Future<void> pumpReader(WidgetTester tester) async {
      _phone(tester);
      await tester.pumpAppWithProviders(
        const LessonPage(lessonId: 'long'),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();
    }

    group('idle screens settle, with no endless ticker', () {
      testWidgets('Study', (tester) async {
        await pumpStudy(tester);
        await tester.pumpAndSettle();
        expect(find.text('SUBJECT 0'), findsOneWidget);
        _expectIdle(tester);
        await _close(tester, db);
      });

      testWidgets('Reader', (tester) async {
        await pumpReader(tester);
        expect(find.byType(ContentRenderer), findsOneWidget);
        _expectIdle(tester);
        await _close(tester, db);
      });

      testWidgets('Home', (tester) async {
        _phone(tester);
        await tester.pumpWidget(
          home.harness(
            result: home.assessed(),
            subjects: [home.subject('Mathematics', 8, 10)],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(HomeTab), findsOneWidget);
        _expectIdle(tester);
        await tester.runAsync(db.close);
      });

      testWidgets('Quiz', (tester) async {
        _phone(tester);
        const exam = Exam(
          id: 'e',
          code: 'E',
          name: 'Exam',
          shortName: 'Exam',
          language: 'en',
          isActive: true,
          subjects: [],
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              activeExamFocusProvider.overrideWith(
                (_) async => const ActiveExamFocus.selected(exam),
              ),
              sessionPanelProvider('e').overrideWith(
                (_) async =>
                    const SessionPanelInProgress(position: 6, total: 10),
              ),
              quizTodayCountsProvider('e').overrideWith(
                (_) async => const QuizTodayCounts(
                  reviewsDone: 12,
                  reviewsTotal: 18,
                  newDone: 3,
                  newTotal: 7,
                ),
              ),
              quizPracticeCountsProvider('e').overrideWith(
                (_) async => (mistakes: 28, flags: 12),
              ),
            ],
            child: MaterialApp(
              theme: buildLightTheme(),
              home: const QuizTabScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(QuizTabScreen), findsOneWidget);
        _expectIdle(tester);
        await tester.runAsync(db.close);
      });
    });

    group('Study list', () {
      testWidgets(
          'builds only the subjects near the screen, so the list is lazy '
          'already (the stall is not a non-lazy list)', (tester) async {
        await pumpStudy(tester);
        final built = find.byType(StudySubjectSection).evaluate().length;
        expect(built, lessThan(subjects));
        expect(built, lessThanOrEqualTo(3));
        // Far down the list nothing exists yet, not even offstage.
        expect(
          find.text('Topic ${subjects - 1}.0', skipOffstage: false),
          findsNothing,
        );
        await tester.pumpAndSettle();
        await _close(tester, db);
      });

      testWidgets(
          'the intro animations (rings and fades) repaint only themselves, '
          'not every row beside them', (tester) async {
        await pumpStudy(tester);
        // Rows are painted when they first appear. They must not be painted
        // again for each of the 100 frames the rings and the fade run: before
        // the fix this was 1768 paints for the same screen.
        final rows = find.byType(ListRow).evaluate().length;
        final paints = await _paints(
          (o) => _text(o, 'Topic '),
          () async {
            for (var i = 0; i < 100; i++) {
              await tester.pump(const Duration(milliseconds: 16));
            }
          },
        );
        expect(rows, greaterThan(5));
        expect(paints, lessThanOrEqualTo(rows * 4));
        await tester.pumpAndSettle();
        await _close(tester, db);
      });

      testWidgets('a scroll step rebuilds no section and no row',
          (tester) async {
        await pumpStudy(tester);
        await tester.pumpAndSettle();
        final rebuilds = _Rebuilds(tester);
        addTearDown(rebuilds.stop);
        await _drag(tester, from: const Offset(195, 600));
        await tester.pumpAndSettle();
        expect(rebuilds.of(StudyTabHome), 0);
        expect(rebuilds.of(StudySubjectSection), 0);
        expect(rebuilds.of(ListRow), 0);
        rebuilds.stop();
        await _close(tester, db);
      });

      testWidgets('newly scrolled-in sections do not repaint the rows above',
          (tester) async {
        await pumpStudy(tester);
        await tester.pumpAndSettle();
        final paints = await _paints(
          (o) => _text(o, 'Topic 0.'),
          () async {
            await _drag(tester, from: const Offset(195, 600), steps: 12);
            await tester.pump(const Duration(milliseconds: 800));
          },
        );
        // Subject 0 is above the new sections. A scroll moves its layer and
        // paints nothing.
        expect(paints, lessThanOrEqualTo(6));
        await tester.pumpAndSettle();
        await _close(tester, db);
      });
    });

    group('Reader', () {
      testWidgets(
          'scrolling does not repaint the lesson body, which has a layer of '
          'its own', (tester) async {
        await pumpReader(tester);
        final paints = await _paints(
          (o) => _text(o, 'Body paragraph'),
          () =>
              _drag(tester, from: const Offset(195, 600), steps: 20, step: 20),
        );
        // Before the fix a scroll view repainted its whole child every frame:
        // 1202 paragraph paints for 20 frames of a 60 paragraph lesson.
        expect(paints, 0);
        await tester.pumpAndSettle();
        await _close(tester, db);
      });

      testWidgets('a scroll step rebuilds neither the body nor the pull handle',
          (tester) async {
        await pumpReader(tester);
        final rebuilds = _Rebuilds(tester);
        addTearDown(rebuilds.stop);
        await _drag(tester, from: const Offset(195, 600), steps: 20, step: 20);
        await tester.pumpAndSettle();
        expect(rebuilds.of(ContentRenderer), 0);
        expect(rebuilds.of(PullToAdvance), 0);
        rebuilds.stop();
        await _close(tester, db);
      });
    });

    group('Tab bar', () {
      late ProviderContainer container;

      Future<void> pumpShell(WidgetTester tester) async {
        _phone(tester);
        container = ProviderContainer(
          overrides: [
            ...overrides(),
            entitlementProvider
                .overrideWith((_) => Stream.value(const Entitlement.free())),
            telemetryProvider.overrideWithValue(const DisabledTelemetry()),
          ],
        );
        addTearDown(container.dispose);
        await AppPreferencesRepository(db).setPassedAgeGate(value: true);
        final router = container.read(routerProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: buildLightTheme(),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        router.go('/study');
        await tester.pumpAndSettle();
      }

      Finder barBox() => find
          .descendant(
            of: find.byType(AppNavBar),
            matching: find.byType(DecoratedBox),
          )
          .first;

      testWidgets('a Study scroll does not repaint the bar', (tester) async {
        await pumpShell(tester);
        final box = tester.renderObject(barBox());
        final paints = await _paints(
          (o) => o == box,
          () => _drag(tester, from: const Offset(195, 500)),
        );
        expect(paints, 0);
        await tester.pumpAndSettle();
        await _close(tester, db);
      });

      testWidgets(
          'a selection rebuilds the shell and the bar once, and no page on '
          'any later frame of the glide', (tester) async {
        await pumpShell(tester);
        final rebuilds = _Rebuilds(tester);
        addTearDown(rebuilds.stop);
        await tester.tap(
          find.descendant(
            of: find.byType(AppNavBar),
            matching: find.bySemanticsLabel('Quiz'),
          ),
        );
        await tester.pump();
        expect(rebuilds.of(AppShell), 1);
        expect(rebuilds.of(AppNavBar), 1);
        // The page left behind is rebuilt in that first frame, once.
        expect(rebuilds.of(StudyTabHome), lessThanOrEqualTo(1));
        rebuilds.reset();
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        for (final type in [
          AppShell,
          AppNavBar,
          HomeTab,
          StudyTabHome,
          SettingsHomePage,
        ]) {
          expect(
            rebuilds.of(type),
            0,
            reason: '$type rebuilt during the glide',
          );
        }
        rebuilds.stop();
        await tester.pumpAndSettle();
        await _close(tester, db);
      });
    });
  });

  group('blur', () {
    // A blur is the most expensive thing a phone GPU is asked to draw, and a
    // VM test cannot see its cost. So the way to keep it out of scrolling
    // screens is a list: every file that uses one is named here, with what it
    // is for. A new use fails this test until someone reads this comment and
    // adds the file on purpose. Box shadows (blurRadius) are not scanned;
    // there are many and they are part of the approved look.
    const allowed = {
      // The mock exam pause screen fades the paper behind it in and out.
      'lib/features/mock_exam/presentation/pause_page.dart',
      // The mock exam finale glow, drawn once on a still painter.
      'lib/features/mock_exam/presentation/widgets/cse_mock_finale.dart',
    };
    final pattern = RegExp(
      r'ImageFilter\.blur|BackdropFilter|ImageFiltered|MaskFilter\.blur',
    );

    test('only the listed files use a blur', () {
      final found = <String>{};
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (pattern.hasMatch(entity.readAsStringSync())) {
          found.add(entity.path);
        }
      }
      expect(found, allowed);
    });

    test('the scan finds a blur when there is one', () {
      expect(pattern.hasMatch('BackdropFilter(filter: x)'), isTrue);
      expect(pattern.hasMatch('ui.ImageFilter.blur(sigmaX: 1)'), isTrue);
      expect(pattern.hasMatch('Container(color: x)'), isFalse);
    });
  });
}
