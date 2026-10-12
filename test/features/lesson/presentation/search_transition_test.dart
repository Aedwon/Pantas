import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';

import '../../../helpers/pump_app.dart';
import 'fake_open_topic.dart';

void main() {
  testWidgets('search fades the map over 200ms and recents from 100 to 400ms',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpAppWithProviders(
        const StudyTabHome(),
        overrides: [
          studyMapProvider.overrideWith(
            (_) async => const StudyMap(
              examShortName: 'UPCAT',
              readCount: 0,
              totalCount: 1,
              minutesLeftToRead: 10,
              subjects: [
                StudySubject(
                  id: 's',
                  name: 'Mathematics',
                  topics: [
                    StudyTopic(
                      id: 't',
                      name: 'Geometry',
                      lessons: [
                        StudyLesson(
                          id: 'l',
                          title: 'Circles',
                          estimatedMinutes: 10,
                          isRead: false,
                          isBookmarked: false,
                        ),
                      ],
                      readCount: 0,
                      hasBookmark: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          openTopicProvider.overrideWith(FakeOpenTopic.new),
          lastOpenedLessonProvider.overrideWith((_) async => null),
          bookmarkRowsProvider.overrideWith((_) async => []),
          recentlyOpenedLessonsProvider.overrideWith(
            (_) async => const [
              StudyLesson(
                id: 'recent',
                title: 'Recent lesson',
                estimatedMinutes: 5,
                isRead: false,
                isBookmarked: false,
              ),
            ],
          ),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester
            .widget<Opacity>(find.byKey(const ValueKey('study-map-opacity')))
            .opacity,
        closeTo(.057725, .001),
      );
      expect(find.bySemanticsLabel('Mathematics'), findsNothing);
      final incoming = find.byKey(const ValueKey('search-results-opacity'));
      expect(tester.widget<Opacity>(incoming).opacity, 0);
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.widget<Opacity>(incoming).opacity, closeTo(.942275, .001));
      final header = find.text('RECENTLY OPENED');
      expect(find.ancestor(of: header, matching: incoming), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Opacity>(find.byKey(const ValueKey('study-map-opacity')))
            .opacity,
        1,
      );
      expect(find.text('RECENTLY OPENED'), findsNothing);
    } finally {
      semantics.dispose();
    }
  });
}
