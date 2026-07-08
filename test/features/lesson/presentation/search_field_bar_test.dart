import 'package:cse_cet_reviewer/core/ui/components/ink_magnifier.dart';
import 'package:cse_cet_reviewer/features/lesson/application/lesson_search_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/application/study_map_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/models/study_map.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/search_field_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the placeholder counts the corpus', (tester) async {
    await tester.pumpAppWithProviders(
      SearchFieldBar(onCancel: () {}),
      overrides: [
        searchCorpusSizeProvider.overrideWith((ref) async => 141),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Search 141 lessons'), findsOneWidget);
  });

  testWidgets('typing writes the query', (tester) async {
    late ProviderContainer container;

    await tester.pumpAppWithProviders(
      Consumer(
        builder: (context, ref, child) {
          container = ProviderScope.containerOf(context);
          return SearchFieldBar(onCancel: () {});
        },
      ),
      overrides: [
        searchCorpusSizeProvider.overrideWith((ref) async => 141),
      ],
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'venn');
    expect(container.read(searchQueryProvider), 'venn');
  });

  testWidgets('cancel calls back and clears the query', (tester) async {
    var cancelled = false;
    late ProviderContainer container;

    await tester.pumpAppWithProviders(
      Consumer(
        builder: (context, ref, child) {
          container = ProviderScope.containerOf(context);
          return SearchFieldBar(
            onCancel: () {
              cancelled = true;
            },
          );
        },
      ),
      overrides: [
        searchCorpusSizeProvider.overrideWith((ref) async => 141),
      ],
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'venn');
    expect(container.read(searchQueryProvider), 'venn');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(cancelled, isTrue);
    expect(container.read(searchQueryProvider), '');
  });

  testWidgets('the map bar shows one trailing element', (tester) async {
    const testMap = StudyMap(
      examShortName: 'CSE Pro',
      subjects: [
        StudySubject(
          id: 's1',
          name: 'Verbal',
          topics: [
            StudyTopic(
              id: 't1',
              name: 'Vocabulary',
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
        studyMapProvider.overrideWith((ref) async => testMap),
        lastOpenedLessonProvider.overrideWith((ref) async => null),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(InkMagnifier), findsOneWidget);
  });
}
