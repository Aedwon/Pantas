import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';

import '../golden_harness.dart';

/// The thresholds the bar follows: the title fades in by 90 and the bar
/// leaves by 120 (ReaderTopBar README).
const _titled = 90.0;

Widget _bar(
  double offset, {
  ReaderOrigin origin = ReaderOrigin.study,
  bool bookmarked = false,
}) =>
    ReaderBar(
      title: 'Adding fractions',
      origin: origin,
      isBookmarked: bookmarked,
      onBookmark: () {},
      onContents: () {},
      scrollOffset: ValueNotifier<double>(offset),
    );

final _router = GoRouter(
  routes: [GoRoute(path: '/', builder: (_, __) => const SizedBox())],
);

Widget _routed(Widget child) =>
    InheritedGoRouter(goRouter: _router, child: child);

void main() {
  goldenSheet(
    'reader_top_bar',
    [
      GoldenState('At the top', (_) => _routed(_bar(0)), width: 390),
      GoldenState('Titled', (_) => _routed(_bar(_titled)), width: 390),
      GoldenState(
        'Bookmarked',
        (_) => _routed(
          ReaderBar(
            title: 'Adding fractions',
            origin: ReaderOrigin.home,
            isBookmarked: true,
            onBookmark: () {},
            onContents: () {},
            scrollOffset: ValueNotifier<double>(_titled),
          ),
        ),
        width: 390,
      ),
      GoldenState(
        'Back hover',
        (_) => _routed(_bar(0)),
        action: GoldenAction.hover,
        target: () => find.text('Study'),
        width: 390,
      ),
      GoldenState(
        'Back pressed',
        (_) => _routed(_bar(0)),
        action: GoldenAction.pressed,
        target: () => find.text('Study'),
        width: 390,
      ),
      GoldenState(
        'Focus',
        (_) => _routed(_bar(0)),
        action: GoldenAction.focus,
        width: 390,
      ),
      GoldenState(
        'Contents hover',
        (_) => _routed(_bar(0)),
        action: GoldenAction.hover,
        target: () => find.byType(ContentsGlyph),
        width: 390,
      ),
      GoldenState(
        'Contents pressed',
        (_) => _routed(_bar(0)),
        action: GoldenAction.pressed,
        target: () => find.byType(ContentsGlyph),
        width: 390,
      ),
      GoldenState(
        'Contents focus',
        (_) => _routed(_bar(0)),
        action: GoldenAction.focus,
        tabs: 2,
        width: 390,
      ),
      GoldenState(
        'Bookmark hover',
        (_) => _routed(_bar(0)),
        action: GoldenAction.hover,
        target: () => find.byKey(const ValueKey('reader-bookmark-control')),
        width: 390,
      ),
      GoldenState(
        'Bookmark pressed',
        (_) => _routed(_bar(0)),
        action: GoldenAction.pressed,
        target: () => find.byKey(const ValueKey('reader-bookmark-control')),
        width: 390,
      ),
      GoldenState(
        'Bookmark focus',
        (_) => _routed(_bar(0)),
        action: GoldenAction.focus,
        tabs: 3,
        width: 390,
      ),
      GoldenState(
        'Bookmarked hover',
        (_) => _routed(_bar(0, bookmarked: true)),
        action: GoldenAction.hover,
        target: () => find.byKey(const ValueKey('reader-bookmark-control')),
        width: 390,
      ),
      GoldenState(
        'Bookmarked focus',
        (_) => _routed(_bar(0, bookmarked: true)),
        action: GoldenAction.focus,
        tabs: 3,
        width: 390,
      ),
    ],
    cellWidth: 390,
    columns: 2,
  );
}
