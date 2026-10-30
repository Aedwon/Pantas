import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
        'Plan reader uses stored lesson and closes with Enter dark=$dark',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
        name: 'Biology',
      );
      await seedContentLesson(
        content,
        lessonId: 'l',
        topicId: 't',
        title: 'DNA and genes',
        bodyJson: '[]',
      );
      await AppPreferencesRepository(db).setSelectedExamId('e');
      var closed = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(content),
          ],
          child: MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: Scaffold(
              body: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 620,
                  child: LessonPage(
                    lessonId: 'l',
                    origin: ReaderOrigin.home,
                    dayContext: LessonDayContext(
                      date: DateTime(2026, 10, 20),
                      lessonIds: const ['l'],
                      index: 0,
                    ),
                    planLabel: 'Tuesday · Science',
                    onPlanClose: () => closed++,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('DNA and genes'), findsOneWidget);
      expect(find.text('Tuesday · Science'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(
        find.text("That's the lesson. It counts toward Tuesday."),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(closed, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(closed, 2);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
