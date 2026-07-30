import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpResults(
    WidgetTester tester, {
    int hits = 1,
    bool bodyHit = false,
    String query = 'venn',
    int recent = 0,
  }) async {
    final list = <LessonSearchHit>[];
    if (hits > 0) {
      for (var i = 0; i < hits; i++) {
        list.add(
          LessonSearchHit(
            lessonId: 'l_$i',
            title: bodyHit ? 'Algebraic Expressions' : 'Venn diagrams',
            topicName: 'Vocabulary',
            estimatedMinutes: 5,
            titleMatch: bodyHit
                ? null
                : const SearchSnippet(
                    text: 'Venn diagrams',
                    matchStart: 0,
                    matchLength: 4,
                  ),
            bodySnippet: bodyHit
                ? const SearchSnippet(
                    text: '...less than means swap the plan and sign...',
                    matchStart: 18,
                    matchLength: 4,
                  )
                : null,
          ),
        );
      }
    }

    final recentLessons = <StudyLesson>[];
    for (var i = 0; i < recent; i++) {
      recentLessons.add(
        StudyLesson(
          id: 'recent_$i',
          title: 'Recent Lesson $i',
          estimatedMinutes: 5,
          isRead: true,
          isBookmarked: false,
        ),
      );
    }

    await tester.pumpAppWithProviders(
      const SearchResults(),
      overrides: [
        searchQueryProvider.overrideWith((ref) => query),
        searchResultsProvider.overrideWith((ref) async => list),
        recentlyOpenedLessonsProvider
            .overrideWith((ref) async => recentLessons),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the kicker counts the matches', (tester) async {
    await pumpResults(tester, hits: 3);

    expect(find.text('3 lessons'), findsOneWidget);
  });

  testWidgets('one match says lesson, not lessons', (tester) async {
    await pumpResults(tester);

    expect(find.text('1 lesson'), findsOneWidget);
  });

  testWidgets('a title match is weighted, not filled', (tester) async {
    await pumpResults(tester);

    final title = tester.widget<RichText>(find.byType(RichText).at(1));
    final leafSpans = <TextSpan>[];
    void collect(TextSpan span) {
      if (span.text != null) leafSpans.add(span);
      if (span.children != null) {
        for (final child in span.children!) {
          if (child is TextSpan) collect(child);
        }
      }
    }

    collect(title.text as TextSpan);

    final matched = leafSpans.firstWhere((span) => span.text == 'Venn');
    expect(matched.style?.fontWeight, FontWeight.w700);
    expect(matched.style?.backgroundColor, isNull);
  });

  testWidgets('a body match shows the sentence it came from', (tester) async {
    await pumpResults(tester, bodyHit: true);

    expect(find.textContaining('swap the plan'), findsOneWidget);
  });

  testWidgets('an empty query offers the recently opened', (tester) async {
    await pumpResults(tester, query: '', recent: 2);

    expect(find.text('Recently opened'), findsOneWidget);
  });

  testWidgets('no matches names what was typed', (tester) async {
    await pumpResults(tester, query: 'swap', hits: 0);

    expect(find.text('Nothing matched "swap"'), findsOneWidget);
    expect(find.text('Try a shorter word, or part of one.'), findsOneWidget);
  });
}
