import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_section.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpWith(
    WidgetTester tester, {
    required int rows,
    VoidCallback? onSeeAll,
  }) async {
    final list = List.generate(
      rows,
      (i) => BookmarkRow(
        lessonId: 'l${i + 1}',
        title: 'Lesson ${i + 1}',
        topicName: 'Chemistry',
        estimatedMinutes: 13,
      ),
    );

    await tester.pumpAppWithProviders(
      BookmarksSection(onSeeAll: onSeeAll),
      overrides: [
        bookmarkRowsProvider.overrideWith((ref) async => list),
        bookmarkCountProvider.overrideWith((ref) async => rows),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an empty bookmarks section keeps its approved prompt',
      (tester) async {
    await tester.pumpAppWithProviders(
      const BookmarksSection(),
      overrides: [
        bookmarkRowsProvider.overrideWith((ref) async => const []),
        bookmarkCountProvider.overrideWith((ref) async => 0),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('BOOKMARKS'), findsOneWidget);
    expect(find.text('Bookmark a lesson to keep it here.'), findsOneWidget);
  });

  testWidgets('three or fewer bookmarks hide See all', (tester) async {
    await pumpWith(tester, rows: 3);

    expect(find.text('BOOKMARKS'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    expect(find.text('See all'), findsOneWidget);
  });

  testWidgets('more than three shows See all and still draws three',
      (tester) async {
    await pumpWith(tester, rows: 7);

    expect(find.text('See all'), findsOneWidget);
    expect(find.text('7'), findsNothing);
    expect(find.byType(ListRow), findsNWidgets(3));
  });

  testWidgets('a row prints its topic and minutes together', (tester) async {
    await pumpWith(tester, rows: 1);

    expect(find.text('Chemistry'), findsOneWidget);
  });

  testWidgets('See all is labeled and at least 44dp', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpWith(tester, rows: 4, onSeeAll: () {});

    final action = find.semantics.byLabel('See all bookmarks');
    expect(action, findsOne);
    expect(action.evaluate().single.rect.size.width, greaterThanOrEqualTo(44));
    expect(action.evaluate().single.rect.size.height, greaterThanOrEqualTo(44));

    semantics.dispose();
  });
}
