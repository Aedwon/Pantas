import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/lesson_contents_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/pull_to_advance.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_rail.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

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
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l1',
      topicId: 't1',
      title: 'Vocabulary Basics',
      summary: 'Core vocab',
      bodyJson: jsonEncode(<Map<String, Object?>>[
        {
          '_type': 'block',
          'style': 'normal',
          'children': <Map<String, Object?>>[
            {
              '_type': 'span',
              'text': 'Synonyms share meaning.',
              'marks': <String>[],
            },
          ],
        },
      ]),
    );
  });

  tearDown(() => db.close());

  testWidgets('audit guarded open refreshes cached Study consumers',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);
    final last = container.listen(lastOpenedLessonProvider, (_, __) {});
    final recent = container.listen(recentlyOpenedLessonsProvider, (_, __) {});
    addTearDown(last.close);
    addTearDown(recent.close);
    await container.read(lastOpenedLessonProvider.future);
    await container.read(recentlyOpenedLessonsProvider.future);
    await tester.pumpApp(
      UncontrolledProviderScope(
        container: container,
        child: const LessonPage(lessonId: 'l1'),
      ),
    );
    await tester.pumpAndSettle();
    expect((await container.read(lastOpenedLessonProvider.future))?.id, 'l1');
    expect(
      (await container.read(recentlyOpenedLessonsProvider.future))
          .map((l) => l.id),
      ['l1'],
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets(
      'audit bookmark failure is handled and retries desired membership',
      (tester) async {
    final bookmarks = _FailOnceBookmarks(db);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        lessonBookmarksRepositoryProvider.overrideWithValue(bookmarks),
      ],
    );
    await tester.pumpAndSettle();
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onBookmark();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(await bookmarks.isMarked('l1'), isFalse);
    await bookmarks.mark('l1');
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(await bookmarks.isMarked('l1'), isTrue);
    expect(find.text('Could not save your progress.'), findsNothing);
  });
  testWidgets('audit open failure is handled and Retry saves original lesson',
      (tester) async {
    final prefs = _FailOnceOpenPrefs(db);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        appPreferencesRepositoryProvider.overrideWithValue(prefs),
      ],
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Could not save your progress.'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(await prefs.lastOpenedLessonId('e1'), 'l1');
    expect(find.text('Could not save your progress.'), findsNothing);
  });
  testWidgets('audit Contents suppresses dwell until fully dismissed',
      (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onContents();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 16));
    await tester.pumpAndSettle();
    final progress = LessonProgressRepository(db, contentDb);
    expect(await progress.isRead('l1'), isFalse);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(await progress.isRead('l1'), isFalse);
    await tester.pumpAndSettle();
    expect(await progress.isRead('l1'), isTrue);
  });
  testWidgets(
      'audit lifecycle suppresses dwell and resumes without resetting floor',
      (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 16));
    await tester.pumpAndSettle();
    final progress = LessonProgressRepository(db, contentDb);
    expect(await progress.isRead('l1'), isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(await progress.isRead('l1'), isTrue);
  });
  testWidgets('audit covering route suppresses dwell until route returns',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/lesson',
      routes: [
        GoRoute(
          path: '/lesson',
          builder: (_, __) => const LessonPage(lessonId: 'l1'),
        ),
        GoRoute(
          path: '/cover',
          builder: (_, __) => const Scaffold(body: Text('Cover')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();
    unawaited(router.push<void>('/cover'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 16));
    await tester.pumpAndSettle();
    final progress = LessonProgressRepository(db, contentDb);
    expect(await progress.isRead('l1'), isFalse);
    router.pop();
    await tester.pumpAndSettle();
    expect(await progress.isRead('l1'), isTrue);
  });

  testWidgets('audit retained Retry cannot retry a later lesson error',
      (tester) async {
    await seedContentLesson(
      contentDb,
      lessonId: 'l2',
      topicId: 't1',
      title: 'Second lesson',
      bodyJson: '[]',
    );
    final bookmarks = _FailOnceBookmarks(db);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        lessonBookmarksRepositoryProvider.overrideWithValue(bookmarks),
      ],
    );
    await tester.pumpAndSettle();
    final container =
        ProviderScope.containerOf(tester.element(find.byType(LessonPage)));
    await container.read(lastOpenedLessonProvider.future);
    await container.read(recentlyOpenedLessonsProvider.future);
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onBookmark();
    await tester.pumpAndSettle();
    final staleRetry = tester
        .widget<PantasButton>(find.widgetWithText(PantasButton, 'Try Again'))
        .onPressed!;
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onContents();
    await tester.pumpAndSettle();
    tester
        .widget<LessonContentsSheet>(find.byType(LessonContentsSheet))
        .onSelectLesson('l2');
    await tester.pumpAndSettle();
    expect((await container.read(lastOpenedLessonProvider.future))?.id, 'l2');
    expect(
      (await container.read(recentlyOpenedLessonsProvider.future))
          .map((l) => l.id),
      ['l2', 'l1'],
    );
    bookmarks.fail = true;
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onBookmark();
    await tester.pumpAndSettle();
    staleRetry();
    await tester.pumpAndSettle();
    expect(await bookmarks.isMarked('l2'), isFalse);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(await bookmarks.isMarked('l2'), isTrue);
    expect(await bookmarks.isMarked('l1'), isFalse);
  });

  testWidgets('audit held bookmark cannot revive after A to B to A activation',
      (tester) async {
    await seedContentLesson(
      contentDb,
      lessonId: 'l2',
      topicId: 't1',
      title: 'Second lesson',
      bodyJson: '[]',
    );
    final positions =
        _HeldActionPositions(AppPreferencesRepository(db), database: db);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        readerPositionRepositoryProvider.overrideWithValue(positions),
      ],
    );
    await tester.pumpAndSettle();
    positions.hold = true;
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onBookmark();
    await tester.pumpAndSettle();
    for (final id in ['l2', 'l1']) {
      tester.widget<ReaderBar>(find.byType(ReaderBar)).onContents();
      await tester.pumpAndSettle();
      tester
          .widget<LessonContentsSheet>(find.byType(LessonContentsSheet))
          .onSelectLesson(id);
      await tester.pumpAndSettle();
      expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, id);
    }
    positions.release.complete();
    await tester.pumpAndSettle();
    expect(await LessonBookmarksRepository(db).isMarked('l1'), isFalse);
  });

  testWidgets('audit read persistence failure Retry keeps original dwell floor',
      (tester) async {
    final progress = _FailOnceReadProgress(db, contentDb);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        lessonProgressRepositoryProvider.overrideWithValue(progress),
      ],
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(await progress.isRead('l1'), isFalse);
    expect(find.text('Could not save your progress.'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(await progress.isRead('l1'), isTrue);
    expect(find.text('Could not save your progress.'), findsNothing);
  });
  testWidgets('audit overlapping save errors keep each pending original action',
      (tester) async {
    final prefs = _FailOnceOpenPrefs(db, failures: 2);
    final progress = _FailOnceReadProgress(db, contentDb);
    final bookmarks = _FailOnceBookmarks(db);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        appPreferencesRepositoryProvider.overrideWithValue(prefs),
        lessonProgressRepositoryProvider.overrideWithValue(progress),
        lessonBookmarksRepositoryProvider.overrideWithValue(bookmarks),
      ],
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onBookmark();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(await prefs.lastOpenedLessonId('e1'), isNull);
    expect(await progress.isRead('l1'), isFalse);
    expect(await bookmarks.isMarked('l1'), isFalse);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(await prefs.lastOpenedLessonId('e1'), isNull);
    expect(await progress.isRead('l1'), isTrue);
    expect(await bookmarks.isMarked('l1'), isTrue);
    expect(find.text('Could not save your progress.'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(await prefs.lastOpenedLessonId('e1'), 'l1');
    expect(find.text('Could not save your progress.'), findsNothing);
  });

  Future<void> seedLongReaderLessons() async {
    final body = jsonEncode([
      for (var i = 0; i < 50; i++)
        {
          '_type': 'block',
          'style': 'normal',
          'children': [
            {
              '_type': 'span',
              'text': 'Paragraph $i with enough lesson content to scroll.',
              'marks': <String>[],
            },
          ],
        },
    ]);
    await (contentDb.update(contentDb.contentLessons)
          ..where((r) => r.id.equals('l1')))
        .write(ContentLessonsCompanion(bodyJson: Value(body)));
    await seedContentLesson(
      contentDb,
      lessonId: 'l2',
      topicId: 't1',
      title: 'Second lesson',
      bodyJson: body,
    );
  }

  testWidgets(
      'audit retained position Retry cannot save the next lesson offset',
      (tester) async {
    await seedLongReaderLessons();
    final prefs = AppPreferencesRepository(db);
    final positions = _FailReaderPositions(prefs, database: db);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        readerPositionRepositoryProvider.overrideWithValue(positions),
      ],
    );
    await tester.pumpAndSettle();
    final scroll = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView).first)
        .controller!;
    positions.failWrite = true;
    scroll.jumpTo(240);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    final staleRetry = tester
        .widget<PantasButton>(find.widgetWithText(PantasButton, 'Try Again'))
        .onPressed!;
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onContents();
    await tester.pumpAndSettle();
    tester
        .widget<LessonContentsSheet>(find.byType(LessonContentsSheet))
        .onSelectLesson('l2');
    await tester.pumpAndSettle();
    expect(await positions.read('e1', 'l1'), 240);
    scroll.jumpTo(360);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    staleRetry();
    await tester.pumpAndSettle();
    expect(await positions.read('e1', 'l1'), 240);
    expect(await positions.read('e1', 'l2'), 360);
  });
  testWidgets('audit retained resume Retry cannot jump the next lesson',
      (tester) async {
    await seedLongReaderLessons();
    final positions =
        _FailReaderPositions(AppPreferencesRepository(db), database: db)
          ..failRead = true;
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1', resume: true),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        readerPositionRepositoryProvider.overrideWithValue(positions),
      ],
    );
    await tester.pumpAndSettle();
    final staleRetry = tester
        .widget<PantasButton>(find.widgetWithText(PantasButton, 'Try Again'))
        .onPressed!;
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onContents();
    await tester.pumpAndSettle();
    tester
        .widget<LessonContentsSheet>(find.byType(LessonContentsSheet))
        .onSelectLesson('l2');
    await tester.pumpAndSettle();
    final scroll = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView).first)
        .controller!
      ..jumpTo(360);
    staleRetry();
    await tester.pumpAndSettle();
    expect(scroll.offset, 360);
  });

  testWidgets(
      'audit obsolete position Retry cannot overwrite a later measured save',
      (tester) async {
    await seedLongReaderLessons();
    final positions =
        _FailReaderPositions(AppPreferencesRepository(db), database: db);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        readerPositionRepositoryProvider.overrideWithValue(positions),
      ],
    );
    await tester.pumpAndSettle();
    final scroll = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView).first)
        .controller!;
    positions.failWrite = true;
    scroll.jumpTo(240);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    final staleRetry = tester
        .widget<PantasButton>(find.widgetWithText(PantasButton, 'Try Again'))
        .onPressed!;
    scroll.jumpTo(360);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(await positions.read('e1', 'l1'), 360);
    staleRetry();
    await tester.pumpAndSettle();
    expect(await positions.read('e1', 'l1'), 360);
  });

  for (final failNewer in [false, true]) {
    testWidgets(
        'queued position Retry preserves newer intent failure=$failNewer',
        (tester) async {
      await seedLongReaderLessons();
      final prefs = _HeldPositionPrefs(db);
      final positions = _FailReaderPositions(prefs, database: db);
      await tester.pumpAppWithProviders(
        const LessonPage(lessonId: 'l1'),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          readerPositionRepositoryProvider.overrideWithValue(positions),
        ],
      );
      await tester.pumpAndSettle();
      final scroll = tester
          .widget<SingleChildScrollView>(
            find.byType(SingleChildScrollView).first,
          )
          .controller!;
      positions.failWrite = true;
      scroll.jumpTo(240);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      final oldRetry = tester
          .widget<PantasButton>(
            find.widgetWithText(PantasButton, 'Try Again'),
          )
          .onPressed!;
      prefs
        ..holdNext = true
        ..failHeld = failNewer;
      scroll.jumpTo(360);
      final expectedFraction = 360 / scroll.position.maxScrollExtent;
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      expect(prefs.started.isCompleted, isTrue);
      oldRetry();
      await tester.pump();
      prefs.release.complete();
      await tester.pumpAndSettle();
      expect(scroll.offset, 360);
      expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l1');
      if (failNewer) {
        expect(await positions.read('e1', 'l1'), 0);
        expect(find.text('Could not save your progress.'), findsOneWidget);
        oldRetry();
        await tester.pumpAndSettle();
        expect(await positions.read('e1', 'l1'), 0);
        tester
            .widget<PantasButton>(
              find.widgetWithText(PantasButton, 'Try Again'),
            )
            .onPressed!();
        await tester.pumpAndSettle();
      }
      expect(await positions.read('e1', 'l1'), 360);
      expect(
        await positions.readFraction('e1', 'l1'),
        closeTo(expectedFraction, .000001),
      );
      expect(prefs.offsets, isNot(contains(240)));
      expect(find.text('Could not save your progress.'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('current position Retry saves its retained offset and fraction',
      (tester) async {
    await seedLongReaderLessons();
    final positions =
        _FailReaderPositions(AppPreferencesRepository(db), database: db);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        readerPositionRepositoryProvider.overrideWithValue(positions),
      ],
    );
    await tester.pumpAndSettle();
    final scroll = tester
        .widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView).first,
        )
        .controller!;
    positions.failWrite = true;
    scroll.jumpTo(240);
    final expectedFraction = 240 / scroll.position.maxScrollExtent;
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    tester
        .widget<PantasButton>(find.widgetWithText(PantasButton, 'Try Again'))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(await positions.read('e1', 'l1'), 240);
    expect(
      await positions.readFraction('e1', 'l1'),
      closeTo(expectedFraction, .000001),
    );
    expect(find.text('Could not save your progress.'), findsNothing);
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l1');
  });

  testWidgets('queued position Retry completion retains newer failure',
      (tester) async {
    await seedLongReaderLessons();
    final prefs = _HeldPositionPrefs(db);
    final positions = _HeldPositionCompletion(prefs, database: db);
    final bookmarks = _HeldBookmarks(db);
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        readerPositionRepositoryProvider.overrideWithValue(positions),
        lessonBookmarksRepositoryProvider.overrideWithValue(bookmarks),
      ],
    );
    await tester.pumpAndSettle();
    final scroll = tester
        .widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView).first,
        )
        .controller!;
    positions.failWrite = true;
    scroll.jumpTo(240);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    final oldRetry = tester
        .widget<PantasButton>(
          find.widgetWithText(PantasButton, 'Try Again'),
        )
        .onPressed!;
    tester.widget<ReaderBar>(find.byType(ReaderBar)).onBookmark();
    await tester.pumpAndSettle();
    expect(bookmarks.started.isCompleted, isTrue);
    positions.holdCompletion = true;
    oldRetry();
    await tester.pump();
    prefs.failOffset = 360;
    scroll.jumpTo(360);
    final expectedFraction = 360 / scroll.position.maxScrollExtent;
    await tester.pump(const Duration(milliseconds: 350));
    bookmarks.release.complete();
    await tester.pumpAndSettle();
    expect(positions.ready.isCompleted, isTrue);
    expect(find.text('Could not save your progress.'), findsOneWidget);
    positions.deliver.complete();
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l1');
    expect(await positions.read('e1', 'l1'), 0);
    tester
        .widget<PantasButton>(find.widgetWithText(PantasButton, 'Try Again'))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(await positions.read('e1', 'l1'), 360);
    expect(
      await positions.readFraction('e1', 'l1'),
      closeTo(expectedFraction, .000001),
    );
    expect(prefs.offsets, isNot(contains(240)));
    expect(find.text('Could not save your progress.'), findsNothing);
  });

  testWidgets('shows lesson title and body content', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Vocabulary Basics'), findsOneWidget);
    expect(find.text('Synonyms share meaning.'), findsOneWidget);
  });

  testWidgets('Resume restores a clamped saved offset and leaving saves it',
      (tester) async {
    await (contentDb.update(contentDb.contentLessons)
          ..where((r) => r.id.equals('l1')))
        .write(
      ContentLessonsCompanion(
        bodyJson: Value(
          jsonEncode([
            for (var i = 0; i < 30; i++)
              {
                '_type': 'block',
                'style': 'normal',
                'children': [
                  {
                    '_type': 'span',
                    'text': 'Paragraph $i with enough content to scroll.',
                    'marks': <String>[],
                  }
                ],
              },
          ]),
        ),
      ),
    );
    final prefs = AppPreferencesRepository(db);
    await prefs.setDeviceValue('lesson_offset.e1.l1', '240');
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1', resume: true),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();
    final scroll = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView).first)
        .controller!;
    expect(scroll.offset, 240);
    scroll.jumpTo(360);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    final positions = ReaderPositionRepository(prefs);
    expect(await positions.read('e1', 'l1'), 360);
    expect(await positions.readFraction('e1', 'l1'), inExclusiveRange(0, 1));
  });

  testWidgets('omits superseded material duration', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('min read'), findsNothing);
  });

  testWidgets('lesson page renders Quiz yourself card after lesson body',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/lesson/l1?from=study',
      routes: [
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (_, state) => LessonPage(
            lessonId: state.pathParameters['lessonId']!,
          ),
        ),
        GoRoute(
          path: '/quiz/inline/:examId/:lessonId',
          builder: (_, state) => Text(
            'Inline ${state.pathParameters['examId']} '
            '${state.pathParameters['lessonId']}',
          ),
        ),
      ],
    );

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Quiz yourself'), findsOneWidget);
    await tester.tap(find.textContaining('Quiz yourself'));
    await tester.pumpAndSettle();
    expect(find.text('Inline e1 l1'), findsOneWidget);
  });

  testWidgets('advancing never falls back to the loading skeleton',
      (tester) async {
    // Aedwon: "when pulling up, the entire app still has a moment of loading
    // sort of". The skeleton replaces the whole body, chrome included, so a
    // swap flashed the bar and the rail out and back.
    await seedContentLesson(
      contentDb,
      lessonId: 'l2',
      topicId: 't1',
      title: 'Antonyms',
      summary: 'Opposites',
      bodyJson: jsonEncode([
        {
          '_type': 'block',
          'style': 'normal',
          'children': [
            {
              '_type': 'span',
              'text': 'Antonyms are opposites.',
              'marks': <String>[],
            },
          ],
        },
      ]),
      estimatedMinutes: 4,
      ordering: 2,
    );

    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Vocabulary Basics'), findsOneWidget);

    final bar = tester.element(find.byType(ReaderBar));
    final rail = tester.element(find.byType(ReaderRail));
    // Watch the active loader and lesson continuity during every frame.
    final body = tester.getRect(find.byType(PullToAdvance));
    final gesture = await tester.startGesture(body.center);
    await gesture.moveBy(const Offset(0, -140));
    await tester.pump();
    await gesture.up();

    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      expect(
        find.byType(LoadingShapes),
        findsNothing,
        reason: 'the reader must never blank out while advancing',
      );
      expect(tester.element(find.byType(ReaderBar)), same(bar));
      expect(tester.element(find.byType(ReaderRail)), same(rail));
      expect(
        find.text('Vocabulary Basics').evaluate().isNotEmpty ||
            find.text('Antonyms').evaluate().isNotEmpty,
        isTrue,
        reason: 'an actual lesson body remains visible through the handoff',
      );
    }
    await tester.pumpAndSettle();

    // Without this the loop above proves nothing: it would pass just as well
    // if the pull never committed.
    expect(find.text('Antonyms'), findsOneWidget);
  });
}

