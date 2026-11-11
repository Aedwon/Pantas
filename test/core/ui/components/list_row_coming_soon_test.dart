import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';

import '../../../helpers/accessibility.dart';

// ListRow README: subtitles wrap, no ellipsis. Beside "Coming soon" a long
// organization wraps and the label stays at the row end (the system wins over
// the older board "f A").
const _long = 'Maritime Academy of Asia and the Pacific Academy Foundation';

Future<void> _pump(
  WidgetTester tester, {
  required bool comingSoon,
  required bool settingsMode,
  double textScale = 1,
  Brightness brightness = Brightness.light,
}) =>
    pumpAccessibilitySurface(
      tester,
      Builder(
        builder: (context) => ListRow.exam(
          title: 'MAAP',
          subtitle: _long,
          selected: false,
          comingSoon: comingSoon,
          settingsMode: settingsMode,
          onTap: () {},
        ),
      ),
      brightness: brightness,
      textScale: textScale,
      viewportSize: const Size(390, 844),
      disableAnimations: true,
    );

void main() {
  for (final brightness in Brightness.values) {
    for (final settingsMode in [false, true]) {
      testWidgets(
          'a Coming soon row wraps its organization $brightness'
          ' settings $settingsMode', (tester) async {
        await _pump(
          tester,
          comingSoon: true,
          settingsMode: settingsMode,
          brightness: brightness,
        );
        final text = tester.widget<Text>(find.text(_long));
        expect(text.maxLines, isNull);
        expect(text.overflow, isNull);
        expect(find.text('Coming soon'), findsOneWidget);
        // Two lines of the 13 px footnote beside the label.
        expect(tester.getSize(find.text(_long)).height, greaterThan(24));
      });
      testWidgets(
          'an exam that is out still wraps its organization $brightness'
          ' settings $settingsMode', (tester) async {
        await _pump(
          tester,
          comingSoon: false,
          settingsMode: settingsMode,
          brightness: brightness,
        );
        final text = tester.widget<Text>(find.text(_long));
        expect(text.maxLines, isNull);
        expect(find.text('Coming soon'), findsNothing);
      });
    }
  }

  testWidgets('at large text the label moves under and the line wraps',
      (tester) async {
    await _pump(
      tester,
      comingSoon: true,
      settingsMode: false,
      textScale: 2,
    );
    final text = tester.widget<Text>(find.text(_long));
    expect(text.maxLines, isNull);
    expect(find.text('Coming soon'), findsOneWidget);
  });
}
