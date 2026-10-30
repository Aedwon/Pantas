import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/data/repos/practice_preferences_repository.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_screen.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  PracticeIndex inventory({bool runsShort = false}) => PracticeIndex([
        PracticeSubjectEntry(
          id: 's',
          name: 'Mathematics',
          topics: [
            for (var i = 0; i < 30; i++)
              PracticeTopicEntry(
                id: 't$i',
                name: 'Topic $i',
                questionCount: runsShort && i == 1 ? 6 : 100,
                lessons: [
                  PracticeLessonEntry(
                    id: 'l$i',
                    title: 'Lesson $i',
                    isRead: i == 0,
                    questionCount: runsShort && i == 1 ? 6 : 100,
                  ),
                ],
              ),
            const PracticeTopicEntry(
              id: 'empty',
              name: 'Empty topic',
              questionCount: 0,
              lessons: [],
            ),
          ],
        ),
      ]);
  for (final dark in [false, true]) {
    for (final state in [
      'None',
      'One',
      'Many',
      'ManyTime',
      'Short',
      'RunsShort',
      'Long',
    ]) {
      testWidgets('CZ_$state dark=$dark at 1440', (tester) async {
        debugWebPlatformOverride = true;
        addTearDown(() => debugWebPlatformOverride = null);
        tester.view.physicalSize = const Size(1440, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = inMemoryDatabase();
        addTearDown(db.close);
        final repository = PracticePreferencesRepository(db);
        final count = switch (state) {
          'None' => 0,
          'One' => 1,
          'RunsShort' => 2,
          _ => 8
        };
        final timed = state == 'ManyTime' || state == 'Short';
        final amount = switch (state) {
          'One' => 20,
          'Long' => 50,
          'Short' => 10,
          'ManyTime' => 20,
          _ => 10
        };
        await repository.save(
          'e',
          lessonIds: {for (var i = 0; i < count; i++) 'l$i'},
          mode: timed ? PracticeUnitMode.minutes : PracticeUnitMode.questions,
          value: amount,
          adjustments: {},
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              practicePreferencesRepositoryProvider
                  .overrideWithValue(repository),
              practiceIndexProvider('e').overrideWith(
                (_) async => inventory(runsShort: state == 'RunsShort'),
              ),
              practicePaceProvider('e').overrideWith((_) async => 54000),
            ],
            child: MaterialApp(
              theme:
                  dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
              home: const Scaffold(
                body: Padding(
                  padding: EdgeInsets.fromLTRB(288, 28, 44, 44),
                  child: PracticePickerScreen(examId: 'e'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final panel = find
            .ancestor(of: find.text('Start'), matching: find.byType(WebCard))
            .first;
        expect(tester.getSize(panel).width, 400);
        expect(find.text('No questions yet'), findsOneWidget);
        final start =
            tester.widget<WebButton>(find.widgetWithText(WebButton, 'Start'));
        final pageScroll = find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.drag(pageScroll, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(find.text('Your quiz')).dy, closeTo(28, 1));
        expect(find.text('Start').hitTestable(), findsOneWidget);
        await tester.drag(pageScroll, const Offset(0, 500));
        await tester.pumpAndSettle();
        if (count == 0) {
          expect(start.onPressed, isNull);
          expect(find.text('Nothing picked yet'), findsOneWidget);
          expect(find.text('Pick a topic or a lesson'), findsOneWidget);
        } else {
          expect(start.onPressed, isNotNull);
          expect(
            find.text('$count lesson${count == 1 ? '' : 's'} picked'),
            findsOneWidget,
          );
          expect(find.text('Split by lesson'), findsOneWidget);
          if (timed) {
            expect(find.widgetWithText(TextButton, '25'), findsNothing);
            expect(find.widgetWithText(TextButton, '35'), findsNothing);
            if (state == 'Short') {
              final five = tester
                  .widget<TextButton>(find.widgetWithText(TextButton, '5'));
              expect(five.onPressed, isNull);
              final text = tester.widget<Text>(
                find.descendant(
                  of: find.widgetWithText(TextButton, '5'),
                  matching: find.byType(Text),
                ),
              );
              expect(text.style!.decoration, TextDecoration.lineThrough);
            }
          }
          if (state == 'RunsShort') {
            expect(find.text('Only 6 questions so far'), findsOneWidget);
          }
          if (state == 'Long') expect(find.text('400'), findsOneWidget);
          await tester.tap(find.text('Adjust'));
          await tester.pumpAndSettle();
          expect(find.text('Reset'), findsOneWidget);
          expect(find.byTooltip('Increase Lesson 0'), findsOneWidget);
          await tester.tap(find.text('Reset'));
          await tester.pumpAndSettle();
          expect(find.text('Adjust'), findsOneWidget);
          await tester.tap(find.text('Clear'));
          await tester.pumpAndSettle();
          expect(find.text('Nothing picked yet'), findsOneWidget);
          expect(
            tester
                .widget<WebButton>(find.widgetWithText(WebButton, 'Start'))
                .onPressed,
            isNull,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
