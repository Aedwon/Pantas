import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_ending_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/in_memory_database.dart';

// B-5 to B-8, B-10, B-11, B-14 and B-27 of the Nov 4 browser check, on the
// wide reader and the wide search.

const _first = StudyLesson(
  id: 'l1',
  title: 'Layers',
  estimatedMinutes: 11,
  isRead: true,
  isBookmarked: false,
);
const _second = StudyLesson(
  id: 'l2',
  title: 'Plate Tectonics',
  estimatedMinutes: 12,
  isRead: false,
  isBookmarked: false,
);
const _longTopic = 'Spatial & Abstract (Non-Verbal) Reasoning';
const _longTitle = 'Sets and Set Notation (Unions, Intersections, Subsets, '
    'Venn Diagrams) and Their Everyday Uses in Exam Questions About Groups';

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.light,
    List<Override> overrides = const [],
  }) async {
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

  group('the contents menu', () {
    Future<void> openMenu(WidgetTester tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final scroll = ScrollController();
      final offset = ValueNotifier<double>(0);
      final progress = ValueNotifier<double>(0);
      addTearDown(scroll.dispose);
      addTearDown(offset.dispose);
      addTearDown(progress.dispose);
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
          ],
        ),
        topicId: 't1',
        topicName: _longTopic,
        next: _second,
        positionInTopic: 1,
        lessonsInTopic: 2,
        topicLessons: [_first, _second],
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
          onBookmark: () {},
          onLesson: (_) {},
          footer: const SizedBox(),
        ),
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 of 2'));
      await tester.pumpAndSettle();
    }

    testWidgets('a long topic name stays on one line beside the count (B-10)',
        (tester) async {
      await openMenu(tester);
      final name = find.text(_longTopic.toUpperCase());
      final count = find.text(' · 2 LESSONS');
      expect(name, findsOneWidget);
      expect(count, findsOneWidget);
      // One line, and the count is on it.
      expect(
        tester.getSize(name).height,
        lessThan(24),
      );
      expect(
        tester.getCenter(count).dy,
        closeTo(tester.getCenter(name).dy, 1),
      );
    });

    testWidgets('it hangs from the page centre line (B-11)', (tester) async {
      await openMenu(tester);
      // RD_FocusOpen: the menu's left edge is on the centre line, 720 at 1440.
      // Its heading sits 8 px of padding and 12 px of indent inside.
      expect(
        tester.getTopLeft(find.text(_longTopic.toUpperCase())).dx,
        closeTo(720 + 8 + 12, 1),
      );
    });
  });

  group('the reader bar', () {
    testWidgets('the error bar sits where the lesson bar sits (B-14)',
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
      await pump(
        tester,
        const LessonPage(lessonId: 'missing'),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          readerContextProvider('missing').overrideWith(
            (_) async => throw Exception('private database path'),
          ),
        ],
      );
      await tester.pumpAndSettle();
      final error = tester.getTopLeft(find.byType(WebReaderBackControl));
      await tester.pumpWidget(const SizedBox());

      final scroll = ScrollController();
      final offset = ValueNotifier<double>(0);
      final progress = ValueNotifier<double>(0);
      addTearDown(scroll.dispose);
      addTearDown(offset.dispose);
      addTearDown(progress.dispose);
      await pump(
        tester,
        WebReaderLayout(
          reader: const ReaderContext(
            lesson: Lesson(
              id: 'l1',
              topicId: 't1',
              title: 'Layers',
              summary: '',
              estimatedMinutes: 11,
              bodyJson: [],
            ),
            topicId: 't1',
            topicName: 'Earth Science',
            next: _second,
            positionInTopic: 1,
            lessonsInTopic: 2,
            topicLessons: [_first, _second],
            isRead: true,
            isBookmarked: false,
            examId: 'e',
          ),
          controller: scroll,
          scrollOffset: offset,
          progress: progress,
          onBack: () {},
          onBookmark: () {},
          onLesson: (_) {},
          footer: const SizedBox(),
        ),
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(WebReaderBackControl)), error);
    });

    testWidgets('the back label holds still while the page leaves (B-8)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    // The page repaints on every frame of its own exit, as
                    // the reader does while it fades out.
                    body: AnimatedBuilder(
                      animation: ModalRoute.of(context)!.animation!,
                      builder: (context, _) =>
                          Text(ReaderOrigin.bookmarks.backLabel(context)),
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Bookmarks'), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      // The first frame of the exit used to read "Study".
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Study'), findsNothing);
      await tester.pumpAndSettle();
    });
  });

  group('the wide search', () {
    final hits = [
      const LessonSearchHit(
        lessonId: 'l9',
        title: _longTitle,
        topicName: 'Mathematics',
        estimatedMinutes: 12,
      ),
    ];

    testWidgets('the scrim darkens a dark page with black (B-7)',
        (tester) async {
      await pump(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showWebLessonSearch(context),
            child: const Text('search'),
          ),
        ),
        brightness: Brightness.dark,
        overrides: [
          studyMapProvider.overrideWith((_) async => null),
          recentlyOpenedLessonsProvider.overrideWith((_) async => []),
        ],
      );
      await tester.tap(find.text('search'));
      await tester.pumpAndSettle();
      final route = ModalRoute.of(
        tester.element(find.byType(WebLessonSearch)),
      )!;
      // The board's gray is lighter than a dark page, so it would lighten it.
      expect(route.barrierColor, Colors.black.withValues(alpha: .28));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });

    testWidgets('nothing opened yet shows no label and no key footer (2G-5)',
        (tester) async {
      await pump(
        tester,
        const WebLessonSearch(),
        overrides: [
          studyMapProvider.overrideWith((_) async => null),
          recentlyOpenedLessonsProvider.overrideWith((_) async => []),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('RECENTLY OPENED'), findsNothing);
      expect(find.text('↑ ↓ to move · Enter to open'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('a long title wraps to two lines with an ellipsis (B-5, B-6)',
        (tester) async {
      await pump(
        tester,
        const WebLessonSearch(),
        overrides: [
          studyMapProvider.overrideWith((_) async => null),
          recentlyOpenedLessonsProvider.overrideWith((_) async => []),
          searchResultsProvider.overrideWith((_) async => hits),
        ],
      );
      await tester.enterText(find.byType(TextField), 'venn');
      await tester.pumpAndSettle();
      final title = tester.renderObject<RenderParagraph>(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText() == _longTitle,
        ),
      );
      // The whole title is the text, not a cut of it; the box ends it.
      expect(title.maxLines, 2);
      expect(title.overflow, TextOverflow.ellipsis);
      expect(title.didExceedMaxLines, isTrue);
    });

    testWidgets('a lesson opened from the dialog names the page behind it',
        (tester) async {
      final seen = <String?>[];
      final router = GoRouter(
        initialLocation: '/study',
        routes: [
          GoRoute(
            path: '/study',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showWebLessonSearch(context),
                  child: const Text('search'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/lesson/:id',
            builder: (context, state) {
              seen.add(state.uri.queryParameters['from']);
              return const Scaffold(body: Text('reader'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyMapProvider.overrideWith((_) async => null),
            recentlyOpenedLessonsProvider.overrideWith((_) async => []),
            searchResultsProvider.overrideWith((_) async => hits),
          ],
          child: MaterialApp.router(
            theme: buildLightTheme(web: true),
            routerConfig: router,
          ),
        ),
      );
      await tester.tap(find.text('search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'venn');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      // Esc from the lesson lands on Study, so the label says Study, not
      // Search, which is a dialog that closed.
      expect(seen, ['study']);
    });
  });

  testWidgets('the day ending shows its button with its line (B-27)',
      (tester) async {
    await pump(
      tester,
      WebEndingLayout(
        ending: const DayFinished(),
        onLesson: (_) {},
        onHome: () {},
      ),
    );
    // How seen a widget is: the product of the fades above it.
    double seen(Finder finder) {
      var opacity = 1.0;
      finder.evaluate().single.visitAncestorElements((ancestor) {
        final widget = ancestor.widget;
        if (widget is Opacity) opacity *= widget.opacity;
        return true;
      });
      return opacity;
    }

    final line = find.text('That’s enough for today.');
    final button = find.text('Back to Home');
    for (var elapsed = 0; elapsed < 900; elapsed += 100) {
      expect(
        seen(button),
        closeTo(seen(line), .001),
        reason: 'the button and the line differ at $elapsed ms',
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(seen(button), closeTo(1, .001));
  });
}
