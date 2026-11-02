import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';

import '../../../helpers/accessibility.dart';

const _stem = 'Consider the table:\n\n'
    '| Month | Paper | Ink |\n'
    '| :--- | :--- | :--- |\n'
    '| January | 12000 | 18000 |\n'
    '| February | 15000 | 22000 |\n\n'
    'What was the total on Paper?';

const _longCell =
    'Uphold the public interest over and above personal interest. Use '
    'government resources and the powers of the office efficiently, '
    'effectively, honestly and economically.';

void main() {
  group('splitTables', () {
    test('text without a table is one plain run', () {
      final parts = ContentRenderer.splitTables('Pick **one** of 2 | 3.');
      expect(parts, hasLength(1));
      expect(parts.single.rows, isNull);
    });

    test('a stem splits into text, table, text', () {
      final parts = ContentRenderer.splitTables(_stem);
      expect(parts.map((p) => p.rows == null), [true, false, true]);
      expect(parts[0].text, 'Consider the table:');
      expect(parts[2].text, 'What was the total on Paper?');
      expect(parts[1].rows, [
        ['Month', 'Paper', 'Ink'],
        ['January', '12000', '18000'],
        ['February', '15000', '22000'],
      ]);
    });

    test('a pipe inside maths stays in its cell', () {
      final rows = ContentRenderer.splitTables(
        '| Expr | Value |\n| --- | --- |\n| \$|x|\$ | 3 |',
      ).single.rows!;
      expect(rows.last, [r'$|x|$', '3']);
    });

    test('a ragged row is padded to the widest row', () {
      final rows = ContentRenderer.splitTables(
        '| A | B |\n| --- | --- |\n| 1 |',
      ).single.rows!;
      expect(rows.last, ['1', '']);
    });

    test('pipes without a delimiter row stay text', () {
      final parts = ContentRenderer.splitTables('| a | b |\n| c | d |');
      expect(parts.single.rows, isNull);
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('a stem table draws as a table, not pipes $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const SingleChildScrollView(
          child: QuestionCard(subject: 'Math', stem: _stem),
        ),
        brightness: brightness,
        viewportSize: const Size(358, 700),
      );
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('February'), findsOneWidget);
      expect(find.text('Consider the table:'), findsOneWidget);
      expect(find.text('What was the total on Paper?'), findsOneWidget);
      expect(find.textContaining('|'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a line limit keeps a table stem as a plain preview',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(text: _stem, maxLines: 2),
    );
    expect(find.byType(Table), findsNothing);
  });

  testWidgets('header row is filled and numbers align right', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(text: _stem),
      viewportSize: const Size(358, 700),
    );
    final row = tester.widget<Table>(find.byType(Table)).children.first;
    expect((row.decoration! as BoxDecoration).color, isNotNull);
    final number = tester.widget<RichText>(
      find
          .descendant(
            of: find.ancestor(
              of: find.text('12000'),
              matching: find.byType(Padding),
            ),
            matching: find.byType(RichText),
          )
          .first,
    );
    expect(number.textAlign, TextAlign.right);
    expect(
      tester
          .widget<RichText>(
            find
                .descendant(
                  of: find.ancestor(
                    of: find.text('January'),
                    matching: find.byType(Padding),
                  ),
                  matching: find.byType(RichText),
                )
                .first,
          )
          .textAlign,
      TextAlign.left,
    );
  });

  for (final width in [358.0, 1440.0]) {
    testWidgets('a long table cell wraps and nothing overflows at $width',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const SingleChildScrollView(
          child: ContentRenderer(
            blocks: [
              {
                '_type': 'table',
                'rows': [
                  ['', 'Norm', 'What it requires'],
                  [
                    'a',
                    '**Commitment to public interest**',
                    _longCell,
                  ],
                ],
              },
            ],
          ),
        ),
        viewportSize: Size(width, 900),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Commitment to public interest'), findsOneWidget);
      expect(find.textContaining('**'), findsNothing);
      // The test font is far wider than Geist, so only the wide page is a
      // fair check that the table fits and wraps.
      if (width > 1000) {
        expect(
          tester.getSize(find.byType(Table)).width,
          lessThanOrEqualTo(width),
        );
      }
    });
  }

  testWidgets('a table wider than the page scrolls sideways', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(
        blocks: [
          {
            '_type': 'table',
            'rows': [
              [
                'Region',
                'Quarter one total',
                'Quarter two total',
                'Quarter three total',
                'Quarter four total',
              ],
              [
                'NCR',
                '1,200,000,000',
                '1,350,000,000',
                '1,400,000,000',
                '1,500,000,000',
              ],
            ],
          },
        ],
      ),
      viewportSize: const Size(358, 600),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(Table)).width,
      greaterThan(358),
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
