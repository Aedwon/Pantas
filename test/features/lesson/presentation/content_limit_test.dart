import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_study_layout.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import 'fake_open_topic.dart';

const _message = 'Daily content limit reached. Try again tomorrow.';
const _focus = ActiveExamFocus.selected(
  Exam(
    id: 'e',
    code: 'CSE',
    name: 'CSE',
    shortName: 'CSE',
    language: 'en',
    isActive: true,
    subjects: [],
  ),
);
const _emptyMap = StudyMap(
  examShortName: 'CSE',
  subjects: [],
  readCount: 0,
  totalCount: 0,
  minutesLeftToRead: 0,
);

void main() {
  late AppDatabase db;
  setUp(() => db = inMemoryDatabase());
  tearDown(() {
    debugWebPlatformOverride = null;
    return db.close();
  });

  for (final wide in [false, true]) {
    for (final limited in [false, true]) {
      testWidgets('a lesson that did not load, wide $wide, limit $limited',
          (tester) async {
        debugWebPlatformOverride = wide;
        if (wide) {
          tester.view
            ..physicalSize = const Size(1440, 900)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        }
        final content = openTestContentDatabase();
        await seedContentExam(
          content,
          examId: 'e',
          code: 'CSE',
          name: 'CSE',
          shortName: 'CSE',
        );
        await AppPreferencesRepository(db).setSelectedExamId('e');
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              contentDatabaseProvider.overrideWithValue(content),
              activeExamFocusProvider.overrideWith((_) async => _focus),
              readerContextProvider('listed').overrideWith(
                (_) async => throw const LessonLoadFailure('listed'),
              ),
              if (limited)
                contentLimitReachedProvider.overrideWith((_) => true),
            ],
            child: MaterialApp(
              theme: buildLightTheme(web: wide),
              home: const Scaffold(body: LessonPage(lessonId: 'listed')),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(_message), limited ? findsOneWidget : findsNothing);
        expect(
          find.text('Could not load this lesson.'),
          limited ? findsNothing : findsOneWidget,
        );
      });
    }
  }

  testWidgets('an empty study map on a phone says the limit when reached',
      (tester) async {
    await tester.pumpAppWithProviders(
      const StudyTabHome(),
      overrides: [
        activeExamFocusProvider.overrideWith((_) async => _focus),
        studyMapProvider.overrideWith((ref) async => _emptyMap),
        openTopicProvider.overrideWith(FakeOpenTopic.new),
        studyTodayLessonIdsProvider.overrideWith((ref) async => const {}),
        contentLimitReachedProvider.overrideWith((_) => true),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byType(StateView), findsOneWidget);
    expect(find.text(_message), findsOneWidget);
    expect(find.text('Nothing to study yet'), findsNothing);
  });

  testWidgets('an empty study map on wide web says the limit when reached',
      (tester) async {
    debugWebPlatformOverride = true;
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeExamFocusProvider.overrideWith((_) async => _focus),
          studyMapProvider.overrideWith((ref) async => _emptyMap),
          openTopicProvider.overrideWith(FakeOpenTopic.new),
          studyTodayLessonIdsProvider.overrideWith((ref) async => const {}),
          contentLimitReachedProvider.overrideWith((_) => true),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: const Scaffold(body: WebStudyLayout()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(_message), findsOneWidget);
    expect(find.text('Nothing to study yet'), findsNothing);
  });
}
