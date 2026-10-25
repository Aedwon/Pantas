import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/lesson_contents_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/pull_to_advance.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _HeldBoundaryChecks extends ReaderPositionRepository {
  _HeldBoundaryChecks(AppDatabase db)
      : super(AppPreferencesRepository(db), database: db);
  int hold = 0;
  final checks = <Completer<void>>[];
  @override
  Future<bool> isBoundaryCurrent(
    ReaderBoundary boundary, {
    required bool Function() isCurrent,
  }) async {
    if (hold > 0) {
      hold--;
      final gate = Completer<void>();
      checks.add(gate);
      await gate.future;
    }
    return super.isBoundaryCurrent(boundary, isCurrent: isCurrent);
  }
}

class _HeldResume extends ReaderPositionRepository {
  _HeldResume(AppDatabase db)
      : super(AppPreferencesRepository(db), database: db);
  final position = Completer<double>();
  @override
  Future<double> read(String examId, String lessonId) => position.future;
}

class _HeldBookmark extends LessonBookmarksRepository {
  _HeldBookmark(super.db);
  bool hold = false;
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<bool> isMarked(String lessonId) async {
    if (hold) {
      hold = false;
      entered.complete();
      await release.future;
    }
    return super.isMarked(lessonId);
  }
}

class _FailingBoundary extends ReaderPositionRepository {
  _FailingBoundary(AppDatabase db)
      : super(AppPreferencesRepository(db), database: db);
  bool failNext = false;
  bool hold = false;
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<bool> isBoundaryCurrent(
    ReaderBoundary boundary, {
    required bool Function() isCurrent,
  }) async {
    if (failNext) {
      failNext = false;
      entered.complete();
      if (hold) await release.future;
      throw StateError('boundary read fixture');
    }
    return super.isBoundaryCurrent(boundary, isCurrent: isCurrent);
  }
}

