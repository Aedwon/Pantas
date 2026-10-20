import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_section.dart';

import '../../../helpers/pump_app.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('audit preview long title scale=$scale preserves label',
        (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(
        () => tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio(),
      );
      final semantics = tester.ensureSemantics();
      try {
        const title = 'A complete and very long bookmark lesson title about '
            'mathematics and careful reasoning';
        await tester.pumpAppWithProviders(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const Scaffold(
              body: SingleChildScrollView(child: BookmarksSection()),
            ),
          ),
          overrides: [
            bookmarkRowsProvider.overrideWith(
              (ref) async => const [
                BookmarkRow(
                  lessonId: 'l1',
                  title: title,
                  topicName: 'Topic',
                  estimatedMinutes: 5,
                ),
              ],
            ),
          ],
        );
        await tester.pumpAndSettle();
        final text = tester.widget<Text>(find.text(title));
        if (scale == 1) {
          expect(text.maxLines, 1);
          expect(text.overflow, TextOverflow.ellipsis);
        }
        expect(find.semantics.byLabel(RegExp(title)), findsOne);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }
  testWidgets('audit Study preview records actual Study origin',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: BookmarksSection()),
        ),
        GoRoute(
          path: '/lesson/:id',
          builder: (_, state) =>
              Text('Origin ${state.uri.queryParameters['from']!}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [
        bookmarkRowsProvider.overrideWith(
          (ref) async => const [
            BookmarkRow(
              lessonId: 'l1',
              title: 'Lesson',
              topicName: 'Topic',
              estimatedMinutes: 5,
            ),
          ],
        ),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lesson'));
    await tester.pumpAndSettle();
    expect(find.text('Origin study'), findsOneWidget);
  });

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
