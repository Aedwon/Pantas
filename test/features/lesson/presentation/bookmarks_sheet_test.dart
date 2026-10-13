import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_sheet.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  late AppDatabase db;
  late ContentDatabase contentDb;
  late LessonBookmarksRepository repo;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    repo = LessonBookmarksRepository(db);

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
      name: 'Science',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Chemistry',
    );

    for (var i = 1; i <= 10; i++) {
      await seedContentLesson(
        contentDb,
        lessonId: 'l$i',
        topicId: 't1',
        title: 'Lesson $i',
        bodyJson: jsonEncode(<Map<String, Object?>>[]),
        estimatedMinutes: 10,
      );
    }
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    required int rows,
    BookmarkOrder order = BookmarkOrder.recent,
    TextScaler textScaler = TextScaler.noScaling,
    bool dark = false,
    bool reduceMotion = false,
    bool preloadReader = false,
    Stream<AuthState>? authStates,
    BookmarkPrefsRepository? prefs,
  }) async {
    for (var i = 1; i <= rows; i++) {
      await repo.mark('l$i');
    }

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        if (prefs != null)
          bookmarkPrefsRepositoryProvider.overrideWithValue(prefs),
        if (authStates != null)
          authStateProvider.overrideWith((_) => authStates),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('e1');
    await container.read(bookmarkOrderProvider.notifier).choose(order);
    if (preloadReader) await container.read(readerContextProvider('l1').future);

    var sheetOpen = false;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          key: UniqueKey(),
          theme: dark ? buildDarkTheme() : buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: textScaler,
              disableAnimations: reduceMotion,
            ),
            child: child!,
          ),
          home: StatefulBuilder(
            builder: (context, setState) => PantasSheet(
              bookmarks: true,
              scrollable: false,
              open: sheetOpen,
              label: 'Bookmarks',
              onDismiss: () => setState(() => sheetOpen = false),
              page: Scaffold(
                body: ElevatedButton(
                  onPressed: () => setState(() => sheetOpen = true),
                  child: const Text('Open'),
                ),
              ),
              child: BookmarksSheet(
                onClose: () => setState(() => sheetOpen = false),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('bookmark board states dark=$dark scale=$scale',
          (tester) async {
        tester.view
          ..physicalSize = const Size(390, 844)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await pumpSheet(
          tester,
          rows: 3,
          dark: dark,
          reduceMotion: true,
          textScaler: TextScaler.linear(scale),
        );
        expect(
          tester
              .getSize(find.byKey(const ValueKey('pantas-sheet-surface')))
              .height,
          closeTo(844 * .74, .01),
        );
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (scale == 1) {
          expect(tester.getSize(find.byKey(const ValueKey('l3'))).height, 62);
        }
        final grip = tester.widget<IconTheme>(
          find.byKey(const ValueKey('bookmark-grip')).first,
        );
        final colors = tester.element(find.byType(BookmarksSheet)).colors;
        expect(grip.data.color, colors.controlOutline);
        await tester.tap(find.text('Select All'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();
        expect(find.text('No bookmarks yet'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        expect(await repo.markedIds(), hasLength(3));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('bookmark selection follows the approved 200 ms spring',
      (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lesson 3'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final transform = tester
        .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')));
    expect(
      transform.transform.storage[0],
      closeTo(.5 + .5 * PantasCurves.popB.transform(.5), .001),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('By subject draws the actual subject heading', (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('By subject'));
    await tester.pumpAndSettle();
    expect(find.text('SCIENCE'), findsOneWidget);
  });

  testWidgets('a changed order crossfades the rows over 200 ms',
      (tester) async {
    await pumpSheet(tester, rows: 3);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(BookmarksSheet)));
    final changed = Completer<void>();
    final subscription = container.listen(bookmarkOrderProvider, (_, next) {
      if (next.valueOrNull == BookmarkOrder.oldest && !changed.isCompleted) {
        changed.complete();
      }
    });
    try {
      await tester.tap(find.text('Oldest'));
      await tester.runAsync(() => changed.future);
      await tester.runAsync(() => container.read(bookmarkRowsProvider.future));
      await tester.pump();
      final incoming = find.byKey(const ValueKey('bookmark-order-fade-oldest'));
      expect(incoming, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.widget<FadeTransition>(incoming).opacity.value,
        closeTo(.5, .01),
      );
      await tester.pumpAndSettle();
    } finally {
      subscription.close();
    }
  });

  testWidgets('Remove and Undo refresh the reader bookmark state',
      (tester) async {
    await pumpSheet(tester, rows: 3, preloadReader: true);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(BookmarksSheet)));
    Future<ReaderContext?> read() async {
      final result = container.read(readerContextProvider('l1').future);
      await tester.pumpAndSettle();
      return result;
    }

    expect((await read())!.isBookmarked, isTrue);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lesson 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect((await read())!.isBookmarked, isFalse);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await read())!.isBookmarked, isTrue);
  });

  Future<void> removeAll(WidgetTester tester) async {
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
  }

  testWidgets('mounted sheet expires Undo after an exam change',
      (tester) async {
    await seedContentExam(
      contentDb,
      examId: 'other',
      code: 'LET',
      name: 'Licensure Examination for Teachers',
      shortName: 'LET',
    );
    await pumpSheet(tester, rows: 2);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(BookmarksSheet)));
    await removeAll(tester);
    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('other');
    container.invalidate(activeExamFocusProvider);
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsNothing);
    expect(await repo.markedIds(), isEmpty);
  });

  testWidgets('mounted sheet expires Undo after the real reset path',
      (tester) async {
    await pumpSheet(tester, rows: 2);
    await removeAll(tester);
    await SyncLocalStateWiper(db).wipeAll();
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsNothing);
    expect(await repo.markedIds(), isEmpty);
  });

  testWidgets(
      'mounted sheet expires Undo when the existing auth identity changes',
      (tester) async {
    final auth = StreamController<AuthState>.broadcast();
    addTearDown(auth.close);
    Stream<AuthState> states() async* {
      yield const AuthState.anonymous(uid: 'before');
      yield* auth.stream;
    }

    await pumpSheet(tester, rows: 2, authStates: states());
    await removeAll(tester);
    auth.add(const AuthState.anonymous(uid: 'after'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsNothing);
    expect(await repo.markedIds(), isEmpty);
  });

  testWidgets('reset expires Undo and removes its failed-save Retry',
      (tester) async {
    final failing = _FailingUndoPrefs(db);
    await pumpSheet(tester, rows: 2, prefs: failing);
    await removeAll(tester);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsOneWidget);
    await SyncLocalStateWiper(db).wipeAll();
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsNothing);
    expect(find.text('Try Again'), findsNothing);
    expect(await repo.markedIds(), isEmpty);
  });

  testWidgets('a late old Undo error does not recreate Retry after reset',
      (tester) async {
    final failing = _FailingUndoPrefs(db, delayed: true);
    await pumpSheet(tester, rows: 2, prefs: failing);
    await removeAll(tester);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    await SyncLocalStateWiper(db).wipeAll();
    await tester.pumpAndSettle();
    failing.completion.completeError(Exception('old operation failed'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsNothing);
    expect(find.text('Try Again'), findsNothing);
    expect(await repo.markedIds(), isEmpty);
  });

  testWidgets('Edit shows grips in Recent and one bookmark hides ordering',
      (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bookmark-grip')), findsNWidgets(3));
  });
  testWidgets('one bookmark hides the order switch', (tester) async {
    await pumpSheet(tester, rows: 1);
    expect(find.text('Recent'), findsNothing);
    expect(find.byKey(const ValueKey('bookmark-grip')), findsNothing);
  });
  testWidgets('Undo restores the original dates and exact positions',
      (tester) async {
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);
    await repo.reorder(['l2', 'l3', 'l1']);
    final before = await repo.customOrder();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    final after = await repo.customOrder();
    expect(
      after.map((r) => [r.lessonId, r.markedAt, r.sortIndex]).toList(),
      before.map((r) => [r.lessonId, r.markedAt, r.sortIndex]).toList(),
    );
  });
  testWidgets('the sheet lists every bookmark, not three', (tester) async {
    await pumpSheet(tester, rows: 7);

    await tester.scrollUntilVisible(
      find.text('Lesson 1'),
      120,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Lesson 1'), findsOneWidget);
  });

  testWidgets('the four orders are all visible', (tester) async {
    await pumpSheet(tester, rows: 2);

    for (final label in ['Recent', 'By subject', 'Oldest', 'Custom']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('the bookmark sheet fits at 320dp and 200% text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSheet(
      tester,
      rows: 2,
      textScaler: const TextScaler.linear(2),
    );

    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the active order is the heavy one', (tester) async {
    await pumpSheet(tester, rows: 2, order: BookmarkOrder.oldest);

    expect(
      tester.widget<Text>(find.text('Oldest')).style?.fontWeight,
      FontWeight.w600,
    );
    expect(
      tester.widget<Text>(find.text('Recent')).style?.fontWeight,
      FontWeight.w600,
    );
  });

  testWidgets('choosing an order writes it', (tester) async {
    await pumpSheet(tester, rows: 2);

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    final prefsRepo = BookmarkPrefsRepository(db);
    expect(await prefsRepo.readOrder(examId: 'e1'), BookmarkOrder.custom);
  });

  testWidgets('the header offers Edit, never Save', (tester) async {
    await pumpSheet(tester, rows: 2);

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('sheet actions are labeled and at least 48dp', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, rows: 2);

    void expectTarget(String label) {
      final target = find.semantics.byLabel(label);
      expect(target, findsOne);
      expect(
        target.evaluate().single.rect.size.width,
        greaterThanOrEqualTo(44),
      );
      expect(
        target.evaluate().single.rect.size.height,
        greaterThanOrEqualTo(44),
      );
    }

    expectTarget('Edit bookmarks');

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expectTarget('Reset bookmark order');

    semantics.dispose();
  });

  testWidgets('edit actions are labeled and at least 48dp', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, rows: 2);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    for (final label in [
      'Done editing bookmarks',
      'Select all bookmarks',
      'Remove selected bookmarks',
    ]) {
      final target = find.semantics.byLabel(label);
      expect(target, findsOne);
      expect(
        target.evaluate().single.rect.size.width,
        greaterThanOrEqualTo(44),
      );
      expect(
        target.evaluate().single.rect.size.height,
        greaterThanOrEqualTo(44),
      );
    }

    semantics.dispose();
  });

  testWidgets('bookmark rows are labeled buttons at least 48dp high',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, rows: 2);

    final target = find.semantics.byLabel('Open bookmark: Lesson 2');
    expect(target, findsOne);
    final data = target.evaluate().single.getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    expect(target.evaluate().single.rect.size.height, greaterThanOrEqualTo(44));

    semantics.dispose();
  });

  testWidgets('grips appear only in Edit', (tester) async {
    await pumpSheet(tester, rows: 3);
    expect(find.byKey(const ValueKey('bookmark-grip')), findsNothing);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bookmark-grip')), findsNWidgets(3));
  });

  testWidgets('dragging a row down persists the adjusted order',
      (tester) async {
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('bookmark-grip')).first,
      const Offset(0, 120),
    );
    await tester.pumpAndSettle();

    final rows = await BookmarkPrefsRepository(db).readCustomOrder('e1');
    expect(rows, ['l2', 'l1', 'l3']);
  });

  testWidgets('the move down semantic action writes a new custom order',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final node = tester.getSemantics(find.byKey(const ValueKey('l3')));
    final actions = node.getSemanticsData().customSemanticsActionIds!;
    final moveDownId = actions.firstWhere(
      (id) => CustomSemanticsAction.getAction(id)?.label == 'Move down',
    );

    node.owner!.performAction(
      node.id,
      SemanticsAction.customAction,
      moveDownId,
    );
    await tester.pumpAndSettle();

    final rows = await BookmarkPrefsRepository(db).readCustomOrder('e1');
    expect(rows, ['l2', 'l3', 'l1']);
    semantics.dispose();
  });

  for (final direction in ['up', 'down']) {
    testWidgets('semantic move $direction announces its destination',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        tester.takeAnnouncements();
        final id = direction == 'up' ? 'l1' : 'l3';
        final node = tester.getSemantics(find.byKey(ValueKey(id)));
        final actions = node.getSemanticsData().customSemanticsActionIds!;
        final move = actions.firstWhere(
          (id) =>
              CustomSemanticsAction.getAction(id)?.label == 'Move $direction',
        );
        node.owner!.performAction(node.id, SemanticsAction.customAction, move);
        await tester.pumpAndSettle();
        final preposition = direction == 'up' ? 'above' : 'below';
        expect(
          tester.takeAnnouncements().map((message) => message.message).toList(),
          ['Moved $preposition Lesson 2.'],
        );
        expect(
          await BookmarkPrefsRepository(db).readCustomOrder('e1'),
          direction == 'up' ? ['l3', 'l1', 'l2'] : ['l2', 'l3', 'l1'],
        );
      } finally {
        semantics.dispose();
      }
    });
  }

  testWidgets('switching away from custom asks nothing', (tester) async {
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);

    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('reset order is offered only in custom', (tester) async {
    await pumpSheet(tester, rows: 3);
    expect(find.text('Reset order'), findsNothing);

    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Reset order'), findsOneWidget);
  });

  testWidgets('Edit swaps to Done and reveals checkboxes', (tester) async {
    await pumpSheet(tester, rows: 3);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(find.byType(CheckMark), findsNWidgets(3));
  });

  testWidgets('a row in edit mode selects rather than opening', (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lesson 1'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
  });

  testWidgets('select all selects every row', (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select All'));
    await tester.pumpAndSettle();

    expect(find.text('3 selected'), findsOneWidget);
  });

  testWidgets('removing offers an undo naming the count', (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select All'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('3 bookmarks removed'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('undo puts them back', (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select All'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final marked = await repo.markedIds();
    expect(marked, hasLength(3));
  });

  testWidgets('removing one says bookmark, not bookmarks', (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lesson 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('1 bookmark removed'), findsOneWidget);
  });
}

class _FailingUndoPrefs extends BookmarkPrefsRepository {
  _FailingUndoPrefs(super.db, {this.delayed = false});
  final bool delayed;
  final completion = Completer<bool>();
  @override
  Future<bool> restore(BookmarkRemoval removal) async {
    if (delayed) return completion.future;
    throw Exception('restore failed');
  }
}
