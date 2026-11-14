// PROTOTYPE renders for the bite-sized lessons visual companion. Not for merge.
//
// Run once per variant:
//   flutter test --tags golden --run-skipped --update-goldens \
//     --dart-define=BITE=before test/goldens/screens/bite_label_mockup_test.dart
//   (and again with BITE=after)
// Each surface renders at 390 and 1440, light and dark.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/ending_content.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';

import 'fixtures/bite_fixtures.dart';
import 'screen_harness.dart';

List<LessonSearchHit> _hits() => [
      for (final l in biteLessons.take(6))
        LessonSearchHit(
          lessonId: l.$1,
          title: l.$2,
          topicName: 'Philippine Constitution',
          estimatedMinutes: biteTodayMinutes,
        ),
    ];

final _nextTopic = StudyTopic(
  id: 'rep',
  name: 'Code of Conduct (RA 6713)',
  lessons: const [
    StudyLesson(
      id: 'next-1',
      title: 'Norms of Conduct of Public Officials',
      estimatedMinutes: biteTodayMinutes,
      isRead: false,
      isBookmarked: false,
    ),
  ],
  readCount: 0,
  hasBookmark: false,
);

TopicStoppedShort _ending() => TopicStoppedShort(
      studentName: 'Student',
      topicName: 'Philippine Constitution',
      examAndSubject: 'CSE · General Information',
      footing: '3 of 10 lessons read',
      dateLine: 'November 14, 2026',
      unread:
          biteStudyLessons(read: 3).where((l) => !l.isRead).take(5).toList(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  configureBite();
  final after = biteVariant == 'after';

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';
    String name(String surface) => 'bite_${biteVariant}_${surface}_$theme';

    // Study topic list: phone and web Study.
    goldenScreen(
      name('study'),
      (tester, width) => pumpBiteScreen(
        tester,
        width,
        const StudyTabHome(openTopicId: 'tpc'),
        dark: dark,
        shell: true,
      ),
    );

    // The reader: lesson header, quiz entry, next lesson.
    goldenScreen(
      name('reader'),
      (tester, width) => pumpBiteScreen(
        tester,
        width,
        const LessonPage(lessonId: 'bor-3'),
        dark: dark,
      ),
    );

    // The reader at the end of the lesson, phone scrolled to the bottom.
    goldenScreen(
      name('readerEnd'),
      (tester, width) => pumpBiteScreen(
        tester,
        width,
        const LessonPage(lessonId: 'bor-3'),
        dark: dark,
        after: (tester) async {
          if (width < 1024) {
            await tester.fling(
              find.byType(Scrollable).first,
              const Offset(0, -140),
              300,
            );
          }
        },
      ),
      widths: const [390],
    );

    // Contents: the phone sheet and the web popover.
    goldenScreen(
      name('contents'),
      (tester, width) => pumpBiteScreen(
        tester,
        width,
        const LessonPage(lessonId: 'bor-3'),
        dark: dark,
        after: (tester) async {
          if (width < 1024) {
            tester.widget<ReaderBar>(find.byType(ReaderBar)).onContents();
          } else {
            await tester.tap(find.text('3 of 10'));
          }
        },
      ),
    );

    // Search results: phone results list and the web overlay.
    goldenScreen(
      name('search'),
      (tester, width) async {
        final web = width >= 1024;
        return pumpScreen(
          tester,
          width,
          scaffolded(
            web
                ? const WebLessonSearch()
                : const SafeArea(child: SearchResults()),
          ),
          overrides: [
            studyMapProvider.overrideWith((_) async => null),
            recentlyOpenedLessonsProvider.overrideWith((_) async => []),
            searchResultsProvider.overrideWith((_) async => _hits()),
            if (!web) searchQueryProvider.overrideWith((_) => 'rights'),
          ],
          dark: dark,
          router: true,
          appTextScale: true,
        ).then((target) async {
          if (web) {
            await tester.enterText(find.byType(TextField), 'rights');
            await settleFrames(tester, 8);
          }
          return target;
        });
      },
    );

    // Lesson ending: the unread list. The web ending also has the next-topic
    // card, where the summed "minutes of material" line used to be meant.
    // Option A adds a count line, option B has no line (as the screen is today).
    for (final option in after ? ['A', 'B'] : ['']) {
      goldenScreen(
        name('ending$option'),
        (tester, width) => pumpScreen(
          tester,
          width,
          scaffolded(
            EndingContent(
              ending: _ending(),
              nextTopic: _nextTopic,
              nextDetail: option == 'A' ? 'Four lessons left' : null,
              onLesson: (_) {},
              onHome: () {},
            ),
          ),
          dark: dark,
          router: true,
          appTextScale: true,
        ),
      );
    }

    // Home Today: the checklist's lesson rows.
    goldenScreen(
      name('home'),
      (tester, width) {
        final web = width >= 1024;
        return pumpScreen(
          tester,
          width,
          scaffolded(
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: web ? 620 : null,
                  child: SingleChildScrollView(
                    child: HomeTodayChecklist(
                      web: web,
                      lessons: const [
                        HomeTodayLesson(
                          id: 'bor-2',
                          title:
                              'Bill of Rights: due process and equal protection',
                          subject: 'Philippine Constitution',
                          minutes: biteTodayMinutes,
                          read: false,
                        ),
                        HomeTodayLesson(
                          id: 'bor-3',
                          title: 'Bill of Rights: searches',
                          subject: 'Philippine Constitution',
                          minutes: biteTodayMinutes,
                          read: false,
                        ),
                        HomeTodayLesson(
                          id: 'outline',
                          title: 'The Articles in Outline',
                          subject: 'Philippine Constitution',
                          minutes: biteTodayMinutes,
                          read: false,
                        ),
                        HomeTodayLesson(
                          id: 'bor-1',
                          title: 'Bill of Rights: overview',
                          subject: 'Philippine Constitution',
                          minutes: biteTodayMinutes,
                          read: true,
                        ),
                      ],
                      reviewsDone: 0,
                      reviewsTotal: 18,
                      newDone: 0,
                      newTotal: 7,
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
                      onPlan: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
          dark: dark,
          router: true,
          appTextScale: true,
        );
      },
    );
  }
}
