import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/line_breaks.dart';

/// ListRow README: titles and subtitles wrap, no ellipsis by default. At 390
/// and 320 wide and 200% text a long title takes more lines and a word is
/// never split unless it alone is wider than the row.
void main() {
  setUpAll(loadDsFonts);

  const cells = [
    DsCell(390, 2, dark: false),
    DsCell(320, 2, dark: false),
    DsCell(320, 1, dark: false),
  ];
  const long = 'Spatial and Abstract (Non-Verbal) Reasoning';

  bool cutWithEllipsis(WidgetTester tester, Finder finder) {
    for (final e in finder.evaluate()) {
      final render = e.renderObject;
      if (render is RenderParagraph && render.didExceedMaxLines) return true;
    }
    return false;
  }

  for (final cell in cells) {
    testWidgets('a navigation row wraps its title ($cell)', (tester) async {
      await pumpDs(
        tester,
        cell,
        ListRow(title: long, subtitle: long, onTap: () {}),
      );
      expect(cutWithEllipsis(tester, find.textContaining('Spatial')), isFalse);
      for (final text in tester.widgetList<Text>(
        find.textContaining('Spatial'),
      )) {
        expect(text.maxLines, isNull);
      }
    });

    testWidgets('a switch row wraps its title ($cell)', (tester) async {
      await pumpDs(
        tester,
        cell,
        ListRow(
          title: 'Keyboard Shortcuts and Letter Keys',
          variant: ListRowVariant.switchControl,
          onTap: () {},
        ),
      );
      for (final text in tester.widgetList<Text>(
        find.textContaining('Keyboard'),
      )) {
        expect(text.maxLines, isNull);
      }
    });

    testWidgets('an exam row wraps title and subtitle ($cell)', (tester) async {
      await pumpDs(
        tester,
        cell,
        ListRow.exam(
          title: 'NAPOLCOM',
          subtitle: 'National Police Commission Entrance Examination',
          selected: false,
          comingSoon: true,
          settingsMode: true,
          onTap: () {},
        ),
      );
      expect(find.text('Coming soon'), findsOneWidget);
      expect(splitsAWord(tester, find.text('NAPOLCOM')), isFalse);
      final subtitle = tester.widget<Text>(
        find.descendant(
          of: find.byType(ListRow),
          matching: find.textContaining('National Police'),
        ),
      );
      if (cell.scale > 1.5) expect(subtitle.maxLines, isNull);
    });

    testWidgets('a scope row wraps its topic title ($cell)', (tester) async {
      await pumpDs(
        tester,
        cell,
        ScopePicker(
          phoneBoardRows: true,
          selectedIds: const {'t1'},
          onChanged: (_) {},
          subjects: const [
            ScopeSubject(
              title: 'Reasoning',
              topics: [ScopeTopic(id: 't1', title: long)],
            ),
          ],
        ),
      );
      for (final text in tester.widgetList<Text>(
        find.textContaining('Spatial'),
      )) {
        expect(text.maxLines, isNull);
      }
    });
  }
}
