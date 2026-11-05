import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_sheet.dart';

import '../../../helpers/in_memory_database.dart';

// B-21 and B-22 of the Nov 4 browser check: the wide bookmarks panel's hover
// tint reaches the row's edge, and a click on the grip does not open the row.

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });

  Future<void> pumpSheet(WidgetTester tester) async {
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
    for (var i = 0; i < 3; i++) {
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
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 480,
                child: BookmarksSheet(wide: true, onClose: () {}),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<TestGesture> mouseOver(WidgetTester tester, Offset at) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(at);
    await tester.pump();
    return gesture;
  }

  testWidgets('hover on a row in Edit mode tints the whole row',
      (tester) async {
    await pumpSheet(tester);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lesson 0'));
    await tester.pumpAndSettle();
    final row = find.byType(CheckboxRow).first;
    final grip = find.byKey(const ValueKey('bookmark-grip')).first;
    await mouseOver(tester, tester.getCenter(grip));
    final tint = find
        .ancestor(of: row, matching: find.byType(ColoredBox))
        .evaluate()
        .map((e) => e.widget as ColoredBox)
        .where((box) => box.color == tester.element(row).webTokens.rowHover);
    expect(tint, hasLength(1));
    // The tint starts at the row's left edge and runs past the grip, to the
    // right edge, instead of stopping where the row's button ends.
    final tinted = tester.getRect(
      find.ancestor(of: row, matching: find.byWidget(tint.single)),
    );
    expect(tinted.right, greaterThanOrEqualTo(tester.getRect(grip).right));
    expect(tinted.left, lessThan(tester.getRect(row).left + 1));
  });

  testWidgets('a click on the grip focuses the row and opens nothing',
      (tester) async {
    await pumpSheet(tester);
    // Alt and Down moves a row, which makes the order custom and shows grips.
    final firstRow = find.byType(WebRow).first;
    Focus.of(
      tester.element(
        find.descendant(of: firstRow, matching: find.byType(Text)).first,
      ),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    final grip = find.byKey(const ValueKey('bookmark-grip')).first;
    expect(grip, findsOneWidget);
    // Opening a lesson needs the router, which this page does not have. A
    // click that reached the row would throw.
    await tester.tap(grip);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'bookmark grip');
    // The focused grip carries the row's Alt and arrow keys.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
