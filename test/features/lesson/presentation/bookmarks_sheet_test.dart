import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/ink_checkbox.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_sheet.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
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
  }) async {
    for (var i = 1; i <= rows; i++) {
      await repo.mark('l$i');
    }

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('e1');
    await container.read(bookmarkOrderProvider.notifier).choose(order);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          key: UniqueKey(),
          theme: buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showBookmarksSheet(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

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
      FontWeight.w700,
    );
    expect(
      tester.widget<Text>(find.text('Recent')).style?.fontWeight,
      isNot(FontWeight.w700),
    );
  });

  testWidgets('choosing an order writes it', (tester) async {
    await pumpSheet(tester, rows: 2);

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    final prefsRepo = BookmarkPrefsRepository(db);
    expect(await prefsRepo.readOrder(), BookmarkOrder.custom);
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
        greaterThanOrEqualTo(48),
      );
      expect(
        target.evaluate().single.rect.size.height,
        greaterThanOrEqualTo(48),
      );
    }

    expectTarget('Edit bookmarks');
    for (final label in ['Recent', 'By subject', 'Oldest', 'Custom']) {
      expectTarget('Order bookmarks by $label');
    }

    await tester.tap(find.text('Custom'));
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
        greaterThanOrEqualTo(48),
      );
      expect(
        target.evaluate().single.rect.size.height,
        greaterThanOrEqualTo(48),
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
    expect(target.evaluate().single.rect.size.height, greaterThanOrEqualTo(48));

    semantics.dispose();
  });

  testWidgets('grips appear only in custom order', (tester) async {
    await pumpSheet(tester, rows: 3);
    expect(find.byKey(const ValueKey('bookmark-grip')), findsNothing);

    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);
    expect(find.byKey(const ValueKey('bookmark-grip')), findsNWidgets(3));
  });

  testWidgets('dragging a row writes the new order', (tester) async {
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);

    await tester.drag(
      find.byKey(const ValueKey('bookmark-grip')).first,
      const Offset(0, 120),
    );
    await tester.pumpAndSettle();

    final rows = await repo.customOrder();
    expect(rows, isNotEmpty);
  });

  testWidgets('the move down semantic action writes a new custom order',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);

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

    final rows = await repo.customOrder();
    expect(rows.map((row) => row.lessonId), ['l2', 'l3', 'l1']);
    semantics.dispose();
  });

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
    expect(find.text('Reset order'), findsOneWidget);
  });

  testWidgets('Edit swaps to Done and reveals checkboxes', (tester) async {
    await pumpSheet(tester, rows: 3);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(find.byType(InkCheckbox), findsNWidgets(3));
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

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    expect(find.text('3 selected'), findsOneWidget);
  });

  testWidgets('removing offers an undo naming the count', (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select all'));
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
    await tester.tap(find.text('Select all'));
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
