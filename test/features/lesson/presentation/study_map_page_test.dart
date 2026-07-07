import 'dart:async';

import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/features/lesson/application/study_map_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import 'fake_open_topic.dart';

void main() {
  testWidgets('loading state shows FaintBars', (tester) async {
    final completer = Completer<StudyMap?>();

    await tester.pumpAppWithProviders(
      const StudyTabHome(),
      overrides: [
        studyMapProvider.overrideWith((ref) => completer.future),
        openTopicProvider.overrideWith(FakeOpenTopic.new),
      ],
    );

    expect(find.byType(FaintBars), findsWidgets);
  });

  testWidgets('an error never shows the exception to a student',
      (tester) async {
    await tester.pumpAppWithProviders(
      const StudyTabHome(),
      overrides: [
        studyMapProvider.overrideWith(
          (ref) async => throw Exception('SqliteException(1): no such table'),
        ),
        openTopicProvider.overrideWith(FakeOpenTopic.new),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load your topics. Pull down to try again.'),
      findsOneWidget,
    );
    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(find.textContaining('SqliteException'), findsNothing);
  });

  testWidgets('an exam with no lessons shows EmptyState', (tester) async {
    const map = StudyMap(
      examShortName: 'UPCAT',
      subjects: [],
      readCount: 0,
      totalCount: 0,
      minutesLeftToRead: 0,
    );

    await tester.pumpAppWithProviders(
      const StudyTabHome(),
      overrides: [
        studyMapProvider.overrideWith((ref) async => map),
        openTopicProvider.overrideWith(FakeOpenTopic.new),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Nothing to study yet'), findsOneWidget);
  });

  testWidgets('a populated map displays subjects and topics', (tester) async {
    const map = StudyMap(
      examShortName: 'UPCAT',
      subjects: [
        StudySubject(
          id: 's1',
          name: 'Mathematics',
          topics: [
            StudyTopic(
              id: 't1',
              name: 'Algebra',
              lessons: [
                StudyLesson(
                  id: 'l1',
                  title: 'Basics',
                  estimatedMinutes: 5,
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
      readCount: 0,
      totalCount: 1,
      minutesLeftToRead: 5,
    );

    await tester.pumpAppWithProviders(
      const StudyTabHome(),
      overrides: [
        studyMapProvider.overrideWith((ref) async => map),
        openTopicProvider.overrideWith(FakeOpenTopic.new),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('UPCAT'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Algebra'), findsOneWidget);
  });
}
