import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
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
  for (final dark in [false, true]) {
    for (final count in [0, 1, 3]) {
      testWidgets('wide bookmark drawer $count rows dark=$dark',
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
          subjectId: 's',
          examId: 'e',
          name: 'Science',
        );
        await seedContentTopic(
          content,
          topicId: 't',
          subjectId: 's',
          name: 'Earth Science',
        );
        for (var i = 0; i < count; i++) {
          await seedContentLesson(
            content,
            lessonId: 'l$i',
            topicId: 't',
            title: 'Lesson $i',
            bodyJson: '[]',
            estimatedMinutes: 10,
          );
          await LessonBookmarksRepository(db).mark('l$i');
        }
        await AppPreferencesRepository(db).setSelectedExamId('e');
        await SyncActiveContextStore(db).clearStable();
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(content),
          ],
        );
        addTearDown(container.dispose);
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme:
                  dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
              home: Scaffold(
                body: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 480,
                    child: BookmarksSheet(
                      wide: true,
                      onClose: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Bookmarks'), findsOneWidget);
        expect(find.byTooltip('Close bookmarks'), findsOneWidget);
        if (count == 0) {
          expect(find.text('No bookmarks yet'), findsOneWidget);
          expect(
            find.text('Bookmark a lesson to keep it here.'),
            findsOneWidget,
          );
          expect(find.byType(WebSegmentedControl), findsNothing);
        } else {
          expect(find.text('Edit'), findsOneWidget);
          expect(
            find.byType(WebSegmentedControl),
            count == 1 ? findsNothing : findsOneWidget,
          );
          if (count > 1) {
            expect(find.byType(ReorderableListView), findsNothing);
            expect(find.byKey(const ValueKey('bookmark-grip')), findsNothing);
            await tester.tap(find.text('By subject'));
            await tester.pumpAndSettle();
            expect(find.text('SCIENCE'), findsOneWidget);
            expect(find.byType(ReorderableListView), findsNothing);
            await tester.tap(find.text('Recent'));
            await tester.pumpAndSettle();
            final firstRow = find.byType(WebRow).first;
            Focus.of(
              tester.element(
                find
                    .descendant(of: firstRow, matching: find.byType(Text))
                    .first,
              ),
            ).requestFocus();
            await tester.pump();
            await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
            await tester.pumpAndSettle();
            expect(
              container.read(bookmarkOrderProvider).requireValue,
              BookmarkOrder.custom,
            );
            expect(find.text('Reset order'), findsOneWidget);
          }
          await tester.tap(find.text('Edit'));
          await tester.pumpAndSettle();
          expect(find.text('Select All'), findsOneWidget);
          await tester.tap(find.text('Select All'));
          await tester.pumpAndSettle();
          expect(find.text('$count selected'), findsOneWidget);
          await tester.tap(find.text('Remove'));
          await tester.pumpAndSettle();
          expect(find.text('No bookmarks yet'), findsOneWidget);
          expect(find.text('Undo'), findsOneWidget);
          await tester.tap(find.text('Undo'));
          await tester.pumpAndSettle();
          expect(
            container.read(bookmarkRowsProvider).requireValue.length,
            count,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
