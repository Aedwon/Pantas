import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

// QA 4N-8: the labels of a segmented control share one size and one baseline,
// however narrow the control is.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  const labels = ['Recent', 'By subject', 'Oldest', 'Custom'];

  Future<void> mount(WidgetTester tester, double width, int selected) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(web: true),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: WebSegmentedControl(
                  labels: labels,
                  selected: selected,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // 340: equal shares fit every label but "By subject" is longer than a
  // share. 220: no share, and not even the labels at full size, fit.
  for (final width in [420.0, 340.0, 290.0, 220.0]) {
    testWidgets('all four labels are one size on one line at $width',
        (tester) async {
      await mount(tester, width, 3);
      final heights = {
        for (final label in labels) tester.getSize(find.text(label)).height,
      };
      final centers = {
        for (final label in labels) tester.getCenter(find.text(label)).dy,
      };
      expect(heights, hasLength(1), reason: '$heights');
      expect(centers, hasLength(1), reason: '$centers');
      // A label never shrinks or wraps. When the cells do not fit, the track
      // scrolls inside itself; otherwise every label fits inside the control.
      // None overlaps its neighbor.
      final scrolls = find
          .descendant(
            of: find.byType(WebSegmentedControl),
            matching: find.byType(SingleChildScrollView),
          )
          .evaluate()
          .isNotEmpty;
      // 340: the columns follow the labels' own widths and still fit.
      expect(scrolls, width < 340, reason: 'scrolls only when cells overflow');
      final box = tester.getRect(find.byType(WebSegmentedControl));
      var previous = box.left;
      for (final label in labels) {
        final rect = tester.getRect(find.text(label));
        expect(rect.left, greaterThanOrEqualTo(previous), reason: label);
        if (!scrolls) {
          expect(rect.right, lessThanOrEqualTo(box.right), reason: label);
        }
        previous = rect.right;
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a roomy control keeps the board equal shares', (tester) async {
    await mount(tester, 420, 0);
    final lefts = [
      for (final label in labels)
        tester
            .getRect(
              find.ancestor(
                of: find.text(label),
                matching: find.byType(TextButton),
              ),
            )
            .width,
    ];
    expect(lefts.toSet(), hasLength(1), reason: '$lefts');
    expect(lefts.first, (420 - 4) / 4);
  });

  testWidgets('a narrow control keeps the labels at the board size',
      (tester) async {
    await mount(tester, 340, 1);
    // 14 px (`web-label`) on a 1.3 line: 18.2 px tall. A shrunk label would
    // be shorter.
    for (final label in labels) {
      expect(tester.getSize(find.text(label)).height, closeTo(18.2, .3));
    }
    // The selected thumb sits under "By subject".
    final thumb = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('segmented-control-thumb')),
        matching: find.byType(DecoratedBox),
      ),
    );
    final cell = tester.getRect(
      find.ancestor(
        of: find.text('By subject'),
        matching: find.byType(TextButton),
      ),
    );
    expect(thumb.left, closeTo(cell.left, .01));
    expect(thumb.width, closeTo(cell.width, .01));
  });
}
