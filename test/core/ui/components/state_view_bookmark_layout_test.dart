import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/state_view.dart';

import '../../../helpers/accessibility.dart';

/// Pins the accepted bookmark empty-state layout so a merge that touches the
/// onboarding variants cannot drop it again.
void main() {
  for (final brightness in Brightness.values) {
    testWidgets('bookmark layout keeps its mark, type and inset $brightness', (
      tester,
    ) async {
      await pumpAccessibilitySurface(
        tester,
        const StateView(
          message: 'No bookmarks yet.',
          detail: 'Bookmark a lesson to find it here.',
          bookmarkLayout: true,
        ),
        brightness: brightness,
        viewportSize: const Size(390, 844),
      );
      final mark = find.byKey(const ValueKey('state-mark'));
      expect(tester.getSize(mark), const Size(34, 34));

      final message = tester.widget<Text>(find.text('No bookmarks yet.'));
      expect(message.style!.fontSize, 18);
      expect(message.style!.letterSpacing, -.216);
      expect(message.style!.height, 1.35);

      final detail = tester.widget<Text>(
        find.text('Bookmark a lesson to find it here.'),
      );
      expect(detail.style!.height, 1.35);

      expect(
        tester.getTopLeft(find.text('No bookmarks yet.')).dy -
            tester.getBottomLeft(mark).dy,
        closeTo(8, .5),
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Padding &&
              w.padding == const EdgeInsets.fromLTRB(36, 70, 36, 0),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
