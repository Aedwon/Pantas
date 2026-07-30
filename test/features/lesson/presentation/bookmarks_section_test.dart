import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_section.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpWith(WidgetTester tester, {required int rows}) async {
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
      const BookmarksSection(),
      overrides: [
        bookmarkRowsProvider.overrideWith((ref) async => list),
        bookmarkCountProvider.overrideWith((ref) async => rows),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('no bookmarks renders nothing at all', (tester) async {
    await tester.pumpAppWithProviders(
      const BookmarksSection(),
      overrides: [
        bookmarkRowsProvider.overrideWith((ref) async => const []),
        bookmarkCountProvider.overrideWith((ref) async => 0),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Bookmarks'), findsNothing);
    expect(find.byType(PennantMark), findsNothing);
  });

  testWidgets('three or fewer bookmarks hide See all', (tester) async {
    await pumpWith(tester, rows: 3);

    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('See all'), findsNothing);
  });

  testWidgets('more than three shows See all and still draws three',
      (tester) async {
    await pumpWith(tester, rows: 7);

    expect(find.text('See all'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.byType(PennantMark), findsNWidgets(3));
  });

  testWidgets('a row prints its topic and minutes together', (tester) async {
    await pumpWith(tester, rows: 1);

    expect(find.text('Chemistry, 13 min'), findsOneWidget);
  });
}
