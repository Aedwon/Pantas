// Design system 4.0, Study and reader family: every Study and reader screen at
// 390, 1100 and 1440 wide, light and dark, at text scale 1.0 and 2.0, with no
// layout overflow. The last group checks that the reader's own text size
// control still works on top of an OS text scale of 2.0.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_text_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';
import 'package:pantas/features/lesson/domain/use_cases/decide_ending.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/pages/topic_ending_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/lesson_contents_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_skeletons.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';

/// A phone, the compact sidebar range and the full width.
final _cells = <DsCell>[
  for (final width in [390.0, 1100.0, 1440.0])
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
];

const _lessonOne = StudyLesson(
  id: 'l1',
  title: 'Adding Fractions with Unlike Denominators',
  estimatedMinutes: 9,
  isRead: true,
  isBookmarked: true,
);
const _lessonTwo = StudyLesson(
  id: 'l2',
  title: 'Subtracting Fractions',
  estimatedMinutes: 7,
  isRead: false,
  isBookmarked: false,
);

const _map = StudyMap(
  examShortName: 'CSE',
  subjects: [
    StudySubject(
      id: 's1',
      name: 'Mathematics',
      topics: [
        StudyTopic(
          id: 't1',
          name: 'Fractions',
          lessons: [_lessonOne, _lessonTwo],
          readCount: 1,
          hasBookmark: true,
        ),
      ],
    ),
  ],
  readCount: 1,
  totalCount: 2,
  minutesLeftToRead: 7,
);

Map<String, Object?> _text(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
    };

String _body() => jsonEncode([
      _text('Core Concept', style: 'h2'),
      _text('A fraction names a part of a whole. ' * 6),
      {'_type': 'latex', 'body': r'\dfrac{1}{2}+\dfrac{1}{3}=\dfrac{5}{6}'},
      _text('Mnemonics', style: 'h2'),
      {
        ..._text('Bottoms must match before you add.'),
        'style': 'blockquote',
      },
      _text('Traps to Watch For', style: 'h2'),
      {
        ..._text('Do not add the bottoms together.'),
        'style': 'blockquote',
      },
    ]);

/// Pumps [child] at [cell] inside the real theme, the web platform from 1024
/// and the app-root text scale (the OS scaler is captured, the UI is clamped).
Future<void> _pump(
  WidgetTester tester,
  DsCell cell,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = Size(cell.width, 900)
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
  final web = cell.width >= 1024;
  debugWebPlatformOverride = web;
  final theme =
      cell.dark ? buildDarkTheme(web: web) : buildLightTheme(web: web);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        theme: theme,
        builder: (context, home) => MediaQuery(
          data: MediaQueryData(
            size: Size(cell.width, 900),
            textScaler: TextScaler.linear(cell.scale),
            disableAnimations: true,
          ),
          child: AppTextScale(child: home ?? const SizedBox()),
        ),
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => Scaffold(body: child),
            ),
          ],
        ),
      ),
    ),
  );
  // The stores answer on real time, so give the providers a moment.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

void _matrix(
  String name,
  Widget Function(DsCell cell) build, {
  List<Override> Function(DsCell cell)? overrides,
  Future<void> Function(WidgetTester tester, DsCell cell)? check,
  String? shows,
  bool seed = true,
}) {
  for (final cell in _cells) {
    testWidgets('$name ($cell)', (tester) async {
      await tester.runAsync(loadDsFonts);
      final db = inMemoryDatabase();
      final contentDb = openTestContentDatabase();
      if (seed) await tester.runAsync(() => _seed(db, contentDb));
      await _pump(
        tester,
        cell,
        build(cell),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          ...?overrides?.call(cell),
        ],
      );
      expect(tester.takeException(), isNull);
      if (check != null) await check(tester, cell);
      if (shows != null) {
        expect(
          find.textContaining(shows, findRichText: true),
          findsWidgets,
          reason: 'the screen shows its content, not a placeholder',
        );
      }
      await _dispose(tester, db, contentDb);
    });
  }
}

/// Takes the page down and lets its timers run out, then closes both stores.
Future<void> _dispose(
  WidgetTester tester,
  AppDatabase db,
  ContentDatabase contentDb,
) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 10));
  await tester.runAsync(() async {
    await db.close();
    await contentDb.close();
  });
}

