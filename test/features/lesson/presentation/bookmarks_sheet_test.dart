import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_checkbox.dart';
import 'package:cse_cet_reviewer/core/ui/components/pennant_mark.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/lesson/application/bookmark_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/bookmarks_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late LessonBookmarksRepository repo;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    repo = LessonBookmarksRepository(db);

    await seedContentExam(contentDb,
        examId: 'e1',
        code: 'CSE',
        name: 'Civil Service Exam',
        shortName: 'CSE',);
    await seedContentSubject(contentDb,
        subjectId: 's1', examId: 'e1', name: 'Science',);
    await seedContentTopic(contentDb,
        topicId: 't1', subjectId: 's1', name: 'Chemistry',);

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

    expect(find.byType(PennantMark), findsNWidgets(7));
  });

  testWidgets('the four orders are all visible', (tester) async {
    await pumpSheet(tester, rows: 2);

    for (final label in ['Recent', 'By subject', 'Oldest', 'Custom']) {
      expect(find.text(label), findsOneWidget);
    }
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
