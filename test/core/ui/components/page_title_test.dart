import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/page_title.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/line_breaks.dart';

/// D180: the phone large title steps down at large text, and a word is split
/// only when it alone is wider than the line.
void main() {
  setUpAll(loadDsFonts);

  const phone = DsCell(390, 2, dark: false);
  const small = DsCell(320, 2, dark: false);

  for (final cell in [phone, small]) {
    for (final title in [
      'Magandang gabi',
      'Your performance',
      'Your tendencies',
      'Accessibility',
    ]) {
      testWidgets('page title "$title" keeps its words whole ($cell)',
          (tester) async {
        await pumpDs(
          tester,
          cell,
          PantasPage(title: title, children: const [SizedBox(height: 20)]),
          scroll: false,
        );
        expect(tester.takeException(), isNull);
        expect(splitsAWord(tester, find.text(title)), isFalse);
      });
    }
  }

  testWidgets('the large title takes title 2 under 12rem', (tester) async {
    await pumpDs(
      tester,
      phone,
      Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PantasTitle('Greeting', style: context.type.largeTitle),
        ),
      ),
      scroll: false,
    );
    final style = tester.widget<Text>(find.text('Greeting')).style!;
    expect(style.fontSize, PantasType.phoneTitle2.fontSize);
  });

  testWidgets('the large title keeps its size at default text', (tester) async {
    await pumpDs(
      tester,
      const DsCell(390, 1, dark: false),
      Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PantasTitle('Greeting', style: context.type.largeTitle),
        ),
      ),
      scroll: false,
    );
    final style = tester.widget<Text>(find.text('Greeting')).style!;
    expect(style.fontSize, PantasType.phoneLargeTitle.fontSize);
  });

  testWidgets('a page title steps down only to keep a word whole',
      (tester) async {
    await pumpDs(
      tester,
      phone,
      Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PantasTitle(
            'The 1987 Constitutional Convention',
            narrowRule: false,
            style: context.type.pageTitle,
          ),
        ),
      ),
      scroll: false,
    );
    expect(
      splitsAWord(tester, find.text('The 1987 Constitutional Convention')),
      isFalse,
    );
  });
}