void main() {
  late AppDatabase db;
  late ContentDatabase content;
  setUp(() async {
    db = inMemoryDatabase();
    content = openTestContentDatabase();
    await seedContentExam(
      content,
      examId: 'e',
      code: 'CSE',
      name: 'CSE',
      shortName: 'CSE',
    );
    await seedContentSubject(
      content,
      subjectId: 's',
      examId: 'e',
      name: 'Math',
    );
    await seedContentTopic(
      content,
      topicId: 't',
      subjectId: 's',
      name: 'Geometry',
    );
    await seedContentLesson(
      content,
      lessonId: 'l',
      topicId: 't',
      title: 'Circles',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
    );
  });
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester, {
    Key? key,
    bool resume = false,
    List<Override> overrides = const [],
  }) async {
    await tester.pumpAppWithProviders(
      LessonPage(key: key, lessonId: 'l', resume: resume),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        ...overrides,
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'fresh page establishes guest once and wipe retry never recreates it',
      (tester) async {
    final contexts = SyncActiveContextStore(db);
    expect(await contexts.readSnapshot(), isNull);
    await pump(tester);
    expect(find.text('Circles'), findsOneWidget);
    final original = (await contexts.readSnapshot())!.token;
    final container =
        ProviderScope.containerOf(tester.element(find.byType(LessonPage)));
    final reader = await container.read(readerContextProvider('l').future);
    expect(reader!.boundary!.token, original);
    await SyncLocalStateWiper(db).wipeAll();
    container.invalidate(readerContextProvider('l'));
    await tester.pumpAndSettle();
    expect(find.text('Circles'), findsNothing);
    expect(await contexts.readSnapshot(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(await contexts.readSnapshot(), isNull);
    await pump(tester, key: const ValueKey('fresh'));
    expect(find.text('Circles'), findsOneWidget);
    expect((await contexts.readSnapshot())!.token, isNot(original));
  });

  testWidgets('new page rejects a cached context with old provenance',
      (tester) async {
    await pump(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(LessonPage)));
    final cached = await container.read(readerContextProvider('l').future);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await SyncActiveContextStore(db).clearStable();
    final next = (await SyncActiveContextStore(db).readSnapshot())!.token;
    await pump(
      tester,
      overrides: [readerContextProvider('l').overrideWith((_) => cached)],
    );
    expect(find.text('Circles'), findsNothing);
    expect((await SyncActiveContextStore(db).readSnapshot())!.token, next);
    expect(find.text('Could not load this lesson.'), findsOneWidget);
  });

  testWidgets(
      'real wipe cancels reader initial actor await before token exists',
      (tester) async {
    final actor = Completer<AuthState>();
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        authStateProvider.overrideWith((_) => Stream.fromFuture(actor.future)),
      ],
    );
    await SyncLocalStateWiper(db).wipeAll();
    await tester.pumpAndSettle();
    actor.complete(const AuthState.signedOut());
    await tester.pumpAndSettle();
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    expect(find.text('Circles'), findsNothing);
    expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unmount during initial actor await cannot recapture or write',
      (tester) async {
    final actor = Completer<AuthState>();
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        authStateProvider.overrideWith((_) => Stream.fromFuture(actor.future)),
      ],
    );
    final original = (await SyncActiveContextStore(db).readSnapshot())!.token;
    await tester.pumpWidget(const SizedBox());
    actor.complete(const AuthState.signedOut());
    await tester.pumpAndSettle();
    expect((await SyncActiveContextStore(db).readSnapshot())!.token, original);
    expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), isNull);
  });
  testWidgets('actor loading gap during initial await expires original page',
      (tester) async {
    var subscription = 0;
    final secondActor = Completer<AuthState>();
    final focus = Completer<ActiveExamFocus>();
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        activeExamFocusProvider.overrideWith((_) => focus.future),
        authStateProvider.overrideWith(
          (_) => ++subscription == 1
              ? Stream.value(const AuthState.anonymous(uid: 'a'))
              : Stream.fromFuture(secondActor.future),
        ),
      ],
    );
    await tester.pumpAndSettle();
    final original = (await SyncActiveContextStore(db).readSnapshot())!.token;
    ProviderScope.containerOf(tester.element(find.byType(LessonPage)))
        .invalidate(authStateProvider);
    await tester.pump();
    secondActor.complete(const AuthState.anonymous(uid: 'b'));
    await tester.pump();
    await tester.pump();
    focus.complete(
      const ActiveExamFocus.selected(
        Exam(
          id: 'e',
          code: 'CSE',
          name: 'CSE',
          shortName: 'CSE',
          language: 'en',
          isActive: true,
          subjects: [],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect((await SyncActiveContextStore(db).readSnapshot())!.token, original);
    expect(find.text('Circles'), findsNothing);
  });

  testWidgets('newest Contents choice wins across delayed activation checks',
      (tester) async {
    for (final id in ['l2', 'l3']) {
      await seedContentLesson(
        content,
        lessonId: id,
        topicId: 't',
        title: id,
        bodyJson: '[]',
      );
    }
    final positions = _HeldBoundaryChecks(db);
    await pump(
      tester,
      overrides: [
        readerPositionRepositoryProvider.overrideWithValue(positions),
      ],
    );
    final container =
        ProviderScope.containerOf(tester.element(find.byType(LessonPage)));
    await container.read(readerContextProvider('l2').future);
    await container.read(readerContextProvider('l3').future);
    await tester.tap(find.byType(ContentsGlyph));
    await tester.pumpAndSettle();
    final contents =
        tester.widget<LessonContentsSheet>(find.byType(LessonContentsSheet));
    positions.hold = 2;
    contents.onSelectLesson('l2');
    await tester.pump();
    expect(positions.checks, hasLength(1));
    contents.onSelectLesson('l3');
    await tester.pump();
    expect(positions.checks, hasLength(2));
    positions.checks[1].complete();
    await tester.pumpAndSettle();
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l3');
    positions.checks[0].complete();
    await tester.pumpAndSettle();
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l3');
  });
  testWidgets('late resume position cannot jump a different active lesson',
      (tester) async {
    await seedContentLesson(
      content,
      lessonId: 'l2',
      topicId: 't',
      title: 'Long lesson',
      bodyJson: jsonEncode([
        for (var i = 0; i < 50; i++)
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {
                '_type': 'span',
                'text': 'Paragraph $i in the real next lesson.',
                'marks': <String>[],
              }
            ],
          },
      ]),
    );
    final positions = _HeldResume(db);
    await pump(
      tester,
      resume: true,
      overrides: [
        readerPositionRepositoryProvider.overrideWithValue(positions),
      ],
    );
    await tester.tap(find.byType(ContentsGlyph));
    await tester.pumpAndSettle();
    tester
        .widget<LessonContentsSheet>(find.byType(LessonContentsSheet))
        .onSelectLesson('l2');
    await tester.pumpAndSettle();
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l2');
    positions.position.complete(240);
    await tester.pumpAndSettle();
    final scroll = tester
        .widget<SingleChildScrollView>(
          find
              .descendant(
                of: find.byType(PullToAdvance),
                matching: find.byType(SingleChildScrollView),
              )
              .first,
        )
        .controller!;
    expect(scroll.offset, 0);
  });

  for (final initial in [true, false]) {
    testWidgets(
        'actor error gap expires '
        '${initial ? 'pending capture' : 'surviving reader'}', (tester) async {
      final actors = StreamController<AuthState>();
      addTearDown(actors.close);
      actors.add(const AuthState.anonymous(uid: 'a'));
      final focus = Completer<ActiveExamFocus>();
      await pump(
        tester,
        overrides: [
          authStateProvider.overrideWith((_) => actors.stream),
          if (initial)
            activeExamFocusProvider.overrideWith((_) => focus.future),
        ],
      );
      final original = (await SyncActiveContextStore(db).readSnapshot())!.token;
      if (!initial) expect(find.text('Circles'), findsOneWidget);
      actors.addError(StateError('actor fixture'));
      await tester.pumpAndSettle();
      actors.add(const AuthState.anonymous(uid: 'b'));
      await tester.pump();
      await tester.pump();
      if (initial) {
        focus.complete(
          const ActiveExamFocus.selected(
            Exam(
              id: 'e',
              code: 'CSE',
              name: 'CSE',
              shortName: 'CSE',
              language: 'en',
              isActive: true,
              subjects: [],
            ),
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(find.text('Circles'), findsNothing);
      expect(find.text('Could not load this lesson.'), findsOneWidget);
      if (initial) {
        expect(
          (await SyncActiveContextStore(db).readSnapshot())!.token,
          original,
        );
        expect(
          await AppPreferencesRepository(db).lastOpenedLessonId('e'),
          isNull,
        );
      }
    });
  }

  testWidgets('plate departure preserves the real outgoing offset and fraction',
      (tester) async {
    await (content.update(content.contentLessons)
          ..where((r) => r.id.equals('l')))
        .write(
      ContentLessonsCompanion(
        bodyJson: Value(
          jsonEncode([
            for (var i = 0; i < 50; i++)
              {
                '_type': 'block',
                'style': 'normal',
                'children': [
                  {
                    '_type': 'span',
                    'text': 'Paragraph $i in this long real lesson.',
                    'marks': <String>[],
                  }
                ],
              },
          ]),
        ),
      ),
    );
    await seedContentTopic(
      content,
      topicId: 't2',
      subjectId: 's',
      name: 'Statistics',
    );
    await seedContentLesson(
      content,
      lessonId: 'l2',
      topicId: 't2',
      title: 'Mean',
      bodyJson: '[]',
    );
    await pump(tester);
    final scroll = tester
        .widget<SingleChildScrollView>(
          find
              .descendant(
                of: find.byType(PullToAdvance),
                matching: find.byType(SingleChildScrollView),
              )
              .first,
        )
        .controller!;
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    final offset = scroll.offset;
    final container =
        ProviderScope.containerOf(tester.element(find.byType(LessonPage)));
    final positions = container.read(readerPositionRepositoryProvider);
    await tester.tap(find.byKey(const ValueKey('pull-handle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ending-plate')), findsOneWidget);
    expect(await positions.read('e', 'l'), offset);
    expect(await positions.readFraction('e', 'l'), 1);
    await tester.tap(find.byKey(const ValueKey('pull-handle')));
    await tester.pumpAndSettle();
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l2');
    expect(await positions.read('e', 'l'), offset);
    expect(await positions.readFraction('e', 'l'), 1);
  });

  testWidgets('a stale warmed next context cannot preview or activate',
      (tester) async {
    await seedContentLesson(
      content,
      lessonId: 'l2',
      topicId: 't',
      title: 'Next real lesson',
      bodyJson: '[]',
    );
    await pump(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(LessonPage)));
    final cached = await container.read(readerContextProvider('l2').future);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await SyncActiveContextStore(db).clearStable();
    final token = (await SyncActiveContextStore(db).readSnapshot())!.token;
    await pump(
      tester,
      overrides: [readerContextProvider('l2').overrideWith((_) => cached)],
    );
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l');
    expect(find.byKey(const ValueKey('pull-handle')), findsNothing);
    expect(find.text('Could not load this lesson.'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect((await SyncActiveContextStore(db).readSnapshot())!.token, token);
    expect(
      await AppPreferencesRepository(db).deviceValue('lesson_offset.e.l2'),
      isNull,
    );
    expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), 'l');
  });

  testWidgets(
      'real wipe cancels an already committed preview without next writes',
      (tester) async {
    await seedContentLesson(
      content,
      lessonId: 'l2',
      topicId: 't',
      title: 'Next real lesson',
      bodyJson: '[]',
    );
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('pull-handle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));
    expect(find.byKey(const ValueKey('pull-incoming')), findsOneWidget);
    expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), 'l');
    expect(
      await AppPreferencesRepository(db).deviceValue('lesson_offset.e.l2'),
      isNull,
    );
    expect(await LessonProgressRepository(db, content).isRead('l2'), isFalse);
    await SyncLocalStateWiper(db).wipeAll();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pull-incoming')), findsNothing);
    expect(find.text('Could not load this lesson.'), findsOneWidget);
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    expect(
      await AppPreferencesRepository(db).deviceValue('lesson_offset.e.l2'),
      isNull,
    );
    expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), 'l');
    expect(await LessonProgressRepository(db, content).isRead('l2'), isFalse);
  });

  testWidgets('advance collapses strip and rail480ms while title fades150ms',
      (tester) async {
    await (content.update(content.contentLessons)
          ..where((r) => r.id.equals('l')))
        .write(
      ContentLessonsCompanion(
        bodyJson: Value(
          jsonEncode([
            for (var i = 0; i < 50; i++)
              {
                '_type': 'block',
                'style': 'normal',
                'children': [
                  {
                    '_type': 'span',
                    'text': 'Paragraph $i in this long real lesson.',
                    'marks': <String>[],
                  }
                ],
              },
          ]),
        ),
      ),
    );
    await seedContentLesson(
      content,
      lessonId: 'l2',
      topicId: 't',
      title: 'Next',
      bodyJson: '[]',
    );
    await pump(tester);
    final scroll = tester
        .widget<SingleChildScrollView>(
          find
              .descendant(
                of: find.byType(PullToAdvance),
                matching: find.byType(SingleChildScrollView),
              )
              .first,
        )
        .controller!;
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    final strip = find.byKey(const ValueKey('reader-title-strip'));
    final initialHeight = tester.getSize(strip).height;
    final outgoingOffset = scroll.offset;
    final back = tester.getRect(find.text('Study'));
    await tester.tap(find.byKey(const ValueKey('pull-handle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 75));
    expect(scroll.offset, outgoingOffset);
    final fraction = PantasCurves.slideA.transform(75 / 480);
    expect(
      tester.getSize(strip).height,
      closeTo(initialHeight * (1 - fraction), .01),
    );
    expect(
      tester
          .widget<Opacity>(
            find.descendant(of: strip, matching: find.byType(Opacity)),
          )
          .opacity,
      closeTo(.5, .001),
    );
    final rail = tester.widget<FractionallySizedBox>(
      find.ancestor(
        of: find.byKey(const ValueKey('reader-progress-fill')),
        matching: find.byType(FractionallySizedBox),
      ),
    );
    expect(rail.widthFactor, closeTo(1 - fraction, .001));
    expect(tester.getRect(find.text('Study')), back);
    await tester.pump(const Duration(milliseconds: 75));
    expect(
      tester
          .widget<Opacity>(
            find.descendant(of: strip, matching: find.byType(Opacity)),
          )
          .opacity,
      0,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 500));
    expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), 'l');
    expect(
      await AppPreferencesRepository(db).deviceValue('lesson_offset.e.l2'),
      isNull,
    );
  });
  testWidgets('held reader bookmark cannot cross an actor change',
      (tester) async {
    final actors = StreamController<AuthState>();
    addTearDown(actors.close);
    actors.add(const AuthState.anonymous(uid: 'a'));
    final bookmarks = _HeldBookmark(db);
    await pump(
      tester,
      overrides: [
        authStateProvider.overrideWith((_) => actors.stream),
        lessonBookmarksRepositoryProvider.overrideWithValue(bookmarks),
      ],
    );
    bookmarks.hold = true;
    await tester.tap(find.byKey(const ValueKey('reader-bookmark-control')));
    await bookmarks.entered.future;
    actors.add(const AuthState.anonymous(uid: 'b'));
    await tester.pumpAndSettle();
    bookmarks.release.complete();
    await tester.pumpAndSettle();
    expect(await LessonBookmarksRepository(db).isMarked('l'), isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('same boundary bookmark toggles real membership and ReaderBar',
      (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('reader-bookmark-control')));
    await tester.pumpAndSettle();
    expect(await LessonBookmarksRepository(db).isMarked('l'), isTrue);
    expect(
      tester.widget<ReaderBar>(find.byType(ReaderBar)).isBookmarked,
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('reader-bookmark-control')));
    await tester.pumpAndSettle();
    expect(await LessonBookmarksRepository(db).isMarked('l'), isFalse);
    expect(
      tester.widget<ReaderBar>(find.byType(ReaderBar)).isBookmarked,
      isFalse,
    );
  });

  testWidgets('unavailable real next content retries under the original token',
      (tester) async {
    await seedContentLesson(
      content,
      lessonId: 'l2',
      topicId: 't',
      title: 'Next real lesson',
      bodyJson: '[]',
    );
    await pump(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(LessonPage)));
    final next = await container.read(readerContextProvider('l2').future);
    final token = next!.boundary!.token;
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    var attempts = 0;
    await pump(
      tester,
      overrides: [
        readerContextProvider('l2').overrideWith((_) async {
          if (++attempts == 1) throw StateError('next fixture');
          return next;
        }),
      ],
    );
    expect(find.byKey(const ValueKey('pull-handle')), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pull-handle')), findsOneWidget);
    expect(attempts, 2);
    expect((await SyncActiveContextStore(db).readSnapshot())!.token, token);
    expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), 'l');
    expect(
      await AppPreferencesRepository(db).deviceValue('lesson_offset.e.l2'),
      isNull,
    );
  });
  for (final change in ['wipe', 'account', 'exam', 'cancel']) {
    testWidgets('held reader bookmark rejects $change boundary',
        (tester) async {
      final actors = StreamController<AuthState>();
      addTearDown(actors.close);
      actors.add(const AuthState.anonymous(uid: 'a'));
      const exam = Exam(
        id: 'e',
        code: 'CSE',
        name: 'CSE',
        shortName: 'CSE',
        language: 'en',
        isActive: true,
        subjects: [],
      );
      const other = Exam(
        id: 'other',
        code: 'OTHER',
        name: 'Other',
        shortName: 'Other',
        language: 'en',
        isActive: true,
        subjects: [],
      );
      final focus = StateProvider<ActiveExamFocus>(
        (_) => const ActiveExamFocus.selected(exam),
      );
      if (change == 'account') {
        await SyncActiveContextStore(db)
            .publishStable(uid: 'a', generationId: 'g1');
      }
      final bookmarks = _HeldBookmark(db);
      await pump(
        tester,
        overrides: [
          authStateProvider.overrideWith((_) => actors.stream),
          activeExamFocusProvider.overrideWith((ref) async => ref.watch(focus)),
          lessonBookmarksRepositoryProvider.overrideWithValue(bookmarks),
        ],
      );
      final container =
          ProviderScope.containerOf(tester.element(find.byType(LessonPage)));
      bookmarks.hold = true;
      await tester.tap(find.byKey(const ValueKey('reader-bookmark-control')));
      await bookmarks.entered.future;
      Future<void>? mutation;
      switch (change) {
        case 'wipe':
          mutation = SyncLocalStateWiper(db).wipeAll();
        case 'account':
          actors.add(const AuthState.anonymous(uid: 'b'));
          mutation = SyncActiveContextStore(db)
              .publishStable(uid: 'b', generationId: 'g2');
        case 'exam':
          container.read(focus.notifier).state =
              const ActiveExamFocus.selected(other);
          mutation = AppPreferencesRepository(db).setSelectedExamId('other');
        case 'cancel':
          await tester.pumpWidget(const SizedBox());
      }
      await tester.pump();
      await tester.pump();
      bookmarks.release.complete();
      await mutation;
      await tester.pumpAndSettle();
      expect(await LessonBookmarksRepository(db).isMarked('l'), isFalse);
      expect(await db.select(db.accountPrefs).get(), isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
  for (final entry in ['pull', 'plate', 'contents']) {
    testWidgets('failed boundary lookup during $entry expires the owner safely',
        (tester) async {
      if (entry != 'plate') {
        await seedContentLesson(
          content,
          lessonId: 'l2',
          topicId: 't',
          title: 'Next',
          bodyJson: '[]',
        );
      }
      final positions = _FailingBoundary(db);
      await pump(
        tester,
        overrides: [
          readerPositionRepositoryProvider.overrideWithValue(positions),
        ],
      );
      if (entry == 'contents') {
        await tester.tap(find.byType(ContentsGlyph));
        await tester.pumpAndSettle();
      }
      positions.failNext = true;
      if (entry == 'contents') {
        tester
            .widget<LessonContentsSheet>(find.byType(LessonContentsSheet))
            .onSelectLesson('l2');
      } else {
        await tester.tap(find.byKey(const ValueKey('pull-handle')));
      }
      await tester.pumpAndSettle();
      expect(find.text('Could not load this lesson.'), findsOneWidget);
      expect(find.byKey(const ValueKey('pull-incoming')), findsNothing);
      expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), 'l');
      expect(
        await AppPreferencesRepository(db).deviceValue('lesson_offset.e.l2'),
        isNull,
      );
      expect(await LessonProgressRepository(db, content).isRead('l2'), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('failed held metadata lookup after unmount has no stale callback',
      (tester) async {
    final positions = _FailingBoundary(db);
    await pump(
      tester,
      overrides: [
        readerPositionRepositoryProvider.overrideWithValue(positions),
      ],
    );
    positions
      ..failNext = true
      ..hold = true;
    await SyncLocalStateWiper(db).wipeAll();
    await tester.pump();
    await positions.entered.future;
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    await tester.pumpWidget(const SizedBox());
    positions.release.complete();
    await tester.pumpAndSettle();
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    expect(tester.takeException(), isNull);
  });
  for (final missing in [false, true]) {
    testWidgets(
        'selected non-warmed ${missing ? 'missing' : 'failed'} lesson '
        'retries its own load', (tester) async {
      for (final id in ['l2', 'l3']) {
        await seedContentLesson(
          content,
          lessonId: id,
          topicId: 't',
          title: id,
          bodyJson: '[]',
        );
      }
      final clean = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
        ],
      );
      addTearDown(clean.dispose);
      ReaderContext? ready;
      var attempts = 0;
      await pump(
        tester,
        overrides: [
          readerContextProvider('l3').overrideWith((_) async {
            if (++attempts == 1) {
              if (missing) return null;
              throw StateError('private selected-load fixture');
            }
            return ready;
          }),
        ],
      );
      ready = await clean.read(readerContextProvider('l3').future);
      final token = ready!.boundary!.token;
      final positions = clean.read(readerPositionRepositoryProvider);
      await tester.pump(const Duration(milliseconds: 350));
      final offset = await positions.read('e', 'l');
      final fraction = await positions.readFraction('e', 'l');
      expect(attempts, 0);
      await tester.tap(find.byType(ContentsGlyph));
      await tester.pumpAndSettle();
      tester
          .widget<LessonContentsSheet>(find.byType(LessonContentsSheet))
          .onSelectLesson('l3');
      await tester.pumpAndSettle();
      expect(
        find.text(
          missing ? 'Lesson not found.' : 'Could not load this lesson.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('private'), findsNothing);
      expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), 'l');
      expect(
        await AppPreferencesRepository(db).deviceValue('lesson_offset.e.l3'),
        isNull,
      );
      expect(await positions.read('e', 'l'), offset);
      expect(await positions.readFraction('e', 'l'), fraction);
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l3');
      expect(attempts, 2);
      expect((await SyncActiveContextStore(db).readSnapshot())!.token, token);
      expect(await positions.read('e', 'l'), offset);
      expect(await positions.readFraction('e', 'l'), fraction);
    });
  }

  testWidgets('an older selected-load error cannot replace the newer lesson',
      (tester) async {
    for (final id in ['l2', 'l3', 'l4']) {
      await seedContentLesson(
        content,
        lessonId: id,
        topicId: 't',
        title: id,
        bodyJson: '[]',
      );
    }
    final old = Completer<ReaderContext?>();
    await pump(
      tester,
      overrides: [
        readerContextProvider('l3').overrideWith((_) => old.future),
      ],
    );
    final container =
        ProviderScope.containerOf(tester.element(find.byType(LessonPage)));
    await container.read(readerContextProvider('l4').future);
    await tester.tap(find.byType(ContentsGlyph));
    await tester.pumpAndSettle();
    final contents =
        tester.widget<LessonContentsSheet>(find.byType(LessonContentsSheet));
    contents.onSelectLesson('l3');
    await tester.pump();
    contents.onSelectLesson('l4');
    await tester.pumpAndSettle();
    old.completeError(StateError('older selection fixture'));
    await tester.pumpAndSettle();
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l4');
    expect(find.text('Could not load this lesson.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an external reader change cancels the earlier selected load',
      (tester) async {
    for (final id in ['l2', 'l3', 'l4']) {
      await seedContentLesson(
        content,
        lessonId: id,
        topicId: 't',
        title: id,
        bodyJson: '[]',
      );
    }
    final old = Completer<ReaderContext?>();
    final overrides = [
      appDatabaseProvider.overrideWithValue(db),
      contentDatabaseProvider.overrideWithValue(content),
      readerContextProvider('l3').overrideWith((_) => old.future),
    ];
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l'),
      overrides: overrides,
    );
    await tester.pumpAndSettle();
    final clean = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
      ],
    );
    addTearDown(clean.dispose);
    final target = await clean.read(readerContextProvider('l3').future);
    await tester.tap(find.byType(ContentsGlyph));
    await tester.pumpAndSettle();
    tester
        .widget<LessonContentsSheet>(find.byType(LessonContentsSheet))
        .onSelectLesson('l3');
    await tester.pump();
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l4'),
      overrides: overrides,
    );
    await tester.pumpAndSettle();
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l4');
    old.complete(target);
    await tester.pumpAndSettle();
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l4');
  });
  testWidgets('opening Contents cancels a committed preview without holding it',
      (tester) async {
    await seedContentLesson(
      content,
      lessonId: 'l2',
      topicId: 't',
      title: 'Next',
      bodyJson: '[]',
    );
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('pull-handle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    expect(find.byKey(const ValueKey('pull-incoming')), findsOneWidget);
    await tester.tap(find.byType(ContentsGlyph));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pull-incoming')), findsNothing);
    expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l');
    expect(await AppPreferencesRepository(db).lastOpenedLessonId('e'), 'l');
  });

  testWidgets('a selected-load failure under a replaced token offers only Back',
      (tester) async {
    for (final id in ['l2', 'l3']) {
      await seedContentLesson(
        content,
        lessonId: id,
        topicId: 't',
        title: id,
        bodyJson: '[]',
      );
    }
    final target = Completer<ReaderContext?>();
    await pump(
      tester,
      overrides: [
        readerContextProvider('l3').overrideWith((_) => target.future),
      ],
    );
    await tester.tap(find.byType(ContentsGlyph));
    await tester.pumpAndSettle();
    tester
        .widget<LessonContentsSheet>(find.byType(LessonContentsSheet))
        .onSelectLesson('l3');
    await tester.pump();
    await SyncActiveContextStore(db).clearStable();
    final replacement =
        (await SyncActiveContextStore(db).readSnapshot())!.token;
    target.completeError(StateError('late selected-load fixture'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load this lesson.'), findsOneWidget);
    expect(find.text('Try Again'), findsNothing);
    expect(find.text('Study'), findsOneWidget);
    expect(
      (await SyncActiveContextStore(db).readSnapshot())!.token,
      replacement,
    );
  });
}
