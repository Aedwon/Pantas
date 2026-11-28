// Study, Quiz and Settings put their large title at the same height from the
// top, on a phone (390) and on wide web (1440). Settings is the reference: the
// staging pass found Study and Quiz about 25 px lower than Settings.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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

void main() {
  late List<Override> overrides;
  setUp(() {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    overrides = [
      appDatabaseProvider.overrideWithValue(db),
      userSettingsProvider.overrideWith((ref) async => UserSettings.defaults()),
      isAnonymousProvider.overrideWith((ref) async => true),
      activeExamFocusProvider
          .overrideWith((_) async => const ActiveExamFocus.selected(_exam)),
      studyMapProvider.overrideWith((_) async => _populated),
      openTopicProvider.overrideWith(FakeOpenTopic.new),
      studyTodayLessonIdsProvider.overrideWith((_) async => const {}),
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
  });

  Future<double> top(
    WidgetTester tester, {
    required Widget page,
    required String title,
    required double width,
    required bool wide,
  }) async {
    debugWebPlatformOverride = wide ? true : null;
    addTearDown(() => debugWebPlatformOverride = null);
    final size = Size(width, 1000);
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: overrides,
        child: MaterialApp(
          theme: buildLightTheme(web: wide),
          home: MediaQuery(
            data: MediaQueryData(size: size, disableAnimations: true),
            child: wide
                ? Scaffold(
                    body: Padding(
                      padding: const EdgeInsets.fromLTRB(288, 28, 44, 44),
                      child: page,
                    ),
                  )
                : page,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final finder = find.text(title).first;
    return tester.getTopLeft(finder).dy;
  }

  for (final (name, width, wide) in [
    ('phone 390', 390.0, false),
    ('wide 1440', 1440.0, true),
  ]) {
    testWidgets('Study, Quiz and Settings titles share one top at $name',
        (tester) async {
      final settings = await top(
        tester,
        page: const SettingsHomePage(),
        title: 'Settings',
        width: width,
        wide: wide,
      );
      final study = await top(
        tester,
        page: const StudyTabHome(),
        title: 'Study',
        width: width,
        wide: wide,
      );
      final quiz = await top(
        tester,
        page: const QuizTabScreen(),
        title: 'Quiz',
        width: width,
        wide: wide,
      );
      expect(study, closeTo(settings, 0.5), reason: 'Study vs Settings');
      expect(quiz, closeTo(settings, 0.5), reason: 'Quiz vs Settings');
    });
  }
}
