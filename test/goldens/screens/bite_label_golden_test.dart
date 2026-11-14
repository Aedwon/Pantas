// The bite-sized lesson label on every screen that used to show minutes.
// One sheet per screen, at 390 and 1440, light and dark.
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
import 'package:pantas/features/lesson/presentation/widgets/study_topic_section.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';

import 'fixtures/bite_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    goldenScreen('bite_study_$mode', (tester, width) async {
      final target = await pumpBiteScreen(
        tester,
        width,
        const StudyTabHome(),
        dark: dark,
        shell: true,
      );
      final topic = find.text('Philippine Constitution');
      if (topic.evaluate().isNotEmpty) {
        await tester.tap(topic.first);
        await settleFrames(tester, 8);
      }
      return target;
    });
    goldenScreen(
      'bite_reader_$mode',
      (tester, width) => pumpBiteScreen(
        tester,
        width,
        const LessonPage(lessonId: 'l3'),
        dark: dark,
      ),
    );
    goldenScreen('bite_reader_end_$mode', (tester, width) async {
      final target = await pumpBiteScreen(
        tester,
        width,
        const LessonPage(lessonId: 'l3'),
        dark: dark,
      );
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        final position =
            tester.state<ScrollableState>(scrollable.first).position;
        position.jumpTo(position.maxScrollExtent);
        // Long enough for the bar title's scroll fade to finish.
        await settleFrames(tester, 24);
      }
      return target;
    });
  }

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    goldenScreen('bite_contents_$mode', (tester, width) async {
      final target = await pumpBiteScreen(
        tester,
        width,
        const LessonPage(lessonId: 'l3'),
        dark: dark,
      );
      final control = width >= 1024
          ? find.text('3 of 6')
          : find.bySemanticsLabel('Contents');
      await tester.tap(control.first);
      await settleFrames(tester, 8);
      return target;
    });
    goldenScreen('bite_search_$mode', (tester, width) async {
      final overrides = [
        ...biteCountOverrides(),
        searchQueryProvider.overrideWith((_) => 'bill of rights'),
        searchResultsProvider.overrideWith((_) async => biteSearchHits),
      ];
      if (width >= 1024) {
        final target = await pumpScreen(
          tester,
          width,
          scaffolded(const WebLessonSearch()),
          overrides: overrides,
          dark: dark,
          router: true,
        );
        await tester.enterText(find.byType(EditableText), 'bill of rights');
        await settleFrames(tester, 8);
        return target;
      }
      return pumpScreen(
        tester,
        width,
        scaffolded(
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 56, 16, 0),
            child: SearchResults(),
          ),
        ),
        overrides: overrides,
        dark: dark,
        router: true,
      );
    });
    EndingContent ending({required bool onWide}) => EndingContent(
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
    goldenScreen(
      'bite_ending_$mode',
      (tester, width) => pumpScreen(
        tester,
        width,
        scaffolded(
          width >= 1024
              ? ending(onWide: true)
              : SingleChildScrollView(child: ending(onWide: false)),
        ),
        overrides: biteCountOverrides(),
        dark: dark,
        router: true,
      ),
    );
    goldenScreen(
      'bite_home_$mode',
      (tester, width) => pumpScreen(
        tester,
        width,
        scaffolded(
          Padding(
            padding: EdgeInsets.fromLTRB(
              width >= 1024 ? 280 : 16,
              56,
              16,
              0,
            ),
            child: HomeTodayChecklist(
              web: width >= 1024,
              lessons: [
                for (final (i, l) in biteLessons.indexed.skip(1).take(4))
                  HomeTodayLesson(
                    id: l.id,
                    title: l.title,
                    subject: 'Philippine Constitution',
                    part: l.part,
                    partCount: biteParts,
                    read: i == 1,
                    fraction: i == 2 ? .4 : null,
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
        dark: dark,
        router: true,
      ),
    );
  }

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    goldenScreen(
      'bite_study_today_$mode',
      (tester, width) => pumpScreen(
        tester,
        width,
        scaffolded(
          Padding(
            padding: EdgeInsets.fromLTRB(width >= 1024 ? 280 : 16, 56, 16, 0),
            child: Column(
              children: [
                for (final (i, l) in biteLessons.indexed.take(4))
                  StudyLessonRow(
                    lesson: StudyLesson(
                      id: l.id,
                      title: l.title,
                      part: l.part,
                      partCount: l.part == null ? null : biteParts,
                      isRead: i == 1,
                      isBookmarked: false,
                    ),
                    isToday: i == 2,
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
        overrides: biteCountOverrides(),
        dark: dark,
        router: true,
      ),
    );
  }
}
