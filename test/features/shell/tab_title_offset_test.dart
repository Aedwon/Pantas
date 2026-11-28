// U3 and U4: the Study and Quiz tab titles start at the same height in every
// state, 20 px under the top of the screen, the height of the Settings title
// (his staging pass, 26 November, superseding the 50 px of the boards).
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/page_title.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../helpers/in_memory_database.dart';
import '../lesson/presentation/fake_open_topic.dart';

const _exam = Exam(
  id: 'e',
  code: 'E',
  name: 'Exam',
  shortName: 'Exam',
  language: 'en',
  isActive: true,
  subjects: [],
);

const _populated = StudyMap(
  examShortName: 'Exam',
  subjects: [
    StudySubject(
      id: 's1',
      name: 'Mathematics',
      topics: [
        StudyTopic(
          id: 't1',
          name: 'Algebra',
          lessons: [
            StudyLesson(
              id: 'l1',
              title: 'Basics',
              isRead: false,
              isBookmarked: false,
            ),
          ],
          readCount: 0,
          hasBookmark: false,
        ),
      ],
    ),
  ],
  readCount: 0,
  totalCount: 1,
);

const _empty = StudyMap(
  examShortName: 'Exam',
  subjects: [],
  readCount: 0,
  totalCount: 0,
);

void main() {
  const boardTitleTop = 20.0;

  test('the shared offset is the Settings title top', () {
    expect(PantasPage.tabTitleTop, boardTitleTop);
  });

  Future<void> phone(WidgetTester tester, Widget home, List<Override> o) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: o,
        child: MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 1000),
              disableAnimations: true,
            ),
            child: home,
          ),
        ),
      ),
    );
  }

  List<Override> studyOverrides({
    required Future<StudyMap?> Function() map,
    bool selected = true,
  }) =>
      [
        activeExamFocusProvider.overrideWith(
          (_) async => selected
              ? const ActiveExamFocus.selected(_exam)
              : const ActiveExamFocus.needsSelection(),
        ),
        studyMapProvider.overrideWith((_) => map()),
        openTopicProvider.overrideWith(FakeOpenTopic.new),
        studyTodayLessonIdsProvider.overrideWith((_) async => const {}),
      ];

  double studyTitleTop(WidgetTester tester) =>
      tester.getTopLeft(find.text('Study')).dy;

  group('Study title (phone)', () {
    testWidgets('loaded', (tester) async {
      await phone(
        tester,
        const StudyTabHome(),
        studyOverrides(map: () async => _populated),
      );
      await tester.pumpAndSettle();
      expect(studyTitleTop(tester), boardTitleTop);
    });

    testWidgets('loading', (tester) async {
      final never = Completer<StudyMap?>();
      await phone(
        tester,
        const StudyTabHome(),
        studyOverrides(map: () => never.future),
      );
      await tester.pump();
      expect(studyTitleTop(tester), boardTitleTop);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('empty', (tester) async {
      await phone(
        tester,
        const StudyTabHome(),
        studyOverrides(map: () async => _empty),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nothing to study yet'), findsOneWidget);
      expect(studyTitleTop(tester), boardTitleTop);
    });

    testWidgets('error', (tester) async {
      await phone(
        tester,
        const StudyTabHome(),
        studyOverrides(map: () async => throw Exception('x')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Could not load your topics.'), findsOneWidget);
      expect(studyTitleTop(tester), boardTitleTop);
    });

    testWidgets('no exam chosen', (tester) async {
      await phone(
        tester,
        const StudyTabHome(),
        studyOverrides(map: () async => null, selected: false),
      );
      await tester.pumpAndSettle();
      expect(find.text('Choose your exam'), findsOneWidget);
      expect(studyTitleTop(tester), boardTitleTop);
    });
  });

  List<Override> quizOverrides({
    required Future<ActiveExamFocus> Function() focus,
  }) =>
      [
        activeExamFocusProvider.overrideWith((_) => focus()),
        sessionPanelProvider('e').overrideWith(
          (_) async => const SessionPanelInProgress(position: 6, total: 10),
        ),
        quizTodayCountsProvider('e').overrideWith(
          (_) async => const QuizTodayCounts(
            reviewsDone: 12,
            reviewsTotal: 18,
            newDone: 3,
            newTotal: 7,
          ),
        ),
        quizPracticeCountsProvider('e')
            .overrideWith((_) async => (mistakes: 28, flags: 12)),
      ];

  double quizTitleTop(WidgetTester tester) =>
      tester.getTopLeft(find.text('Quiz').first).dy;

  group('Quiz title (phone)', () {
    testWidgets('loaded', (tester) async {
      await phone(
        tester,
        const QuizTabScreen(),
        quizOverrides(
          focus: () async => const ActiveExamFocus.selected(_exam),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reviews'), findsOneWidget);
      expect(quizTitleTop(tester), boardTitleTop);
    });

    testWidgets('loading', (tester) async {
      final never = Completer<ActiveExamFocus>();
      await phone(
        tester,
        const QuizTabScreen(),
        quizOverrides(focus: () => never.future),
      );
      await tester.pump();
      expect(quizTitleTop(tester), boardTitleTop);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('error', (tester) async {
      await phone(
        tester,
        const QuizTabScreen(),
        quizOverrides(focus: () async => throw Exception('x')),
      );
      await tester.pumpAndSettle();
      expect(quizTitleTop(tester), boardTitleTop);
    });

    testWidgets('no exam chosen', (tester) async {
      await phone(
        tester,
        const QuizTabScreen(),
        quizOverrides(
          focus: () async => const ActiveExamFocus.needsSelection(),
        ),
      );
      await tester.pumpAndSettle();
      expect(quizTitleTop(tester), boardTitleTop);
    });
  });

  // His call (26 November, real browser, 390 wide): the Study title's letters
  // sat 2 px below Quiz and Settings although the boxes matched. The painted
  // alphabetic baseline of the real Geist font is what the eye compares, so
  // this holds the baseline, not only the box.
  group('Tab title glyph baseline (phone)', () {
    setUpAll(() async {
      final loader = FontLoader('Geist');
      for (final f in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        final bytes = File('assets/fonts/Geist-$f.ttf').readAsBytesSync();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    });

    double baselineOf(WidgetTester tester, Finder text) {
      final box = tester.renderObject<RenderParagraph>(text);
      return box.localToGlobal(Offset.zero).dy +
          box.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    }

    Future<double> study(WidgetTester tester) async {
      await phone(
        tester,
        const StudyTabHome(),
        studyOverrides(map: () async => _populated),
      );
      await tester.pumpAndSettle();
      return baselineOf(tester, find.text('Study'));
    }

    Future<double> quiz(WidgetTester tester) async {
      await phone(
        tester,
        const QuizTabScreen(),
        quizOverrides(focus: () async => const ActiveExamFocus.selected(_exam)),
      );
      await tester.pumpAndSettle();
      return baselineOf(tester, find.text('Quiz').first);
    }

    Future<double> settings(WidgetTester tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await phone(tester, const SettingsHomePage(), [
        appDatabaseProvider.overrideWithValue(db),
        userSettingsProvider.overrideWith(
          (ref) async => UserSettings.defaults(),
        ),
        isAnonymousProvider.overrideWith((ref) async => true),
      ]);
      await tester.pumpAndSettle();
      return baselineOf(tester, find.text('Settings').first);
    }

    // In a real browser at 390 wide, a plain Text paints this title 2 px below
    // the same text inside PantasTitle (Quiz and Settings), box and baseline
    // equal in every widget test. Only a browser run shows it (glyph rows 26
    // vs 24 at 390 x 844), so the loaded Study title must be a PantasTitle
    // like the other two.
    testWidgets(
        'the loaded Study title is a PantasTitle, as in Quiz and Settings',
        (tester) async {
      await phone(
        tester,
        const StudyTabHome(),
        studyOverrides(map: () async => _populated),
      );
      await tester.pumpAndSettle();
      expect(
        find.ancestor(
          of: find.text('Study'),
          matching: find.byType(PantasTitle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Study, Quiz and Settings paint the title on one baseline', (
      tester,
    ) async {
      final s = await study(tester);
      final q = await quiz(tester);
      final t = await settings(tester);
      expect(q, t, reason: 'Quiz vs Settings');
      expect(s, t, reason: 'Study vs Settings');
    });
  });

  testWidgets('Study and Quiz start at the same height in the same states',
      (tester) async {
    await phone(
      tester,
      const StudyTabHome(),
      studyOverrides(map: () async => _populated),
    );
    await tester.pumpAndSettle();
    final study = studyTitleTop(tester);
    await phone(
      tester,
      const QuizTabScreen(),
      quizOverrides(
        focus: () async => const ActiveExamFocus.selected(_exam),
      ),
    );
    await tester.pumpAndSettle();
    expect(quizTitleTop(tester), study);
  });

  // Boards W_Study and W_QuizTab: both h1 carry the same 4 px side inset.
  testWidgets('wide web: the Study and Quiz headings start at the same x',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<double> left(Widget page, List<Override> o, String text) async {
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: o,
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData(
                  size: Size(1440, 900),
                  disableAnimations: true,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(288, 28, 44, 44),
                  child: page,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final h1 = find.byWidgetPredicate(
        (w) => w is WebText && w.kind == WebTextKind.h1 && w.text == text,
      );
      return tester.getTopLeft(h1).dx;
    }

    final study = await left(
      const StudyTabHome(),
      studyOverrides(map: () async => _populated),
      'Study',
    );
    final quiz = await left(
      const QuizTabScreen(),
      quizOverrides(
        focus: () async => const ActiveExamFocus.selected(_exam),
      ),
      'Quiz',
    );
    expect(quiz, study);
  });
}
