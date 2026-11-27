import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/figures/concept_diagram_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../goldens/golden_harness.dart';

/// The lesson reader pads a phone page 24 px on each side.
const double _pagePad = 24;

const _spec = <String, Object?>{
  'kind': 'concept-diagram',
  'type': 'nested-boxes',
  'boxes': [
    'Natural Numbers',
    'Whole Numbers',
    'Integers',
    'Rational Numbers',
    'Irrational Numbers',
    'Real Numbers',
  ],
};

/// Pumps the figure the way the lesson reader does, on a phone of
/// [phoneWidth], and returns the plan the figure drew.
Future<({NestedBoxesPlan plan, Size figure, TextStyle style})> _pump(
  WidgetTester tester, {
  required double phoneWidth,
  required bool dark,
  double textScale = 1,
}) async {
  tester.view
    ..physicalSize = Size(phoneWidth, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  late TextStyle style;
  late TextScaler scaler;
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: dark ? buildDarkTheme() : buildLightTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: _pagePad),
            child: Builder(
              builder: (context) {
                style =
                    context.type.subhead.copyWith(color: context.colors.label);
                scaler = MediaQuery.textScalerOf(context);
                return const ContentRenderer(
                  readerFigures: true,
                  blocks: [
                    {
                      '_type': 'figureSpec',
                      'spec': _spec,
                      'semanticsLabel': 'Nested sets.',
                    },
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final figure = tester.getSize(find.byType(ConceptDiagramFigure));
  final plan = NestedBoxesLayout.of(figure.width, style, textScaler: scaler);
  return (plan: plan, figure: figure, style: style);
}

String _describe(NestedBoxesPlan plan) {
  String n(double v) => v.toStringAsFixed(1);
  return plan.boxes
      .map(
        (b) => '${b.label}: box ${n(b.rect.width)} wide, '
            'label ${n(b.labelRect.width)} wide ${n(b.labelRect.height)} high',
      )
      .join('; ');
}

void _expectEveryLabelFits(NestedBoxesPlan plan, {required bool oneLine}) {
  final reason = _describe(plan);
  final lineHeight = plan.boxes.first.labelRect.height;
  final figure = Offset.zero & plan.size;
  for (final b in plan.boxes) {
    expect(
      b.labelRect.right,
      lessThanOrEqualTo(b.rect.right - NestedBoxesLayout.labelPadX + 0.01),
      reason: '${b.label} spills out of its box. $reason',
    );
    expect(b.labelRect.bottom, lessThanOrEqualTo(b.rect.bottom));
    expect(b.labelRect.left, greaterThanOrEqualTo(b.rect.left));
    expect(
      figure.inflate(0.01).contains(b.rect.topLeft) &&
          figure.inflate(0.01).contains(b.rect.bottomRight),
      isTrue,
      reason: '${b.label} leaves the figure. $reason',
    );
    if (oneLine) {
      expect(
        b.labelRect.height,
        closeTo(lineHeight, 0.5),
        reason: '${b.label} wraps. $reason',
      );
    }
    // A label stays clear of every other box's border, so it never crosses
    // a line. Its own box and the boxes around it hold it.
    for (final other in plan.boxes) {
      if (identical(other, b)) continue;
      final holdsIt = other.rect.contains(b.labelRect.topLeft) &&
          other.rect.contains(b.labelRect.bottomRight);
      final apart = !other.rect.inflate(0.01).overlaps(b.labelRect);
      expect(
        holdsIt || apart,
        isTrue,
        reason: '${b.label} crosses the border of ${other.label}. $reason',
      );
    }
  }
}

void main() {
  setUpAll(loadGoldenFonts);

  for (final (name, phone) in [('320', 320.0), ('390', 390.0)]) {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      testWidgets('every label fits its box at a $name phone, $mode',
          (tester) async {
        final r = await _pump(tester, phoneWidth: phone, dark: dark);
        expect(r.figure.width, phone - 2 * _pagePad);
        _expectEveryLabelFits(r.plan, oneLine: true);
        expect(
          tester.getSize(find.byType(ConceptDiagramFigure)).height,
          r.plan.size.height,
        );
      });

      testWidgets('labels stay in their boxes at 200% text, $name, $mode',
          (tester) async {
        final r = await _pump(
          tester,
          phoneWidth: phone,
          dark: dark,
          textScale: 2,
        );
        _expectEveryLabelFits(r.plan, oneLine: false);
      });
    }
  }

  testWidgets('another concept diagram keeps the fixed height', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const Scaffold(
            body: ConceptDiagramFigure(
              type: 'venn',
              sets: ['A', 'B'],
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(ConceptDiagramFigure)).height, 220);
  });
}