/// The wide search keeps its query in its own field, so type it.
Future<void> _typeInWideSearch(
  WidgetTester tester,
  DsCell cell,
  String query,
) async {
  if (cell.width < 1024) return;
  await tester.enterText(find.byType(TextField), query);
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
  expect(tester.takeException(), isNull);
}

Future<void> _seed(AppDatabase db, ContentDatabase contentDb) async {
  await seedContentExam(
    contentDb,
    examId: 'e1',
    code: 'CSE',
    name: 'Civil Service Exam',
    shortName: 'CSE',
  );
  await seedContentSubject(
    contentDb,
    subjectId: 's1',
    examId: 'e1',
    name: 'Mathematics',
  );
  await seedContentTopic(
    contentDb,
    topicId: 't1',
    subjectId: 's1',
    name: 'Fractions',
  );
  for (final (id, title, order) in [
    ('l1', _lessonOne.title, 1),
    ('l2', _lessonTwo.title, 2),
  ]) {
    await seedContentLesson(
      contentDb,
      lessonId: id,
      topicId: 't1',
      title: title,
      summary: 'Fractions',
      bodyJson: _body(),
      estimatedMinutes: 8,
      ordering: order,
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'question_$id',
      topicId: 't1',
      examId: 'e1',
      lessonId: id,
    );
  }
  await AppPreferencesRepository(db).setSelectedExamId('e1');
}

