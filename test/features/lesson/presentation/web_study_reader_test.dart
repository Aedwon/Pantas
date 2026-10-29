import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_gap.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_ending_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_study_layout.dart';

import '../../../helpers/in_memory_database.dart';

const first = StudyLesson(
  id: 'l1',
  title: 'Layers',
  estimatedMinutes: 11,
  isRead: true,
  isBookmarked: true,
);
const second = StudyLesson(
  id: 'l2',
  title: 'Plate Tectonics',
  estimatedMinutes: 12,
  isRead: false,
  isBookmarked: false,
);
const topic = StudyTopic(
  id: 't1',
  name: 'Earth Science',
  lessons: [first, second],
  readCount: 1,
  hasBookmark: true,
);
const map = StudyMap(
  examShortName: 'CSE',
  subjects: [
    StudySubject(id: 's1', name: 'Science', topics: [topic]),
  ],
  readCount: 1,
  totalCount: 2,
  minutesLeftToRead: 12,
);

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  Future<void> pump(
    WidgetTester tester,
    Widget child,
    Brightness brightness, {
    List<Override> overrides = const [],
  }) async {
    tester.view.resetPhysicalSize();
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: brightness == Brightness.dark
              ? buildDarkTheme(web: true)
              : buildLightTheme(web: true),
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
  }

  for (final brightness in Brightness.values) {
    testWidgets(
        'wide reader failure retries without exposing details $brightness',
        (tester) async {
      final db = inMemoryDatabase();
      final content = openTestContentDatabase();
      addTearDown(db.close);
      addTearDown(content.close);
      await seedContentExam(
        content,
        examId: 'e',
        code: 'CSE',
        name: 'CSE',
        shortName: 'CSE',
      );
      await AppPreferencesRepository(db).setSelectedExamId('e');
      var attempts = 0;
      await pump(
        tester,
        const LessonPage(lessonId: 'missing'),
        brightness,
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          readerContextProvider('missing').overrideWith((_) async {
            attempts++;
            throw Exception('private database path');
          }),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(WebTopBar), findsOneWidget);
      expect(find.text('Could not load this lesson.'), findsOneWidget);
      expect(find.textContaining('private database'), findsNothing);
      final before = attempts;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(attempts, greaterThan(before));
      await tester.pumpWidget(const SizedBox());
    });
    testWidgets(
        'wide Home day reader advances and finishes its list $brightness',
        (tester) async {
      final db = inMemoryDatabase();
      final content = openTestContentDatabase();
      addTearDown(db.close);
      addTearDown(content.close);
      await seedContentExam(
        content,
        examId: 'e',
        code: 'CSE',
        name: 'CSE',
        shortName: 'CSE',
      );
      await seedContentSubject(
        content,
        subjectId: 's1',
        examId: 'e',
        name: 'Science',
      );
      await seedContentTopic(
        content,
        topicId: 't1',
        subjectId: 's1',
        name: 'Earth Science',
      );
      for (final lesson in [first, second]) {
        await seedContentLesson(
          content,
          lessonId: lesson.id,
          topicId: 't1',
          title: lesson.title,
          bodyJson: '[]',
        );
      }
      await AppPreferencesRepository(db).setSelectedExamId('e');
      await pump(
        tester,
        LessonPage(
          lessonId: 'l1',
          origin: ReaderOrigin.home,
          dayContext: LessonDayContext(
            date: DateTime(2026, 10, 30),
            lessonIds: const ['l1', 'l2'],
            index: 0,
          ),
        ),
        brightness,
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          studyMapProvider.overrideWith((_) async => map),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(WebReaderLayout), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('1 of 2'), findsOneWidget);
      await tester.tap(find.text('1 of 2'));
      await tester.pumpAndSettle();
      expect(find.text('Plate Tectonics'), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('2 of 2'), findsOneWidget);
      expect(find.text('Finish today'), findsOneWidget);
      await tester.tap(find.byTooltip('Bookmark this lesson (B)'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('That’s enough for today.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    testWidgets('wide study map and topic stay side by side $brightness',
        (tester) async {
      String? opened;
      await pump(
        tester,
        WebStudyMap(
          map: map,
          openTopicId: 't1',
          today: const {'l2'},
          lastLessonId: 'l1',
          lastTitle: 'Layers',
          onTopic: (_) {},
          onLesson: (id, {required resume}) => opened = id,
          onBookmarks: () {},
        ),
        brightness,
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('web-study-topic'))).dx,
        greaterThan(
          tester.getTopLeft(find.byKey(const ValueKey('web-study-map'))).dx +
              340,
        ),
      );
      expect(find.text('LAST OPENED'), findsOneWidget);
      expect(find.text('BOOKMARKS'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('12 min'), findsOneWidget);
      await tester.tap(find.text('Plate Tectonics'));
      expect(opened, 'l2');
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide study empty bookmarks and state copy $brightness',
        (tester) async {
      const emptyMap = StudyMap(
        examShortName: 'CSE',
        subjects: [],
        readCount: 0,
        totalCount: 0,
        minutesLeftToRead: 0,
      );
      await pump(
        tester,
        WebStudyMap(
          map: emptyMap,
          onTopic: (_) {},
          onLesson: (_, {required resume}) {},
          onBookmarks: () {},
        ),
        brightness,
      );
      expect(find.text('Bookmark a lesson to keep it here.'), findsOneWidget);
      for (final title in [
        'Choose your exam',
        'Nothing to study yet',
        'Could not load your topics.',
      ]) {
        await pump(
          tester,
          WebStudyState(
            title: title,
            isError: title.startsWith('Could not'),
            action: 'Try Again',
            onAction: () {},
          ),
          brightness,
        );
        expect(find.text(title), findsOneWidget);
        expect(
          tester.widget<WebButton>(find.byType(WebButton)).variant,
          WebButtonVariant.secondary,
        );
        if (title.startsWith('Could not')) {
          expect(tester.widget<Text>(find.text(title)).style!.fontSize, 17);
          expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
        }
        expect(tester.getSize(find.byType(WebButton)).width, lessThan(300));
      }
      await pump(tester, const WebStudyLoading(), brightness);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(WebStudyLoading), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
    testWidgets('wide empty map still requires exam selection $brightness',
        (tester) async {
      await pump(
        tester,
        const WebStudyLayout(),
        brightness,
        overrides: [
          studyMapProvider.overrideWith(
            (_) async => const StudyMap(
              examShortName: '',
              subjects: [],
              readCount: 0,
              totalCount: 0,
              minutesLeftToRead: 0,
            ),
          ),
          activeExamFocusProvider.overrideWith(
            (_) async => const ActiveExamFocus.needsSelection(),
          ),
          lastOpenedLessonProvider.overrideWith((_) async => null),
          studyTodayLessonIdsProvider.overrideWith((_) async => <String>{}),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Choose your exam'), findsOneWidget);
      expect(find.text('Choose Exam'), findsOneWidget);
    });
    testWidgets('wide reader outline, menu, B and focus bar $brightness',
        (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final scroll = ScrollController();
      final offset = ValueNotifier<double>(0);
      final progress = ValueNotifier<double>(0);
      addTearDown(scroll.dispose);
      addTearDown(offset.dispose);
      addTearDown(progress.dispose);
      var bookmarks = 0;
      var advanced = 0;
      const reader = ReaderContext(
        lesson: Lesson(
          id: 'l1',
          topicId: 't1',
          title: 'Layers',
          summary: '',
          estimatedMinutes: 11,
          bodyJson: [
            {
              '_type': 'block',
              'style': 'h2',
              'children': [
                {'text': 'Core concept'},
              ],
            },
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {'text': 'Earth has several layers.'},
              ],
            },
            {
              '_type': 'block',
              'style': 'h2',
              'children': [
                {'text': 'Crust'},
              ],
            },
          ],
        ),
        topicId: 't1',
        topicName: 'Earth Science',
        next: second,
        positionInTopic: 1,
        lessonsInTopic: 2,
        topicLessons: [first, second],
        isRead: true,
        isBookmarked: false,
        examId: 'e',
      );
      await pump(
        tester,
        WebReaderLayout(
          reader: reader,
          controller: scroll,
          scrollOffset: offset,
          progress: progress,
          onBack: () {},
          onBookmark: () => bookmarks++,
          onLesson: (_) {},
          onNext: () => advanced++,
          footer: const SizedBox(),
          resumed: true,
        ),
        brightness,
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const ValueKey('web-reader-column'))).width,
        680,
      );
      expect(find.text('IN THIS LESSON'), findsOneWidget);
      expect(find.text('Earth Science · 11 min'), findsOneWidget);
      expect(find.text('1 of 2'), findsOneWidget);
      final control = find
          .ancestor(of: find.text('1 of 2'), matching: find.byType(TextButton))
          .first;
      expect(tester.getCenter(control).dx, 720);
      await tester.tap(find.byTooltip('Bookmark this lesson (B)'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(advanced, 1);
      await tester.tap(find.text('Core concept').first);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(advanced, 2);
      expect(find.text('Picked up where you left off'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      expect(bookmarks, 2);
      await tester.tap(find.text('1 of 2'));
      await tester.pumpAndSettle();
      expect(find.text('EARTH SCIENCE · 2 LESSONS'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('EARTH SCIENCE · 2 LESSONS'), findsNothing);
      offset.value = 100;
      await tester.pump();
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .minHeight,
        2,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
    testWidgets('wide read and quiz share a ruled row $brightness',
        (tester) async {
      await pump(
        tester,
        const Center(
          child: SizedBox(
            width: 680,
            child: ReaderGap(isRead: true, examId: 'e', lessonId: 'l1'),
          ),
        ),
        brightness,
      );
      expect(
        tester.getCenter(find.text('Read')).dy,
        closeTo(tester.getCenter(find.byType(WebButton)).dy, 1),
      );
      expect(tester.getTopRight(find.byType(WebButton)).dx, 1060);
      final ruled = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(WebButton),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((ruled.decoration! as BoxDecoration).border, isNotNull);
    });
    testWidgets('wide next card supports its arrow key $brightness',
        (tester) async {
      var advanced = 0;
      await pump(
        tester,
        Center(
          child: SizedBox(
            width: 680,
            child: WebReaderNext(
              label: 'Next in Earth Science',
              title: 'Plate Tectonics',
              detail: '12 min',
              onPressed: () => advanced++,
            ),
          ),
        ),
        brightness,
      );
      expect(find.text('NEXT IN EARTH SCIENCE'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(advanced, 1);
    });
    testWidgets('wide day and topic endings $brightness', (tester) async {
      var home = 0;
      await pump(
        tester,
        WebEndingLayout(
          ending: const DayFinished(),
          onLesson: (_) {},
          onHome: () => home++,
        ),
        brightness,
      );
      expect(find.text('That’s enough for today.'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(home, 1);
      await pump(
        tester,
        WebEndingLayout(
          ending: const TopicFinished(
            studentName: null,
            topicName: 'Earth Science',
            examAndSubject: 'CSE · Science',
            footing: '2 lessons, all read',
            dateLine: 'October 30, 2026',
            next: topic,
          ),
          onLesson: (_) {},
          onHome: () {},
        ),
        brightness,
      );
      expect(find.text('2 lessons, all read'), findsOneWidget);
      expect(find.text('NEXT TOPIC · EARTH SCIENCE'), findsOneWidget);
      await pump(
        tester,
        WebEndingLayout(
          ending: const TopicStoppedShort(
            studentName: null,
            topicName: 'Earth Science',
            examAndSubject: 'CSE · Science',
            footing: '1 of 2 lessons read',
            dateLine: 'October 30, 2026',
            unread: [second],
          ),
          onLesson: (_) {},
          onHome: () {},
        ),
        brightness,
      );
      expect(find.text('Still unread'), findsOneWidget);
      expect(find.text('Plate Tectonics'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide reader figure and failed image $brightness',
        (tester) async {
      await pump(
        tester,
        Center(
          child: SizedBox(
            width: 680,
            child: ContentRenderer(
              readerFigures: true,
              blocks: const [
                {
                  '_type': 'figureSpec',
                  'spec': <String, Object?>{'kind': 'test'},
                  'semanticsLabel': 'Earth layers',
                  'credit': 'Published source',
                }
              ],
              figureBuilder: (_, __) => const SizedBox(
                width: 300,
                height: 300,
                child: Text('Diagram'),
              ),
            ),
          ),
        ),
        brightness,
      );
      expect(find.text('Published source'), findsOneWidget);
      await tester.tap(find.byTooltip('Expand figure'));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byKey(const ValueKey('web-figure-card')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('web-figure-card'))).width,
        lessThan(1440),
      );
      final hint =
          find.text('Published source · Scroll or + − to zoom · Esc to close');
      expect(tester.widget<Text>(hint).style!.fontSize, 14);
      final viewer =
          tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1.25);
      await tester.sendKeyEvent(LogicalKeyboardKey.minus);
      expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
      expect(
        tester
            .widget<Material>(find.byKey(const ValueKey('web-figure-scrim')))
            .color,
        const Color.fromRGBO(10, 10, 12, .88),
      );
      await tester.tap(find.byTooltip('Close figure'));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsNothing);
      await pump(
        tester,
        const Center(
          child: SizedBox(
            width: 680,
            child: ContentRenderer(
              readerFigures: true,
              blocks: [
                {'_type': 'image', 'url': 'data:image/png;base64,bad'},
              ],
            ),
          ),
        ),
        brightness,
      );
      await tester.pumpAndSettle();
      expect(find.text('This illustration didn’t load.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide search recent, results and no match $brightness',
        (tester) async {
      await pump(
        tester,
        const WebLessonSearch(),
        brightness,
        overrides: [
          studyMapProvider.overrideWith((_) async => map),
          recentlyOpenedLessonsProvider.overrideWith((_) async => [first]),
          searchResultsProvider.overrideWith(
            (ref) async => ref.watch(searchQueryProvider) == 'none'
                ? []
                : [
                    const LessonSearchHit(
                      lessonId: 'l2',
                      title: 'Plate Tectonics',
                      topicName: 'Earth Science',
                      estimatedMinutes: 12,
                    ),
                    const LessonSearchHit(
                      lessonId: 'l3',
                      title: 'Core',
                      topicName: 'Earth Science',
                      estimatedMinutes: 10,
                    ),
                  ],
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('RECENTLY OPENED'), findsOneWidget);
      final surface = tester.widget<Material>(
        find
            .ancestor(
              of: find.byType(TextField),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(
        (surface.shape! as RoundedRectangleBorder).side.color,
        brightness == Brightness.dark
            ? const Color(0xFF2C2C2C)
            : Colors.transparent,
      );
      await tester.enterText(find.byType(TextField), 'plate');
      await tester.pumpAndSettle();
      expect(find.text('2 LESSONS'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(
        tester
            .widget<Semantics>(
              find.byKey(const ValueKey('web-search-result-l3')),
            )
            .properties
            .selected,
        isTrue,
      );
      expect(find.text('Plate Tectonics'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'none');
      await tester.pumpAndSettle();
      expect(find.text('Nothing matched “none”'), findsOneWidget);
      expect(find.text('Try a shorter word, or part of one.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
