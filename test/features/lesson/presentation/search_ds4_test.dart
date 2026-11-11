import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';

import '../../../helpers/ds_matrix.dart';

const _footer = 'Up and Down to move, Enter to open, Esc to close';

const _hits = [
  LessonSearchHit(
    lessonId: 'l2',
    title: 'Plate Tectonics',
    topicName: 'Earth Science',
    estimatedMinutes: 12,
  ),
  LessonSearchHit(
    lessonId: 'l3',
    title: 'Core',
    topicName: 'Earth Science',
    estimatedMinutes: 10,
  ),
  LessonSearchHit(
    lessonId: 'l4',
    title: 'Mantle',
    topicName: 'Earth Science',
    estimatedMinutes: 8,
  ),
];

const _recent = StudyLesson(
  id: 'l1',
  title: 'Minerals',
  estimatedMinutes: 6,
  isRead: false,
  isBookmarked: false,
);

List<Override> _overrides({int hits = 3}) => [
      studyMapProvider.overrideWith((_) async => null),
      recentlyOpenedLessonsProvider.overrideWith((_) async => [_recent]),
      searchResultsProvider.overrideWith(
        (_) async => _hits.take(hits).toList(),
      ),
    ];

void main() {
  setUpAll(loadDsFonts);

  group('wide overlay', () {
    for (final cell in dsShellCells.where((c) => c.width >= 1024)) {
      testWidgets('groups and key footer ($cell)', (tester) async {
        final c = cell.dark ? PantasColors.dark : PantasColors.light;
        await pumpDs(
          tester,
          cell,
          ProviderScope(
            overrides: _overrides(),
            child: const WebLessonSearch(),
          ),
          scroll: false,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Recently Opened'), findsOneWidget);
        expect(find.text('RECENTLY OPENED'), findsNothing);
        expect(find.text(_footer), findsOneWidget);
        final footer = find.ancestor(
          of: find.text(_footer),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration! as BoxDecoration).color == c.surfaceInset,
          ),
        );
        expect(footer, findsOneWidget);

        await tester.enterText(find.byType(TextField), 'plate');
        await tester.pumpAndSettle();
        expect(find.text('3 Lessons'), findsOneWidget);
        expect(find.text('3 LESSONS'), findsNothing);
        expect(find.text(_footer), findsOneWidget);
        // No Topics or Questions group: the provider resolves no topic hits
        // and no question search exists (R12).
        expect(find.textContaining('Topics'), findsNothing);
        expect(find.textContaining('Questions'), findsNothing);
      });
    }

    testWidgets('one match uses the singular label', (tester) async {
      await pumpDs(
        tester,
        dsShellCells.last,
        ProviderScope(
          overrides: _overrides(hits: 1),
          child: const WebLessonSearch(),
        ),
        scroll: false,
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'plate');
      await tester.pumpAndSettle();
      expect(find.text('1 Lesson'), findsOneWidget);
    });
  });

  group('phone search', () {
    for (final cell in dsShellCells.where((c) => c.width < 1024)) {
      testWidgets('group label in README case and no footer ($cell)',
          (tester) async {
        await pumpDs(
          tester,
          cell,
          ProviderScope(
            overrides: [
              ..._overrides(),
              searchQueryProvider.overrideWith((_) => 'plate'),
            ],
            child: const SizedBox(height: 700, child: SearchResults()),
          ),
          scroll: false,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('3 Lessons'), findsOneWidget);
        expect(find.text('3 LESSONS'), findsNothing);
        expect(find.text(_footer), findsNothing);
      });
    }
  });
}
