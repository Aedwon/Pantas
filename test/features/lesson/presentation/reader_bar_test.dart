import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/bookmark_ribbon.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    String title = 'Test Title',
    ReaderOrigin origin = ReaderOrigin.study,
    bool isBookmarked = false,
    VoidCallback? onBookmark,
    VoidCallback? onContents,
    double scrollOffset = 0,
  }) async {
    await tester.pumpApp(
      ReaderBar(
        title: title,
        origin: origin,
        isBookmarked: isBookmarked,
        onBookmark: onBookmark ?? () {},
        onContents: onContents ?? () {},
        scrollOffset: ValueNotifier(scrollOffset),
      ),
    );
  }

  testWidgets('the origin word names where the reader came from',
      (tester) async {
    await pumpBar(tester);
    expect(find.text('Study'), findsOneWidget);

    await pumpBar(tester, origin: ReaderOrigin.home);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('the title is never in the bar itself', (tester) async {
    await pumpBar(tester, title: 'Balancing equations');

    expect(find.text('Balancing equations'), findsNothing);
  });

  testWidgets('the strip grows over the first ninety pixels of scroll',
      (tester) async {
    await pumpBar(tester, title: 'Balancing equations', scrollOffset: 45);
    final half =
        tester.getSize(find.byKey(const ValueKey('reader-title-strip')));

    await pumpBar(tester, title: 'Balancing equations', scrollOffset: 90);
    final full =
        tester.getSize(find.byKey(const ValueKey('reader-title-strip')));

    expect(half.height, greaterThan(0));
    expect(half.height, lessThan(30));
    expect(full.height, 30);
  });

  testWidgets('past ninety the strip does not keep growing', (tester) async {
    await pumpBar(tester, title: 'T', scrollOffset: 400);

    expect(
      tester.getSize(find.byKey(const ValueKey('reader-title-strip'))).height,
      30,
    );
  });

  testWidgets('the bookmark is the outermost trailing element', (tester) async {
    await pumpBar(tester);

    expect(
      tester.getCenter(find.byType(BookmarkRibbon)).dx,
      greaterThan(tester.getCenter(find.byType(ContentsGlyph)).dx),
    );
  });

  testWidgets('tapping the ribbon calls back', (tester) async {
    var toggled = false;
    await pumpBar(tester, onBookmark: () => toggled = true);

    await tester.tap(find.byType(BookmarkRibbon));
    expect(toggled, isTrue);
  });
}