class _FailOnceOpenPrefs extends AppPreferencesRepository {
  _FailOnceOpenPrefs(super.db, {this.failures = 1});
  int failures;
  @override
  Future<void> pushOpenedLesson({
    required String examId,
    required String lessonId,
  }) async {
    if (failures > 0) {
      failures--;
      throw Exception('open failed');
    }
    return super.pushOpenedLesson(examId: examId, lessonId: lessonId);
  }
}

class _FailOnceBookmarks extends LessonBookmarksRepository {
  _FailOnceBookmarks(super.db);
  bool fail = true;
  @override
  Future<void> mark(String lessonId) async {
    await super.mark(lessonId);
    if (fail) {
      fail = false;
      throw Exception('bookmark failed');
    }
  }
}

class _HeldActionPositions extends ReaderPositionRepository {
  _HeldActionPositions(super.preferences, {required super.database});
  bool hold = false;
  final release = Completer<void>();
  @override
  Future<bool> runGuarded(
    ReaderBoundary boundary,
    Future<void> Function() operation, {
    required bool Function() isCurrent,
  }) async {
    if (hold) {
      hold = false;
      await release.future;
    }
    return super.runGuarded(boundary, operation, isCurrent: isCurrent);
  }
}

class _FailOnceReadProgress extends LessonProgressRepository {
  _FailOnceReadProgress(super.db, super.contentDb);
  bool fail = true;
  @override
  Future<void> markRead(String id) async {
    await super.markRead(id);
    if (fail) {
      fail = false;
      throw Exception('read failed');
    }
  }
}

