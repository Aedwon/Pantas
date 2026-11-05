import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_study_layout.dart';

// B-15 and B-26 of the Nov 4 browser check: the wide Study page's Bookmarks
// section follows the student's bookmark order, and Tab walks one column at a
// time.

StudyTopic _topic(String id, String name, {bool bookmarked = false}) =>
    StudyTopic(
      id: id,
      name: name,
      lessons: [
        StudyLesson(
          id: '$id-l1',
          title: 'Lesson of $name',
          estimatedMinutes: 10,
          isRead: false,
          isBookmarked: bookmarked,
        ),
      ],
      readCount: 0,
      hasBookmark: bookmarked,
    );

StudyMap _map({Set<String> bookmarked = const {}}) => StudyMap(
      examShortName: 'CSE',
      subjects: [
        StudySubject(
          id: 's1',
          name: 'Reasoning',
          topics: [
            for (final n in ['A1', 'A2', 'A3', 'A4'])
              _topic(n, n, bookmarked: bookmarked.contains(n)),
          ],
        ),
        StudySubject(
          id: 's2',
          name: 'Verbal',
          topics: [
            for (final n in ['B1', 'B2'])
              _topic(n, n, bookmarked: bookmarked.contains(n)),
          ],
        ),
        StudySubject(
          id: 's3',
          name: 'General',
          topics: [
            for (final n in ['C1', 'C2', 'C3'])
              _topic(n, n, bookmarked: bookmarked.contains(n)),
          ],
        ),
        StudySubject(
          id: 's4',
          name: 'Maths',
          topics: [
            for (final n in ['D1', 'D2'])
              _topic(n, n, bookmarked: bookmarked.contains(n)),
          ],
        ),
      ],
      readCount: 0,
      totalCount: 11,
      minutesLeftToRead: 110,
    );

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pumpMap(
    WidgetTester tester,
    StudyMap map, {
    List<String> bookmarkOrder = const [],
    String? openTopicId,
  }) async {
    tester.view
      ..physicalSize = const Size(1440, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 1080,
              height: 900,
              child: WebStudyMap(
                map: map,
                openTopicId: openTopicId,
                bookmarkOrder: bookmarkOrder,
                onTopic: (_) {},
                onLesson: (_, {required resume}) {},
                onBookmarks: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group("the Bookmarks section follows the student's order", () {
    // Bookmarked in subject order: A1, B1, C1, D1. The newest is D1.
    final marked = {'A1', 'B1', 'C1', 'D1'};

    List<String> shown(WidgetTester tester) => [
          for (final id in ['A1', 'B1', 'C1', 'D1'])
            if (find.text('Lesson of $id').evaluate().isNotEmpty) id,
        ]..sort((a, b) {
            // Reading order: rows top to bottom, the two columns left to
            // right.
            final pa = tester.getTopLeft(find.text('Lesson of $a'));
            final pb = tester.getTopLeft(find.text('Lesson of $b'));
            final byRow = pa.dy.compareTo(pb.dy);
            return byRow != 0 ? byRow : pa.dx.compareTo(pb.dx);
          });

    testWidgets('the three newest show, newest first', (tester) async {
      await pumpMap(
        tester,
        _map(bookmarked: marked),
        bookmarkOrder: ['D1-l1', 'C1-l1', 'B1-l1', 'A1-l1'],
      );
      expect(shown(tester), ['D1', 'C1', 'B1']);
    });

    testWidgets('a reordered list shows the new order', (tester) async {
      await pumpMap(
        tester,
        _map(bookmarked: marked),
        bookmarkOrder: ['B1-l1', 'D1-l1', 'A1-l1', 'C1-l1'],
      );
      expect(shown(tester), ['B1', 'D1', 'A1']);
    });

    testWidgets('with no order yet it keeps the map order', (tester) async {
      await pumpMap(tester, _map(bookmarked: marked));
      expect(shown(tester), ['A1', 'B1', 'C1']);
    });

    testWidgets('a bookmark the order does not name goes last', (tester) async {
      await pumpMap(
        tester,
        _map(bookmarked: marked),
        bookmarkOrder: ['D1-l1'],
      );
      expect(shown(tester), ['D1', 'A1', 'B1']);
    });
  });

  group('Tab walks one column at a time', () {
    /// The topic each Tab lands on, read from the focused row's label.
    Future<List<String>> tabbed(WidgetTester tester, int count) async {
      final seen = <String>[];
      for (var i = 0; i < count; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final context = FocusManager.instance.primaryFocus?.context;
        final button = context?.findAncestorWidgetOfExactType<TextButton>();
        final label = context == null || button == null
            ? null
            : find
                .descendant(
                  of: find.byWidget(button),
                  matching: find.byType(Text),
                )
                .evaluate()
                .map((e) => (e.widget as Text).data)
                .firstWhere((text) => text != null, orElse: () => null);
        if (label != null) seen.add(label);
      }
      return seen;
    }

    testWidgets('with nothing selected, the whole first column comes first',
        (tester) async {
      await pumpMap(tester, _map());
      final order = await tabbed(tester, 11);
      // Subjects stay whole in a column, and the columns are consecutive
      // runs of subjects, so column by column is the map's own order.
      expect(order, [
        'A1',
        'A2',
        'A3',
        'A4',
        'B1',
        'B2',
        'C1',
        'C2',
        'C3',
        'D1',
        'D2',
      ]);
    });

    testWidgets('with a topic open, the list comes before the topic card',
        (tester) async {
      await pumpMap(tester, _map(), openTopicId: 'B1');
      final order = await tabbed(tester, 12);
      expect(order.take(11), [
        'A1',
        'A2',
        'A3',
        'A4',
        'B1',
        'B2',
        'C1',
        'C2',
        'C3',
        'D1',
        'D2',
      ]);
    });
  });
}