void main() {
  _matrix('Study list', (_) => const StudyTabHome(), shows: 'Fractions');

  _matrix(
    'Reader',
    (_) => const LessonPage(lessonId: 'l1'),
    shows: 'Core Concept',
  );

  _matrix(
    'Reader opened from a plan day',
    (_) => LessonPage(
      lessonId: 'l1',
      dayContext: LessonDayContext(
        date: DateTime(2026, 10, 30),
        lessonIds: const ['l1', 'l2'],
        index: 0,
      ),
    ),
    shows: 'Core Concept',
  );

  _matrix(
    'Topic ending',
    (_) => TopicEndingPage(
      topicId: 't1',
      ending: decideEnding(
        topic: _map.subjects.first.topics.first,
        subject: _map.subjects.first,
        examShortName: 'CSE',
        studentName: 'Aedwon',
        today: DateTime(2026, 10, 2),
        nextTopic: null,
      ),
    ),
    shows: 'Fractions',
    seed: false,
  );

  _matrix(
    'Day ending',
    (_) => const TopicEndingPage(topicId: 't1', ending: DayFinished()),
    shows: 'enough for today',
    seed: false,
  );

  _matrix(
    'Search results',
    (cell) =>
        cell.width >= 1024 ? const WebLessonSearch() : const SearchResults(),
    overrides: (_) => [
      searchQueryProvider.overrideWith((ref) => 'frac'),
      searchResultsProvider.overrideWith(
        (ref) async => [
          const LessonSearchHit(
            lessonId: 'l1',
            title: 'Adding Fractions',
            topicName: 'Fractions',
            estimatedMinutes: 9,
            titleMatch: SearchSnippet(
              text: 'Adding Fractions',
              matchStart: 7,
              matchLength: 4,
            ),
          ),
          const LessonSearchHit(
            lessonId: 'l2',
            title: 'Subtracting',
            topicName: 'Fractions',
            estimatedMinutes: 7,
            bodySnippet: SearchSnippet(
              text: '...a fraction names a part of a whole...',
              matchStart: 5,
              matchLength: 8,
            ),
          ),
        ],
      ),
      recentlyOpenedLessonsProvider.overrideWith((ref) async => const []),
    ],
    check: (tester, cell) => _typeInWideSearch(tester, cell, 'frac'),
    shows: 'Adding Fractions',
  );

  _matrix(
    'Search with no match',
    (cell) =>
        cell.width >= 1024 ? const WebLessonSearch() : const SearchResults(),
    overrides: (_) => [
      searchQueryProvider.overrideWith((ref) => 'zzzz'),
      searchResultsProvider
          .overrideWith((ref) async => const <LessonSearchHit>[]),
      recentlyOpenedLessonsProvider.overrideWith((ref) async => const []),
    ],
    check: (tester, cell) => _typeInWideSearch(tester, cell, 'zzzz'),
    shows: 'Nothing matched',
  );

  _matrix(
    'Bookmarks sheet',
    (cell) => BookmarksSheet(wide: cell.width >= 1024, onClose: () {}),
    overrides: (_) => [
      bookmarkRowsProvider.overrideWith(
        (ref) async => const [
          BookmarkRow(
            lessonId: 'l1',
            title: 'Adding Fractions with Unlike Denominators',
            topicName: 'Fractions',
            estimatedMinutes: 9,
            subjectName: 'Mathematics',
          ),
        ],
      ),
    ],
    shows: 'Adding Fractions with Unlike',
  );

  _matrix(
    'Lesson contents sheet',
    (_) => SingleChildScrollView(
      child: LessonContentsSheet(
        reader: ReaderContext(
          lesson: _readerLesson(),
          topicId: 't1',
          topicName: 'Fractions',
          next: _lessonTwo,
          positionInTopic: 1,
          lessonsInTopic: 2,
          topicLessons: const [_lessonOne, _lessonTwo],
          isRead: true,
          isBookmarked: false,
          examId: 'e1',
        ),
        onSelectLesson: (_) {},
      ),
    ),
    overrides: (_) => [studyMapProvider.overrideWith((_) async => _map)],
    shows: 'Subtracting Fractions',
  );

  _matrix(
    'Reader loading skeleton',
    (_) => const SingleChildScrollView(child: ReaderSkeleton()),
    seed: false,
  );

  _matrix(
    'Study loading skeleton',
    (_) => const SingleChildScrollView(child: StudyMapSkeleton()),
    seed: false,
  );

  group('the reader text size control on top of the OS text scale', () {
    for (final lessonScale in [1.0, 1.4]) {
      testWidgets('OS 2.0 times lesson $lessonScale reaches the reader text',
          (tester) async {
        await tester.runAsync(loadDsFonts);
        final db = inMemoryDatabase();
        addTearDown(db.close);
        late double readerPixels;
        late double uiPixels;
        await _pump(
          tester,
          const DsCell(390, 2, dark: false),
          Consumer(
            builder: (context, ref, _) {
              ref.watch(lessonTextScaleProvider);
              return Column(
                children: [
                  Builder(
                    builder: (context) {
                      uiPixels = MediaQuery.textScalerOf(context).scale(10);
                      return const Text('Interface text');
                    },
                  ),
                  LessonTextScale(
                    child: Builder(
                      builder: (context) {
                        readerPixels =
                            MediaQuery.textScalerOf(context).scale(10);
                        return ContentRenderer(
                          readerFigures: true,
                          blocks: [_text('Reader paragraph.')],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            lessonTextScaleProvider.overrideWith(
              (ref) => _FixedLessonScale(ref, lessonScale),
            ),
          ],
        );
        expect(uiPixels, 20, reason: 'the UI follows the OS scale');
        expect(
          readerPixels,
          closeTo(20 * lessonScale, .001),
          reason: 'the reader multiplies the OS scale by the lesson scale',
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('the reader keeps the full OS size above the UI clamp',
        (tester) async {
      await tester.runAsync(loadDsFonts);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      late double readerPixels;
      late double uiPixels;
      await _pump(
        tester,
        const DsCell(390, 3, dark: false),
        Builder(
          builder: (context) {
            uiPixels = MediaQuery.textScalerOf(context).scale(10);
            return LessonTextScale(
              child: Builder(
                builder: (context) {
                  readerPixels = MediaQuery.textScalerOf(context).scale(10);
                  return const SizedBox();
                },
              ),
            );
          },
        ),
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      expect(uiPixels, 10 * maxUiTextScale);
      expect(readerPixels, 30);
    });
  });
}

Lesson _readerLesson() => Lesson(
      id: 'l1',
      topicId: 't1',
      title: _lessonOne.title,
      summary: '',
      estimatedMinutes: 9,
      bodyJson: const [],
    );

class _FixedLessonScale extends LessonTextScaleController {
  _FixedLessonScale(Ref ref, double scale)
      : super(ref.watch(appPreferencesRepositoryProvider)) {
    state = scale;
  }
}
