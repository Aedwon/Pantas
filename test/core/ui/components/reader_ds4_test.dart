import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

import '../../../helpers/ds_matrix.dart';

Map<String, Object?> _run(String text) =>
    {'_type': 'span', 'text': text, 'marks': <String>[]};

Map<String, Object?> _block(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [_run(text)],
    };

final _lesson = <Map<String, Object?>>[
  _block('Core Concept', style: 'h2'),
  _block('A plain note.', style: 'blockquote'),
  _block('Mnemonics & Memory Aids', style: 'h2'),
  _block('Powers of i repeat.', style: 'blockquote'),
  _block('Examples', style: 'h2'),
  _block('#1: Classifying Sets', style: 'h3'),
  _block('Which statement is false?'),
  {
    '_type': 'block',
    'style': 'normal',
    'children': [
      {
        '_type': 'span',
        'text': 'Solution:',
        'marks': ['strong'],
      },
    ],
  },
  {...(_block('Integers are fractions over 1.')), 'listItem': 'number'},
  _block('Traps to Watch For', style: 'h2'),
  _block('#1: Square Roots', style: 'h3'),
  _block('Rewrite using i first.', style: 'blockquote'),
];

String _svg() {
  const svg = '<svg xmlns="http://www.w3.org/2000/svg" width="400" '
      'height="220" viewBox="0 0 400 220"> '
      '<rect x="2" y="2" width="396" height="216" fill="none" '
      'stroke="currentColor" stroke-width="4"/></svg>';
  return 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
}

Widget _reader(List<Map<String, Object?>> blocks) => ProviderScope(
      child: SizedBox(
        width: 340,
        child: ContentRenderer(blocks: blocks, readerFigures: true),
      ),
    );

Finder _iconOf(IconData glyph) => find.byWidgetPredicate(
      (w) => w is Icon && w.icon == glyph,
    );

void main() {
  setUpAll(loadDsFonts);

  group('block icons', () {
    for (final cell in dsShellCells) {
      testWidgets('icons sit bare beside the titles ($cell)', (tester) async {
        await pumpDs(tester, cell, _reader(_lesson));
        expect(tester.takeException(), isNull);
        final c = cell.dark ? PantasColors.dark : PantasColors.light;

        void check(IconData glyph, String label, Color color) {
          final icon = _iconOf(glyph);
          expect(icon, findsOneWidget, reason: label);
          final widget = tester.widget<Icon>(icon);
          expect(widget.size, PantasSpace.s18);
          expect(widget.color, color);
          expect(widget.semanticLabel, isNull, reason: 'decorative');
          final iconRect = tester.getRect(icon);
          final labelRect = tester.getRect(find.text(label));
          expect(
            labelRect.left - iconRect.right,
            PantasSpace.s8,
            reason: label,
          );
          expect(
            (iconRect.center.dy - labelRect.center.dy).abs(),
            lessThan(3),
            reason: label,
          );
          expect(find.bySemanticsLabel(label), findsWidgets);
        }

        check(PantasIcons.info, 'Remember', c.accentTintText);
        check(PantasIcons.warning, 'Watch out', c.readerMistake);
        check(PantasIcons.bookOpen, 'Example 1', c.readerStrong);
        // A note with no title gets no icon.
        expect(_iconOf(PantasIcons.info), findsOneWidget);
      });
    }
  });

  group('inset solution panel', () {
    for (final cell in dsShellCells) {
      testWidgets('shape after Show solution ($cell)', (tester) async {
        await pumpDs(tester, cell, _reader(_lesson));
        final c = cell.dark ? PantasColors.dark : PantasColors.light;
        final button = find.byKey(const ValueKey('reader-solution-button'));
        await tester.ensureVisible(button);
        await tester.pump();
        await tester.tap(button);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);

        final panel = find.byKey(const ValueKey('reader-solution-panel'));
        final box = tester.widget<Container>(panel);
        final decoration = box.decoration! as BoxDecoration;
        expect(decoration.color, c.readerDeep);
        expect(decoration.borderRadius, BorderRadius.circular(PantasRadius.md));
        expect(decoration.border, isNull);
        expect(
          box.padding,
          const EdgeInsets.symmetric(
            horizontal: PantasSpace.s16,
            vertical: PantasSpace.s14,
          ),
        );
        expect(box.margin, const EdgeInsets.only(top: PantasSpace.s4));
        expect(find.text('SOLUTION'), findsOneWidget);

        // Inset: the panel does not touch the card edges.
        final card = tester.getRect(
          find.byKey(const ValueKey('reader-example-card')),
        );
        final rect = tester.getRect(panel);
        expect(rect.left, greaterThan(card.left + 1));
        expect(rect.right, lessThan(card.right - 1));
        expect(rect.bottom, lessThan(card.bottom - 1));
      });
    }
  });

  group('figure zoom badge', () {
    for (final cell in dsShellCells) {
      testWidgets('is 32 px with the magnifier at the bottom right ($cell)',
          (tester) async {
        await pumpDs(
          tester,
          cell,
          ProviderScope(
            child: SizedBox(
              width: 340,
              child: ContentRenderer(
                readerFigures: true,
                blocks: [
                  {
                    '_type': 'image',
                    'asset': {'url': _svg(), 'credit': 'Pantas'},
                    'alt': 'A figure',
                  },
                ],
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final tip = find.byTooltip('Expand figure');
        final badge = find.descendant(
          of: tip,
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration! as BoxDecoration).color != null,
          ),
        );
        final colors = cell.dark ? PantasColors.dark : PantasColors.light;
        final decoration =
            tester.widget<Container>(badge).decoration! as BoxDecoration;
        expect(tester.getSize(badge), const Size.square(PantasSize.iconBtnSm));
        expect(decoration.color, colors.surface);
        expect(decoration.shape, BoxShape.rectangle);
        expect(decoration.borderRadius, BorderRadius.circular(PantasRadius.sm));
        expect(decoration.boxShadow, isNotEmpty);
        final icon = tester.widget<Icon>(
          find.descendant(of: badge, matching: find.byType(Icon)),
        );
        expect(icon.icon, PantasIcons.magnifyingGlassPlus);
        expect(icon.size, PantasSpace.s16);

        // Bottom right of the figure, below its centre line.
        final frame = tester.getRect(find.byType(ClipRRect).first);
        final rect = tester.getRect(badge);
        expect(rect.center.dx, greaterThan(frame.center.dx));
        expect(rect.center.dy, greaterThan(frame.center.dy));
        expect(frame.right - rect.right, lessThan(12));
        expect(frame.bottom - rect.bottom, lessThan(12));
      });
    }
  });
}
