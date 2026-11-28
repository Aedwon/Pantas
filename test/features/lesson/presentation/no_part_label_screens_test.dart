// The "Part X of Y · N questions" label is gone from every screen that used
// to show it (Aedwon, Nov 23 2026). These pump the real screens with split
// lessons (parts 1 to 5 of 9) and fail if the label or a shortened form shows.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/ending_content.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';

import '../../../goldens/screens/fixtures/bite_fixtures.dart';
import '../../../goldens/screens/screen_harness.dart';
import '../../../helpers/no_part_label.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final width in screenWidths) {
    final size = width >= 1024 ? 'wide' : 'phone';

    testWidgets('Study list rows, $size', (tester) async {
      await pumpBiteScreen(
        tester,
        width,
        const StudyTabHome(),
        shell: true,
      );
      final topic = find.text('Philippine Constitution');
      if (topic.evaluate().isNotEmpty) {
        await tester.tap(topic.first);
        await settleFrames(tester, 8);
      }
      expect(find.text('Bill of Rights: searches'), findsWidgets);
      expectNoPartLabel();
      await takeDown(tester);
    });

    testWidgets('reader header and Next card, $size', (tester) async {
      await pumpBiteScreen(tester, width, const LessonPage(lessonId: 'l3'));
      expect(find.text('Bill of Rights: searches'), findsWidgets);
      expectNoPartLabel();
      await takeDown(tester);
    });

    testWidgets('Contents, $size', (tester) async {
      await pumpBiteScreen(tester, width, const LessonPage(lessonId: 'l3'));
      final control = width >= 1024
          ? find.text('3 of 6')
          : find.bySemanticsLabel('Contents');
      await tester.tap(control.first);
      await settleFrames(tester, 8);
      expectNoPartLabel();
      await takeDown(tester);
    });

    testWidgets('search, $size', (tester) async {
      final overrides = [
        ...biteCountOverrides(),
        searchQueryProvider.overrideWith((_) => 'bill of rights'),
        searchResultsProvider.overrideWith((_) async => biteSearchHits),
      ];
      if (width >= 1024) {
        await pumpScreen(
          tester,
          width,
          scaffolded(const WebLessonSearch()),
          overrides: overrides,
          router: true,
        );
        await tester.enterText(find.byType(EditableText), 'bill of rights');
        await settleFrames(tester, 8);
      } else {
        await pumpScreen(
          tester,
          width,
          scaffolded(
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 56, 16, 0),
              child: SearchResults(),
            ),
          ),
          overrides: overrides,
          router: true,
        );
      }
      expect(find.text('Philippine Constitution'), findsWidgets);
      expectNoPartLabel();
      await takeDown(tester);
    });

    testWidgets('end of topic list, $size', (tester) async {
      final ending = EndingContent(
        ending: TopicStoppedShort(
          studentName: null,
          topicName: 'Philippine Constitution',
          examAndSubject: 'CSE · General Information',
          footing: '3 of 6 lessons read',
          dateLine: 'November 14, 2026',
          unread: [
            for (final l in biteLessons.skip(3))
              StudyLesson(
                id: l.id,
                title: l.title,
                part: l.part,
                partCount: biteParts,
                isRead: false,
                isBookmarked: false,
              ),
          ],
        ),
        onLesson: (_) {},
        onHome: () {},
      );
      await pumpScreen(
        tester,
        width,
        scaffolded(
          width >= 1024 ? ending : SingleChildScrollView(child: ending),
        ),
        overrides: biteCountOverrides(),
        router: true,
      );
      expect(
        find.text('Bill of Rights: privacy of communication'),
        findsWidgets,
      );
      expectNoPartLabel();
    });

    testWidgets('Home lessons, $size', (tester) async {
      await pumpScreen(
        tester,
        width,
        scaffolded(
          Padding(
            padding: EdgeInsets.fromLTRB(width >= 1024 ? 280 : 16, 56, 16, 0),
            child: HomeTodayChecklist(
              web: width >= 1024,
              lessons: [
                for (final l in biteLessons.skip(1).take(3))
                  HomeTodayLesson(
                    id: l.id,
                    title: l.title,
                    subject: 'Philippine Constitution',
                    part: l.part,
                    partCount: biteParts,
                    read: false,
                  ),
              ],
              reviewsDone: 0,
              reviewsTotal: 18,
              newDone: 1,
              newTotal: 4,
              canAdvance: false,
              isMockDay: false,
              onLesson: (_) {},
              onLessons: () {},
              onReviews: () {},
              onNew: () {},
              onStartReviews: () {},
              onStartNew: () {},
              onAdvance: () {},
              onMock: () {},
            ),
          ),
        ),
        overrides: biteCountOverrides(),
        router: true,
      );
      expect(find.text('Bill of Rights: overview'), findsWidgets);
      expectNoPartLabel();
    });
  }
}

/// Takes the page down so no timer is left running.
Future<void> takeDown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 10));
}