class _FailReaderPositions extends ReaderPositionRepository {
  _FailReaderPositions(super.preferences, {required super.database});
  bool failWrite = false;
  bool failRead = false;
  @override
  Future<double> read(String examId, String lessonId) async {
    if (failRead) {
      failRead = false;
      throw Exception('resume failed');
    }
    return super.read(examId, lessonId);
  }

  @override
  Future<bool> writeGuarded(
    ReaderBoundary boundary,
    String lessonId,
    double offset, {
    required double fraction,
    required bool Function() isCurrent,
  }) async {
    if (failWrite) {
      failWrite = false;
      throw Exception('position failed');
    }
    return super.writeGuarded(
      boundary,
      lessonId,
      offset,
      fraction: fraction,
      isCurrent: isCurrent,
    );
  }
}

class _HeldPositionPrefs extends AppPreferencesRepository {
  _HeldPositionPrefs(super.db);
  bool holdNext = false;
  bool failHeld = false;
  double? failOffset;
  final started = Completer<void>();
  final release = Completer<void>();
  final offsets = <double>[];
  @override
  Future<void> setDeviceValue(String key, String value) async {
    var held = false;
    double? offset;
    if (key == 'lesson_offset.e1.l1') {
      if (holdNext) {
        holdNext = false;
        held = true;
        started.complete();
        await release.future;
      }
      final position = jsonDecode(value) as Map<String, Object?>;
      offset = (position['offset']! as num).toDouble();
      offsets.add(offset);
    }
    await super.setDeviceValue(key, value);
    if ((held && failHeld) || (offset != null && offset == failOffset)) {
      failOffset = null;
      throw Exception('newer position failed');
    }
  }
}

class _HeldBookmarks extends LessonBookmarksRepository {
  _HeldBookmarks(super.db);
  final started = Completer<void>();
  final release = Completer<void>();
  @override
  Future<void> mark(String lessonId) async {
    started.complete();
    await release.future;
    await super.mark(lessonId);
  }
}

class _HeldPositionCompletion extends _FailReaderPositions {
  _HeldPositionCompletion(super.preferences, {required super.database});
  bool holdCompletion = false;
  final ready = Completer<bool>();
  final deliver = Completer<void>();
  @override
  Future<bool> writeGuarded(
    ReaderBoundary boundary,
    String lessonId,
    double offset, {
    required double fraction,
    required bool Function() isCurrent,
  }) async {
    final held = holdCompletion;
    holdCompletion = false;
    final saved = await super.writeGuarded(
      boundary,
      lessonId,
      offset,
      fraction: fraction,
      isCurrent: isCurrent,
    );
    if (held) {
      ready.complete(saved);
      await deliver.future;
    }
    return saved;
  }
}
